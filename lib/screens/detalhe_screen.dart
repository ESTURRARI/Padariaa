import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/api_service.dart';
import 'produto_form_screen.dart';

class DetalheScreen extends StatelessWidget {
  final Produto produto;
  const DetalheScreen({super.key, required this.produto});

  Future<void> _excluir(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text(produto.nome),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService().excluir(produto.id!);
      if (context.mounted) Navigator.pop(context, true);
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha: $e')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(produto.nome)),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Icon(produto.icone, size: 96, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 16),
            Text(produto.detalhe, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text('R\$ ${produto.precoFinal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium),
            if (produto.promocao) Text('Promoção! De R\$ ${produto.preco.toStringAsFixed(2)}'),
            const Spacer(),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  onPressed: () async {
                    final mudou = await Navigator.push<bool>(
                        context, MaterialPageRoute(builder: (_) => ProdutoFormScreen(produto: produto)));
                    if (mudou == true && context.mounted) Navigator.pop(context, true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(icon: const Icon(Icons.delete), label: const Text('Excluir'), onPressed: () => _excluir(context)),
              ),
            ]),
          ]),
        ),
      );
}