// lib/modelos/anamnese.dart

class Anamnese {
  final int? id;
  final int pacienteId;
  final DateTime? data;
  final String queixaPrincipal;
  final String historiaDoencaAtual;
  final String historicoPatologicoPregresso;
  final String usoMedicamentos;
  final String habitosVida;
  final String antecedentesFamiliares;

  Anamnese({
    this.id,
    required this.pacienteId,
    this.data,
    required this.queixaPrincipal,
    required this.historiaDoencaAtual,
    required this.historicoPatologicoPregresso,
    required this.usoMedicamentos,
    required this.habitosVida,
    required this.antecedentesFamiliares,
  });

  Map<String, dynamic> toMap() {
    return {
      'paciente_id': pacienteId,
      'queixa_principal': queixaPrincipal,
      'historia_doenca_atual': historiaDoencaAtual,
      'historico_patologico_pregresso': historicoPatologicoPregresso,
      'uso_medicamentos': usoMedicamentos,
      'habitos_vida': habitosVida,
      'antecedentes_familiares': antecedentesFamiliares,
    };
  }

  factory Anamnese.fromMap(Map<String, dynamic> map) {
    return Anamnese(
      id: map['id'],
      pacienteId: map['paciente_id'],
      data: DateTime.parse(map['created_at']),
      queixaPrincipal: map['queixa_principal'] ?? '',
      historiaDoencaAtual: map['historia_doenca_atual'] ?? '',
      historicoPatologicoPregresso: map['historico_patologico_pregresso'] ?? '',
      usoMedicamentos: map['uso_medicamentos'] ?? '',
      habitosVida: map['habitos_vida'] ?? '',
      antecedentesFamiliares: map['antecedentes_familiares'] ?? '',
    );
  }
}