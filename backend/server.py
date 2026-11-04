"""API REST da Padaria Pão Quente — só biblioteca padrão do Python. Sem instalar nada."""
import json, os, re, socket, sqlite3
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

DB = os.path.join(os.path.dirname(os.path.abspath(__file__)), "padaria.db")
PORTA = int(os.environ.get("PORT", 8000))
CATEGORIAS = {"pao", "doce", "bebida"}


def conn():
    c = sqlite3.connect(DB)
    c.row_factory = sqlite3.Row
    return c


def linha(r):
    d = dict(r)
    d["promocao"] = bool(d["promocao"])
    return d


def iniciar_banco():
    with conn() as c:
        c.execute("""CREATE TABLE IF NOT EXISTS produtos(
            id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT NOT NULL, categoria TEXT NOT NULL,
            preco REAL NOT NULL, descricao TEXT DEFAULT '', promocao INTEGER DEFAULT 0)""")
        if c.execute("SELECT COUNT(*) FROM produtos").fetchone()[0] == 0:
            c.executemany("INSERT INTO produtos(nome,categoria,preco,descricao,promocao) VALUES(?,?,?,?,?)", [
                ("Pão Francês (kg)", "pao", 16.90, "Crocante, saído do forno toda hora", 0),
                ("Pão de Queijo (un)", "pao", 4.50, "Receita mineira", 1),
                ("Brigadeiro Gourmet", "doce", 5.00, "Chocolate belga", 0),
                ("Torta de Limão (fatia)", "doce", 12.00, "Massa amanteigada", 1),
                ("Café Coado", "bebida", 4.00, "Café fresco 200ml", 0),
                ("Suco de Laranja", "bebida", 8.00, "Natural, 300ml", 0),
            ])


def validar(d):
    """Retorna (dados_limpos, erro)."""
    try:
        nome = str(d.get("nome", "")).strip()
        preco = float(d.get("preco"))
        cat = d.get("categoria")
    except (TypeError, ValueError, AttributeError):
        return None, "Dados inválidos"
    if len(nome) < 2:
        return None, "Nome deve ter ao menos 2 letras"
    if preco <= 0:
        return None, "Preço deve ser maior que zero"
    if cat not in CATEGORIAS:
        return None, "Categoria deve ser pao, doce ou bebida"
    return (nome, cat, preco, str(d.get("descricao", "")), int(bool(d.get("promocao")))), None


class Handler(BaseHTTPRequestHandler):
    def responder(self, codigo, dados=None):
        corpo = b"" if dados is None else json.dumps(dados, ensure_ascii=False).encode("utf-8")
        self.send_response(codigo)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")  # permite o app rodar no navegador
        self.send_header("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Content-Length", str(len(corpo)))
        self.end_headers()
        self.wfile.write(corpo)

    def pid(self):
        m = re.fullmatch(r"/produtos/(\d+)/?", self.path.split("?")[0])
        return int(m.group(1)) if m else None

    def corpo(self):
        try:
            n = int(self.headers.get("Content-Length", 0))
            return json.loads(self.rfile.read(n) or b"{}")
        except ValueError:
            return {}

    def buscar(self, i):
        with conn() as c:
            r = c.execute("SELECT * FROM produtos WHERE id=?", (i,)).fetchone()
        return linha(r) if r else None

    def do_OPTIONS(self):
        self.responder(204)

    def do_GET(self):
        p = self.path.split("?")[0].rstrip("/")
        if p == "":
            return self.responder(200, {"api": "Padaria Pão Quente", "rotas": [
                "GET /produtos", "GET /produtos/{id}", "POST /produtos", "PUT /produtos/{id}", "DELETE /produtos/{id}"]})
        if p == "/produtos":
            with conn() as c:
                return self.responder(200, [linha(r) for r in c.execute("SELECT * FROM produtos ORDER BY id")])
        i = self.pid()
        prod = self.buscar(i) if i else None
        self.responder(200, prod) if prod else self.responder(404, {"erro": "Produto não encontrado"})

    def do_POST(self):
        if self.path.split("?")[0].rstrip("/") != "/produtos":
            return self.responder(404, {"erro": "Rota não encontrada"})
        v, erro = validar(self.corpo())
        if erro:
            return self.responder(422, {"erro": erro})
        with conn() as c:
            cur = c.execute("INSERT INTO produtos(nome,categoria,preco,descricao,promocao) VALUES(?,?,?,?,?)", v)
        self.responder(201, self.buscar(cur.lastrowid))

    def do_PUT(self):
        i = self.pid()
        if not i or not self.buscar(i):
            return self.responder(404, {"erro": "Produto não encontrado"})
        v, erro = validar(self.corpo())
        if erro:
            return self.responder(422, {"erro": erro})
        with conn() as c:
            c.execute("UPDATE produtos SET nome=?,categoria=?,preco=?,descricao=?,promocao=? WHERE id=?", v + (i,))
        self.responder(200, self.buscar(i))

    def do_DELETE(self):
        i = self.pid()
        if not i or not self.buscar(i):
            return self.responder(404, {"erro": "Produto não encontrado"})
        with conn() as c:
            c.execute("DELETE FROM produtos WHERE id=?", (i,))
        self.responder(200, {"ok": True})

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
    print("=" * 56)
    print(" Servidor da Padaria rodando! (Ctrl+C para parar)")
    print(f" No computador:        http://localhost:{PORTA}")
    print(f" Celular (mesmo Wi-Fi): http://{ip_local()}:{PORTA}")
    print("=" * 56)
    ThreadingHTTPServer(("0.0.0.0", PORTA), Handler).serve_forever()