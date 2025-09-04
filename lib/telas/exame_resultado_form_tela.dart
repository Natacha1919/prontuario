// lib/telas/exame_resultado_form_tela.dart

import 'package:flutter/material.dart';
import 'package:prontuario_medico/modelos/exame_resultado.dart';
import 'package:prontuario_medico/modelos/exame_solicitacao.dart';
import 'package:prontuario_medico/modelos/exame_tipo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
const Color corPrimaria = Color(0xFF1463DD); // Usando a mesma cor do main.dart

class ExameResultadoFormTela extends StatefulWidget {
  final ExameSolicitacao solicitacao;
  final ExameResultado? resultadoExistente;

  const ExameResultadoFormTela({
    super.key,
    required this.solicitacao,
    this.resultadoExistente,
  });

  @override
  State<ExameResultadoFormTela> createState() => _ExameResultadoFormTelaState();
}

class _ExameResultadoFormTelaState extends State<ExameResultadoFormTela> {
  final _formKey = GlobalKey<FormState>();
  final _observacoesController = TextEditingController();
  final Map<int, TextEditingController> _resultadoControllers = {};

  List<ExameTipo> _tiposDeExame = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _observacoesController.text = widget.resultadoExistente?.observacoes ?? '';
    _buscarTiposDeExame();
  }

  Future<void> _buscarTiposDeExame() async {
    try {
      final ids = widget.solicitacao.examesSolicitadosIds;
      if (ids.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final data =
          await supabase.from('exame_tipos').select().inFilter('id', ids);
      final List<ExameTipo> tipos = [];
      for (final item in data) {
        final tipo = ExameTipo.fromMap(item as Map<String, dynamic>);
        tipos.add(tipo);
        final valorExistente =
            widget.resultadoExistente?.resultados[tipo.nome] ?? '';
        _resultadoControllers[tipo.id] =
            TextEditingController(text: valorExistente.toString());
      }
      setState(() {
        _tiposDeExame = tipos;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao buscar tipos de exame: $e'),
            backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _salvarResultados() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, String> resultados = {};
    for (var tipo in _tiposDeExame) {
      resultados[tipo.nome] = _resultadoControllers[tipo.id]!.text;
    }
    try {
      if (widget.resultadoExistente != null) {
        await supabase.from('exame_resultados').update({
          'observacoes': _observacoesController.text,
          'resultados': resultados
        }).eq('id', widget.resultadoExistente!.id!);
      } else {
        await supabase.from('exame_resultados').insert({
          'solicitacao_id': widget.solicitacao.id,
          'observacoes': _observacoesController.text,
          'resultados': resultados
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Resultados salvos com sucesso!'),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao salvar resultados: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    for (var controller in _resultadoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resultadoExistente == null
            ? 'Inserir Resultados'
            : 'Editar Resultados'),
      ),
      // **** BOTÃO "SALVAR" AGORA É UM FLOATINGACTIONBUTTON ****
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _salvarResultados,
        label: const Text('Salvar Alterações'),
        icon: const Icon(Icons.save),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // Centraliza o botão
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    16, 16, 16, 80), // Espaço extra para o FAB
                children: [
                  // **** MUDANÇA PRINCIPAL: DATATABLE COM ESTILO DO PDF ****
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                          corPrimaria), // Cabeçalho azul
                      headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white), // Texto do cabeçalho branco
                      border: TableBorder.all(
                          color: Colors.grey.shade400, width: 1),
                      columns: const [
                        DataColumn(label: Text('Exame Solicitado')),
                        DataColumn(label: Text('Resultado')),
                        DataColumn(label: Text('Valores de Referência')),
                      ],
                      rows: _tiposDeExame.map((tipo) {
                        return DataRow(
                          cells: [
                            DataCell(Text(tipo.nome)),
                            DataCell(
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: TextFormField(
                                  controller: _resultadoControllers[tipo.id],
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 8)),
                                  textAlign: TextAlign.center,
                                  validator: (v) =>
                                      v!.trim().isEmpty ? '*' : null,
                                ),
                              ),
                            ),
                            DataCell(Text(tipo.valorReferencia,
                                textAlign: TextAlign.center)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _observacoesController,
                    decoration: const InputDecoration(
                        labelText: 'Observações Gerais',
                        border: OutlineInputBorder()),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
    );
  }
}
