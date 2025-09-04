// lib/telas/atendimento_evento_form_tela.dart

import 'package:flutter/material.dart';
import 'package:prontuario_medico/modelos/atendimento_evento.dart';

class AtendimentoEventoFormTela extends StatefulWidget {
  final int pacienteId;

  const AtendimentoEventoFormTela({super.key, required this.pacienteId});

  @override
  State<AtendimentoEventoFormTela> createState() => _AtendimentoEventoFormTelaState();
}

class _AtendimentoEventoFormTelaState extends State<AtendimentoEventoFormTela> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _responsavelController = TextEditingController();

  // Opções para o tipo de evento
  final List<String> _tiposDeEvento = ['Coleta', 'Observação de Aluno', 'Intercorrência Laboratorial', 'Outro'];
  String? _tipoSelecionado;

  @override
  void initState() {
    super.initState();
    _tipoSelecionado = _tiposDeEvento.first; // Inicia com o primeiro item
  }

  void _salvarFormulario() {
    if (_formKey.currentState!.validate()) {
      final evento = AtendimentoEvento(
        pacienteId: widget.pacienteId,
        data: DateTime.now(),
        tipoEvento: _tipoSelecionado!,
        descricao: _descricaoController.text,
        responsavel: _responsavelController.text,
      );
      Navigator.of(context).pop(evento);
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _responsavelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Novo Evento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Dropdown para selecionar o tipo de evento
            DropdownButtonFormField<String>(
              value: _tipoSelecionado,
              decoration: const InputDecoration(labelText: 'Tipo de Evento', border: OutlineInputBorder()),
              items: _tiposDeEvento.map((String tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
              onChanged: (String? novoValor) {
                setState(() {
                  _tipoSelecionado = novoValor;
                });
              },
              validator: (v) => v == null ? 'Selecione um tipo' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição / Observações', border: OutlineInputBorder()),
              maxLines: 7,
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _responsavelController,
              decoration: const InputDecoration(labelText: 'Responsável pelo Registro', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvarFormulario,
              child: const Text('Salvar Evento'),
            ),
          ],
        ),
      ),
    );
  }
}