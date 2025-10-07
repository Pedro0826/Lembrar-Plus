import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class ServicoNotificacao {
  // Dispara uma notificação imediata para teste
  static Future<void> mostrarNotificacaoImediata({
    required int id,
    required String titulo,
    required String mensagem,
  }) async {
    try {
      await _pluginNotificacoes.show(
        id,
        titulo,
        mensagem,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'canal_medicamentos',
            'Medicamentos',
            channelDescription: 'Notificações de medicamentos',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e, stack) {
      print('Erro ao mostrar notificação imediata: $e');
      print(stack);
    }
  }
  static final FlutterLocalNotificationsPlugin _pluginNotificacoes = FlutterLocalNotificationsPlugin();

  // Inicializa o serviço de notificações locais
  static Future<void> inicializar() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    const AndroidInitializationSettings configAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings config = InitializationSettings(android: configAndroid);
    await _pluginNotificacoes.initialize(config);
  }

  // Agenda uma notificação local para o horário especificado
  static Future<void> agendarNotificacao({
    required int id,
    required String titulo,
    required String mensagem,
    required DateTime horarioAgendado,
  }) async {
    try {
      await _pluginNotificacoes.zonedSchedule(
        id,
        titulo,
        mensagem,
        tz.TZDateTime.from(horarioAgendado, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'canal_medicamentos',
            'Medicamentos',
            channelDescription: 'Notificações de medicamentos',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
  androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e, stack) {
      print('Erro ao agendar notificação: $e');
      print(stack);
    }
  }

  // Cancela todas as notificações agendadas
  static Future<void> cancelarTodas() async {
    await _pluginNotificacoes.cancelAll();
  }
}
