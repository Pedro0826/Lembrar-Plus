import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

// Caixa de edição no mesmo estilo do paciente_info
class _EditBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _EditBox({required this.label, required this.controller});

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
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 64, 161, 108),
                fontWeight: FontWeight.w500,
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
  const EditarPacientePage({super.key, required this.idosoId, required this.dados});

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

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.dados['nome'] ?? '');
    apelidoController = TextEditingController(text: widget.dados['apelido'] ?? '');
    cpfController = TextEditingController(text: widget.dados['cpf'] ?? '');
    telefoneController = TextEditingController(text: widget.dados['telefone'] ?? '');
    pesoController = TextEditingController(text: widget.dados['peso']?.toString() ?? '');
    alturaController = TextEditingController(text: widget.dados['altura']?.toString() ?? '');
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
    bool completed = false;
    Future updateFuture = FirebaseFirestore.instance.collection('idoso').doc(widget.idosoId).update({
      'nome': nomeController.text.trim(),
      'apelido': apelidoController.text.trim(),
      'cpf': cpfController.text.trim(),
      'data_nasc': dataNascSelecionada ?? '',
      'telefone': telefoneController.text.trim(),
      'convenio': convenioSelecionado,
      'tipo_sanguineo': tipoSangSelecionado,
      'peso': double.tryParse(pesoController.text.trim()),
      'altura': double.tryParse(alturaController.text.trim()),
    }).then((_) {
      completed = true;
      if (mounted) {
        Navigator.pop(context, true);
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
    });

    await Future.any([
      updateFuture,
      Future.delayed(const Duration(seconds: 3)),
    ]);
    if (!completed && mounted) {
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
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: dataNascSelecionada ?? DateTime(2000, 1, 1),
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
                // Convênio como dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: DropdownButtonFormField<String>(
                    value: convenioSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Convênio',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Unimed', child: Text('Unimed')),
                      DropdownMenuItem(value: 'Ipsemg', child: Text('Ipsemg')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        convenioSelecionado = value ?? 'Unimed';
                      });
                    },
                  ),
                ),
                // Tipo sanguíneo como dropdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: DropdownButtonFormField<String>(
                    value: tipoSangSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo Sanguíneo',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'A+', child: Text('A+')),
                      DropdownMenuItem(value: 'A-', child: Text('A-')),
                      DropdownMenuItem(value: 'B+', child: Text('B+')),
                      DropdownMenuItem(value: 'B-', child: Text('B-')),
                      DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                      DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                      DropdownMenuItem(value: 'O+', child: Text('O+')),
                      DropdownMenuItem(value: 'O-', child: Text('O-')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tipoSangSelecionado = value ?? 'A+';
                      });
                    },
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
                    onPressed: salvarEdicao,
                    child: const Text('Salvar Alterações'),
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
