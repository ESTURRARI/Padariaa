import 'package:flutter/material.dart';
import '../models/produto.dart';

/// Mostra a imagem do produto; se não houver (ou falhar), mostra o ícone.
class ProdutoImagem extends StatelessWidget {
  final Produto produto;
  final double altura;
  const ProdutoImagem({super.key, required this.produto, required this.altura});

  @override
  Widget build(BuildContext context) {
    final icone = SizedBox(
      height: altura,
      child: Center(child: Icon(produto.icone, size: altura * 0.5, color: Theme.of(context).colorScheme.primary)),
    );
    if (produto.imagem.isEmpty) return icone;
    return Image.network(
      produto.imagem,
      height: altura,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => icone,
    );
  }
}