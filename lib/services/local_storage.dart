import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produto.dart';

/// Dados SENSÍVEIS (perfil do cliente) -> armazenamento seguro, só no aparelho.
/// Dados PÚBLICOS (cache de produtos) e favoritos -> SharedPreferences.
class LocalStorage {
  final _secure = const FlutterSecureStorage();

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

  // ---- favoritos (modificação persistida no armazenamento interno)
  Future<Set<int>> lerFavoritos() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList('favoritos') ?? []).map(int.parse).toSet();
  }

  Future<void> salvarFavoritos(Set<int> f) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('favoritos', f.map((e) => e.toString()).toList());
  }

  // ---- perfil sensível (armazenamento seguro; se a plataforma não suportar, usa o interno)
  Future<void> salvarPerfil(Map<String, String> perfil) async {
    final s = jsonEncode(perfil);
    try {
      await _secure.write(key: 'perfil', value: s);
    } catch (_) {
      (await SharedPreferences.getInstance()).setString('perfil_fallback', s);
    }
  }

  Future<Map<String, String>> lerPerfil() async {
    String? s;
    try {
      s = await _secure.read(key: 'perfil');
    } catch (_) {}
    s ??= (await SharedPreferences.getInstance()).getString('perfil_fallback');
    return s == null ? {} : Map<String, String>.from(jsonDecode(s));
  }
}