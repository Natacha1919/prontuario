// lib/telas/pacientes_tela.dart

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
  late Future<List<Paciente>> _pacientesFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _pacientesFuture = _buscarPacientes();
    // O listener para a busca foi removido para simplificar, como solicitado.
    // Se precisar reativar, veja as sugestões anteriores sobre como gerenciar o estado.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Função de busca que busca todos os pacientes (sem filtro por enquanto)
  Future<List<Paciente>> _buscarPacientes() async {
    final data = await supabase.from('pacientes').select().order('nomeCompleto', ascending: true);
    return data.map((item) => Paciente.fromMap(item)).toList();
  }

  // Função para forçar a atualização da lista (útil após criar/editar/excluir)
  void _atualizarLista() {
    // Limpa o campo de busca se ele estiver visível
    _searchController.clear(); 
    setState(() {
      _searchTerm = ''; // Reseta o termo de busca
      _pacientesFuture = _buscarPacientes(); // Refaz a busca completa
    });
  }

  // Abre o formulário para adicionar ou editar um paciente
  void _abrirFormularioPaciente({Paciente? paciente}) async {
    // Navega para a tela de formulário e espera um resultado (true se salvou)
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => PacienteFormTela(paciente: paciente)),
    );
    // Se o formulário retornou 'true', significa que algo foi salvo com sucesso
    if (resultado ?? false) {
      _atualizarLista(); // Atualiza a lista para mostrar o novo/editado paciente
    }
  }

  // Navega para a tela de detalhes do paciente
  void _mostrarDetalhes(Paciente paciente) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PacienteDetalhesTela(paciente: paciente)),
    ).then((_) => _atualizarLista()); // Atualiza a lista ao voltar, caso algo tenha mudado
  }

  // Função para excluir um paciente
  Future<void> _excluirPaciente(int pacienteId, String pacienteNome) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o paciente "$pacienteNome" e todos os seus registros? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirmar ?? false) {
      try {
        await supabase.from('pacientes').delete().eq('id', pacienteId);
        // Registrar atividade de exclusão
        await supabase.from('historico_atividades').insert({
          'tipo_acao': 'Paciente Excluído',
          'descricao': 'Paciente "$pacienteNome" (ID: $pacienteId) excluído.',
          'usuario_id': supabase.auth.currentUser?.id,
          'paciente_id': pacienteId,
          'paciente_nome': pacienteNome,
        });
        _atualizarLista(); // Atualiza a lista após a exclusão
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pacientes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), // Tamanho ligeiramente menor
                  SizedBox(height: 4),
                  Text('Gerencie todos os pacientes cadastrados', style: TextStyle(color: Colors.grey)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _abrirFormularioPaciente(),
                icon: const Icon(Icons.add),
                label: const Text('Novo Paciente'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding ajustado
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // A BARRA DE BUSCA FOI REMOVIDA, CONFORME SUA SOLICITAÇÃO
          const SizedBox(height: 24), // Mantém o espaçamento
          Expanded(
            child: FutureBuilder<List<Paciente>>(
              future: _pacientesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar pacientes: ${snapshot.error}'));
                }
                final pacientes = snapshot.data ?? [];
                if (pacientes.isEmpty) {
                  return const Center(child: Text('Nenhum paciente cadastrado.\nClique em "Novo Paciente" para adicionar.'));
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: pacientes.length,
                  itemBuilder: (context, index) {
                    final paciente = pacientes[index];
                    return _buildPatientCard(paciente);
                  },
                );
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 24, child: Text(initials)),
                const SizedBox(width: 12),
                Expanded(child: Text(paciente.nomeCompleto, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.badge_outlined, paciente.cpf),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today_outlined, paciente.dataNascimento),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on_outlined, 'Endereço', paciente.endereco.isNotEmpty ? paciente.endereco : 'Não informado'),
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
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(color: Colors.grey[800]), overflow: TextOverflow.ellipsis)), // Usando overflow ellipsis para textos longos
    ]);
  }
}
