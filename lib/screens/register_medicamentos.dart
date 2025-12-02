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

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A7CA5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background3.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Text(
                    widget.medicamentoId != null
                        ? 'Editar Medicamento'
                        : 'Registrar Medicamento',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF3A7CA5),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Nome do Medicamento
                _buildField('Nome do Medicamento', nomeController),

                // Dosagem
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dosagem',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A7CA5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: dosagemController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Radio<String>(
                                      value: 'mg',
                                      groupValue: unidadeDosagem,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (value) {
                                        if (value != null &&
                                            value != unidadeDosagem) {
                                          setState(() {
                                            unidadeDosagem = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const Text(
                                    'mg',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Radio<String>(
                                      value: 'ml',
                                      groupValue: unidadeDosagem,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (value) {
                                        if (value != null &&
                                            value != unidadeDosagem) {
                                          setState(() {
                                            unidadeDosagem = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const Text(
                                    'ml',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Data de Início
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data de Início',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A7CA5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: dataInicio ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              dataInicio = pickedDate;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF3A7CA5),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                dataInicio != null
                                    ? '${dataInicio!.day.toString().padLeft(2, '0')}/${dataInicio!.month.toString().padLeft(2, '0')}/${dataInicio!.year}'
                                    : 'Selecione a data',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: dataInicio != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkbox para Data de Fim
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Row(
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
                      const Text(
                        'Tem Data de Fim?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3A7CA5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (temDataFim)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data de Fim',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A7CA5),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: dataFim ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dataFim = pickedDate;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF3A7CA5),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  dataFim != null
                                      ? '${dataFim!.day.toString().padLeft(2, '0')}/${dataFim!.month.toString().padLeft(2, '0')}/${dataFim!.year}'
                                      : 'Selecione a data',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: dataFim != null
                                        ? Colors.black87
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Horário de Início
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Horário de Início',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A7CA5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: horarioInicio ?? TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              horarioInicio = pickedTime;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF3A7CA5),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                horarioInicio != null
                                    ? '${horarioInicio!.hour.toString().padLeft(2, '0')}:${horarioInicio!.minute.toString().padLeft(2, '0')}'
                                    : 'Selecione o horário',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: horarioInicio != null
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Período
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Período',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A7CA5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: periodoController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButton<String>(
                                value: unidadePeriodo,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: ['horas', 'dias', 'semanas', 'meses']
                                    .map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    })
                                    .toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null &&
                                      newValue != unidadePeriodo) {
                                    setState(() {
                                      unidadePeriodo = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Observações
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Observações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A7CA5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: observacoesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            hintText: 'Observações adicionais (opcional)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Botão Salvar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : adicionarMedicamento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7CA5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Salvar Medicamento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          // Botão voltar
          Positioned(
            left: 32,
            bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
