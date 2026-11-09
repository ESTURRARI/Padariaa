import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../theme.dart';
import 'produto_imagem.dart';

class ProdutoCard extends StatelessWidget {
  final Produto produto;
  final bool favorito;
  final VoidCallback onTap;
  final VoidCallback onFavorito;
  final VoidCallback? onAdicionar; // só aparece para o cliente

  const ProdutoCard({
    super.key,
    required this.produto,
    required this.favorito,
    required this.onTap,
    required this.onFavorito,
    this.onAdicionar,
  });

  static const _rotulos = {'pao': 'PÃO', 'doce': 'DOCE', 'bebida': 'BEBIDA'};

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ProdutoImagem(produto: produto), // mesma proporção em todos os cards
            if (produto.promocao)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: amora, borderRadius: BorderRadius.circular(20)),
                  child: const Text('-10%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: 'Favoritar',
                style: IconButton.styleFrom(backgroundColor: Colors.white, visualDensity: VisualDensity.compact),
                onPressed: onFavorito,
                icon: Icon(favorito ? Icons.favorite : Icons.favorite_border, color: amora, size: 20),
              ),
            ),
          ]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_rotulos[produto.categoria] ?? '',
                    style: const TextStyle(fontSize: 11, letterSpacing: 1.3, color: caramelo, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(produto.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: espresso, height: 1.2)),
                const Spacer(),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      if (produto.promocao)
                        Text('R\$ ${produto.preco.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                      Text('R\$ ${produto.precoFinal.toStringAsFixed(2)}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cafe)),
                    ]),
                  ),
                  if (onAdicionar != null)
                    IconButton.filled(
                      tooltip: 'Adicionar ao carrinho',
                      onPressed: onAdicionar,
                      icon: const Icon(Icons.add_shopping_cart, size: 20),
                    ),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
