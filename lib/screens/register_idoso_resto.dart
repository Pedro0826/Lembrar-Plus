import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'register_responsavel.dart';

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

  Future<void> salvarDados() async {
    setState(() { isLoading = true; errorMsg = null; });
    final cpf = cpfController.text.trim();
    if (!validarCPF(cpf)) {
      setState(() { errorMsg = 'CPF inválido.'; isLoading = false; });
      return;
    }
    if (dataNascSelecionada == null) {
      setState(() { errorMsg = 'Selecione a data de nascimento.'; isLoading = false; });
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
        cpf: cpf,
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() { errorMsg = 'Erro ao salvar: ${e.toString()}'; });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informações adicionais do idoso')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: cpfController,
                decoration: const InputDecoration(labelText: 'CPF'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: convenioSelecionado,
                decoration: const InputDecoration(labelText: 'Convênio'),
                items: const [
                  DropdownMenuItem(value: 'Unimed', child: Text('Unimed')),
                  DropdownMenuItem(value: 'Ipsemg', child: Text('Ipsemg')),
                ],
                onChanged: (value) {
                  setState(() { convenioSelecionado = value ?? 'Unimed'; });
                },
              ),
              Row(
                children: [
                  const Text("Data de Nascimento: "),
                  Text(dataNascSelecionada == null
                      ? "Selecione"
                      : "${dataNascSelecionada!.day.toString().padLeft(2, '0')}/${dataNascSelecionada!.month.toString().padLeft(2, '0')}/${dataNascSelecionada!.year}"),
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
              TextField(
                controller: alturaController,
                decoration: const InputDecoration(labelText: 'Altura (cm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: pesoController,
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              DropdownButtonFormField<String>(
                value: tipoSangSelecionado,
                decoration: const InputDecoration(labelText: 'Tipo sanguíneo'),
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
                  setState(() { tipoSangSelecionado = value ?? 'A+'; });
                },
              ),
              if (errorMsg != null)
                Text(errorMsg!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: isLoading ? null : salvarDados,
                child: isLoading ? const CircularProgressIndicator() : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
