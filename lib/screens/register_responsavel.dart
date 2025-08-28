
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class RegisterResponsavelPage extends StatefulWidget {
  const RegisterResponsavelPage({super.key});

  @override
  State<RegisterResponsavelPage> createState() => _RegisterResponsavelPageState();
}


class _RegisterResponsavelPageState extends State<RegisterResponsavelPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  // Não precisa de userType ou didChangeDependencies para idoso

  final AuthService _authService = AuthService();

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> registrarUsuario() async {
    String nome = nomeController.text;
    String email = emailController.text;
    String senha = senhaController.text;
    try {
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      // Opcional: atualizar o displayName
      await cred.user?.updateDisplayName(nome);
      Navigator.pushReplacementNamed(context, '/home_responsavel');
    } catch (e) {
      mostrarErro('Erro ao registrar: ${e.toString()}');
    }
  }

  Future<void> registrarComGoogle() async {
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        // Aqui você pode decidir para onde redirecionar
        Navigator.pushReplacementNamed(context, '/home_responsavel');
      }
    } catch (e) {
      mostrarErro('Erro ao registrar com Google: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar como responsável")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: "Nome"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: senhaController,
                decoration: const InputDecoration(labelText: "Senha"),
                obscureText: true,
              ),
              const SizedBox(height: 20),


              ElevatedButton(
                onPressed: registrarUsuario,
                child: const Text("Registrar"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: registrarComGoogle,
                icon: Image.asset(
                  'assets/google_logo.png',
                  height: 24,
                  width: 24,
                ),
                label: const Text("Registrar com Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
