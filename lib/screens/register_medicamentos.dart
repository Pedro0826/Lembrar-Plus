import '../services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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


  @override
  void initState() {
    super.initState();
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

  // ...existing code...

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
