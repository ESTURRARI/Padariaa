/// Classe base abstrata. Subclasses: Cliente (compra) e Administrador (gerencia).
abstract class Usuario {
  final int id;
  final String nome;
  final String email;
  final String telefone;

  Usuario({required this.id, required this.nome, required this.email, this.telefone = ''});

  String get papel;
  bool get admin => false;

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome, 'email': email, 'telefone': telefone, 'papel': papel};

  factory Usuario.fromJson(Map<String, dynamic> j) {
    final id = j['id'] as int;
    final nome = j['nome'] as String;
    final email = j['email'] as String;
    final tel = (j['telefone'] ?? '') as String;
    return j['papel'] == 'admin'
        ? Administrador(id: id, nome: nome, email: email, telefone: tel)
        : Cliente(id: id, nome: nome, email: email, telefone: tel);
  }
}

class Cliente extends Usuario {
  Cliente({required super.id, required super.nome, required super.email, super.telefone});
  @override
  String get papel => 'cliente';
}

class Administrador extends Usuario {
  Administrador({required super.id, required super.nome, required super.email, super.telefone});
  @override
  String get papel => 'admin';
  @override
  bool get admin => true;
}
