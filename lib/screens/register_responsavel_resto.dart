import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class RegisterResponsavelRestoPage extends StatefulWidget {
  final String nome;
  final String email;
  const RegisterResponsavelRestoPage({super.key, required this.nome, required this.email});

  @override
  State<RegisterResponsavelRestoPage> createState() => _RegisterResponsavelRestoPageState();
}

class _RegisterResponsavelRestoPageState extends State<RegisterResponsavelRestoPage> {
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  DateTime? dataNascSelecionada;
  bool isLoading = false;

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  bool validarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11 || RegExp(r'(\d)\1{10}').hasMatch(cpf)) return false;
    List<int> digits = cpf.split('').map(int.parse).toList();
    int calc(int n) {
      int sum = 0;
      for (int i = 0; i < n; i++) {
        sum += digits[i] * (n + 1 - i);
      }
      int mod = (sum * 10) % 11;
      return mod == 10 ? 0 : mod;
    }
    return calc(9) == digits[9] && calc(10) == digits[10];
  }

  Future<void> salvarDados() async {
    String telefone = telefoneController.text.trim();
    String cpf = cpfController.text.trim();
    DateTime? dataNasc = dataNascSelecionada;

    if (telefone.isEmpty || cpf.isEmpty || dataNasc == null) {
      mostrarErro('Preencha todos os campos.');
      return;
    }
    if (!validarCPF(cpf)) {
      mostrarErro('CPF inválido.');
      return;
    }

    setState(() { isLoading = true; });

    try {
      final firestoreService = FirestoreService();
      await firestoreService.addResponsavel(
        nome: widget.nome,
        telefone: telefone,
        email: widget.email,
        dataNasc: dataNasc,
        cpf: cpf,
      );
      Navigator.pushReplacementNamed(context, '/home_responsavel');
    } catch (e) {
      mostrarErro('Erro ao salvar dados: ${e.toString()}');
    } finally {
      setState(() { isLoading = false; });
    }
  }

  InputDecoration campoDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF707070)),
      filled: true,
      fillColor: const Color(0xFFE4FBFB),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Completar dados do cuidador',
          style: TextStyle(
            color: Color(0xFF3A7CA5),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3A7CA5)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: telefoneController,
                decoration: campoDecoration('Telefone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cpfController,
                decoration: campoDecoration('CPF'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Data de Nascimento: ", style: TextStyle(fontSize: 16)),
                  Text(
                    dataNascSelecionada == null
                        ? "Selecione"
                        : "${dataNascSelecionada!.day}/${dataNascSelecionada!.month}/${dataNascSelecionada!.year}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Color(0xFF3A7CA5)),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000, 1, 1),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() { dataNascSelecionada = picked; });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : salvarDados,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A7CA5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  elevation: 2,
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