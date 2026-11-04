import 'package:flutter/material.dart';
import '../models/produto.dart';
import 'produto_imagem.dart';

class ProdutoCard extends StatelessWidget {
  final Produto produto;
  final bool favorito;
  final VoidCallback onTap;
  final VoidCallback onFavorito;
  const ProdutoCard({super.key, required this.produto, required this.favorito, required this.onTap, required this.onFavorito});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ProdutoImagem(produto: produto, altura: 100),
            Positioned(
              top: 2,
              right: 2,
              child: IconButton(
                tooltip: 'Favoritar',
                style: IconButton.styleFrom(backgroundColor: Colors.white70),
                onPressed: onFavorito,
                icon: Icon(favorito ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
              ),
            ),
          ]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(produto.nome, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Row(children: [
                  Text('R\$ ${produto.precoFinal.toStringAsFixed(2)}', style: TextStyle(color: cor.primary, fontSize: 16)),
                  if (produto.promocao) ...[
                    const SizedBox(width: 6),
                    const Chip(label: Text('-10%'), visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                  ],
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}