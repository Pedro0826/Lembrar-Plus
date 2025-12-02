import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class RegisterIdosoRestoPage extends StatefulWidget {
  final String idosoId;
  const RegisterIdosoRestoPage({super.key, required this.idosoId});

  @override
  State<RegisterIdosoRestoPage> createState() => _RegisterIdosoRestoPageState();
}

class _RegisterIdosoRestoPageState extends State<RegisterIdosoRestoPage> {
  final TextEditingController alturaController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  DateTime? dataNascSelecionada;
  String convenioSelecionado = 'Unimed';
  String tipoSangSelecionado = 'A+';
  bool isLoading = false;
  String? errorMsg;

  Widget editBox({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
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
            child: child,
          ),
        ],
      ),
    );
  }

  Future<void> salvarDados() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    if (dataNascSelecionada == null) {
      setState(() {
        errorMsg = 'Selecione a data de nascimento.';
        isLoading = false;
      });
      return;
    }

    try {
      await FirestoreService().atualizarDadosIdoso(
        idosoId: widget.idosoId,
        convenio: convenioSelecionado,
        dataNasc: dataNascSelecionada!,
        altura: double.tryParse(alturaController.text.trim()) ?? 0,
        peso: double.tryParse(pesoController.text.trim()) ?? 0,
        telefone: telefoneController.text.trim(),
        tipoSanguineo: tipoSangSelecionado,
        cpf: cpfController.text.trim(),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        errorMsg = 'Erro ao salvar: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
                    'Informações adicionais do paciente',
                    textAlign: TextAlign.center,
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
                editBox(
                  label: 'CPF',
                  child: TextField(
                    controller: cpfController,
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
                editBox(
                  label: 'Convênio',
                  child: DropdownButtonFormField<String>(
                    value: convenioSelecionado,
                    items: const [
                      DropdownMenuItem(value: 'Unimed', child: Text('Unimed')),
                      DropdownMenuItem(value: 'Ipsemg', child: Text('Ipsemg')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        convenioSelecionado = value ?? 'Unimed';
                      });
                    },
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                editBox(
                  label: 'Data de Nascimento',
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dataNascSelecionada == null
                              ? 'Selecione'
                              : '${dataNascSelecionada!.day.toString().padLeft(2, '0')}/${dataNascSelecionada!.month.toString().padLeft(2, '0')}/${dataNascSelecionada!.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000, 1, 1),
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
                editBox(
                  label: 'Altura (cm)',
                  child: TextField(
                    controller: alturaController,
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
                editBox(
                  label: 'Peso (kg)',
                  child: TextField(
                    controller: pesoController,
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
                editBox(
                  label: 'Telefone',
                  child: TextField(
                    controller: telefoneController,
                    keyboardType: TextInputType.phone,
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
                editBox(
                  label: 'Tipo sanguíneo',
                  child: DropdownButtonFormField<String>(
                    value: tipoSangSelecionado,
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
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : salvarDados,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7CA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
          // Botão voltar
          Positioned(
            left: 24,
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
