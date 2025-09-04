// lib/telas/pacientes_tela.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prontuario_medico/modelos/paciente.dart';
import 'package:prontuario_medico/telas/paciente_detalhes_tela.dart';
import 'package:prontuario_medico/telas/paciente_form_tela.dart';

final supabase = Supabase.instance.client;

class PacientesView extends StatefulWidget {
  const PacientesView({super.key});

  @override
  State<PacientesView> createState() => _PacientesViewState();
}

class _PacientesViewState extends State<PacientesView> {
  // Inicialização segura com listas vazias
  List<Paciente> _pacientes = [];
  List<Paciente> _pacientesFiltrados = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _buscarPacientes();
    _searchController.addListener(_filtrarPacientes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _buscarPacientes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _pacientes = []; // Reinicializa a lista antes da busca
      _pacientesFiltrados = [];
    });
    try {
      final data = await supabase.from('pacientes').select().order('nomeCompleto', ascending: true);
      final listaPacientes = (data as List).map((item) => Paciente.fromMap(item)).toList();
      if (!mounted) return;
      setState(() {
        _pacientes = listaPacientes;
        _pacientesFiltrados = listaPacientes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar pacientes: $e'), backgroundColor: Colors.red));
      }
      // Garante que as listas permaneçam vazias em caso de erro
      if (!mounted) return;
      setState(() {
        _pacientes = [];
        _pacientesFiltrados = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filtrarPacientes() {
    final termoBusca = _searchController.text.toLowerCase();
    setState(() {
      // Usa um null-aware operator para garantir que a lista _pacientes não seja nula
      _pacientesFiltrados = _pacientes.where((paciente) {
        return paciente.nomeCompleto.toLowerCase().contains(termoBusca) ||
               paciente.cpf.toLowerCase().contains(termoBusca);
      }).toList();
    });
  }

  void _atualizarLista() {
    _searchController.clear();
    _buscarPacientes();
  }

  void _abrirFormularioPaciente({Paciente? paciente}) async {
    final foiSalvo = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => PacienteFormTela(paciente: paciente)),
    );
    if (foiSalvo ?? false) {
      _atualizarLista();
      if (paciente == null) {
        final newPatientData = await supabase.from('pacientes').select('id, nomeCompleto').order('created_at', ascending: false).limit(1);
        if (newPatientData.isNotEmpty) {
          final newPatientId = newPatientData.first['id'];
          final newPatientName = newPatientData.first['nomeCompleto'];
          await supabase.from('historico_atividades').insert({
            'tipo_acao': 'Paciente Criado',
            'descricao': 'Novo paciente "$newPatientName" cadastrado.',
            'usuario_id': supabase.auth.currentUser?.id,
            'paciente_id': newPatientId,
            'paciente_nome': newPatientName,
          });
        }
      } else {
        await supabase.from('historico_atividades').insert({
          'tipo_acao': 'Prontuário Atualizado',
          'descricao': 'Prontuário de "${paciente.nomeCompleto}" atualizado.',
          'usuario_id': supabase.auth.currentUser?.id,
          'paciente_id': paciente.id,
          'paciente_nome': paciente.nomeCompleto,
        });
      }
    }
  }

  void _mostrarDetalhes(Paciente paciente) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PacienteDetalhesTela(paciente: paciente)),
    ).then((_) => _atualizarLista());
  }

  Future<void> _excluirPaciente(int pacienteId, String pacienteNome) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o paciente "$pacienteNome" e todo o seu histórico? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirmar ?? false) {
      try {
        await supabase.from('pacientes').delete().eq('id', pacienteId);
        await supabase.from('historico_atividades').insert({
          'tipo_acao': 'Paciente Excluído',
          'descricao': 'Paciente "$pacienteNome" excluído.',
          'usuario_id': supabase.auth.currentUser?.id,
          'paciente_id': pacienteId,
          'paciente_nome': pacienteNome,
        });
        _atualizarLista();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir paciente: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pacientes', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Gerencie todos os pacientes cadastrados', style: TextStyle(color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _abrirFormularioPaciente(),
                icon: const Icon(Icons.add),
                label: const Text('Novo Paciente'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou CPF...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: _pacientesFiltrados.isEmpty && _searchController.text.isNotEmpty
                      ? const Center(child: Text('Nenhum resultado encontrado.'))
                      : _pacientesFiltrados.isEmpty && _searchController.text.isEmpty
                          ? const Center(child: Text('Nenhum paciente encontrado.'))
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.5),
                              itemCount: _pacientesFiltrados.length,
                              itemBuilder: (context, index) {
                                final paciente = _pacientesFiltrados[index];
                                return _buildPatientCard(paciente);
                              },
                            ),
                ),
        ],
      ),
    );
  }

Widget _buildPatientCard(Paciente paciente) {
  final initials = paciente.nomeCompleto.isNotEmpty ? paciente.nomeCompleto.split(' ').map((e) => e[0]).take(2).join().toUpperCase() : '?';
  return Card(
    color: Colors.white, // <--- ALTERAÇÃO AQUI
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: InkWell(
      onTap: () => _mostrarDetalhes(paciente),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [CircleAvatar(child: Text(initials)), const SizedBox(width: 12), Expanded(child: Text(paciente.nomeCompleto, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)))]),
            const Divider(height: 24),
            _buildInfoRow(Icons.badge_outlined, paciente.cpf),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today_outlined, paciente.dataNascimento),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on_outlined, paciente.endereco.isNotEmpty ? paciente.endereco : 'Não informado'),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(onPressed: () => _mostrarDetalhes(paciente), icon: const Icon(Icons.visibility_outlined, size: 16), label: const Text('Ver')),
                const SizedBox(width: 8),
                OutlinedButton.icon(onPressed: () => _abrirFormularioPaciente(paciente: paciente), icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Editar')),
              ],
            )
          ],
        ),
      ),
    ),
  );
}

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(color: Colors.grey[800]))),
    ]);
  }
}