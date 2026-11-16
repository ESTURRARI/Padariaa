
# 🫐 Amora Bakery — Aplicativo Mobile

Aplicativo de uma padaria e cafeteria desenvolvido em **Flutter e Dart**, como parte da Avaliação Somativa de PPDM do SENAI "Roberto Mange".

O objetivo do projeto é facilitar a experiência dos clientes, permitindo consultar o cardápio, escolher produtos e realizar pedidos pelo próprio aplicativo. Além disso, o sistema possui uma área administrativa para que o responsável pela padaria possa gerenciar os produtos e acompanhar os pedidos recebidos.

---

# ▶️ Como executar o projeto

## Pré-requisitos

Antes de começar, verifique se você tem os seguintes programas instalados:

- Python 3;
- Flutter SDK;
- VS Code;
- Extensões Flutter e Dart no VS Code.

Para verificar se o Flutter está configurado corretamente, execute `flutter doctor` no terminal.

## 1. Iniciar o servidor

Abra um terminal na pasta do projeto e execute:

```bash
cd backend
python server.py
```

O servidor será iniciado na porta 8000. No terminal, serão exibidos os endereços para acessar a API pelo computador e por outros dispositivos conectados à mesma rede.

Na primeira execução, o sistema cria automaticamente o banco de dados `padaria.db`, incluindo alguns produtos de exemplo e a conta de administrador.

**Importante:** mantenha esse terminal aberto enquanto estiver utilizando o aplicativo.

## 2. Preparar e executar o aplicativo

Abra outro terminal, agora na pasta principal do projeto, e execute:

```bash
flutter pub get
```

Esse comando instala as dependências necessárias.

Em seguida, para abrir o aplicativo no navegador:

```bash
flutter run -d chrome
```

Caso queira executar em um emulador ou celular Android conectado ao computador:

```bash
flutter run
```

## 3. Acessos ao aplicativo

O sistema possui dois tipos de usuários: **cliente e administrador**.

### Administrador

A conta administrativa já vem cadastrada no banco de dados na primeira execução. Portanto, não é necessário criar uma conta para esse perfil.

| Campo | Acesso |
|---|---|
| E-mail | admin@amora.com |
| Senha | admin123 |

### Cliente

Para acessar como cliente, basta abrir a tela de login e selecionar a opção **Criar conta de cliente**.

O próprio usuário realiza seu cadastro, informando seus dados e escolhendo uma senha. Depois disso, poderá utilizar o e-mail e a senha cadastrados para entrar no aplicativo.

Cada cliente possui sua própria conta e consegue visualizar somente os pedidos realizados por ele.

## 4. Gerar o APK para Android

Também é possível gerar uma versão instalável do aplicativo para celulares Android.

Antes de gerar o arquivo, confira as configurações:

No arquivo `android/app/src/main/AndroidManifest.xml`:

- Antes da tag `<application>`, deve existir a permissão de internet:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

- Dentro da tag `<application>`, deve existir:

```xml
android:usesCleartextTraffic="true"
```

No arquivo `android/app/build.gradle.kts`, confira se o `minSdk` está configurado como 23.

Depois, execute na pasta principal:

```bash
flutter build apk --release
```

O arquivo será gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Para utilizar o aplicativo no celular, basta instalar o APK.

**Conexão com o servidor pelo celular:**

O computador e o celular precisam estar conectados à mesma rede Wi-Fi. Com o servidor ligado, abra o aplicativo, toque nos três pontinhos do menu e selecione **Endereço do servidor**.

Informe o endereço IP do computador, exibido no terminal do servidor, no seguinte formato:

```text
http://IP_DO_COMPUTADOR:8000
```

No emulador Android, o endereço de conexão já funciona automaticamente.

---

# 🫐 Sobre o projeto

A **Amora Bakery** foi pensada para representar uma padaria e cafeteria que deseja oferecer uma experiência mais prática aos seus clientes.

Pelo aplicativo, é possível consultar os produtos disponíveis, visualizar preços e promoções, adicionar itens aos favoritos e montar um carrinho de compras.

Na finalização do pedido, o cliente pode escolher entre receber os produtos em casa ou retirar diretamente no balcão da padaria.

O projeto também conta com uma área administrativa, que permite controlar o cardápio e acompanhar os pedidos realizados pelos clientes.

## 👤 Funcionalidades do cliente

- Criar uma conta e realizar login.
- Manter a sessão salva no aparelho, sem precisar entrar novamente toda vez que abrir o aplicativo.
- Consultar o cardápio e visualizar os produtos disponíveis.
- Pesquisar produtos pelo nome.
- Filtrar os produtos por categoria: pães, doces e bebidas.
- Adicionar produtos aos favoritos.
- Adicionar itens ao carrinho e alterar suas quantidades.
- Visualizar o valor total da compra.
- Escolher entre entrega ou retirada no balcão.
- Informar o endereço de entrega, com preenchimento automático dos dados por meio do CEP.
- Consultar seus pedidos anteriores e acompanhar o andamento de cada um.
- Consultar o cardápio mesmo sem conexão com a internet, utilizando os dados armazenados em cache.

## 🛠️ Funcionalidades do administrador

O administrador possui acesso a funcionalidades específicas para gerenciar a padaria.

- Cadastrar novos produtos.
- Editar informações de produtos já cadastrados.
- Excluir produtos do cardápio.
- Informar nome, categoria, preço, descrição e promoção.
- Adicionar fotos aos produtos utilizando a galeria, câmera ou um link de imagem.
- Consultar todos os pedidos realizados pelos clientes.
- Visualizar os dados de quem realizou cada pedido, incluindo nome, telefone e e-mail.
- Consultar os itens, quantidades, tipo de pedido e endereço de entrega, quando aplicável.
- Atualizar o status dos pedidos.

Os pedidos podem passar pelos seguintes status:

1. Novo;
2. Preparando;
3. Pronto;
4. Entregue;
5. Cancelado.

---

# 🧱 Tecnologias utilizadas

Para desenvolver o projeto, foram utilizadas as seguintes tecnologias:

| Parte do projeto | Tecnologia |
|---|---|
| Aplicativo mobile | Flutter e Dart |
| Servidor | Python 3 |
| API | API REST desenvolvida em Python |
| Banco de dados | SQLite |
| Armazenamento local | Shared Preferences e Flutter Secure Storage |
| Requisições HTTP | HTTP |
| Seleção de imagens | Image Picker |
| Consulta de CEP | ViaCEP |

O servidor foi desenvolvido utilizando apenas bibliotecas da própria linguagem Python, sem a necessidade de instalar frameworks adicionais para o backend.

## 📁 Organização das pastas

O projeto foi organizado para separar as telas, os modelos, os serviços e os componentes utilizados pelo aplicativo.

```text
padaria/
│
├── backend/
│   └── server.py
│
├── lib/
│   ├── main.dart
│   ├── theme.dart
│   │
│   ├── models/
│   │
│   ├── services/
│   │
│   ├── screens/
│   │
│   └── widgets/
│
├── assets/
│   └── logo.png
│
├── android/
├── web/
│
└── pubspec.yaml
```

**O que cada pasta contém:**

- `backend/`: contém o servidor responsável pela API e pelo banco de dados.
- `models/`: reúne as classes utilizadas para representar produtos, usuários, pedidos e carrinho.
- `services/`: concentra os serviços de comunicação com a API, armazenamento local, carrinho e consulta de CEP.
- `screens/`: contém as telas do aplicativo, como login, cardápio, detalhes dos produtos, carrinho e pedidos.
- `widgets/`: reúne componentes reutilizáveis utilizados em diferentes partes do aplicativo.
- `assets/`: armazena os arquivos visuais, incluindo a logo da Amora Bakery.

---

# 🌐 API e banco de dados

O projeto utiliza uma API REST própria para realizar a comunicação entre o aplicativo e o servidor.

Os dados dos produtos, usuários e pedidos são armazenados no banco SQLite, localizado em `backend/padaria.db`.

A API também é responsável por verificar as permissões de acesso, processar os pedidos e recalcular os preços no servidor antes de registrar uma compra.

### Principais rotas da API

| Método | Rota | Acesso | Função |
|---|---|---|---|
| POST | `/auth/registro` | Público | Cadastro de clientes |
| POST | `/auth/login` | Público | Login e geração de token |
| GET | `/produtos` | Público | Consultar produtos |
| POST | `/produtos` | Administrador | Cadastrar produto |
| PUT | `/produtos/{id}` | Administrador | Editar produto |
| DELETE | `/produtos/{id}` | Administrador | Excluir produto |
| POST | `/pedidos` | Usuário logado | Criar pedido |
| GET | `/pedidos` | Usuário logado | Consultar pedidos |
| PUT | `/pedidos/{id}/status` | Administrador | Atualizar status |

As rotas protegidas exigem um token de autenticação enviado no cabeçalho da requisição:

```text
Authorization: Bearer <token>
```

Além da API própria, o aplicativo utiliza o serviço ViaCEP para consultar os dados de endereço a partir do CEP informado pelo cliente.

---

# 🔐 Armazenamento e proteção dos dados

O projeto utiliza diferentes formas de armazenamento, dependendo do tipo de informação.

| Tipo de informação | Onde é armazenada |
|---|---|
| Produtos, preços e promoções | Banco SQLite no servidor |
| Pedidos e dados dos usuários | Banco SQLite no servidor |
| Sessão e token de autenticação | Armazenamento seguro no aparelho |
| Endereço salvo pelo usuário | Armazenamento seguro no aparelho |
| Cache dos produtos | Shared Preferences |
| Produtos favoritos | Shared Preferences |

As senhas dos usuários são armazenadas no servidor em formato de hash, utilizando PBKDF2 com salt, em vez de serem salvas como texto comum.

O endereço de entrega é enviado ao servidor somente quando necessário para registrar um pedido de entrega.

---

# 📚 Desenvolvimento e requisitos da avaliação

Durante o desenvolvimento, foram aplicados diferentes conceitos trabalhados nas aulas de PPDM.

Abaixo estão alguns dos principais critérios da avaliação e como foram utilizados no projeto.

| Critério | Como foi aplicado |
|---|---|
| **2. Ambiente de desenvolvimento** | Configuração do Flutter SDK, variáveis de ambiente, VS Code e extensões Flutter e Dart. |
| **3. Requisitos e componentes** | Organização das funcionalidades em telas, serviços, modelos e widgets. |
| **4. Variáveis, processos e saídas** | Utilização de tipos como `int`, `double`, `String`, `bool`, `List`, `Map` e `Set`, além de cálculos, filtros e validações. |
| **5. Interfaces móveis** | Desenvolvimento das telas com layouts responsivos e adaptação dos elementos conforme o tamanho da tela. |
| **6. Lógica em Dart** | Utilização de `async/await`, `Future`, null safety, construtores `factory`, `switch` e records. |
| **7. Persistência local** | Armazenamento da sessão, favoritos e cache dos produtos no aparelho. |
| **8. Integração com serviços web** | Comunicação com a API própria utilizando GET, POST, PUT e DELETE, além da integração com o ViaCEP. |
| **10. Publicação** | Geração do APK para instalação em dispositivos Android. |
| **11. Programação orientada a objetos** | Criação de classes, herança, polimorfismo e utilização de componentes reutilizáveis. |

### Programação orientada a objetos

Foram criadas classes para organizar as principais entidades do sistema:

- `Produto`: representação dos produtos da padaria.
- `Pao`, `Doce` e `Bebida`: subclasses de Produto.
- `Usuario`: classe base para os usuários.
- `Cliente` e `Administrador`: subclasses de Usuario.
- `Pedido`: representação dos pedidos realizados.
- `Carrinho`: responsável por organizar os itens selecionados e calcular os valores.

Também foram criados widgets reutilizáveis, como `ProdutoCard`, `ProdutoImagem`, `Rodape`, `AmoraLogo` e `AvisoOffline`.

---

# ⚠️ Problemas comuns

| Problema | O que verificar |
|---|---|
| A logo não aparece | Confira se `assets/logo.png` existe e está declarado no `pubspec.yaml`. Depois execute `flutter clean` e `flutter pub get`. |
| Erro relacionado ao `image_picker` | Execute `flutter pub add image_picker`. |
| O aplicativo não consegue conectar ao servidor | Verifique se o `server.py` está em execução e se o endereço configurado está correto. |
| O celular não consegue acessar o servidor | Confira se os dois dispositivos estão na mesma rede Wi-Fi e se o firewall permite a conexão com o Python. |
| O login do administrador não funciona | Confira se o banco foi criado corretamente e se as credenciais estão corretas. |

---

# 👩‍💻 Autoria

Projeto desenvolvido por **Gabriella Esturrari — 3DSMB20**, para a Avaliação Somativa de PPDM do SENAI "Roberto Mange".

**Amora Bakery — Um toque de carinho em cada pedido.** 🫐
