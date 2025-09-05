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

  Map<String, dynamic> toMap() {
    return {
      // Ao salvar, o Supabase gerencia o ID e created_at, não precisamos enviá-los aqui
      'nomeCompleto': nomeCompleto,
      'dataNascimento': dataNascimento,
      'sexo': sexo,
      'cpf': cpf,
      'endereco': endereco,
      'responsavel_nome': responsavelNome,
      'responsavel_contato': responsavelContato,
      'numero_prontuario': numeroProntuario,
      'turma_academica': turmaAcademica,
      'professor_responsavel': professorResponsavel,
    };
  }

  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id'],
      dataAbertura: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      nomeCompleto: map['nomeCompleto'] ?? '',
      dataNascimento: map['dataNascimento'] ?? '',
      sexo: map['sexo'] ?? '',
      cpf: map['cpf'] ?? '',
      endereco: map['endereco'] ?? '',
      responsavelNome: map['responsavel_nome'] ?? '',
      responsavelContato: map['responsavel_contato'] ?? '',
      numeroProntuario: map['numero_prontuario'] ?? '',
      turmaAcademica: map['turma_academica'] ?? '',
      professorResponsavel: map['professor_responsavel'] ?? '',
    );
  }
}
