import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/carrinho.dart';
import '../services/cep_service.dart';
import '../services/local_storage.dart';
import '../theme.dart';

/// Carrinho + finalização: escolher ENTREGA (com endereço) ou RETIRADA no balcão.
class CarrinhoScreen extends StatefulWidget {
  const CarrinhoScreen({super.key});
  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  final _carrinho = Carrinho.instancia;
  final _store = LocalStorage();
  final _c = {for (final k in ['cep', 'rua', 'numero', 'bairro', 'cidade', 'complemento']) k: TextEditingController()};
  final _obs = TextEditingController();
  String _tipo = 'entrega';
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    // endereço salvo na última compra (guardado só no aparelho)
    _store.lerEndereco().then((e) {
      if (mounted) setState(() => e.forEach((k, v) => _c[k]?.text = v));
    });
  }

  String _t(String k) => _c[k]!.text.trim();
  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _buscarCep() async {
    try {
      final r = await CepService().buscar(_t('cep'));
      if (r == null) return _msg('CEP não encontrado');
      setState(() {
        _c['rua']!.text = r['logradouro'] ?? '';
        _c['bairro']!.text = r['bairro'] ?? '';
        _c['cidade']!.text = '${r['localidade']} - ${r['uf']}';
      });
    } catch (_) {
      _msg('Sem conexão para consultar o CEP');
    }
  }

  Future<void> _finalizar() async {
    final itens = _carrinho.itens;
    if (itens.isEmpty) return;
    var endereco = 'Retirada no balcão';
    if (_tipo == 'entrega') {
      if (_t('rua').isEmpty || _t('numero').isEmpty || _t('cidade').isEmpty) return _msg('Preencha rua, número e cidade');
      final compl = _t('complemento').isEmpty ? '' : ' (${_t('complemento')})';
      endereco = [
        '${_t('rua')}, ${_t('numero')}$compl',
        _t('bairro'),
        _t('cidade'),
        if (_t('cep').isNotEmpty) 'CEP ${_t('cep')}',
      ].where((s) => s.isNotEmpty).join(' - ');
    }
    setState(() => _enviando = true);
    try {
      await ApiService().criarPedido(tipo: _tipo, endereco: endereco, obs: _obs.text.trim(), itens: itens);
      if (_tipo == 'entrega') await _store.salvarEndereco({for (final e in _c.entries) e.key: e.value.text.trim()});
      _carrinho.limpar();
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: amora, size: 48),
          title: const Text('Pedido enviado!'),
          content: Text(_tipo == 'entrega' ? 'Vamos preparar e entregar no endereço informado.' : 'Seu pedido estará pronto para retirada no balcão.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _msg('$e');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Widget _campo(String k, String label, {TextInputType? tipo}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: _c[k],
          keyboardType: tipo,
          decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.white, border: const OutlineInputBorder()),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Meu carrinho')),
        body: ListenableBuilder(
          listenable: _carrinho,
          builder: (_, __) {
            final itens = _carrinho.itens;
            if (itens.isEmpty) return const Center(child: Text('Seu carrinho está vazio'));
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  for (final i in itens)
                    Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: Icon(i.produto.icone, color: cafe),
                        title: Text(i.produto.nome),
                        subtitle: Text('R\$ ${i.subtotal.toStringAsFixed(2)}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _carrinho.remover(i.produto)),
                          Text('${i.qtd}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _carrinho.adicionar(i.produto)),
                        ]),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'entrega', icon: Icon(Icons.delivery_dining), label: Text('Entrega')),
                      ButtonSegment(value: 'retirada', icon: Icon(Icons.storefront), label: Text('Retirar')),
                    ],
                    selected: {_tipo},
                    onSelectionChanged: (s) => setState(() => _tipo = s.first),
                  ),
                  const SizedBox(height: 12),
                  if (_tipo == 'entrega') ...[
                    Row(children: [
                      Expanded(child: _campo('cep', 'CEP', tipo: TextInputType.number)),
                      const SizedBox(width: 8),
                      Padding(padding: const EdgeInsets.only(bottom: 10), child: FilledButton(onPressed: _buscarCep, child: const Text('Buscar'))),
                    ]),
                    _campo('rua', 'Rua'),
                    Row(children: [
                      Expanded(child: _campo('numero', 'Número', tipo: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(flex: 2, child: _campo('complemento', 'Complemento')),
                    ]),
                    _campo('bairro', 'Bairro'),
                    _campo('cidade', 'Cidade'),
                  ] else
                    const Card(
                      color: Colors.white,
                      child: ListTile(leading: Icon(Icons.storefront, color: amora), title: Text('Retire no balcão da Amora Bakery')),
                    ),
                  TextField(
                    controller: _obs,
                    decoration: const InputDecoration(labelText: 'Observação (opcional)', filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total', style: TextStyle(fontSize: 18)),
                    Text('R\$ ${_carrinho.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cafe)),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _enviando ? null : _finalizar,
                      child: _enviando
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Finalizar pedido'),
                    ),
                  ),
                ]),
              ),
            );
          },
        ),
      );
}
