import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../theme.dart';

/// Imagem do produto (foto enviada ou link). Sempre recorta no mesmo formato (cover),
/// então os cards ficam com o mesmo tamanho. Sem imagem: fundo suave com o ícone da categoria.
/// Use [altura] para altura fixa (detalhes) ou [proporcao] para largura/altura (cards).
class ProdutoImagem extends StatelessWidget {
  final Produto produto;
  final double? altura;
  final double proporcao;
  const ProdutoImagem({super.key, required this.produto, this.altura, this.proporcao = 4 / 3});

  Widget _placeholder() => Container(
        color: const Color(0xFFF1E4D3),
        child: Center(child: Icon(produto.icone, size: 44, color: caramelo)),
      );

  Widget _imagem() {
    final img = produto.imagem;
    if (img.isEmpty) return _placeholder();
    if (img.startsWith('data:')) {
      try {
        return Image.memory(
          base64Decode(img.split(',').last),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      } catch (_) {
        return _placeholder();
      }
    }
    return Image.network(
      img,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  @override
  Widget build(BuildContext context) => altura != null
      ? SizedBox(height: altura, width: double.infinity, child: _imagem())
      : AspectRatio(aspectRatio: proporcao, child: _imagem());
}
