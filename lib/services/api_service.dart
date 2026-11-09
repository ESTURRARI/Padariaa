import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pedido.dart';
import '../models/produto.dart';

class ApiErro implements Exception {
  final String mensagem;
  ApiErro(this.mensagem);
  @override
  String toString() => mensagem;
}

/// Consome a API REST própria (GET, POST, PUT, DELETE) enviando o token do usuário logado.
class ApiService {
  static String? token;

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

  Future<dynamic> _req(String metodo, String caminho, {Object? corpo, List<int> ok = const [200]}) async {
    final b = await baseUrl();
    final uri = Uri.parse('$b$caminho');
    final headers = {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
    final body = corpo == null ? null : jsonEncode(corpo);
    http.Response r;
    try {
      final envio = switch (metodo) {
        'POST' => http.post(uri, headers: headers, body: body),
        'PUT' => http.put(uri, headers: headers, body: body),
        'DELETE' => http.delete(uri, headers: headers),
        _ => http.get(uri, headers: headers),
      };
      r = await envio.timeout(const Duration(seconds: 8));
    } catch (_) {
      throw ApiErro('Não foi possível conectar ao servidor');
    }
    final txt = utf8.decode(r.bodyBytes);
    dynamic dados;
    try {
      dados = txt.isEmpty ? null : jsonDecode(txt);
    } catch (_) {}
    if (!ok.contains(r.statusCode)) {
      throw ApiErro(dados is Map && dados['erro'] != null ? '${dados['erro']}' : 'Erro ${r.statusCode}');
    }
    return dados;
  }

  // ---- autenticação
  Future<Map<String, dynamic>> login(String email, String senha) async =>
      Map<String, dynamic>.from(await _req('POST', '/auth/login', corpo: {'email': email, 'senha': senha}));

  Future<Map<String, dynamic>> registrar(String nome, String telefone, String email, String senha) async =>
      Map<String, dynamic>.from(await _req('POST', '/auth/registro',
          corpo: {'nome': nome, 'telefone': telefone, 'email': email, 'senha': senha}, ok: [201]));

  // ---- produtos
  Future<List<Produto>> listar() async =>
      (await _req('GET', '/produtos') as List).map((e) => Produto.fromJson(e)).toList(); // GET

  Future<void> criar(Produto p) => _req('POST', '/produtos', corpo: p.toJson(), ok: [201]); // POST

  Future<void> atualizar(Produto p) => _req('PUT', '/produtos/${p.id}', corpo: p.toJson()); // PUT

  Future<void> excluir(int id) => _req('DELETE', '/produtos/$id'); // DELETE

  // ---- pedidos
  Future<void> criarPedido({
    required String tipo,
    required String endereco,
    required String obs,
    required List<ItemCarrinho> itens,
  }) =>
      _req('POST', '/pedidos', ok: [201], corpo: {
        'tipo': tipo,
        'endereco': endereco,
        'obs': obs,
        'itens': [for (final i in itens) {'produto_id': i.produto.id, 'qtd': i.qtd}],
      });

  Future<List<Pedido>> listarPedidos() async =>
      (await _req('GET', '/pedidos') as List).map((e) => Pedido.fromJson(Map<String, dynamic>.from(e))).toList();

  Future<void> atualizarStatus(int id, String status) => _req('PUT', '/pedidos/$id/status', corpo: {'status': status});
}
