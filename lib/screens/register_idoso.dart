import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterIdosoPage extends StatefulWidget {
  const RegisterIdosoPage({super.key});

  @override
  State<RegisterIdosoPage> createState() => _RegisterIdosoPageState();
}

class _RegisterIdosoPageState extends State<RegisterIdosoPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  final AuthService _authService = AuthService();

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> registrarUsuario() async {
    String nome = nomeController.text;
    String email = emailController.text;
    String senha = senhaController.text;

    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);
      await cred.user?.updateDisplayName(nome);

      final firestoreService = FirestoreService();
      // Use o UID como ID do documento no Firestore
      await firestoreService.addIdoso(nome: nome, email: email);

      Navigator.pushReplacementNamed(context, '/home_idoso');
    } catch (e) {
      mostrarErro('Erro ao registrar: ${e.toString()}');
    }
  }

  Future<void> registrarComGoogle() async {
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        final firestoreService = FirestoreService();
        // Use o UID como ID do documento no Firestore
        await firestoreService.addIdoso(
          nome: user.displayName ?? '',
          email: user.email ?? '',
        );
        Navigator.pushReplacementNamed(context, '/home_idoso');
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
      fillColor: const Color(0xFFD8F8E1),
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
          "Registrar como idoso",
          style: TextStyle(
            color: Color(0xFF6DBE81),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF6DBE81)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomeController,
                decoration: campoDecoration("Nome"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: campoDecoration("Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: senhaController,
                decoration: campoDecoration("Senha"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registrarUsuario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6DBE81),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    side: BorderSide(color: Color(0xFF707070), width: 1),
                  ),
                  elevation: 0,
                ),
                child: const Text("Registrar"),
              ),
              const SizedBox(height: 10),
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
                  foregroundColor: const Color(0xFF707070),
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Color(0xFF707070)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
