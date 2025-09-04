// lib/modelos/exame_tipo.dart

class ExameTipo {
  final int id;
  final String nome;
  final int categoriaId;
  final String valorReferencia; // <-- NOVO CAMPO

  ExameTipo({
    required this.id,
    required this.nome,
    required this.categoriaId,
    required this.valorReferencia, // <-- NOVO CAMPO
  });

  factory ExameTipo.fromMap(Map<String, dynamic> map) {
    return ExameTipo(
      id: map['id'],
      nome: map['nome'] ?? '',
      categoriaId: map['categoria_id'],
      valorReferencia: map['valor_referencia'] ?? '', // <-- NOVO CAMPO
    );
  }
}