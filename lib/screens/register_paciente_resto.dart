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

  InputDecoration campoDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
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
      appBar: AppBar(
        title: const Text(
          'Informações adicionais do paciente',
          style: TextStyle(
            color: Color(0xFF66B2B2),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF66B2B2)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: cpfController,
                decoration: campoDecoration('CPF'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: convenioSelecionado,
                decoration: campoDecoration('Convênio'),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Data de Nascimento: "),
                  Text(
                    dataNascSelecionada == null
                        ? "Selecione"
                        : "${dataNascSelecionada!.day.toString().padLeft(2, '0')}/${dataNascSelecionada!.month.toString().padLeft(2, '0')}/${dataNascSelecionada!.year}",
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
              const SizedBox(height: 10),
              TextField(
                controller: alturaController,
                decoration: campoDecoration('Altura (cm)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pesoController,
                decoration: campoDecoration('Peso (kg)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: telefoneController,
                decoration: campoDecoration('Telefone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: tipoSangSelecionado,
                decoration: campoDecoration('Tipo sanguíneo'),
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
              if (errorMsg != null)
                Text(errorMsg!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : salvarDados,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66B2B2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    side: BorderSide(color: Color(0xFFCCCCCC), width: 1),
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
