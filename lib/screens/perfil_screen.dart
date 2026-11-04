import 'package:flutter/material.dart';
import '../services/cep_service.dart';
import '../services/local_storage.dart';

/// Dados sensíveis do cliente: ficam SOMENTE no aparelho (armazenamento seguro).
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _store = LocalStorage();
  final _c = {for (final k in ['nome', 'telefone', 'cep', 'rua', 'cidade']) k: TextEditingController()};

  @override
  void initState() {
    super.initState();
    _store.lerPerfil().then((p) => setState(() => p.forEach((k, v) => _c[k]?.text = v)));
  }

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _buscarCep() async {
    try {
      final r = await CepService().buscar(_c['cep']!.text);
      if (r == null) return _msg('CEP não encontrado');
      setState(() {
        _c['rua']!.text = r['logradouro'] ?? '';
        _c['cidade']!.text = '${r['localidade']} - ${r['uf']}';
      });
    } catch (_) {
      _msg('Sem conexão para consultar o CEP');
    }
  }

  Future<void> _salvar() async {
    await _store.salvarPerfil({for (final e in _c.entries) e.key: e.value.text});
    _msg('Dados salvos com segurança no aparelho');
  }

  Widget _campo(String k, String label, {TextInputType? tipo}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(controller: _c[k], keyboardType: tipo, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Meu perfil')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(children: [
                const Text('Seus dados ficam apenas neste aparelho.'),
                const SizedBox(height: 12),
                _campo('nome', 'Nome'),
                _campo('telefone', 'Telefone', tipo: TextInputType.phone),
                Row(children: [
                  Expanded(child: _campo('cep', 'CEP', tipo: TextInputType.number)),
                  const SizedBox(width: 8),
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: FilledButton(onPressed: _buscarCep, child: const Text('Buscar'))),
                ]),
                _campo('rua', 'Endereço'),
                _campo('cidade', 'Cidade'),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _salvar, child: const Text('Salvar'))),
              ]),
            ),
          ),
        ),
      );
}