// lib/modelos/devolutiva.dart

class Devolutiva {
  final int? id;
  final int pacienteId;
  final DateTime data;
  final String relatorioPaciente;
  final String interpretacaoBasica;
  final String orientacaoEncaminhamento;
  final String assinaturaAluno;
  final String assinaturaProfessor;

  Devolutiva({
    this.id,
    required this.pacienteId,
    required this.data,
    required this.relatorioPaciente,
    required this.interpretacaoBasica,
    required this.orientacaoEncaminhamento,
    required this.assinaturaAluno,
    required this.assinaturaProfessor,
  });

  Map<String, dynamic> toMap() {
    return {
      'paciente_id': pacienteId,
      'relatorio_paciente': relatorioPaciente,
      'interpretacao_basica': interpretacaoBasica,
      'orientacao_encaminhamento': orientacaoEncaminhamento,
      'assinatura_aluno': assinaturaAluno,
      'assinatura_professor': assinaturaProfessor,
    };
  }

  factory Devolutiva.fromMap(Map<String, dynamic> map) {
    return Devolutiva(
      id: map['id'],
      pacienteId: map['paciente_id'],
      data: DateTime.parse(map['created_at']),
      relatorioPaciente: map['relatorio_paciente'] ?? '',
      interpretacaoBasica: map['interpretacao_basica'] ?? '',
      orientacaoEncaminhamento: map['orientacao_encaminhamento'] ?? '',
      assinaturaAluno: map['assinatura_aluno'] ?? '',
      assinaturaProfessor: map['assinatura_professor'] ?? '',
    );
  }
}