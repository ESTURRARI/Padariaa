import 'produto.dart';

/// Item dentro do carrinho (antes de finalizar).
class ItemCarrinho {
  final Produto produto;
  int qtd;
  ItemCarrinho(this.produto, this.qtd);
  double get subtotal => produto.precoFinal * qtd;
}

class ItemPedido {
  final String nome;
  final int qtd;
  final double preco;
  ItemPedido({required this.nome, required this.qtd, required this.preco});
  factory ItemPedido.fromJson(Map<String, dynamic> j) =>
      ItemPedido(nome: j['nome'], qtd: j['qtd'], preco: (j['preco_unit'] as num).toDouble());
}

class Pedido {
  final int id;
  final String tipo; // 'entrega' | 'retirada'
  final String endereco;
  final String status;
  final String criadoEm;
  final String obs;
  final double total;
  final String clienteNome;
  final String clienteEmail;
  final String clienteTelefone;
  final List<ItemPedido> itens;

  Pedido({
    required this.id,
    required this.tipo,
    required this.endereco,
    required this.status,
    required this.criadoEm,
    required this.obs,
    required this.total,
    required this.clienteNome,
    required this.clienteEmail,
    required this.clienteTelefone,
    required this.itens,
  });

  bool get entrega => tipo == 'entrega';

  factory Pedido.fromJson(Map<String, dynamic> j) {
    final c = Map<String, dynamic>.from(j['cliente'] ?? {});
    return Pedido(
      id: j['id'],
      tipo: j['tipo'],
      endereco: j['endereco'] ?? '',
      status: j['status'],
      criadoEm: j['criado_em'],
      obs: j['obs'] ?? '',
      total: (j['total'] as num).toDouble(),
      clienteNome: c['nome'] ?? '',
      clienteEmail: c['email'] ?? '',
      clienteTelefone: c['telefone'] ?? '',
      itens: [for (final i in (j['itens'] as List)) ItemPedido.fromJson(Map<String, dynamic>.from(i))],
    );
  }
}
