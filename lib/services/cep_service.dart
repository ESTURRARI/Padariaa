import 'dart:convert';
import 'package:http/http.dart' as http;

/// 2ª API (pública): ViaCEP, para preencher o endereço de entrega.
class CepService {
  Future<Map<String, dynamic>?> buscar(String cep) async {
    final c = cep.replaceAll(RegExp(r'\D'), '');
    if (c.length != 8) return null;
    final r = await http.get(Uri.parse('https://viacep.com.br/ws/$c/json/'));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    return j['erro'] == true ? null : j;
  }
}