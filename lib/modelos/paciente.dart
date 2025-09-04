// lib/modelos/paciente.dart

class Paciente {
  final int? id;
  final DateTime? dataAbertura;
  final String nomeCompleto;
  final String dataNascimento;
  final String sexo;
  final String cpf;
  final String endereco;
  final String responsavelNome;
  final String responsavelContato;
  final String numeroProntuario;
  final String turmaAcademica;
  final String professorResponsavel;

  Paciente({
    this.id,
    this.dataAbertura,
    required this.nomeCompleto,
    required this.dataNascimento,
    required this.sexo,
    required this.cpf,
    this.endereco = '', // Valor padrão se não informado
    required this.responsavelNome,
    required this.responsavelContato,
    required this.numeroProntuario,
    required this.turmaAcademica,
    required this.professorResponsavel,
  });

 factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id'],
      // Trata o caso de dataAbertura ser null
      dataAbertura: map['created_at'] != null ? DateTime.parse(map['created_at']) : null, 
      nomeCompleto: map['nomeCompleto'] ?? '',
      dataNascimento: map['dataNascimento'] ?? '',
      sexo: map['sexo'] ?? '',
      cpf: map['cpf'] ?? '',
      endereco: map['endereco'] ?? '', // Garante que não seja null
      responsavelNome: map['responsavel_nome'] ?? '',
      responsavelContato: map['responsavel_contato'] ?? '', // Garante que não seja null
      numeroProntuario: map['numero_prontuario'] ?? '',
      turmaAcademica: map['turma_academica'] ?? '',
      professorResponsavel: map['professor_responsavel'] ?? '',
    );
  }
}