// lib/telas/prontuario_entrada_form_tela.dart

import 'package:flutter/material.dart';
import 'package:prontuario_medico/modelos/prontuario_entrada.dart';

class ProntuarioEntradaFormTela extends StatefulWidget {
  final ProntuarioEntrada? entrada;

  const ProntuarioEntradaFormTela({super.key, this.entrada});

  @override
  State<ProntuarioEntradaFormTela> createState() =>
      _ProntuarioEntradaFormTelaState();
}

class _ProntuarioEntradaFormTelaState
    extends State<ProntuarioEntradaFormTela> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.entrada?.titulo);
    _descricaoController =
        TextEditingController(text: widget.entrada?.descricao);
  }

  void _salvarFormulario() {
    if (_formKey.currentState!.validate()) {
      // Cria um objeto temporário com os dados do formulário
      final entradaProcessada = ProntuarioEntrada(
        id: widget.entrada?.id,
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        // O pacienteId e a data serão preenchidos na tela anterior
        pacienteId: widget.entrada?.pacienteId ?? 0, 
        data: widget.entrada?.data ?? DateTime.now(),
      );
      Navigator.of(context).pop(entradaProcessada);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entrada == null ? 'Nova Entrada no Prontuário' : 'Editar Entrada'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => (value?.isEmpty ?? true) ? 'Por favor, insira um título.' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição Detalhada'),
                maxLines: 8,
                validator: (value) => (value?.isEmpty ?? true) ? 'Por favor, insira a descrição.' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarFormulario,
                child: const Text('Salvar Entrada'),
              )
            ],
          ),
        ),
      ),
    );
  }
}