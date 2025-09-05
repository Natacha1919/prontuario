// lib/telas/tela_principal.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prontuario_medico/telas/login_tela.dart';
import 'package:prontuario_medico/telas/pacientes_tela.dart';

const Color corPrimaria = Color(0xFF1463DD);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'SUA_URL_AQUI',
    anonKey: 'SUA_CHAVE_ANON_AQUI',
  );
  runApp(const ProntuarioMedicoApp());
}

final supabase = Supabase.instance.client;

class ProntuarioMedicoApp extends StatefulWidget {
  const ProntuarioMedicoApp({super.key});

  @override
  State<ProntuarioMedicoApp> createState() => _ProntuarioMedicoAppState();
}

class _ProntuarioMedicoAppState extends State<ProntuarioMedicoApp> {
  bool _estaLogado = false;

  @override
  void initState() {
    super.initState();
    _estaLogado = supabase.auth.currentSession != null;
    supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _estaLogado = data.session != null;
      });
    });
  }

  void _realizarLogout() {
    supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Prontuários',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: corPrimaria),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: corPrimaria,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicator: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white, width: 2.0))),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: corPrimaria,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: _estaLogado
          ? TelaPrincipal(onLogout: _realizarLogout)
          : LoginTela(onLogin: () {}),
    );
  }
}

class TelaPrincipal extends StatelessWidget {
  final VoidCallback onLogout;
  const TelaPrincipal({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    // A lógica para detectar se é desktop ou mobile é feita aqui
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      // AppBar só é exibida em telas mobile (quando não é desktop)
      appBar: isDesktop
          ? null // Em desktop, a navegação lateral é a principal
          : AppBar(
              title: Text(_selectedIndex == 0 ? 'Dashboard' : 'Pacientes'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sair',
                  onPressed: onLogout,
                )
              ],
            ),
      // O Drawer só é exibido em telas mobile
      drawer: isDesktop ? null : _buildDrawer(),
      body: Row(
        children: [
          // O NavigationRail (barra lateral) só aparece em desktop
          if (isDesktop) _buildSideNavBar(),
          
          // A área de conteúdo principal
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
    );
  }

  // --- Widgets de Navegação ---

  // Barra de navegação lateral para telas maiores (desktop)
  Widget _buildSideNavBar() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        // Ao clicar em um item, atualiza o estado e muda a tela
        setState(() {
          _selectedIndex = index;
        });
      },
      // extended: true, // Esta propriedade faz o NavigationRail expandir para mostrar os textos
      // labelType: NavigationRailLabelType.all, // Específica como os labels devem aparecer
      
      // Removi labelType e extended para simplificar, pois o comportamento desejado é o Drawer
      // Se você quiser reativar o comportamento de barra lateral expandida no futuro,
      // pode descomentar essas linhas e garantir que o tema esteja bem configurado.
      
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Text(
          'MedSystem',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Pacientes'),
        ),
      ],
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: widget.onLogout,
            ),
          ),
        ),
      ),
    );
  }

  // Menu gaveta (Drawer) para telas menores (mobile)
  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Text(
              'MedSystem',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context); // Fecha o drawer
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

// Widget de placeholder para o conteúdo do Dashboard (como definido anteriormente)
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding( // Adicionado padding para melhor visualização
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visão geral do sistema de prontuários', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Text('Atividade Recente', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: FutureBuilder<List<dynamic>>( // Usando dynamic pois não temos o modelo ainda
                future: Future.value([]), // Placeholder, pois não temos a busca real ainda
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()));
                  if (snapshot.hasError) return Padding(padding: const EdgeInsets.all(16.0), child: Center(child: Text('Erro: ${snapshot.error}')));
                  
                  final activities = snapshot.data ?? [];
                  if (activities.isEmpty) return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text('Nenhuma atividade recente.')));

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final activity = activities[index]; // Assumindo que é um Map
                      String description = activity['tipo_acao'] ?? 'Ação desconhecida';
                      if (activity['paciente_nome'] != null && activity['paciente_nome'].isNotEmpty) {
                        description = '${activity['tipo_acao']} para ${activity['paciente_nome']}';
                      }
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.1), child: Icon(Icons.history, color: Colors.blue)),
                        title: Text(description, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(activity['time'] ?? 'Algum tempo atrás'),
                        onTap: () {}, // Sem ação por enquanto
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
