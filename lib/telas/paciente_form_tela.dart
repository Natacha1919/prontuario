// lib/telas/paciente_form_tela.dart

import 'package:flutter/material.dart';
import 'package:prontuario_medico/modelos/paciente.dart';
import 'package:intl/intl.dart';
import 'package:prontuario_medico/telas/tela_principal.dart' as tela_principal;

class PacienteFormTela extends StatefulWidget {
  final Paciente? paciente;
  const PacienteFormTela({super.key, this.paciente});

  @override
  State<PacienteFormTela> createState() => _PacienteFormTelaState();
}

class _PacienteFormTelaState extends State<PacienteFormTela> {
  final _formKey = GlobalKey<FormState>();

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
    _nomeController = TextEditingController(text: widget.paciente?.nomeCompleto);
    _dataNascimentoController = TextEditingController(text: widget.paciente?.dataNascimento);
    _sexoController = TextEditingController(text: widget.paciente?.sexo);
    _cpfController = TextEditingController(text: widget.paciente?.cpf);
    _enderecoController = TextEditingController(text: widget.paciente?.endereco);
    _responsavelNomeController = TextEditingController(text: widget.paciente?.responsavelNome);
    _responsavelContatoController = TextEditingController(text: widget.paciente?.responsavelContato);
    _turmaController = TextEditingController(text: widget.paciente?.turmaAcademica);
    _professorController = TextEditingController(text: widget.paciente?.professorResponsavel);
  }

  void _salvarFormulario() {
    if (_formKey.currentState!.validate()) {
      final numeroProntuario = widget.paciente?.numeroProntuario ?? DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      final pacienteProcessado = Paciente(
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
      Navigator.of(context).pop(pacienteProcessado);
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
    final bool isEditing = widget.paciente != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: tela_principal.corPrimaria,
        foregroundColor: Colors.white,
        title: Text(isEditing ? 'Editar Paciente' : 'Novo Paciente'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEditing ? 'Atualizar informações de ${widget.paciente!.nomeCompleto}' : 'Insira as informações do novo paciente',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),

                  // Seção de Informações Pessoais - Ícone azul
                  _buildSectionCard(
                    context,
                    title: 'Informações Pessoais',
                    icon: Icons.person_outline,
                    iconColor: Colors.blue,
                    children: [
                      _buildTwoColumnLayout([
                        _buildTextField(context, controller: _nomeController, label: 'Nome Completo', isRequired: true),
                        _buildTextField(context, controller: _dataNascimentoController, label: 'Data de Nascimento', isRequired: true),
                      ]),
                      const SizedBox(height: 16),
                      _buildTwoColumnLayout([
                        _buildTextField(context, controller: _sexoController, label: 'Sexo', isRequired: true),
                        _buildTextField(context, controller: _cpfController, label: 'Contato (CPF ou Telefone)', isRequired: true),
                      ]),
                      const SizedBox(height: 16),
                      _buildTextField(context, controller: _enderecoController, label: 'Endereço'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Seção de Contato de Emergência (Responsável) - Ícone vermelho
                  _buildSectionCard(
                    context,
                    title: 'Contato de Emergência',
                    icon: Icons.phone_outlined,
                    iconColor: Colors.red,
                    children: [
                      _buildTwoColumnLayout([
                        _buildTextField(context, controller: _responsavelNomeController, label: 'Nome do Responsável'),
                        _buildTextField(context, controller: _responsavelContatoController, label: 'Contato do Responsável'),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Seção de Dados Acadêmicos - Ícone verde
                  _buildSectionCard(
                    context,
                    title: 'Dados Acadêmicos',
                    icon: Icons.school_outlined,
                    iconColor: Colors.green,
                    children: [
                      _buildTwoColumnLayout([
                        _buildTextField(context, controller: _turmaController, label: 'Turma Acadêmica', isRequired: true),
                        _buildTextField(context, controller: _professorController, label: 'Professor Responsável', isRequired: true),
                      ]),
                      if (isEditing) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow('Nº do Prontuário:', widget.paciente!.numeroProntuario),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Botões de Ação
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isEditing)
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar', style: TextStyle(color: tela_principal.corPrimaria)),
                        ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _salvarFormulario,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: Text(isEditing ? 'Salvar Alterações' : 'Adicionar Paciente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tela_principal.corPrimaria,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required Color iconColor, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor), // Usando a nova propriedade `iconColor`
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTwoColumnLayout(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Wrap(
            spacing: 24.0,
            runSpacing: 16.0,
            children: children.map((child) => SizedBox(width: (constraints.maxWidth - 24) / 2 - 1, child: child)).toList(),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children.map((child) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: child)).toList(),
          );
        }
      },
    );
  }

  Widget _buildTextField(BuildContext context, {required TextEditingController controller, required String label, String? hint, TextInputType? keyboardType, bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Campo obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge,
          children: [
            TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' $value'),
          ],
        ),
      ),
    );
  }
}