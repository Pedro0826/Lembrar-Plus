import '../services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class RegisterMedicamentosPage extends StatefulWidget {
  final String idosoId;
  const RegisterMedicamentosPage({super.key, required this.idosoId});

  @override
  State<RegisterMedicamentosPage> createState() =>
      _RegisterMedicamentosPageState();
}

class _RegisterMedicamentosPageState extends State<RegisterMedicamentosPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController dosagemController = TextEditingController();
  final TextEditingController periodoController = TextEditingController();
  final TextEditingController observacoesController = TextEditingController();

  DateTime? dataInicio;
  DateTime? dataFim;
  TimeOfDay? horarioInicio;
  bool temDataFim = false;
  String unidadeDosagem = 'mg'; // mg ou ml
  String unidadePeriodo = 'horas'; // horas, dias, semanas, meses
  bool isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeLocalNotifications();
    tz.initializeTimeZones(); // Inicializa os timezones
  }

  void _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotificationsPlugin.initialize(initSettings);
  }

  InputDecoration campoDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Color(0xFF707070)),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF66B2B2)),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }

  Future<void> testarNotificacao() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test_channel', // ID do canal
          'Testes', // Nome do canal
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotificationsPlugin.show(
      0, // ID da notificação
      'Teste de Notificação', // Título
      'Esta é uma notificação de teste.', // Corpo
      notificationDetails,
    );
  }

  Future<void> testarNotificacaoAgendada() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test_channel', // ID do canal
          'Testes', // Nome do canal
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final DateTime horario = DateTime.now().add(const Duration(minutes: 1));

    await _localNotificationsPlugin.zonedSchedule(
      1, // ID único para a notificação
      'Teste de Notificação Agendada', // Título
      'Esta notificação foi agendada para 1 minuto no futuro.', // Corpo
      tz.TZDateTime.from(horario, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _agendarNotificacoes({
    required String nome,
    required DateTime dataInicio,
    required TimeOfDay horarioInicio,
    required int periodo,
    required String unidadePeriodo,
    DateTime? dataFim,
  }) async {
    // Converter TimeOfDay para DateTime
    DateTime horarioInicial = DateTime(
      dataInicio.year,
      dataInicio.month,
      dataInicio.day,
      horarioInicio.hour,
      horarioInicio.minute,
    );

    // Determinar o intervalo em horas
    int intervaloHoras;
    switch (unidadePeriodo) {
      case 'horas':
        intervaloHoras = periodo;
        break;
      case 'dias':
        intervaloHoras = periodo * 24;
        break;
      case 'semanas':
        intervaloHoras = periodo * 24 * 7;
        break;
      case 'meses':
        intervaloHoras = periodo * 24 * 30; // Aproximação para meses
        break;
      default:
        intervaloHoras = 0;
    }

    if (intervaloHoras <= 0) return;

    // Agendar notificações até a data final (ou por 30 dias se não houver data final)
    DateTime limite = dataFim ?? dataInicio.add(const Duration(days: 30));
    while (horarioInicial.isBefore(limite)) {
      await _agendarNotificacaoLocal(horarioInicial, nome);
      horarioInicial = horarioInicial.add(Duration(hours: intervaloHoras));
    }
  }

  Future<void> _agendarNotificacaoLocal(
    DateTime horario,
    String medicamento,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'medicamentos_channel',
          'Medicamentos',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotificationsPlugin.zonedSchedule(
      horario.hashCode, // ID único para cada notificação
      'Hora do medicamento',
      'Está na hora de tomar $medicamento',
      tz.TZDateTime.from(
        horario,
        tz.local,
      ), // Certifique-se de que 'horario' é um DateTime válido
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> adicionarMedicamento() async {
    final nome = nomeController.text.trim();
    final dosagem = dosagemController.text.trim();
    final periodo = int.tryParse(periodoController.text.trim());
    final observacoes = observacoesController.text.trim();

    if (nome.isEmpty ||
        dosagem.isEmpty ||
        dataInicio == null ||
        horarioInicio == null ||
        periodo == null ||
        periodo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _firestoreService.addMedicamento(
        idosoId: widget.idosoId,
        nome: nome,
        dosagem: dosagem,
        unidadeDosagem: unidadeDosagem,
        dataInicio: Timestamp.fromDate(dataInicio!),
        dataFim: temDataFim && dataFim != null
            ? Timestamp.fromDate(dataFim!)
            : null,
        horarioInicio: horarioInicio != null
            ? '${horarioInicio!.hour.toString().padLeft(2, '0')}:${horarioInicio!.minute.toString().padLeft(2, '0')}'
            : null,
        periodo: periodo,
        unidadePeriodo: unidadePeriodo,
        observacoes: observacoes,
      );

      // Agendar notificações
      await _agendarNotificacoes(
        nome: nome,
        dataInicio: dataInicio!,
        horarioInicio: horarioInicio!,
        periodo: periodo,
        unidadePeriodo: unidadePeriodo,
        dataFim: temDataFim ? dataFim : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicamento salvo com sucesso!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Medicamento'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF66B2B2)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome do Medicamento
              TextField(
                controller: nomeController,
                decoration: campoDecoration('Nome do medicamento'),
              ),
              const SizedBox(height: 16),

              // Dosagem com opções mg/ml
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dosagemController,
                      decoration: campoDecoration('Dosagem'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'mg',
                            groupValue: unidadeDosagem,
                            onChanged: (value) {
                              setState(() {
                                unidadeDosagem = value!;
                              });
                            },
                          ),
                          const Text('mg'),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'ml',
                            groupValue: unidadeDosagem,
                            onChanged: (value) {
                              setState(() {
                                unidadeDosagem = value!;
                              });
                            },
                          ),
                          const Text('ml'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Data de Início
              Row(
                children: [
                  const Text('Data de Início:'),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dataInicio = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      dataInicio != null
                          ? '${dataInicio!.day}/${dataInicio!.month}/${dataInicio!.year}'
                          : 'Selecionar',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Checkbox para Data de Fim
              Row(
                children: [
                  Checkbox(
                    value: temDataFim,
                    onChanged: (value) {
                      setState(() {
                        temDataFim = value!;
                        if (!temDataFim) {
                          dataFim = null;
                        }
                      });
                    },
                  ),
                  const Text('Tem Data de Fim?'),
                ],
              ),
              if (temDataFim)
                Row(
                  children: [
                    const Text('Data de Fim:'),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dataFim = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        dataFim != null
                            ? '${dataFim!.day}/${dataFim!.month}/${dataFim!.year}'
                            : 'Selecionar',
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Horário de Início
              Row(
                children: [
                  const Text('Horário de Início:'),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          horarioInicio = pickedTime;
                        });
                      }
                    },
                    child: Text(
                      horarioInicio != null
                          ? '${horarioInicio!.hour.toString().padLeft(2, '0')}:${horarioInicio!.minute.toString().padLeft(2, '0')}'
                          : 'Selecionar',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Período
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: periodoController,
                      decoration: campoDecoration('Período'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: unidadePeriodo,
                    items: ['horas', 'dias', 'semanas', 'meses'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        unidadePeriodo = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Observações
              TextField(
                controller: observacoesController,
                decoration: campoDecoration('Observações (opcional)'),
                maxLines: 3, // Permite que o usuário digite várias linhas
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: testarNotificacao,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66B2B2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  elevation: 0,
                ),
                child: const Text('Testar Notificação'),
              ),

              ElevatedButton(
                onPressed: testarNotificacaoAgendada,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66B2B2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  elevation: 0,
                ),
                child: const Text('Testar Notificação Agendada'),
              ),

              // Botão Salvar
              ElevatedButton(
                onPressed: isLoading ? null : adicionarMedicamento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66B2B2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
