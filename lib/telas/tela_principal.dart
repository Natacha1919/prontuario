// lib/telas/tela_principal.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prontuario_medico/telas/login_tela.dart' as login_tela;
import 'package:prontuario_medico/telas/pacientes_tela.dart';
import 'package:prontuario_medico/modelos/atividades_recentes.dart';
import 'package:intl/intl.dart';

// Definimos a cor primária para o novo valor #122640
const Color corPrimaria = Color(0xFF122640);

// Lista dos widgets que serão exibidos na área de conteúdo
final List<Widget> _telas = [
  const DashboardView(), // Índice 0
  const PacientesView(), // Índice 1
];

class TelaPrincipal extends StatefulWidget {
  final VoidCallback onLogout;
  const TelaPrincipal({super.key, required this.onLogout});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isDesktop = constraints.maxWidth > 800;

      return Scaffold(
        appBar: isDesktop
            ? null
            : AppBar(
                title: Text(_selectedIndex == 0 ? 'Dashboard' : 'Pacientes'),
                backgroundColor: corPrimaria, // Usando a nova cor
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Sair',
                    onPressed: widget.onLogout,
                  )
                ],
              ),
        drawer: isDesktop ? null : _buildDrawer(),
        body: Row(
          children: [
            if (isDesktop) ...[
              _buildSideNavBar(),
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: Colors.grey,
              ),
            ],
            Expanded(
              child: _telas.elementAt(_selectedIndex),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSideNavBar() {
    return NavigationRail(
      backgroundColor: corPrimaria, // Usando a nova cor
      indicatorColor:
          Colors.white.withOpacity(0.2), // Tom translúcido para o indicador
      selectedLabelTextStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      extended: true,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Text(
          'Prontuários UniFECAF',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined, color: Colors.white70),
          selectedIcon: Icon(Icons.dashboard, color: Colors.white),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline, color: Colors.white70),
          selectedIcon: Icon(Icons.people, color: Colors.white),
          label: Text('Pacientes'),
        ),
      ],
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              tooltip: 'Sair',
              onPressed: widget.onLogout,
            ),
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: corPrimaria), // Usando a nova cor
            child: Text(
              'MedSystem',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Pacientes'),
            selected: _selectedIndex == 1,
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late Future<List<AtividadeRecente>> _atividadesFuture;

  @override
  void initState() {
    super.initState();
    _atividadesFuture = _buscarAtividadesRecentes();
  }

  Future<List<AtividadeRecente>> _buscarAtividadesRecentes() async {
    final data = await login_tela.supabase
        .from('historico_atividades')
        .select()
        .order('created_at', ascending: false)
        .limit(5);

    return data.map((item) => AtividadeRecente.fromMap(item)).toList();
  }

  IconData _getIconForActivity(String tipoAcao) {
    switch (tipoAcao) {
      case 'Prontuário Atualizado':
        return Icons.history;
      case 'Paciente Criado':
        return Icons.person_add_alt_1_outlined;
      case 'Anamnese Registrada':
        return Icons.description_outlined;
      case 'Exame Solicitado':
        return Icons.checklist_rtl_outlined;
      case 'Resultado Exame Inserido':
        return Icons.science_outlined;
      case 'Paciente Excluído':
        return Icons.person_remove_alt_1_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForActivity(String tipoAcao) {
    switch (tipoAcao) {
      case 'Prontuário Atualizado':
        return Colors.blue;
      case 'Paciente Criado':
        return Colors.green;
      case 'Anamnese Registrada':
        return Colors.purple;
      case 'Exame Solicitado':
        return Colors.orange;
      case 'Resultado Exame Inserido':
        return Colors.teal;
      case 'Paciente Excluído':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Visão geral do sistema de prontuários',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Text('Atividade Recente',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: FutureBuilder<List<AtividadeRecente>>(
              future: _atividadesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: Text('Erro: ${snapshot.error}')));
                }
                final activities = snapshot.data ?? [];
                if (activities.isEmpty) {
                  return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('Nenhuma atividade recente.')));
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    String description = activity.descricao;
                    if (activity.pacienteNome != null &&
                        activity.pacienteNome!.isNotEmpty) {
                      description =
                          '${activity.tipoAcao} para ${activity.pacienteNome}';
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColorForActivity(activity.tipoAcao)
                            .withOpacity(0.1),
                        child: Icon(_getIconForActivity(activity.tipoAcao),
                            color: _getColorForActivity(activity.tipoAcao)),
                      ),
                      title: Text(description,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(activity.data)),
                      onTap: () {},
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
