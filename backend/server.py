"""API REST da Amora Bakery — só biblioteca padrão do Python. Sem instalar nada.
Perfis: 'admin' (gerencia produtos e vê pedidos) e 'cliente' (compra)."""
import hashlib, json, os, re, secrets, socket, sqlite3
from datetime import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

DB = os.path.join(os.path.dirname(os.path.abspath(__file__)), "padaria.db")
PORTA = int(os.environ.get("PORT", 8000))
CATEGORIAS = {"pao", "doce", "bebida"}
STATUS = ["novo", "preparando", "pronto", "entregue", "cancelado"]
ADMIN_EMAIL, ADMIN_SENHA = "admin@amora.com", "admin123"


def conn():
    c = sqlite3.connect(DB)
    c.row_factory = sqlite3.Row
    return c


def hash_senha(senha, salt):
    return hashlib.pbkdf2_hmac("sha256", senha.encode(), bytes.fromhex(salt), 100_000).hex()


def novo_usuario(c, nome, email, senha, telefone="", papel="cliente"):
    salt = secrets.token_hex(8)
    return c.execute("INSERT INTO usuarios(nome,email,telefone,senha_hash,salt,papel) VALUES(?,?,?,?,?,?)",
                     (nome, email, telefone, hash_senha(senha, salt), salt, papel)).lastrowid


def iniciar_banco():
    with conn() as c:
        c.executescript("""
        CREATE TABLE IF NOT EXISTS produtos(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT NOT NULL,
            categoria TEXT NOT NULL, preco REAL NOT NULL, descricao TEXT DEFAULT '', promocao INTEGER DEFAULT 0,
            imagem TEXT DEFAULT '');
        CREATE TABLE IF NOT EXISTS usuarios(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL, telefone TEXT DEFAULT '', senha_hash TEXT NOT NULL, salt TEXT NOT NULL,
            papel TEXT NOT NULL DEFAULT 'cliente');
        CREATE TABLE IF NOT EXISTS sessoes(token TEXT PRIMARY KEY, usuario_id INTEGER NOT NULL);
        CREATE TABLE IF NOT EXISTS pedidos(id INTEGER PRIMARY KEY AUTOINCREMENT, usuario_id INTEGER NOT NULL,
            tipo TEXT NOT NULL, endereco TEXT DEFAULT '', obs TEXT DEFAULT '', total REAL NOT NULL,
            status TEXT NOT NULL DEFAULT 'novo', criado_em TEXT NOT NULL);
        CREATE TABLE IF NOT EXISTS pedido_itens(id INTEGER PRIMARY KEY AUTOINCREMENT, pedido_id INTEGER NOT NULL,
            produto_id INTEGER, nome TEXT NOT NULL, qtd INTEGER NOT NULL, preco_unit REAL NOT NULL);""")
        if "imagem" not in [r[1] for r in c.execute("PRAGMA table_info(produtos)")]:
            c.execute("ALTER TABLE produtos ADD COLUMN imagem TEXT DEFAULT ''")
        if not c.execute("SELECT 1 FROM usuarios WHERE papel='admin'").fetchone():
            novo_usuario(c, "Administrador", ADMIN_EMAIL, ADMIN_SENHA, "", "admin")
        if c.execute("SELECT COUNT(*) FROM produtos").fetchone()[0] == 0:
            c.executemany("INSERT INTO produtos(nome,categoria,preco,descricao,promocao) VALUES(?,?,?,?,?)", [
                ("Pão Francês (kg)", "pao", 16.90, "Crocante, saído do forno toda hora", 0),
                ("Pão de Queijo (un)", "pao", 4.50, "Receita mineira", 1),
                ("Brigadeiro Gourmet", "doce", 5.00, "Chocolate belga", 0),
                ("Torta de Amora (fatia)", "doce", 12.00, "Massa amanteigada e geleia de amora", 1),
                ("Café Coado", "bebida", 4.00, "Café fresco 200ml", 0),
                ("Suco de Laranja", "bebida", 8.00, "Natural, 300ml", 0),
            ])


def prod_json(r):
    d = dict(r)
    d["promocao"] = bool(d["promocao"])
    return d


def user_json(u):
    return {k: u[k] for k in ("id", "nome", "email", "telefone", "papel")}


def pedido_json(c, r):
    itens = [{"nome": i["nome"], "qtd": i["qtd"], "preco_unit": i["preco_unit"]}
             for i in c.execute("SELECT * FROM pedido_itens WHERE pedido_id=?", (r["id"],))]
    u = c.execute("SELECT nome,email,telefone FROM usuarios WHERE id=?", (r["usuario_id"],)).fetchone()
    return {"id": r["id"], "tipo": r["tipo"], "endereco": r["endereco"], "obs": r["obs"], "total": r["total"],
            "status": r["status"], "criado_em": r["criado_em"], "cliente": dict(u) if u else {}, "itens": itens}


def validar_produto(d):
    try:
        nome, preco, cat = str(d.get("nome", "")).strip(), float(d.get("preco")), d.get("categoria")
    except (TypeError, ValueError, AttributeError):
        return None, "Dados inválidos"
    if len(nome) < 2:
        return None, "Nome deve ter ao menos 2 letras"
    if preco <= 0:
        return None, "Preço deve ser maior que zero"
    if cat not in CATEGORIAS:
        return None, "Categoria deve ser pao, doce ou bebida"
    return (nome, cat, preco, str(d.get("descricao", "")), int(bool(d.get("promocao"))),
            str(d.get("imagem", "")).strip()), None


class Handler(BaseHTTPRequestHandler):
    def responder(self, codigo, dados=None):
        corpo = b"" if dados is None else json.dumps(dados, ensure_ascii=False).encode("utf-8")
        self.send_response(codigo)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        self.send_header("Content-Length", str(len(corpo)))
        self.end_headers()
        self.wfile.write(corpo)

    def corpo(self):
        try:
            d = json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0))) or b"{}")
            return d if isinstance(d, dict) else {}
        except ValueError:
            return {}

    def exigir(self, papel=None):
        h = self.headers.get("Authorization", "")
        u = None
        if h.startswith("Bearer "):
            with conn() as c:
                u = c.execute("SELECT u.* FROM sessoes s JOIN usuarios u ON u.id=s.usuario_id WHERE s.token=?",
                              (h[7:],)).fetchone()
        if not u:
            self.responder(401, {"erro": "Faça login para continuar"})
            return None
        if papel and u["papel"] != papel:
            self.responder(403, {"erro": "Acesso restrito ao administrador"})
            return None
        return u

    def sessao(self, c, uid, codigo):
        token = secrets.token_hex(24)
        c.execute("INSERT INTO sessoes(token,usuario_id) VALUES(?,?)", (token, uid))
        u = c.execute("SELECT * FROM usuarios WHERE id=?", (uid,)).fetchone()
        self.responder(codigo, {"token": token, "usuario": user_json(u)})

    # ---------- auth
    def registro(self):
        d = self.corpo()
        nome, email, senha = str(d.get("nome", "")).strip(), str(d.get("email", "")).strip().lower(), str(d.get("senha", ""))
        if len(nome) < 2 or not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", email) or len(senha) < 6:
            return self.responder(422, {"erro": "Informe nome, e-mail válido e senha com 6+ caracteres"})
        with conn() as c:
            if c.execute("SELECT 1 FROM usuarios WHERE email=?", (email,)).fetchone():
                return self.responder(409, {"erro": "Este e-mail já está cadastrado"})
            uid = novo_usuario(c, nome, email, senha, str(d.get("telefone", "")).strip())
            self.sessao(c, uid, 201)

    def login(self):
        d = self.corpo()
        email, senha = str(d.get("email", "")).strip().lower(), str(d.get("senha", ""))
        with conn() as c:
            u = c.execute("SELECT * FROM usuarios WHERE email=?", (email,)).fetchone()
            if not u or not secrets.compare_digest(u["senha_hash"], hash_senha(senha, u["salt"])):
                return self.responder(401, {"erro": "E-mail ou senha incorretos"})
            self.sessao(c, u["id"], 200)

    # ---------- produtos
    def produto_salvar(self, pid):
        if not self.exigir("admin"):
            return
        v, erro = validar_produto(self.corpo())
        if erro:
            return self.responder(422, {"erro": erro})
        with conn() as c:
            if pid is None:
                pid = c.execute("INSERT INTO produtos(nome,categoria,preco,descricao,promocao,imagem) VALUES(?,?,?,?,?,?)", v).lastrowid
                cod = 201
            else:
                if not c.execute("SELECT 1 FROM produtos WHERE id=?", (pid,)).fetchone():
                    return self.responder(404, {"erro": "Produto não encontrado"})
                c.execute("UPDATE produtos SET nome=?,categoria=?,preco=?,descricao=?,promocao=?,imagem=? WHERE id=?", v + (pid,))
                cod = 200
            self.responder(cod, prod_json(c.execute("SELECT * FROM produtos WHERE id=?", (pid,)).fetchone()))

    def produto_excluir(self, pid):
        if not self.exigir("admin"):
            return
        with conn() as c:
            if c.execute("DELETE FROM produtos WHERE id=?", (pid,)).rowcount == 0:
                return self.responder(404, {"erro": "Produto não encontrado"})
        self.responder(200, {"ok": True})

    # ---------- pedidos
    def pedido_criar(self):
        u = self.exigir()
        if not u:
            return
        d = self.corpo()
        tipo, endereco = d.get("tipo"), str(d.get("endereco", "")).strip()
        itens = d.get("itens")
        if tipo not in ("entrega", "retirada") or not isinstance(itens, list) or not itens:
            return self.responder(422, {"erro": "Pedido inválido"})
        if tipo == "entrega" and len(endereco) < 5:
            return self.responder(422, {"erro": "Informe o endereço de entrega"})
        with conn() as c:
            linhas, total = [], 0.0
            for i in itens:
                try:
                    pid, qtd = int(i["produto_id"]), int(i["qtd"])
                except (KeyError, TypeError, ValueError):
                    return self.responder(422, {"erro": "Item inválido"})
                p = c.execute("SELECT * FROM produtos WHERE id=?", (pid,)).fetchone()
                if not p or qtd < 1:
                    return self.responder(422, {"erro": "Produto indisponível no pedido"})
                preco = round(p["preco"] * (0.9 if p["promocao"] else 1), 2)  # preço calculado no servidor
                total += preco * qtd
                linhas.append((p["id"], p["nome"], qtd, preco))
            oid = c.execute("INSERT INTO pedidos(usuario_id,tipo,endereco,obs,total,criado_em) VALUES(?,?,?,?,?,?)",
                            (u["id"], tipo, endereco if tipo == "entrega" else "Retirada no balcão",
                             str(d.get("obs", "")).strip(), round(total, 2),
                             datetime.now().strftime("%d/%m/%Y %H:%M"))).lastrowid
            c.executemany("INSERT INTO pedido_itens(pedido_id,produto_id,nome,qtd,preco_unit) VALUES(?,?,?,?,?)",
                          [(oid,) + l for l in linhas])
            self.responder(201, pedido_json(c, c.execute("SELECT * FROM pedidos WHERE id=?", (oid,)).fetchone()))

    def pedidos_listar(self):
        u = self.exigir()
        if not u:
            return
        with conn() as c:
            if u["papel"] == "admin":
                rows = c.execute("SELECT * FROM pedidos ORDER BY id DESC").fetchall()
            else:
                rows = c.execute("SELECT * FROM pedidos WHERE usuario_id=? ORDER BY id DESC", (u["id"],)).fetchall()
            self.responder(200, [pedido_json(c, r) for r in rows])

    def pedido_status(self, oid):
        if not self.exigir("admin"):
            return
        st = self.corpo().get("status")
        if st not in STATUS:
            return self.responder(422, {"erro": "Status inválido"})
        with conn() as c:
            if c.execute("UPDATE pedidos SET status=? WHERE id=?", (st, oid)).rowcount == 0:
                return self.responder(404, {"erro": "Pedido não encontrado"})
        self.responder(200, {"ok": True})

    # ---------- roteamento
    def despachar(self, m):
        p = self.path.split("?")[0].rstrip("/")
        mp, ms = re.fullmatch(r"/produtos/(\d+)", p), re.fullmatch(r"/pedidos/(\d+)/status", p)
        try:
            if m == "GET" and p == "":
                self.responder(200, {"api": "Amora Bakery"})
            elif m == "POST" and p == "/auth/registro":
                self.registro()
            elif m == "POST" and p == "/auth/login":
                self.login()
            elif m == "GET" and p == "/produtos":
                with conn() as c:
                    self.responder(200, [prod_json(r) for r in c.execute("SELECT * FROM produtos ORDER BY id")])
            elif m == "POST" and p == "/produtos":
                self.produto_salvar(None)
            elif m == "PUT" and mp:
                self.produto_salvar(int(mp.group(1)))
            elif m == "DELETE" and mp:
                self.produto_excluir(int(mp.group(1)))
            elif m == "POST" and p == "/pedidos":
                self.pedido_criar()
            elif m == "GET" and p == "/pedidos":
                self.pedidos_listar()
            elif m == "PUT" and ms:
                self.pedido_status(int(ms.group(1)))
            else:
                self.responder(404, {"erro": "Rota não encontrada"})
        except Exception as e:  # nunca derruba o servidor
            self.responder(500, {"erro": f"Erro interno: {e}"})

    def do_OPTIONS(self): self.responder(204)
    def do_GET(self): self.despachar("GET")
    def do_POST(self): self.despachar("POST")
    def do_PUT(self): self.despachar("PUT")
    def do_DELETE(self): self.despachar("DELETE")

    def log_message(self, fmt, *args):
        print(f"  {self.command} {self.path} -> {args[1] if len(args) > 1 else ''}")


def ip_local():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("10.255.255.255", 1))
        return s.getsockname()[0]
    except OSError:
        return "127.0.0.1"
    finally:
        s.close()


if __name__ == "__main__":
    iniciar_banco()
    print("=" * 58)
    print(" Servidor da Amora Bakery rodando! (Ctrl+C para parar)")
    print(f" No computador:         http://localhost:{PORTA}")
    print(f" Celular (mesmo Wi-Fi): http://{ip_local()}:{PORTA}")
    print(f" Admin padrão: {ADMIN_EMAIL}  /  senha: {ADMIN_SENHA}")
    print("=" * 58)
    ThreadingHTTPServer(("0.0.0.0", PORTA), Handler).serve_forever()
