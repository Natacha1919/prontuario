// lib/modelos/evento_timeline.dart

// Classe base para todos os eventos da timeline.
abstract class EventoTimeline {
  final DateTime data;
  EventoTimeline(this.data);
}

// Classe específica para eventos de Anamnese
class EventoAnamnese extends EventoTimeline {
  final String queixaPrincipal;
  final int id;

  EventoAnamnese({
    required DateTime data,
    required this.queixaPrincipal,
    required this.id,
  }) : super(data);
}

// Classe específica para eventos de Solicitação de Exame
class EventoSolicitacaoExame extends EventoTimeline {
  final String justificativa;
  final int id;

  EventoSolicitacaoExame({
    required DateTime data,
    required this.justificativa,
    required this.id,
  }) : super(data);
}

// Adicione outras classes de evento aqui no futuro (Resultados, Coleta, etc.)