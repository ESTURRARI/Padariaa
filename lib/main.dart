import 'package:flutter/material.dart';
import 'models/usuario.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/local_storage.dart';
import 'theme.dart';

void main() => runApp(const AmoraApp());

class AmoraApp extends StatelessWidget {
  const AmoraApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Amora Bakery',
        debugShowCheckedModeBanner: false,
        theme: temaAmora(),
        home: const _Inicio(),
      );
}

/// Se já existe sessão salva no aparelho, entra direto; senão mostra o login.
class _Inicio extends StatelessWidget {
  const _Inicio();

  Future<Usuario?> _restaurar() async {
    final s = await LocalStorage().lerSessao();
    if (s == null) return null;
    ApiService.token = s['token'] as String;
    return Usuario.fromJson(Map<String, dynamic>.from(s['usuario']));
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Usuario?>(
        future: _restaurar(),
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snap.data == null ? const LoginScreen() : HomeScreen(usuario: snap.data!);
        },
      );
}
