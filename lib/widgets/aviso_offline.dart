import 'package:flutter/material.dart';

class AvisoOffline extends StatelessWidget {
  const AvisoOffline({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: Colors.orange.shade100,
        padding: const EdgeInsets.all(8),
        child: const Text('Sem conexão com o servidor: mostrando dados salvos no aparelho.', textAlign: TextAlign.center),
      );
}
