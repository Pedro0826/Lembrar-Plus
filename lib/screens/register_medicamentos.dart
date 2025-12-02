import '../services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterMedicamentosPage extends StatefulWidget {
  final String idosoId;
  final String? medicamentoId;
  final Map<String, dynamic>? medicamentoData;
  const RegisterMedicamentosPage({
    super.key,
    required this.idosoId,
    this.medicamentoId,
    this.medicamentoData,
  });

  @override
  State<RegisterMedicamentosPage> createState() =>
      _RegisterMedicamentosPageState();
}

class _RegisterMedicamentosPageState extends State<RegisterMedicamentosPage> {
  late TextEditingController nomeController;
  late TextEditingController dosagemController;
  late TextEditingController periodoController;
  late TextEditingController observacoesController;

  late DateTime? dataInicio;
  late DateTime? dataFim;
  late TimeOfDay? horarioInicio;
  late bool temDataFim;
  late String unidadeDosagem;
  late String unidadePeriodo;
  bool isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController();
    dosagemController = TextEditingController();
    periodoController = TextEditingController();
    observacoesController = TextEditingController();

    dataInicio = null;
    dataFim = null;
    horarioInicio = null;
    temDataFim = false;
    unidadeDosagem = 'mg';
    unidadePeriodo = 'horas';

    // Se for edição, preenche os campos
    if (widget.medicamentoData != null) {
      final data = widget.medicamentoData!;
      nomeController.text = data['nome'] ?? '';
      dosagemController.text = data['dosagem']?.toString() ?? '';
      periodoController.text = data['periodo']?.toString() ?? '';
      observacoesController.text = data['observacoes'] ?? '';
      unidadeDosagem = data['unidadeDosagem'] ?? 'mg';
      unidadePeriodo = data['unidadePeriodo'] ?? 'horas';
      if (data['dataInicio'] != null) {
        if (data['dataInicio'] is Timestamp) {
          dataInicio = (data['dataInicio'] as Timestamp).toDate();
        } else if (data['dataInicio'] is DateTime) {
          dataInicio = data['dataInicio'];
        }
      }
      if (data['dataFim'] != null) {
        temDataFim = true;
        if (data['dataFim'] is Timestamp) {
          dataFim = (data['dataFim'] as Timestamp).toDate();
        } else if (data['dataFim'] is DateTime) {
          dataFim = data['dataFim'];
        }
      }
      if (data['horarioInicio'] != null && data['horarioInicio'] is String) {
        final parts = (data['horarioInicio'] as String).split(':');
        if (parts.length == 2) {
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour != null && minute != null) {
            horarioInicio = TimeOfDay(hour: hour, minute: minute);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    dosagemController.dispose();
    periodoController.dispose();
    observacoesController.dispose();
    super.dispose();
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
      if (widget.medicamentoId != null) {
        // Atualizar medicamento existente
        await FirebaseFirestore.instance
            .collection('medicamentos')
            .doc(widget.medicamentoId)
            .update({
              'idosoId': widget.idosoId,
              'nome': nome,
              'dosagem': dosagem,
              'unidadeDosagem': unidadeDosagem,
              'dataInicio': Timestamp.fromDate(dataInicio!),
              'dataFim': temDataFim && dataFim != null
                  ? Timestamp.fromDate(dataFim!)
                  : null,
              'horarioInicio': horarioInicio != null
                  ? '${horarioInicio!.hour.toString().padLeft(2, '0')}:${horarioInicio!.minute.toString().padLeft(2, '0')}'
                  : null,
              'periodo': periodo,
              'unidadePeriodo': unidadePeriodo,
              'observacoes': observacoes,
            })
            .timeout(
              const Duration(seconds: 3),
              onTimeout: () {
                return;
              },
            );
      } else {
        // Criar novo medicamento
        await _firestoreService
            .addMedicamento(
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
            )
            .timeout(
              const Duration(seconds: 3),
              onTimeout: () {
                return;
              },
            );
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.medicamentoId != null
                ? 'Medicamento atualizado com sucesso!'
                : 'Medicamento salvo com sucesso!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
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
                              if (value != null && value != unidadeDosagem) {
                                setState(() {
                                  unidadeDosagem = value;
                                });
                              }
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
                              if (value != null && value != unidadeDosagem) {
                                setState(() {
                                  unidadeDosagem = value;
                                });
                              }
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
                      if (value != null && value != temDataFim) {
                        setState(() {
                          temDataFim = value;
                          if (!temDataFim) {
                            dataFim = null;
                          }
                        });
                      }
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
                      if (newValue != null && newValue != unidadePeriodo) {
                        setState(() {
                          unidadePeriodo = newValue;
                        });
                      }
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
