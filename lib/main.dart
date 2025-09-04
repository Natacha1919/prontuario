// lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prontuario_medico/telas/tela_principal.dart';
import 'package:prontuario_medico/telas/login_tela.dart';

// Definição da cor primária do aplicativo
const Color corPrimaria = Color(0xFF1463DD);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Supabase com sua URL e Chave Anon
  await Supabase.initialize(
    url: 'https://qqhrskmuzbbhslgmdord.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxaHJza211emJiaHNsZ21kb3JkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxMDc3ODIsImV4cCI6MjA3MDY4Mzc4Mn0.Is0CwDF5lOb2ZPK6jzdLR24W5XWFFsNMsMlHKySVeT4',
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
    // Verifica o estado inicial da sessão
    _estaLogado = supabase.auth.currentSession != null;

    // Escuta por mudanças no estado de autenticação
    supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _estaLogado = data.session != null;
        });
      }
    });
  }

  // Função para fazer logout
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
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white, width: 2.0),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: corPrimaria,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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