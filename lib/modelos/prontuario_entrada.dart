// lib/modelos/prontuario_entrada.dart

class ProntuarioEntrada {
  final int? id;
  final int pacienteId;
  final String titulo;
  final String descricao;
  final DateTime data;

  ProntuarioEntrada({
    this.id,
    required this.pacienteId,
    required this.titulo,
    required this.descricao,
    required this.data,
  });

  // Converte o objeto para um Map para enviar ao Supabase
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'paciente_id': pacienteId,
    };
  }

  // Cria um objeto a partir do Map vindo do Supabase
  factory ProntuarioEntrada.fromMap(Map<String, dynamic> map) {
    return ProntuarioEntrada(
      id: map['id'],
      pacienteId: map['paciente_id'],
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      // 'created_at' é a coluna de data padrão que o Supabase cria
      data: DateTime.parse(map['created_at']), 
    );
  }
}