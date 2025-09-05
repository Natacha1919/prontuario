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
    // Inicializa os controladores com os dados existentes (se estiver editando)
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
      setState(() => _isLoading = true); // Mostra indicador de carregamento

      // Gera o número do prontuário apenas se for um novo paciente
      final numeroProntuario = widget.paciente?.numeroProntuario ?? 
          DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      
      final pacienteData = Paciente(
        id: widget.paciente?.id,
        nomeCompleto: _nomeController.text,
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
          // Salva um novo paciente
          await supabase.from('pacientes').insert(pacienteData.toMap());
          // Registrar atividade de criação de paciente
          await supabase.from('historico_atividades').insert({
            'tipo_acao': 'Paciente Criado',
            'descricao': 'Novo paciente "${pacienteData.nomeCompleto}" cadastrado.',
            'usuario_id': supabase.auth.currentUser?.id,
            'paciente_id': widget.paciente?.id, // Paciente ID será nulo aqui, o Supabase vai atribuir um novo.
            'paciente_nome': pacienteData.nomeCompleto,
          });
        } else {
          // Atualiza um paciente existente
          await supabase.from('pacientes').update(pacienteData.toMap()).eq('id', pacienteData.id!);
          // Registrar atividade de atualização de prontuário
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
          Navigator.of(context).pop(true); // Retorna 'true' para indicar que salvou
        }
      } catch (e) {
        print('Erro ao salvar paciente: $e'); // Log do erro
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar paciente: $e'), backgroundColor: Colors.red));
        }
      } finally {
        // Garante que o loading seja desativado mesmo em caso de erro
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataNascimentoController.dispose();
    _sexoController.dispose();
    _cpfController.dispose();
    _enderecoController.dispose();
    _responsavelNomeController.dispose();
    _responsavelContatoController.dispose();
    _turmaController.dispose();
    _professorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.paciente == null ? 'Novo Paciente' : 'Editar Paciente'),
            Text(
              widget.paciente == null ? 'Cadastrar novo paciente no sistema' : 'Atualizar dados do paciente',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PacienteFormTela(paciente: widget.paciente)))
                    .then((_) => setState(() {})); // Atualiza a lista se a navegação voltar
              },
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Editar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionCard(
              title: 'Informações Pessoais',
              icon: Icons.person_outline,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTextField(controller: _nomeController, label: 'Nome Completo *')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controller: _cpfController, label: 'Contato (CPF ou Telefone) *')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTextField(controller: _dataNascimentoController, label: 'Data de Nascimento *', hint: 'dd/mm/aaaa')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controller: _sexoController, label: 'Sexo *')),
                  ],
                ),
                 const SizedBox(height: 16),
                _buildTextField(controller: _enderecoController, label: 'Endereço Completo'),
                const SizedBox(height: 16), // Adicionado espaço
                _buildTextField(controller: _responsavelNomeController, label: 'Nome do Responsável'),
                const SizedBox(height: 16), // Adicionado espaço
                _buildTextField(controller: _responsavelContatoController, label: 'Contato do Responsável'),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Dados Administrativos',
              icon: Icons.business_center_outlined,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTextField(controller: _turmaController, label: 'Turma Acadêmica *')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controller: _professorController, label: 'Professor Responsável *')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          filled: true,
          fillColor: Colors.white,
        ),
        // Validação condicional para campos obrigatórios
        validator: label.endsWith('*') ? (v) => v!.trim().isEmpty ? 'Campo obrigatório' : null : null,
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(height: 24),
            Column( // Usei Column em vez de GridView para simplificar e garantir que os campos se encaixem
              children: children.map((child) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: child,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')), // Retorna 'false' se cancelar
          const SizedBox(width: 16),
          _isLoading
              ? const CircularProgressIndicator() // Mostra o indicador enquanto salva
              : ElevatedButton.icon(
                  onPressed: _salvarFormulario,
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text('Salvar Paciente'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                ),
        ],
      ),
    );
  }
}
