import 'package:flutter/foundation.dart';
import '../models/pedido.dart';
import '../models/produto.dart';

/// Carrinho de compras (único no app). Avisa as telas quando muda.
class Carrinho extends ChangeNotifier {
  static final Carrinho instancia = Carrinho._();
  Carrinho._();

  final Map<int, ItemCarrinho> _itens = {};

  List<ItemCarrinho> get itens => _itens.values.toList();
  int get quantidade => _itens.values.fold(0, (s, i) => s + i.qtd);
  double get total => _itens.values.fold(0.0, (s, i) => s + i.subtotal);

  void adicionar(Produto p) {
    _itens.update(p.id!, (i) {
      i.qtd++;
      return i;
    }, ifAbsent: () => ItemCarrinho(p, 1));
    notifyListeners();
  }

  void remover(Produto p) {
    final i = _itens[p.id];
    if (i == null) return;
    i.qtd--;
    if (i.qtd <= 0) _itens.remove(p.id);
    notifyListeners();
  }

  void limpar() {
    _itens.clear();
    notifyListeners();
  }
}
