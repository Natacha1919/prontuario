// lib/modelos/paciente.dart

class Paciente {
  // A ID agora é um inteiro e pode ser nula (para novos pacientes)
  final int? id; 
  final String nomeCompleto;
  final String cpf;
  final String dataNascimento;

  Paciente({
    this.id, // Não é mais 'required'
    required this.nomeCompleto,
    required this.cpf,
    required this.dataNascimento,
  });

  // Converte um objeto Paciente para um Map para enviar à API.
  // O Supabase ignora a ID na inserção, o que é perfeito.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // Inclui a ID apenas se ela existir
      'nomeCompleto': nomeCompleto,
      'cpf': cpf,
      'dataNascimento': dataNascimento,
    };
  }

  // Cria um objeto Paciente a partir de um Map (JSON) recebido da API.
  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id'], // O Supabase retorna a ID como int
      nomeCompleto: map['nomeCompleto'] ?? '',
      cpf: map['cpf'] ?? '',
      dataNascimento: map['dataNascimento'] ?? '',
    );
  }
}