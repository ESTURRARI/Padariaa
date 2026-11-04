import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/api_service.dart';

class ProdutoFormScreen extends StatefulWidget {
  final Produto? produto; // null = novo (POST); preenchido = edição (PUT)
  const ProdutoFormScreen({super.key, this.produto});
  @override
  State<ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
  final _chave = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.produto?.nome);
  late final _preco = TextEditingController(text: widget.produto?.preco.toString());
  late final _desc = TextEditingController(text: widget.produto?.descricao);
  late String _categoria = widget.produto?.categoria ?? 'pao';
  late bool _promo = widget.produto?.promocao ?? false;
  bool _salvando = false;

  Future<void> _salvar() async {
    if (!_chave.currentState!.validate()) return;
    setState(() => _salvando = true);
    final p = Produto.fromJson({
      'id': widget.produto?.id,
      'nome': _nome.text.trim(),
      'categoria': _categoria,
      'preco': double.parse(_preco.text.replaceAll(',', '.')),
      'descricao': _desc.text.trim(),
      'promocao': _promo,
    });
    try {
      widget.produto == null ? await ApiService().criar(p) : await ApiService().atualizar(p);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _salvando = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao salvar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.produto == null ? 'Novo produto' : 'Editar produto')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _chave,
                child: Column(children: [
                  TextFormField(
                    controller: _nome,
                    decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _preco,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Preço (R\$)', border: OutlineInputBorder()),
                    validator: (v) {
                      final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                      return (n == null || n <= 0) ? 'Preço inválido' : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _desc, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _categoria,
                    decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'pao', child: Text('Pão')),
                      DropdownMenuItem(value: 'doce', child: Text('Doce')),
                      DropdownMenuItem(value: 'bebida', child: Text('Bebida')),
                    ],
                    onChanged: (v) => setState(() => _categoria = v!),
                  ),
                  SwitchListTile(title: const Text('Em promoção (-10%)'), value: _promo, onChanged: (v) => setState(() => _promo = v)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _salvando ? null : _salvar,
                      child: _salvando ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}