import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';
import '../theme.dart';
import '../widgets/logo.dart';
import '../widgets/servidor.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nome = TextEditingController();
  final _telefone = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _registro = false, _carregando = false, _ocultar = true;

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _enviar() async {
    final email = _email.text.trim();
    if (!email.contains('@') || _senha.text.length < 6) return _msg('Informe um e-mail válido e senha com 6+ caracteres');
    if (_registro && _nome.text.trim().length < 2) return _msg('Informe seu nome');
    setState(() => _carregando = true);
    try {
      final api = ApiService();
      final r = _registro
          ? await api.registrar(_nome.text.trim(), _telefone.text.trim(), email, _senha.text)
          : await api.login(email, _senha.text);
      final token = r['token'] as String;
      final u = Usuario.fromJson(Map<String, dynamic>.from(r['usuario']));
      ApiService.token = token;
      await LocalStorage().salvarSessao(token, u); // sessão guardada só no aparelho
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(usuario: u)));
    } catch (e) {
      _msg('$e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Widget _campo(TextEditingController c, String label, IconData icone, {bool senha = false, TextInputType? tipo}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          keyboardType: tipo,
          obscureText: senha && _ocultar,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icone),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: senha
                ? IconButton(icon: Icon(_ocultar ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _ocultar = !_ocultar))
                : null,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: espresso,
          actions: [
            IconButton(tooltip: 'Servidor', icon: const Icon(Icons.settings_ethernet), onPressed: () => editarServidor(context)),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(children: [
                const AmoraLogo(tamanho: 220),
                const SizedBox(height: 28),
                if (_registro) ...[
                  _campo(_nome, 'Nome', Icons.person),
                  _campo(_telefone, 'Telefone', Icons.phone, tipo: TextInputType.phone),
                ],
                _campo(_email, 'E-mail', Icons.email, tipo: TextInputType.emailAddress),
                _campo(_senha, 'Senha', Icons.lock, senha: true),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _carregando ? null : _enviar,
                    child: _carregando
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_registro ? 'Criar conta' : 'Entrar'),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _registro = !_registro),
                  child: Text(_registro ? 'Já tenho conta' : 'Criar conta de cliente'),
                ),
              ]),
            ),
          ),
        ),
      );
}
