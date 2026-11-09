import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/carrinho.dart';
import '../services/local_storage.dart';
import '../theme.dart';
import '../widgets/aviso_offline.dart';
import '../widgets/logo.dart';
import '../widgets/produto_card.dart';
import '../widgets/rodape.dart';
import '../widgets/servidor.dart';
import 'carrinho_screen.dart';
import 'detalhe_screen.dart';
import 'login_screen.dart';
import 'pedidos_screen.dart';
import 'produto_form_screen.dart';

class HomeScreen extends StatefulWidget {
  final Usuario usuario;
  const HomeScreen({super.key, required this.usuario});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  final _store = LocalStorage();
  final _carrinho = Carrinho.instancia;
  List<Produto> _todos = [];
  Set<int> _favs = {};
  bool _loading = true, _offline = false, _soFavs = false;
  String _busca = '', _cat = 'todos';

  static const _categorias = [('todos', 'Todos'), ('pao', 'Pães'), ('doce', 'Doces'), ('bebida', 'Bebidas')];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    _favs = await _store.lerFavoritos();
    try {
      _todos = await _api.listar();
      await _store.salvarCache(_todos); // cache local
      _offline = false;
    } catch (_) {
      _todos = await _store.lerCache(); // sem rede: usa cache
      _offline = true;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggleFav(Produto p) async {
    setState(() => _favs.contains(p.id) ? _favs.remove(p.id) : _favs.add(p.id!));
    await _store.salvarFavoritos(_favs);
  }

  Future<void> _abrir(Widget tela) async {
    final mudou = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => tela));
    if (mudou == true) _carregar();
  }

  void _adicionar(Produto p) {
    _carrinho.adicionar(p);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${p.nome} adicionado ao carrinho'), duration: const Duration(seconds: 1)));
  }

  Future<void> _sair() async {
    await _store.sair();
    ApiService.token = null;
    _carrinho.limpar();
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final admin = widget.usuario.admin;
    final lista = _todos
        .where((p) => _cat == 'todos' || p.categoria == _cat)
        .where((p) => p.nome.toLowerCase().contains(_busca.toLowerCase()))
        .where((p) => !_soFavs || _favs.contains(p.id))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const AmoraLogo(tamanho: 34),
          ),
          const SizedBox(width: 10),
          const Text('Amora Bakery'),
        ]),
        actions: [
          IconButton(
            tooltip: 'Só favoritos',
            icon: Icon(_soFavs ? Icons.favorite : Icons.favorite_border),
            onPressed: () => setState(() => _soFavs = !_soFavs),
          ),
          IconButton(
            tooltip: admin ? 'Pedidos recebidos' : 'Meus pedidos',
            icon: Icon(admin ? Icons.receipt_long : Icons.history),
            onPressed: () => _abrir(PedidosScreen(usuario: widget.usuario)),
          ),
          if (!admin)
            ListenableBuilder(
              listenable: _carrinho,
              builder: (_, __) => IconButton(
                tooltip: 'Carrinho',
                icon: Badge(
                  label: Text('${_carrinho.quantidade}'),
                  isLabelVisible: _carrinho.quantidade > 0,
                  child: const Icon(Icons.shopping_cart),
                ),
                onPressed: () => _abrir(const CarrinhoScreen()),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'sair') return _sair();
              if (await editarServidor(context)) _carregar();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'servidor', child: Text('Endereço do servidor')),
              PopupMenuItem(value: 'sair', child: Text('Sair')),
            ],
          ),
        ],
      ),
      floatingActionButton: admin
          ? FloatingActionButton.extended(
              onPressed: () => _abrir(const ProdutoFormScreen()),
              icon: const Icon(Icons.add),
              label: const Text('Novo produto'),
            )
          : null,
      body: Column(children: [
        if (_offline) const AvisoOffline(),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [espresso, amora]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            admin ? 'Painel do administrador\nGerencie produtos e acompanhe os pedidos' : 'Olá, ${widget.usuario.nome.split(' ').first}!\nO que vai ser hoje?',
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar produto',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            onChanged: (v) => setState(() => _busca = v),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            for (final (valor, rotulo) in _categorias)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(rotulo),
                  selected: _cat == valor,
                  selectedColor: amora,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(color: _cat == valor ? Colors.white : espresso),
                  onSelected: (_) => setState(() => _cat = valor),
                ),
              ),
          ]),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                          child: Text('Nosso cardápio  •  ${lista.length} ${lista.length == 1 ? 'item' : 'itens'}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: espresso)),
                        ),
                      ),
                      if (lista.isEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(padding: EdgeInsets.all(48), child: Center(child: Text('Nenhum produto encontrado'))),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          // Responsivo: quantidade de colunas se adapta à largura; altura fixa deixa todos os cards iguais
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 240, mainAxisExtent: 320, mainAxisSpacing: 12, crossAxisSpacing: 12),
                            delegate: SliverChildBuilderDelegate(
                              (_, i) {
                                final p = lista[i];
                                return ProdutoCard(
                                  produto: p,
                                  favorito: _favs.contains(p.id),
                                  onTap: () => _abrir(DetalheScreen(produto: p, usuario: widget.usuario)),
                                  onFavorito: () => _toggleFav(p),
                                  onAdicionar: admin ? null : () => _adicionar(p),
                                );
                              },
                              childCount: lista.length,
                            ),
                          ),
                        ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Align(alignment: Alignment.bottomCenter, child: Rodape(espacoFim: admin ? 70 : 0)),
                      ),
                    ],
                  ),
                ),
        ),
      ]),
    );
  }
}
