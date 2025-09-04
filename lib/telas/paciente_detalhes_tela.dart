// lib/telas/paciente_detalhes_tela.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:prontuario_medico/modelos/anamnese.dart';
import 'package:prontuario_medico/modelos/exame_anterior.dart';
import 'package:prontuario_medico/modelos/exame_categoria.dart';
import 'package:prontuario_medico/modelos/exame_resultado.dart';
import 'package:prontuario_medico/modelos/exame_solicitacao.dart';
import 'package:prontuario_medico/modelos/paciente.dart';
import 'package:prontuario_medico/telas/anamnese_form_tela.dart';
import 'package:prontuario_medico/telas/exame_resultado_form_tela.dart';
import 'package:prontuario_medico/telas/paciente_form_tela.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:prontuario_medico/servicos/gerador_pdf.dart';
import 'package:prontuario_medico/telas/tela_principal.dart' as tela_principal; // Importa a cor primária

final supabase = Supabase.instance.client;

class PacienteDetalhesTela extends StatefulWidget {
  final Paciente paciente;
  const PacienteDetalhesTela({super.key, required this.paciente});

  @override
  State<PacienteDetalhesTela> createState() => _PacienteDetalhesTelaState();
}

class _PacienteDetalhesTelaState extends State<PacienteDetalhesTela> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Anamneses', 'Solicitar Exames', 'Anexos', 'Resultados'];
  bool _isUploading = false;
  
  bool _isDownloading = false;

  Future<List<Anamnese>> _buscarAnamneses() async {
    final data = await supabase.from('anamneses').select().eq('paciente_id', widget.paciente.id!).order('created_at', ascending: false);
    return data.map((item) => Anamnese.fromMap(item)).toList();
  }

  Future<List<ExameAnterior>> _buscarExamesAnteriores() async {
    final data = await supabase.from('exames_anteriores').select().eq('paciente_id', widget.paciente.id!).order('created_at', ascending: false);
    return data.map((item) => ExameAnterior.fromMap(item)).toList();
  }

  Future<List<ExameSolicitacao>> _buscarSolicitacoes() async {
    final data = await supabase.from('exame_solicitacoes').select().eq('paciente_id', widget.paciente.id!).order('created_at', ascending: false);
    return data.map((item) => ExameSolicitacao.fromMap(item)).toList();
  }

  Future<ExameResultado?> _buscarResultadoParaSolicitacao(int solicitacaoId) async {
    final data = await supabase.from('exame_resultados').select().eq('solicitacao_id', solicitacaoId).limit(1);
    return data.isNotEmpty ? ExameResultado.fromMap(data.first) : null;
  }
  
  void _abrirFormularioAnamnese({Anamnese? anamnese}) async {
    final resultado = await Navigator.push<Anamnese>(context, MaterialPageRoute(builder: (context) => AnamneseFormTela(pacienteId: widget.paciente.id!, anamnese: anamnese)));
    if (resultado != null) {
      if (anamnese != null) {
        await supabase.from('anamneses').update(resultado.toMap()).eq('id', anamnese.id!);
      } else {
        await supabase.from('anamneses').insert(resultado.toMap());
      }
      setState(() {});
    }
  }

  Future<void> _fazerUploadExame() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;
    setState(() => _isUploading = true);
    try {
      final file = result.files.first;
      final fileBytes = file.bytes;
      if (fileBytes == null) throw 'Não foi possível ler os bytes do arquivo.';
      final originalFileName = file.name;
      final sanitizedFileName = originalFileName.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\.\-]'), '');
      final filePath = '${widget.paciente.id}/${DateTime.now().millisecondsSinceEpoch}_$sanitizedFileName';
      await supabase.storage.from('exames_pacientes').uploadBinary(filePath, fileBytes);
      await supabase.from('exames_anteriores').insert({'paciente_id': widget.paciente.id!, 'nome_arquivo': originalFileName, 'path_storage': filePath});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no upload: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _baixarExame(String path) async {
    try {
      final urlString = await supabase.storage.from('exames_pacientes').createSignedUrl(path, 60);
      final url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Não foi possível abrir a URL: $urlString';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no download: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _gerarLaudoPDF() async {
    setState(() => _isDownloading = true);
    try {
      await GeradorPdf.gerarLaudoCompleto(context, widget.paciente);
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _abrirFormularioResultados(ExameSolicitacao solicitacao) async {
    final resultadoExistente = await _buscarResultadoParaSolicitacao(solicitacao.id);
    Navigator.push(context, MaterialPageRoute(builder: (context) => ExameResultadoFormTela(solicitacao: solicitacao, resultadoExistente: resultadoExistente)))
    .then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: tela_principal.corPrimaria,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prontuário'),
            Text(widget.paciente.nomeCompleto, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          ],
        ),
        actions: [
          _isDownloading
          ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: _gerarLaudoPDF,
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Baixar PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PacienteFormTela(paciente: widget.paciente)))
                  .then((_) => setState(() {}));
              },
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Editar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildPatientInfoCard(),
          _buildInternalNavBar(),
          _buildCurrentTabContent(),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    final initials = widget.paciente.nomeCompleto.isNotEmpty ? widget.paciente.nomeCompleto.split(' ').map((e) => e[0]).take(2).join().toUpperCase() : '?';
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24, child: Text(initials, style: const TextStyle(fontSize: 18))),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.paciente.nomeCompleto, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text('${_calculateAge(widget.paciente.dataNascimento)} anos • Sexo: ${widget.paciente.sexo}'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildInfoColumn(Icons.badge_outlined, 'Nº Prontuário', widget.paciente.numeroProntuario.toString())),
              Expanded(child: _buildInfoColumn(Icons.phone_outlined, 'Contato Paciente', widget.paciente.cpf)),
              Expanded(child: _buildInfoColumn(Icons.phone_outlined, 'Contato Responsável', widget.paciente.responsavelContato.isNotEmpty ? widget.paciente.responsavelContato : 'N/A')),
              Expanded(child: _buildInfoColumn(Icons.calendar_today_outlined, 'Data de Nascimento', widget.paciente.dataNascimento)),
              Expanded(child: _buildInfoColumn(Icons.location_on_outlined, 'Endereço', widget.paciente.endereco.isNotEmpty ? widget.paciente.endereco : 'N/A')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInternalNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (index) => _buildNavItem(index)),
              ),
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (index) => _buildNavItem(index)),
            );
          }
        },
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          _tabs[index],
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_selectedIndex) {
      case 0: return _buildAtendimentosTab();
      case 1: return _buildEvolucaoChecklistTab();
      case 2: return _buildExamesTab();
      case 3: return _buildSolicitacoesTab();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildAtendimentosTab() {
    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Anamneses', style: Theme.of(context).textTheme.titleLarge), ElevatedButton.icon(onPressed: () => _abrirFormularioAnamnese(), icon: const Icon(Icons.add), label: const Text('Nova'))])),
      FutureBuilder<List<Anamnese>>(
        future: _buscarAnamneses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(32.0), child: Center(child: CircularProgressIndicator()));
          if (snapshot.hasError) return Padding(padding: const EdgeInsets.all(32.0), child: Center(child: Text('Erro: ${snapshot.error}')));
          final anamneses = snapshot.data ?? [];
          if (anamneses.isEmpty) return const Padding(padding: EdgeInsets.all(32.0), child: Center(child: Text('Nenhuma anamnese registrada.')));
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: anamneses.length,
            itemBuilder: (context, index) {
              final anamnese = anamneses[index];
              return Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), child: ListTile(leading: const Icon(Icons.description_outlined), title: Text(anamnese.queixaPrincipal, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Data: ${DateFormat('dd/MM/yyyy').format(anamnese.data!)}'), trailing: IconButton(icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary), onPressed: () => _abrirFormularioAnamnese(anamnese: anamnese))));
            },
          );
        },
      ),
    ]);
  }

  Widget _buildEvolucaoChecklistTab() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final formKey = GlobalKey<FormState>();
        final justificativaController = TextEditingController();
        final Map<int, bool> selecionados = {};
        bool isSaving = false;
        Future<List<ExameCategoria>> buscarExamesDisponiveis() async {
          final data = await supabase.from('exame_categorias').select('*, exame_tipos(*)').order('nome');
          return data.map((item) => ExameCategoria.fromMap(item)).toList();
        }
        Future<void> salvarSolicitacao() async {
          if (!formKey.currentState!.validate()) return;
          final idsSelecionadas = selecionados.entries.where((e) => e.value).map((e) => e.key).toList();
          if (idsSelecionadas.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione ao menos um exame.'), backgroundColor: Colors.orange));
            return;
          }
          setState(() => isSaving = true);
          try {
            await supabase.from('exame_solicitacoes').insert({'paciente_id': widget.paciente.id!, 'justificativa_clinica': justificativaController.text, 'exames_solicitados': idsSelecionadas});
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitação salva com sucesso!'), backgroundColor: Colors.green));
            justificativaController.clear();
            selecionados.clear();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red));
          } finally {
            setState(() => isSaving = false);
          }
        }
        return FutureBuilder<List<ExameCategoria>>(
          future: buscarExamesDisponiveis(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final categorias = snapshot.data!;
            return Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...categorias.map((categoria) => ExpansionTile(
                    title: Text(categoria.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                    initiallyExpanded: true,
                    children: categoria.tipos.map((tipo) => CheckboxListTile(
                      title: Text(tipo.nome),
                      value: selecionados[tipo.id] ?? false,
                      onChanged: (bool? value) => setState(() => selecionados[tipo.id] = value!),
                    )).toList(),
                  )),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: justificativaController,
                    decoration: const InputDecoration(labelText: 'Justificativa Clínica', border: OutlineInputBorder()),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 24),
                  isSaving ? const Center(child: CircularProgressIndicator()) : ElevatedButton.icon(onPressed: salvarSolicitacao, icon: const Icon(Icons.send_outlined), label: const Text('Enviar Solicitação'))
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExamesTab() {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Arquivos Anexados', style: Theme.of(context).textTheme.titleLarge), _isUploading ? const CircularProgressIndicator() : ElevatedButton.icon(onPressed: _fazerUploadExame, icon: const Icon(Icons.upload_file), label: const Text('Enviar'))])),
      FutureBuilder<List<ExameAnterior>>(
        future: _buscarExamesAnteriores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(32.0), child: Center(child: CircularProgressIndicator()));
          if (snapshot.hasError) return Padding(padding: const EdgeInsets.all(32.0), child: Center(child: Text('Erro: ${snapshot.error}')));
          final exames = snapshot.data ?? [];
          if (exames.isEmpty) return const Padding(padding: EdgeInsets.all(32.0), child: Center(child: Text('Nenhum exame anexado.')));
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: exames.length,
            itemBuilder: (context, index) {
              final exame = exames[index];
              return Card(margin: const EdgeInsets.symmetric(vertical: 4.0), child: ListTile(leading: const Icon(Icons.insert_drive_file_outlined), title: Text(exame.nomeArquivo, overflow: TextOverflow.ellipsis), subtitle: Text('Enviado em: ${DateFormat('dd/MM/yyyy').format(exame.dataUpload)}'), trailing: IconButton(icon: const Icon(Icons.download_outlined), tooltip: 'Baixar Exame', onPressed: () => _baixarExame(exame.pathStorage))));
            },
          );
        },
      ),
    ]);
  }

  Widget _buildSolicitacoesTab() {
    return FutureBuilder<List<ExameSolicitacao>>(
      future: _buscarSolicitacoes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(32.0), child: Center(child: CircularProgressIndicator()));
        if (snapshot.hasError) return Padding(padding: const EdgeInsets.all(32.0), child: Center(child: Text('Erro: ${snapshot.error}')));
        final solicitacoes = snapshot.data ?? [];
        if (solicitacoes.isEmpty) return const Padding(padding: EdgeInsets.all(32.0), child: Center(child: Text('Nenhuma solicitação de exame encontrada.')));
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: solicitacoes.length,
          itemBuilder: (context, index) {
            final solicitacao = solicitacoes[index];
            return FutureBuilder<ExameResultado?>(
              future: _buscarResultadoParaSolicitacao(solicitacao.id),
              builder: (context, resultadoSnapshot) {
                final resultado = resultadoSnapshot.data;
                final temResultado = resultado != null;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: Icon(temResultado ? Icons.check_circle_outline : Icons.pending_actions_outlined, color: temResultado ? Colors.green : Colors.orange),
                    title: Text('Solicitação de ${DateFormat('dd/MM/yyyy').format(solicitacao.dataSolicitacao)}'),
                    subtitle: Text(solicitacao.justificativaClinica, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: Icon(temResultado ? Icons.visibility_outlined : Icons.edit_note_outlined, color: Theme.of(context).primaryColor),
                      tooltip: temResultado ? 'Ver/Editar Resultados' : 'Inserir Resultados',
                      onPressed: () => _abrirFormularioResultados(solicitacao),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  int _calculateAge(String birthDateString) {
    try {
      final birthDate = DateFormat('dd/MM/yyyy').parse(birthDateString);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age > 0 ? age : 0;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildInfoColumn(IconData icon, String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}