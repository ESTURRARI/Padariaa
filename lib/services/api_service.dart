import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produto.dart';

/// Consome a API REST própria (GET, POST, PUT, DELETE).
/// O endereço do servidor se ajusta sozinho (navegador/PC: localhost;
/// emulador Android: 10.0.2.2) e pode ser trocado dentro do app.
class ApiService {
  static const _h = {'Content-Type': 'application/json'};

  static Future<String> baseUrl() async {
    final p = await SharedPreferences.getInstance();
    final salvo = p.getString('api_url');
    if (salvo != null && salvo.isNotEmpty) return salvo;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  static Future<void> salvarUrl(String url) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('api_url', url.endsWith('/') ? url.substring(0, url.length - 1) : url);
  }

  Future<List<Produto>> listar() async {
    final b = await baseUrl();
    final r = await http.get(Uri.parse('$b/produtos')).timeout(const Duration(seconds: 6)); // GET
    if (r.statusCode != 200) throw Exception('Erro ${r.statusCode}');
    return (jsonDecode(utf8.decode(r.bodyBytes)) as List).map((e) => Produto.fromJson(e)).toList();
  }

  Future<void> criar(Produto p) async {
    final b = await baseUrl();
    final r = await http.post(Uri.parse('$b/produtos'), headers: _h, body: jsonEncode(p.toJson())); // POST
    if (r.statusCode != 201) throw Exception('Erro ao criar (${r.statusCode})');
  }

  Future<void> atualizar(Produto p) async {
    final b = await baseUrl();
    final r = await http.put(Uri.parse('$b/produtos/${p.id}'), headers: _h, body: jsonEncode(p.toJson())); // PUT
    if (r.statusCode != 200) throw Exception('Erro ao atualizar (${r.statusCode})');
  }

  Future<void> excluir(int id) async {
    final b = await baseUrl();
    final r = await http.delete(Uri.parse('$b/produtos/$id')); // DELETE
    if (r.statusCode != 200) throw Exception('Erro ao excluir (${r.statusCode})');
  }
}