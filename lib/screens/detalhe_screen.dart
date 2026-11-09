import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/carrinho.dart';
import '../theme.dart';
import '../widgets/produto_imagem.dart';
import 'produto_form_screen.dart';

class DetalheScreen extends StatelessWidget {
  final Produto produto;
  final Usuario usuario;
  const DetalheScreen({super.key, required this.produto, required this.usuario});

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
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(produto.nome)),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(borderRadius: BorderRadius.circular(16), child: ProdutoImagem(produto: produto, altura: 220)),
                  const SizedBox(height: 16),
                  Text(produto.detalhe, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Text('R\$ ${produto.precoFinal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: cafe, fontWeight: FontWeight.bold)),
                  if (produto.promocao) Text('Promoção! De R\$ ${produto.preco.toStringAsFixed(2)}', style: const TextStyle(color: amora)),
                ]),
              ),
            ),
            if (usuario.admin)
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
              ])
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Adicionar ao carrinho'),
                  onPressed: () {
                    Carrinho.instancia.adicionar(produto);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(content: Text('Adicionado ao carrinho'), duration: Duration(seconds: 1)));
                  },
                ),
              ),
          ]),
        ),
      );
}
