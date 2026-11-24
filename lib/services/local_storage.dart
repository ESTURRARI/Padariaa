import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produto.dart';
import '../models/usuario.dart';

/// Dados SENSÍVEIS (sessão e endereço do cliente) -> armazenamento seguro, só no aparelho.
/// Dados PÚBLICOS (cache de produtos) e favoritos -> SharedPreferences.
class LocalStorage {
  final _secure = const FlutterSecureStorage();

  // Seguro; se a plataforma não suportar (ex.: navegador), usa o armazenamento interno.
  Future<void> _gravar(String chave, String valor) async {
    try {
      await _secure.write(key: chave, value: valor);
    } catch (_) {
      (await SharedPreferences.getInstance()).setString('fb_$chave', valor);
    }
  }

  Future<String?> _ler(String chave) async {
    try {
      final v = await _secure.read(key: chave);
      if (v != null) return v;
    } catch (_) {}
    return (await SharedPreferences.getInstance()).getString('fb_$chave');
  }

  Future<void> _apagar(String chave) async {
    try {
      await _secure.delete(key: chave);
    } catch (_) {}
    (await SharedPreferences.getInstance()).remove('fb_$chave');
  }

  // ---- sessão do usuário (token + dados)
  Future<void> salvarSessao(String token, Usuario u) =>
      _gravar('sessao', jsonEncode({'token': token, 'usuario': u.toJson()}));

  Future<Map<String, dynamic>?> lerSessao() async {
    final s = await _ler('sessao');
    return s == null ? null : Map<String, dynamic>.from(jsonDecode(s));
  }

  Future<void> sair() => _apagar('sessao');

  // ---- endereço de entrega salvo
  Future<void> salvarEndereco(Map<String, String> e) => _gravar('endereco', jsonEncode(e));

  Future<Map<String, String>> lerEndereco() async {
    final s = await _ler('endereco');
    return s == null ? {} : Map<String, String>.from(jsonDecode(s));
  }

  // ---- perfil do cliente (nome, telefone e endereço), só no aparelho
  Future<void> salvarPerfil(Map<String, String> perfil) => _gravar('perfil', jsonEncode(perfil));

  Future<Map<String, String>> lerPerfil() async {
    final s = await _ler('perfil');
    return s == null ? {} : Map<String, String>.from(jsonDecode(s));
  }

  // ---- cache local dos produtos (funciona offline)
  Future<void> salvarCache(List<Produto> lista) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('cache_produtos', jsonEncode(lista.map((e) => e.toMap()).toList()));
  }

  Future<List<Produto>> lerCache() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString('cache_produtos');
    if (s == null) return [];
    return (jsonDecode(s) as List).map((e) => Produto.fromJson(e)).toList();
  }

  // ---- favoritos
  Future<Set<int>> lerFavoritos() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList('favoritos') ?? []).map(int.parse).toSet();
  }

  Future<void> salvarFavoritos(Set<int> f) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('favoritos', f.map((e) => e.toString()).toList());
  }
}
