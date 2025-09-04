// lib/telas/devolutiva_form_tela.dart

import 'package:flutter/material.dart';
import 'package:prontuario_medico/modelos/devolutiva.dart';

class DevolutivaFormTela extends StatefulWidget {
  final int pacienteId;
  const DevolutivaFormTela({super.key, required this.pacienteId});

  @override
  State<DevolutivaFormTela> createState() => _DevolutivaFormTelaState();
}

class _DevolutivaFormTelaState extends State<DevolutivaFormTela> {
  final _formKey = GlobalKey<FormState>();
  final _relatorioController = TextEditingController();
  final _interpretacaoController = TextEditingController();
  final _orientacaoController = TextEditingController();
  final _alunoController = TextEditingController();
  final _professorController = TextEditingController();

  void _salvarFormulario() {
    if (_formKey.currentState!.validate()) {
      final devolutiva = Devolutiva(
        pacienteId: widget.pacienteId,
        data: DateTime.now(),
        relatorioPaciente: _relatorioController.text,
        interpretacaoBasica: _interpretacaoController.text,
        orientacaoEncaminhamento: _orientacaoController.text,
        assinaturaAluno: _alunoController.text,
        assinaturaProfessor: _professorController.text,
      );
      Navigator.of(context).pop(devolutiva);
    }
  }

  @override
  void dispose() {
    _relatorioController.dispose();
    _interpretacaoController.dispose();
    _orientacaoController.dispose();
    _alunoController.dispose();
    _professorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Devolutiva')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(controller: _relatorioController, decoration: const InputDecoration(labelText: 'Relatório para o Paciente', border: OutlineInputBorder()), maxLines: 5, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _interpretacaoController, decoration: const InputDecoration(labelText: 'Interpretação Básica dos Exames', border: OutlineInputBorder()), maxLines: 5, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _orientacaoController, decoration: const InputDecoration(labelText: 'Orientação / Encaminhamento', border: OutlineInputBorder()), maxLines: 3, validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _alunoController, decoration: const InputDecoration(labelText: 'Assinatura Aluno(s)', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _professorController, decoration: const InputDecoration(labelText: 'Assinatura Professor Responsável', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _salvarFormulario, child: const Text('Salvar Devolutiva')),
          ],
        ),
      ),
    );
  }
}