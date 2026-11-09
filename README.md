# 🫐 Amora Bakery — Aplicativo Mobile (Flutter + Dart)

Aplicativo de padaria e café desenvolvido para a **Avaliação Somativa PPDM — SENAI "Roberto Mange"**
(Situação Desafiadora: *Do Zero ao App Integrado*, agência "Digital Horizon").

O app apresenta o cardápio e as promoções da padaria e permite que o cliente monte um carrinho e
faça pedidos para **entrega** ou **retirada**. O administrador gerencia os produtos e acompanha os pedidos.

---

## 📌 Funcionalidades

### 👤 Cliente
- Criar conta e entrar (a sessão fica salva no aparelho)
- Ver o cardápio, buscar por nome e filtrar por categoria (Pães, Doces, Bebidas)
- Favoritar produtos
- Adicionar ao carrinho, alterar quantidades e finalizar o pedido
- Escolher **Entrega** (informando o endereço, com preenchimento automático pelo CEP) ou **Retirada** no balcão
- Acompanhar o histórico e o status dos próprios pedidos
- Ver o cardápio mesmo **sem internet** (dados em cache)

### 🛠️ Administrador
- Adicionar, editar e excluir produtos (nome, categoria, preço, descrição, promoção e **foto** pela galeria/câmera ou link)
- Ver **todos os pedidos**, com nome, telefone e e-mail de quem pediu, tipo (entrega/retirada), endereço e itens
- Alterar o status do pedido (novo → preparando → pronto → entregue / cancelado)

---

## 🧱 Tecnologias

| Parte | Tecnologia |
|---|---|
| App | Flutter / Dart |
| Servidor (API REST) | Python 3 (somente biblioteca padrão) |
| Banco de dados externo | SQLite (`backend/padaria.db`) |
| Bibliotecas do app | `http`, `shared_preferences`, `flutter_secure_storage`, `image_picker` |
| API pública consumida | ViaCEP (busca de endereço pelo CEP) |

---

## 📁 Estrutura do projeto

```
padaria/
├── backend/
│   └── server.py              # API REST + banco SQLite
├── lib/
│   ├── main.dart              # Início do app (restaura a sessão ou mostra o login)
│   ├── theme.dart             # Paleta de cores (café + amora)
│   ├── models/                # Produto (Pao, Doce, Bebida), Usuario (Cliente, Administrador), Pedido
│   ├── services/              # api_service, local_storage, carrinho, cep_service
│   ├── screens/               # login, home, detalhe, produto_form, carrinho, pedidos
│   └── widgets/               # produto_card, produto_imagem, rodape, logo, aviso_offline, servidor
├── assets/
│   └── logo.png               # Logo da Amora Bakery
├── android/ · web/            # Pastas geradas pelo Flutter
└── pubspec.yaml               # Dependências e assets
```

---

## ▶️ Como executar

### Pré-requisitos
- **Python 3** instalado
- **Flutter SDK** instalado e no PATH (`flutter doctor` sem erros no item Flutter)
- VS Code com os plugins **Flutter** e **Dart**

### 1. Ligar o servidor (deixe esse terminal aberto)
```
cd backend
python server.py
```
O servidor mostra no terminal o endereço para o computador (`http://localhost:8000`) e para o celular na mesma rede.
Na primeira execução, o banco é criado automaticamente com produtos de exemplo e o usuário administrador.

### 2. Rodar o app (em outro terminal, na pasta `padaria`)
```
flutter pub get
flutter run -d chrome
```
Para rodar em emulador ou celular Android conectado: `flutter run`.

### 🔑 Acesso

| Perfil | Como entrar |
|---|---|
| **Administrador** | e-mail `admin@amora.com` — senha `admin123` |
| **Cliente** | tela de login → **Criar conta de cliente** |

> A senha do administrador pode ser trocada em `backend/server.py` (constante `ADMIN_SENHA`)
> antes da primeira execução (apague o `padaria.db` para recriar o banco).

---

## 📲 Gerar e instalar o APK

1. Em `android/app/src/main/AndroidManifest.xml`, confirme:
   - antes de `<application`: `<uses-permission android:name="android.permission.INTERNET"/>`
   - dentro da tag `<application`: `android:usesCleartextTraffic="true"`
2. Em `android/app/build.gradle.kts`, confirme `minSdk = 23`.
3. Gere o arquivo:
   ```
   flutter build apk --release
   ```
   O APK fica em `build/app/outputs/flutter-apk/app-release.apk`.
4. Instale no celular (copie o arquivo e abra, ou use `adb install app-release.apk`).
5. Com o servidor ligado no computador e os dois na **mesma rede Wi-Fi**, abra o app, toque nos três pontinhos →
   **Endereço do servidor** e informe `http://IP_DO_COMPUTADOR:8000` (o IP aparece no terminal do servidor).
   No emulador Android o endereço já funciona automaticamente.

---

## 🌐 API REST

Dados públicos (produtos) ficam no banco externo e são acessados por serviços RESTful.
Rotas protegidas exigem o cabeçalho `Authorization: Bearer <token>` recebido no login.

| Método | Rota | Quem acessa | Descrição |
|---|---|---|---|
| POST | `/auth/registro` | público | Cria conta de cliente |
| POST | `/auth/login` | público | Entra e recebe o token |
| **GET** | `/produtos` | público | Lista os produtos |
| **POST** | `/produtos` | admin | Cria produto |
| **PUT** | `/produtos/{id}` | admin | Atualiza produto |
| **DELETE** | `/produtos/{id}` | admin | Exclui produto |
| POST | `/pedidos` | logado | Cria pedido (o preço é recalculado no servidor) |
| GET | `/pedidos` | logado | Admin: todos os pedidos · Cliente: apenas os seus |
| PUT | `/pedidos/{id}/status` | admin | Altera o status do pedido |

---

## 🔐 Dados públicos x dados sensíveis

| Tipo | Exemplos | Onde fica |
|---|---|---|
| **Público** | produtos, preços, promoções, imagens | Banco externo (SQLite) via API REST |
| **Sensível** | sessão/token do usuário e endereço de entrega salvo | **Somente no aparelho**, em armazenamento seguro (`flutter_secure_storage`) |
| Local (não sensível) | cache dos produtos e favoritos | `shared_preferences` |

Observações: a senha é guardada no servidor apenas como **hash** (PBKDF2 com sal), nunca em texto puro.
O endereço só é enviado ao servidor dentro de um pedido de **entrega**, pois é necessário para entregar.

---

## ✅ Critérios da avaliação × onde estão no projeto

| Capacidade / Critério | Atendimento |
|---|---|
| **2. Ambiente de desenvolvimento** | Variáveis de ambiente do Windows (Flutter `bin` no `Path`, `ANDROID_HOME`, `JAVA_HOME`); IDE VS Code; plugins Flutter e Dart; bibliotecas importadas no `pubspec.yaml` (`http`, `shared_preferences`, `flutter_secure_storage`, `image_picker`) |
| **3. Requisitos → componentes** | Tabela abaixo |
| **4. Variáveis, processos e saídas** | Tipos `int`, `double`, `String`, `bool`, `List`, `Map`, `Set` (`models/`); processos: cálculo de promoção (10%) e total do carrinho, validações de formulário, busca e filtro por categoria; saídas: telas, pedidos e status. Adicionais: favoritos, foto do produto, busca de CEP, status do pedido |
| **5. Interfaces móveis** | 6 telas (mínimo exigido: 3): login, cardápio, detalhe, formulário de produto, carrinho/checkout e pedidos. Responsividade: grade com `SliverGridDelegateWithMaxCrossAxisExtent` (colunas se adaptam à largura), `ConstrainedBox`, `Wrap` no rodapé |
| **6. Lógica em Dart** | `async/await` e `Future`, null safety (`int?`, `String?`), construtores `factory`, parâmetros `super.`, `switch` com expressões e *records* |
| **7. Persistência local** | `services/local_storage.dart`: cache dos produtos (funciona offline), favoritos, sessão e endereço salvos no aparelho |
| **8. Integração com serviços web** | `services/api_service.dart`: **GET, POST, PUT e DELETE**; múltiplas APIs: API própria + **ViaCEP** (`services/cep_service.dart`) |
| **10. Publicação** | Exportação do APK e instalação no dispositivo (seção acima) |
| **11. Programação orientada a objetos** | Classes (`Produto`, `Usuario`, `Pedido`, `Carrinho`); subclasses: `Pao`/`Doce`/`Bebida` e `Cliente`/`Administrador` (polimorfismo em `detalhe` e `icone`); componentização com widgets reutilizáveis (`ProdutoCard`, `ProdutoImagem`, `Rodape`, `AmoraLogo`, `AvisoOffline`) |

### Requisitos do cliente → componentes do app

| Requisito do estabelecimento | Componente |
|---|---|
| Apresentar produtos, serviços e promoções | `HomeScreen` + `ProdutoCard` + `DetalheScreen` |
| Interação do usuário | Favoritos, busca, filtros, carrinho e pedidos |
| Cliente compra e escolhe entrega ou retirada | `CarrinhoScreen` + `Carrinho` |
| Administrador gerencia produtos | `ProdutoFormScreen` + `ApiService` (POST/PUT/DELETE) |
| Administrador vê os pedidos e quem os fez | `PedidosScreen` (visão do admin) |
| Dados sensíveis protegidos no aparelho | `LocalStorage` (`flutter_secure_storage`) |
| Dados públicos em banco externo via REST | `backend/server.py` + `ApiService` |
| Funcionar sem internet | Cache de produtos + `AvisoOffline` |
| Dois perfis de acesso | `LoginScreen` + `Usuario` (`Cliente` / `Administrador`) |

---

## 🧰 Problemas comuns

| Problema | Solução |
|---|---|
| A logo não aparece (só bolinhas roxas) | Confirme que `assets/logo.png` existe e que o `pubspec.yaml` tem `assets:` com `- assets/logo.png`; rode `flutter clean`, `flutter pub get` e abra o app de novo |
| Erro `image_picker` não encontrado | `flutter pub add image_picker` |
| "Não foi possível conectar ao servidor" | Confirme que o `server.py` está rodando; no celular, ajuste o endereço do servidor no menu (⋮) |
| Celular não conecta ao PC | Mesma rede Wi-Fi e firewall do Windows liberando o Python |
| Login do admin não funciona | Apague `backend/padaria.db` e inicie o servidor de novo |

---

## 👩‍💻 Autoria

Projeto desenvolvido para a Avaliação Somativa PPDM — Gabriella esturrari 3DSMB20 — SENAI "Roberto Mange".
