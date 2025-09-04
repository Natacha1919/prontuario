// lib/modelos/atividade_recente.dart

class AtividadeRecente {
  final int id;
  final DateTime data;
  final String tipoAcao;
  final String descricao;
  final String? usuarioId; // ID do usuário que realizou a ação
  final int? pacienteId; // ID do paciente relacionado, se houver
  final String? pacienteNome; // Nome do paciente para exibição rápida

  AtividadeRecente({
    required this.id,
    required this.data,
    required this.tipoAcao,
    required this.descricao,
    this.usuarioId,
    this.pacienteId,
    this.pacienteNome,
  });

  factory AtividadeRecente.fromMap(Map<String, dynamic> map) {
    return AtividadeRecente(
      id: map['id'],
      data: DateTime.parse(map['created_at']),
      tipoAcao: map['tipo_acao'] ?? '',
      descricao: map['descricao'] ?? '',
      usuarioId: map['usuario_id'],
      pacienteId: map['paciente_id'],
      pacienteNome: map['paciente_nome'],
    );
  }
}