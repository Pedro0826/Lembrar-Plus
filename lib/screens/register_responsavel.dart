import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'register_responsavel_resto.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

class RegisterResponsavelPage extends StatefulWidget {
  const RegisterResponsavelPage({super.key});

  @override
  State<RegisterResponsavelPage> createState() =>
      _RegisterResponsavelPageState();
}

class _RegisterResponsavelPageState extends State<RegisterResponsavelPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  DateTime? dataNascSelecionada;

  final AuthService _authService = AuthService();

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> registrarUsuario() async {
    String nome = nomeController.text;
    String telefone = telefoneController.text;
    String email = emailController.text;
    String senha = senhaController.text;
    String cpf = cpfController.text;
    DateTime? dataNasc = dataNascSelecionada;

    if (dataNasc == null) {
      mostrarErro('Selecione a data de nascimento.');
      return;
    }
    if (!validarCPF(cpf)) {
      mostrarErro('CPF inválido.');
      return;
    }

    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);
      await cred.user?.updateDisplayName(nome);

      final firestoreService = FirestoreService();
      await firestoreService.addResponsavel(
        nome: nome,
        telefone: telefone,
        email: email,
        dataNasc: dataNasc,
        cpf: cpf,
      );

      Navigator.pushReplacementNamed(context, '/home_responsavel');
    } catch (e) {
      mostrarErro('Erro ao registrar: ${e.toString()}');
    }
  }

  Future<void> registrarComGoogle() async {
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        String nome = user.displayName ?? '';
        String email = user.email ?? '';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterResponsavelRestoPage(
              nome: nome,
              email: email,
            ),
          ),
        );
      }
    } catch (e) {
      mostrarErro('Erro ao registrar com Google: ${e.toString()}');
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
        borderSide: BorderSide.none
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // fundo branco
      appBar: AppBar(
        title: const Text(
          "Registrar como responsável",
          style: TextStyle(
            color: Color(0xFF3A7CA5), // azul título
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
              TextField(controller: nomeController, decoration: campoDecoration("Nome")),
              const SizedBox(height: 10),
              TextField(
                controller: telefoneController,
                decoration: campoDecoration("Telefone"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextField(controller: emailController, decoration: campoDecoration("Email")),
              const SizedBox(height: 10),
              TextField(
                controller: senhaController,
                decoration: campoDecoration("Senha"),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cpfController,
                decoration: campoDecoration("CPF"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Data de Nascimento: "),
                  Text(dataNascSelecionada == null
                      ? "Selecione"
                      : "${dataNascSelecionada!.day}/${dataNascSelecionada!.month}/${dataNascSelecionada!.year}"),
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
              const SizedBox(height: 20),

              // Botão Registrar
              ElevatedButton(
                onPressed: registrarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A7CA5), // mesma cor do login
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  elevation: 2,
                ),
                child: const Text("Registrar"),
              ),
              const SizedBox(height: 10),

              // Botão Google
              ElevatedButton.icon(
                onPressed: registrarComGoogle,
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  height: 24,
                  width: 24,
                ),
                label: const Text("Registrar com Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.grey),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  elevation: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}