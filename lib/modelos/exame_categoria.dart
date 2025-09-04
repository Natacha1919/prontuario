import 'package:prontuario_medico/modelos/exame_tipo.dart';

class ExameCategoria {
  final int id;
  final String nome;
  final List<ExameTipo> tipos; // Para agrupar os tipos de exame

  ExameCategoria({required this.id, required this.nome, this.tipos = const []});

  factory ExameCategoria.fromMap(Map<String, dynamic> map) {
    return ExameCategoria(
      id: map['id'],
      nome: map['nome'] ?? '',
      // Os tipos serão preenchidos depois
      tipos: map.containsKey('exame_tipos')
          ? (map['exame_tipos'] as List).map((tipo) => ExameTipo.fromMap(tipo)).toList()
          : [],
    );
  }
}