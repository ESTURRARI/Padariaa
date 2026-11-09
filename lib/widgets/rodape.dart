import 'package:flutter/material.dart';
import '../theme.dart';
import 'logo.dart';

// ✏️ Edite aqui os dados reais da loja
const _horario = 'Seg a Sáb: 7h às 19h\nDom: 8h às 13h';
const _endereco = 'Rua das Amoras, 123\nCentro';
const _contato = '(19) 99999-9999\ncontato@amorabakery.com';

class Rodape extends StatelessWidget {
  final double espacoFim; // espaço extra embaixo (para o botão flutuante do admin)
  const Rodape({super.key, this.espacoFim = 0});

  Widget _bloco(IconData icone, String titulo, String texto) => SizedBox(
        width: 210,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icone, color: caramelo, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo, style: const TextStyle(color: creme, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(texto, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
            ]),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 24),
        padding: EdgeInsets.fromLTRB(20, 24, 20, 16 + espacoFim),
        decoration: const BoxDecoration(
          color: espresso,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const AmoraLogo(tamanho: 48),
            ),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Amora Bakery', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('PADARIA & CAFÉ', style: TextStyle(color: caramelo, letterSpacing: 2, fontSize: 12)),
            ]),
          ]),
          const SizedBox(height: 20),
          Wrap(alignment: WrapAlignment.center, spacing: 32, runSpacing: 16, children: [
            _bloco(Icons.schedule, 'Horário', _horario),
            _bloco(Icons.place, 'Endereço', _endereco),
            _bloco(Icons.phone, 'Contato', _contato),
          ]),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          Text('© ${DateTime.now().year} Amora Bakery • Feito com carinho e amora',
              textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ]),
      );
}
