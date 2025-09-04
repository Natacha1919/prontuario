// lib/modelos/exame_solicitacao.dart

class ExameSolicitacao {
  final int id;
  final int pacienteId;
  final DateTime dataSolicitacao;
  final String justificativaClinica;
  final List<int> examesSolicitadosIds; // Lista de IDs dos tipos de exame

  ExameSolicitacao({
    required this.id,
    required this.pacienteId,
    required this.dataSolicitacao,
    required this.justificativaClinica,
    required this.examesSolicitadosIds,
  });

  factory ExameSolicitacao.fromMap(Map<String, dynamic> map) {
    // O Supabase retorna o JSONB como uma lista de dynamic, então precisamos converter
    final idsFromDb = map['exames_solicitados'] as List;
    final ids = idsFromDb.map((id) => id as int).toList();

    return ExameSolicitacao(
      id: map['id'],
      pacienteId: map['paciente_id'],
      dataSolicitacao: DateTime.parse(map['created_at']),
      justificativaClinica: map['justificativa_clinica'] ?? '',
      examesSolicitadosIds: ids,
    );
  }
}