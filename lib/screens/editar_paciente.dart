import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

// Reusable input box used across forms
class _EditBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _EditBox({required this.label, required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
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
}

class EditarPacientePage extends StatefulWidget {
  final String idosoId;
  final Map<String, dynamic> dados;
  const EditarPacientePage({
    super.key,
    required this.idosoId,
    required this.dados,
  });

  @override
  State<EditarPacientePage> createState() => _EditarPacientePageState();
}

class _EditarPacientePageState extends State<EditarPacientePage> {
  late TextEditingController nomeController;
  late TextEditingController apelidoController;
  late TextEditingController cpfController;
  late TextEditingController telefoneController;
  late TextEditingController pesoController;
  late TextEditingController alturaController;
  DateTime? dataNascSelecionada;
  String convenioSelecionado = 'Unimed';
  String tipoSangSelecionado = 'A+';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.dados['nome'] ?? '');
    apelidoController = TextEditingController(
      text: widget.dados['apelido'] ?? '',
    );
    cpfController = TextEditingController(text: widget.dados['cpf'] ?? '');
    telefoneController = TextEditingController(
      text: widget.dados['telefone'] ?? '',
    );
    pesoController = TextEditingController(
      text: widget.dados['peso']?.toString() ?? '',
    );
    alturaController = TextEditingController(
      text: widget.dados['altura']?.toString() ?? '',
    );
    // Data de nascimento
    final dn = widget.dados['data_nasc'];
    if (dn is Timestamp) {
      dataNascSelecionada = dn.toDate();
    } else if (dn is String && dn.isNotEmpty) {
      final parts = dn.split('/');
      if (parts.length == 3) {
        dataNascSelecionada = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    }
    // Convênio
    convenioSelecionado = widget.dados['convenio'] ?? 'Unimed';
    // Tipo sanguíneo
    tipoSangSelecionado = widget.dados['tipo_sanguineo'] ?? 'A+';
  }

  Future<void> salvarEdicao() async {
    setState(() {
      isLoading = true;
    });
    bool completed = false;
    Future updateFuture = FirebaseFirestore.instance
        .collection('idoso')
        .doc(widget.idosoId)
        .update({
          'nome': nomeController.text.trim(),
          'apelido': apelidoController.text.trim(),
          'cpf': cpfController.text.trim(),
          'data_nasc': dataNascSelecionada ?? '',
          'telefone': telefoneController.text.trim(),
          'convenio': convenioSelecionado,
          'tipo_sanguineo': tipoSangSelecionado,
          'peso': double.tryParse(pesoController.text.trim()),
          'altura': double.tryParse(alturaController.text.trim()),
        })
        .then((_) {
          completed = true;
          if (mounted) {
            Navigator.pop(context, true);
          }
        })
        .catchError((e) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erro ao salvar: ${e.toString()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        });

    await Future.any([
      updateFuture,
      Future.delayed(const Duration(seconds: 3)),
    ]);
    if (!completed && mounted) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context, true);
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
                const Center(
                  child: Text(
                    'Editar Paciente',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF3A7CA5),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _EditBox(label: 'Nome', controller: nomeController),
                _EditBox(label: 'Apelido', controller: apelidoController),
                _EditBox(label: 'CPF', controller: cpfController),
                // Data de nascimento com seletor
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Row(
                    children: [
                      const Text(
                        'Data de Nascimento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A7CA5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        dataNascSelecionada == null
                            ? 'Selecione'
                            : '${dataNascSelecionada!.day.toString().padLeft(2, '0')}/${dataNascSelecionada!.month.toString().padLeft(2, '0')}/${dataNascSelecionada!.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                dataNascSelecionada ?? DateTime(2000, 1, 1),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              dataNascSelecionada = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                _EditBox(label: 'Telefone', controller: telefoneController),
                // Convênio como dropdown com rótulo e estilo similar ao _EditBox
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plano de Saúde',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A7CA5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: convenioSelecionado,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Unimed',
                              child: Text(
                                'Unimed',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Ipsemg',
                              child: Text(
                                'Ipsemg',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              convenioSelecionado = value ?? 'Unimed';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Tipo sanguíneo com rótulo e estilo igual ao Convênio/_EditBox
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo Sanguíneo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A7CA5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: tipoSangSelecionado,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'A+',
                              child: Text(
                                'A+',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'A-',
                              child: Text(
                                'A-',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'B+',
                              child: Text(
                                'B+',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'B-',
                              child: Text(
                                'B-',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'AB+',
                              child: Text(
                                'AB+',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'AB-',
                              child: Text(
                                'AB-',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'O+',
                              child: Text(
                                'O+',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'O-',
                              child: Text(
                                'O-',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              tipoSangSelecionado = value ?? 'A+';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                _EditBox(label: 'Peso (kg)', controller: pesoController),
                _EditBox(label: 'Altura (cm)', controller: alturaController),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7CA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    onPressed: isLoading ? null : salvarEdicao,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Salvar Alterações'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Botão voltar igual ao paciente_info
          Positioned(
            left: 32,
            bottom: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey,
                shape: const CircleBorder(),
                elevation: 4,
                padding: const EdgeInsets.all(18),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, size: 36),
            ),
          ),
        ],
      ),
    );
  }
}
