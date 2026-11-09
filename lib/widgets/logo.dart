import 'package:flutter/material.dart';
import '../theme.dart';

/// Logo da Amora Bakery (assets/logo.png). Se o arquivo faltar, mostra um ícone.
class AmoraLogo extends StatelessWidget {
  final double tamanho;
  const AmoraLogo({super.key, this.tamanho = 32});

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/logo.png',
        height: tamanho,
        width: tamanho,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(Icons.bubble_chart, size: tamanho, color: amora),
      );
}
