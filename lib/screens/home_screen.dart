import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';
import '../widgets/aviso_offline.dart';
import '../widgets/produto_card.dart';
import 'detalhe_screen.dart';
import 'perfil_screen.dart';
import 'produto_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  final _store = LocalStorage();
  List<Produto> _todos = [];
  Set<int> _favs = {};
  bool _loading = true, _offline = false, _soFavs = false;
  String _busca = '';

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

  Future<void> _configurar() async {
    final c = TextEditingController(text: await ApiService.baseUrl());
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Endereço do servidor'),
        content: TextField(controller: c, decoration: const InputDecoration(helperText: 'Ex.: http://192.168.0.10:8000')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
        ],
      ),
    );
    if (ok == true) {
      await ApiService.salvarUrl(c.text.trim());
      _carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = _todos
        .where((p) => p.nome.toLowerCase().contains(_busca.toLowerCase()))
        .where((p) => !_soFavs || _favs.contains(p.id))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Padaria Pão Quente'),
        actions: [
          IconButton(
            tooltip: 'Só favoritos',
            icon: Icon(_soFavs ? Icons.favorite : Icons.favorite_border),
            onPressed: () => setState(() => _soFavs = !_soFavs),
          ),
          IconButton(tooltip: 'Servidor', icon: const Icon(Icons.settings_ethernet), onPressed: _configurar),
          IconButton(tooltip: 'Meu perfil', icon: const Icon(Icons.person), onPressed: () => _abrir(const PerfilScreen())),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrir(const ProdutoFormScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
      body: Column(children: [
        if (_offline) const AvisoOffline(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar produto', border: OutlineInputBorder()),
            onChanged: (v) => setState(() => _busca = v),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: lista.isEmpty
                      ? ListView(children: const [SizedBox(height: 80), Center(child: Text('Nenhum produto encontrado'))])
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          // Responsivo: quantidade de colunas se adapta à largura da tela
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85),
                          itemCount: lista.length,
                          itemBuilder: (_, i) {
                            final p = lista[i];
                            return ProdutoCard(
                              produto: p,
                              favorito: _favs.contains(p.id),
                              onTap: () => _abrir(DetalheScreen(produto: p)),
                              onFavorito: () => _toggleFav(p),
                            );
                          },
                        ),
                ),
        ),
      ]),
    );
  }
}