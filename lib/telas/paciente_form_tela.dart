// lib/telas/paciente_form_tela.dart

import 'package:flutter/material.dart';
import 'package:prontuario_medico/modelos/paciente.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PacienteFormTela extends StatefulWidget {
  final Paciente? paciente;
  const PacienteFormTela({super.key, this.paciente});
  @override
  State<PacienteFormTela> createState() => _PacienteFormTelaState();
}

class _PacienteFormTelaState extends State<PacienteFormTela> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  late TextEditingController _nomeController;
  late TextEditingController _dataNascimentoController;
  late TextEditingController _sexoController;
  late TextEditingController _cpfController;
  late TextEditingController _enderecoController;
  late TextEditingController _responsavelNomeController;
  late TextEditingController _responsavelContatoController;
  late TextEditingController _turmaController;
  late TextEditingController _professorController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.paciente?.nomeCompleto ?? '');
    _dataNascimentoController = TextEditingController(text: widget.paciente?.dataNascimento ?? '');
    _sexoController = TextEditingController(text: widget.paciente?.sexo ?? '');
    _cpfController = TextEditingController(text: widget.paciente?.cpf ?? '');
    _enderecoController = TextEditingController(text: widget.paciente?.endereco ?? '');
    _responsavelNomeController = TextEditingController(text: widget.paciente?.responsavelNome ?? '');
    _responsavelContatoController = TextEditingController(text: widget.paciente?.responsavelContato ?? '');
    _turmaController = TextEditingController(text: widget.paciente?.turmaAcademica ?? '');
    _professorController = TextEditingController(text: widget.paciente?.professorResponsavel ?? '');
  }

  void _salvarFormulario() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final numeroProntuario = widget.paciente?.numeroProntuario ?? DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      
      final pacienteData = Paciente(
        id: widget.paciente?.id,
        nomeCompleto: _nomeController.text.trim(),
        dataNascimento: _dataNascimentoController.text,
        sexo: _sexoController.text,
        cpf: _cpfController.text,
        endereco: _enderecoController.text,
        responsavelNome: _responsavelNomeController.text,
        responsavelContato: _responsavelContatoController.text,
        numeroProntuario: numeroProntuario,
        turmaAcademica: _turmaController.text,
        professorResponsavel: _professorController.text,
      );

      try {
        if (widget.paciente == null) {
          await supabase.from('pacientes').insert(pacienteData.toMap());
          final userId = supabase.auth.currentUser?.id;
          if (userId != null) {
            await supabase.from('historico_atividades').insert({
              'tipo_acao': 'Paciente Criado',
              'descricao': 'Novo paciente "${pacienteData.nomeCompleto}" cadastrado.',
              'usuario_id': userId,
              'paciente_id': widget.paciente?.id,
              'paciente_nome': pacienteData.nomeCompleto,
            });
          }
        } else {
          await supabase.from('pacientes').update(pacienteData.toMap()).eq('id', pacienteData.id!);
          await supabase.from('historico_atividades').insert({
            'tipo_acao': 'Prontuário Atualizado',
            'descricao': 'Prontuário de "${pacienteData.nomeCompleto}" atualizado.',
            'usuario_id': supabase.auth.currentUser?.id,
            'paciente_id': pacienteData.id,
            'paciente_nome': pacienteData.nomeCompleto,
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paciente salvo com sucesso!'), backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        print('Erro ao salvar paciente: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar paciente: $e'), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF133B4E),
        elevation: 0,
        title: const Text(
          'Novo Paciente',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Define a largura máxima para o formulário
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Insira as informações do novo paciente',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionCard(
                      title: 'Informações Pessoais',
                      icon: Icons.person_outline,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildTextField(controller: _nomeController, label: 'Nome Completo *')),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(controller: _dataNascimentoController, label: 'Data de Nascimento *')),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(controller: _sexoController, label: 'Sexo *')),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(controller: _cpfController, label: 'Contato (CPF ou Telefone) *')),
                          ],
                        ),
                        _buildTextField(controller: _enderecoController, label: 'Endereço'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSectionCard(
                      title: 'Contato de Emergência',
                      icon: Icons.phone_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildTextField(controller: _responsavelNomeController, label: 'Nome do Responsável')),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(controller: _responsavelContatoController, label: 'Contato do Responsável')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSectionCard(
                      title: 'Dados Acadêmicos',
                      icon: Icons.school_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildTextField(controller: _turmaController, label: 'Turma Acadêmica *')),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField(controller: _professorController, label: 'Professor Responsável *')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _salvarFormulario,
                              icon: const Icon(Icons.add_outlined, size: 20, color: Colors.white),
                              label: const Text('Adicionar Paciente', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF133B4E),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: label.endsWith('*') ? (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null : null,
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF133B4E), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF133B4E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
