// lib/modelos/exame_resultado.dart

class ExameResultado {
  final int? id; // A ID pode ser nula se estivermos criando
  final int solicitacaoId;
  final DateTime dataInsercao;
  final String observacoes;
  final Map<String, dynamic> resultados;

  ExameResultado({
    this.id,
    required this.solicitacaoId,
    required this.dataInsercao,
    required this.observacoes,
    required this.resultados,
  });

  // Método para enviar os dados para o Supabase
  Map<String, dynamic> toMap() {
    return {
      'solicitacao_id': solicitacaoId,
      'observacoes': observacoes,
      'resultados': resultados,
    };
  }

  factory ExameResultado.fromMap(Map<String, dynamic> map) {
    return ExameResultado(
      id: map['id'],
      solicitacaoId: map['solicitacao_id'],
      dataInsercao: DateTime.parse(map['created_at']),
      observacoes: map['observacoes'] ?? '',
      resultados: map['resultados'] ?? {},
    );
  }
}