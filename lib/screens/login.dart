
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  String userType = "idoso"; // flag inicial


  final AuthService _authService = AuthService();

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> fazerLogin() async {
    try {
      User? user = await _authService.signIn(emailController.text, senhaController.text);
      if (user != null) {
        if (userType == "idoso") {
          Navigator.pushReplacementNamed(context, '/home_idoso');
        } else {
          Navigator.pushReplacementNamed(context, '/home_responsavel');
        }
      }
    } catch (e) {
      mostrarErro('Falha no login: ${e.toString()}');
    }
  }

  Future<void> fazerLoginGoogle() async {
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        // Aqui você pode decidir para onde redirecionar, por exemplo:
        Navigator.pushReplacementNamed(context, '/home_idoso');
      }
    } catch (e) {
      mostrarErro('Falha no login com Google: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

            const SizedBox(height: 20),
            ElevatedButton(onPressed: fazerLogin, child: const Text("Entrar")),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: fazerLoginGoogle,
              icon: Image.asset(
                'assets/google_logo.png',
                height: 24,
                width: 24,
              ),
              label: const Text("Entrar com Google"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register_principal');
              },
              child: const Text("Não tem login? Registre-se"),
            ),
          ],
        ),
      ),
    );
  }
}
