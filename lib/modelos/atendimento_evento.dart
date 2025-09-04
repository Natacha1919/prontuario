// lib/modelos/atendimento_evento.dart

class AtendimentoEvento {
  final int? id;
  final int pacienteId;
  final DateTime data;
  final String tipoEvento;
  final String descricao;
  final String responsavel;

  AtendimentoEvento({
    this.id,
    required this.pacienteId,
    required this.data,
    required this.tipoEvento,
    required this.descricao,
    required this.responsavel,
  });

  Map<String, dynamic> toMap() {
    return {
      'paciente_id': pacienteId,
      'tipo_evento': tipoEvento,
      'descricao': descricao,
      'responsavel': responsavel,
    };
  }

  factory AtendimentoEvento.fromMap(Map<String, dynamic> map) {
    return AtendimentoEvento(
      id: map['id'],
      pacienteId: map['paciente_id'],
      data: DateTime.parse(map['created_at']),
      tipoEvento: map['tipo_evento'] ?? '',
      descricao: map['descricao'] ?? '',
      responsavel: map['responsavel'] ?? '',
    );
  }
}