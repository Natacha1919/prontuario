// lib/telas/anamnese_form_tela.dart

import 'package:flutter/material.dart';
import 'package:prontuario_medico/modelos/anamnese.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AnamneseFormTela extends StatefulWidget {
  final Anamnese? anamnese;
  final int pacienteId;

  const AnamneseFormTela({super.key, required this.pacienteId, this.anamnese});

  @override
  State<AnamneseFormTela> createState() => _AnamneseFormTelaState();
}

class _AnamneseFormTelaState extends State<AnamneseFormTela> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _queixaController;
  late TextEditingController _historiaController;
  late TextEditingController _patologicoController;
  late TextEditingController _medicamentosController;
  late TextEditingController _habitosController;
  late TextEditingController _familiaresController;

  @override
  void initState() {
    super.initState();
    _queixaController = TextEditingController(text: widget.anamnese?.queixaPrincipal);
    _historiaController = TextEditingController(text: widget.anamnese?.historiaDoencaAtual);
    _patologicoController = TextEditingController(text: widget.anamnese?.historicoPatologicoPregresso);
    _medicamentosController = TextEditingController(text: widget.anamnese?.usoMedicamentos);
    _habitosController = TextEditingController(text: widget.anamnese?.habitosVida);
    _familiaresController = TextEditingController(text: widget.anamnese?.antecedentesFamiliares);
  }

  void _salvarFormulario() async {
    if (_formKey.currentState!.validate()) {
      final anamneseProcessada = Anamnese(
        id: widget.anamnese?.id,
        pacienteId: widget.pacienteId,
        queixaPrincipal: _queixaController.text,
        historiaDoencaAtual: _historiaController.text,
        historicoPatologicoPregresso: _patologicoController.text,
        usoMedicamentos: _medicamentosController.text,
        habitosVida: _habitosController.text,
        antecedentesFamiliares: _familiaresController.text,
      );

      try {
        if (widget.anamnese != null) {
          await supabase.from('anamneses').update(anamneseProcessada.toMap()).eq('id', anamneseProcessada.id!);
        } else {
          await supabase.from('anamneses').insert(anamneseProcessada.toMap());
          // Registrar atividade de anamnese
          await supabase.from('historico_atividades').insert({
            'tipo_acao': 'Anamnese Registrada',
            'descricao': 'Nova anamnese registrada para o paciente com ID "${widget.pacienteId}".',
            'usuario_id': supabase.auth.currentUser?.id,
            'paciente_id': widget.pacienteId,
            // (Opcional) Buscar o nome do paciente aqui se precisar na descrição
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anamnese salva com sucesso!'), backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar anamnese: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  void dispose() {
    _queixaController.dispose();
    _historiaController.dispose();
    _patologicoController.dispose();
    _medicamentosController.dispose();
    _habitosController.dispose();
    _familiaresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.anamnese == null ? 'Nova Anamnese' : 'Editar Anamnese'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField(controller: _queixaController, label: 'Queixa Principal'),
              _buildTextFormField(controller: _historiaController, label: 'História da Doença Atual', maxLines: 5),
              _buildTextFormField(controller: _patologicoController, label: 'Histórico Patológico Pregresso', maxLines: 3),
              _buildTextFormField(controller: _medicamentosController, label: 'Uso de Medicamentos (atuais e anteriores)', maxLines: 3),
              _buildTextFormField(controller: _habitosController, label: 'Hábitos de Vida', maxLines: 3),
              _buildTextFormField(controller: _familiaresController, label: 'Antecedentes Familiares Relevantes', maxLines: 3),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarFormulario,
                child: const Text('Salvar Anamnese'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String label, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        validator: (value) => (value?.trim().isEmpty ?? true) ? 'Campo obrigatório' : null,
      ),
    );
  }
}