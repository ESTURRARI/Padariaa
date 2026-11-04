import 'package:flutter/material.dart';

/// Classe base abstrata. Subclasses: Pao, Doce, Bebida.
abstract class Produto {
  final int? id;
  final String nome;
  final double preco;
  final String descricao;
  final bool promocao;
  final String imagem; // link da imagem (opcional)

  Produto({this.id, required this.nome, required this.preco, this.descricao = '', this.promocao = false, this.imagem = ''});

  String get categoria; // 'pao' | 'doce' | 'bebida'
  String get detalhe; // polimorfismo: cada subclasse descreve de um jeito
  IconData get icone;

  double get precoFinal => promocao ? preco * 0.9 : preco; // 10% off em promoção

  /// Corpo enviado à API (sem id).
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'categoria': categoria,
        'preco': preco,
        'descricao': descricao,
        'promocao': promocao,
        'imagem': imagem,
      };

  /// Usado no cache local (com id).
  Map<String, dynamic> toMap() => {'id': id, ...toJson()};

  /// Fábrica: decide a subclasse conforme a categoria.
  factory Produto.fromJson(Map<String, dynamic> j) {
    final id = j['id'] as int?;
    final nome = j['nome'] as String;
    final preco = (j['preco'] as num).toDouble();
    final desc = (j['descricao'] ?? '') as String;
    final promo = (j['promocao'] ?? false) as bool;
    final img = (j['imagem'] ?? '') as String;
    switch (j['categoria']) {
      case 'doce':
        return Doce(id: id, nome: nome, preco: preco, descricao: desc, promocao: promo, imagem: img);
      case 'bebida':
        return Bebida(id: id, nome: nome, preco: preco, descricao: desc, promocao: promo, imagem: img);
      default:
        return Pao(id: id, nome: nome, preco: preco, descricao: desc, promocao: promo, imagem: img);
    }
  }
}

class Pao extends Produto {
  Pao({super.id, required super.nome, required super.preco, super.descricao, super.promocao, super.imagem});
  @override
  String get categoria => 'pao';
  @override
  String get detalhe => 'Panificação fresca • $descricao';
  @override
  IconData get icone => Icons.bakery_dining;
}

class Doce extends Produto {
  Doce({super.id, required super.nome, required super.preco, super.descricao, super.promocao, super.imagem});
  @override
  String get categoria => 'doce';
  @override
  String get detalhe => 'Confeitaria • $descricao';
  @override
  IconData get icone => Icons.cake;
}

class Bebida extends Produto {
  Bebida({super.id, required super.nome, required super.preco, super.descricao, super.promocao, super.imagem});
  @override
  String get categoria => 'bebida';
  @override
  String get detalhe => 'Bebida • $descricao';
  @override
  IconData get icone => Icons.local_cafe;
}