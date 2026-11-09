import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../theme.dart';

/// Cliente: vê os próprios pedidos. Admin: vê todos, com quem pediu, e muda o status.
class PedidosScreen extends StatefulWidget {
  final Usuario usuario;
  const PedidosScreen({super.key, required this.usuario});
  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final _api = ApiService();
  List<Pedido>? _pedidos;
  String? _erro;

  static const _status = {
    'novo': 'Novo',
    'preparando': 'Preparando',
    'pronto': 'Pronto',
    'entregue': 'Entregue',
    'cancelado': 'Cancelado',
  };

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final p = await _api.listarPedidos();
      if (mounted) setState(() { _pedidos = p; _erro = null; });
    } catch (e) {
      if (mounted) setState(() => _erro = '$e');
    }
  }

  Future<void> _mudar(Pedido p, String status) async {
    try {
      await _api.atualizarStatus(p.id, status);
      _carregar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Color _cor(String s) => switch (s) {
        'novo' => amora,
        'preparando' => caramelo,
        'pronto' => Colors.green.shade700,
        'entregue' => Colors.grey.shade600,
        _ => Colors.red.shade700,
      };

  Widget _linha(IconData i, String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(i, size: 18, color: cafe),
          const SizedBox(width: 8),
          Expanded(child: Text(t)),
        ]),
      );

  Widget _card(Pedido p) {
    final admin = widget.usuario.admin;
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        leading: Icon(p.entrega ? Icons.delivery_dining : Icons.storefront, color: cafe),
        title: Text('Pedido #${p.id} • R\$ ${p.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${p.criadoEm}${admin ? ' • ${p.clienteNome}' : ''}'),
        trailing: Chip(
          label: Text(_status[p.status] ?? p.status, style: const TextStyle(color: Colors.white, fontSize: 12)),
          backgroundColor: _cor(p.status),
          visualDensity: VisualDensity.compact,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (admin) ...[
            _linha(Icons.person, p.clienteNome),
            if (p.clienteTelefone.isNotEmpty) _linha(Icons.phone, p.clienteTelefone),
            _linha(Icons.email, p.clienteEmail),
          ],
          _linha(p.entrega ? Icons.place : Icons.storefront, p.entrega ? p.endereco : 'Retirada no balcão'),
          if (p.obs.isNotEmpty) _linha(Icons.notes, p.obs),
          const Divider(),
          for (final i in p.itens) _linha(Icons.circle, '${i.qtd}x ${i.nome} — R\$ ${(i.preco * i.qtd).toStringAsFixed(2)}'),
          if (admin) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Text('Status: '),
              DropdownButton<String>(
                value: p.status,
                items: [for (final e in _status.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
                onChanged: (v) {
                  if (v != null && v != p.status) _mudar(p, v);
                },
              ),
            ]),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.usuario.admin ? 'Pedidos recebidos' : 'Meus pedidos')),
        body: _erro != null
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_erro!),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _carregar, child: const Text('Tentar de novo')),
                ]),
              )
            : _pedidos == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _carregar,
                    child: _pedidos!.isEmpty
                        ? ListView(children: const [SizedBox(height: 80), Center(child: Text('Nenhum pedido ainda'))])
                        : Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 640),
                              child: ListView(padding: const EdgeInsets.all(12), children: [for (final p in _pedidos!) _card(p)]),
                            ),
                          ),
                  ),
      );
}
