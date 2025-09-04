// lib/modelos/exame_anterior.dart

class ExameAnterior {
  final int id;
  final int pacienteId;
  final String nomeArquivo;
  final String pathStorage;
  final DateTime dataUpload;

  ExameAnterior({
    required this.id,
    required this.pacienteId,
    required this.nomeArquivo,
    required this.pathStorage,
    required this.dataUpload,
  });

  factory ExameAnterior.fromMap(Map<String, dynamic> map) {
    return ExameAnterior(
      id: map['id'],
      pacienteId: map['paciente_id'],
      nomeArquivo: map['nome_arquivo'] ?? '',
      pathStorage: map['path_storage'] ?? '',
      dataUpload: DateTime.parse(map['created_at']),
    );
  }
}