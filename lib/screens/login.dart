import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  final AuthService _authService = AuthService();

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> fazerLogin() async {
    try {
      User? user =
          await _authService.signIn(emailController.text, senhaController.text);
      if (user != null) {
        final firestore = FirestoreService();
        if (await firestore.isResponsavelByEmail(user.email ?? '')) {
          Navigator.pushReplacementNamed(context, '/home_responsavel');
          return;
        }
        if (await firestore.isIdosoByEmail(user.email ?? '')) {
          Navigator.pushReplacementNamed(context, '/home_idoso');
          return;
        }
        mostrarErro('Usuário não encontrado como responsável ou idoso.');
      }
    } catch (e) {
      mostrarErro('Falha no login: ${e.toString()}');
    }
  }

  Future<void> fazerLoginGoogle() async {
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        final firestore = FirestoreService();
        if (await firestore.isResponsavelByEmail(user.email ?? '')) {
          Navigator.pushReplacementNamed(context, '/home_responsavel');
          return;
        }
        if (await firestore.isIdosoByEmail(user.email ?? '')) {
          Navigator.pushReplacementNamed(context, '/home_idoso');
          return;
        }
        mostrarErro('Usuário não encontrado como responsável ou idoso.');
      }
    } catch (e) {
      mostrarErro('Falha no login com Google: ${e.toString()}');
    }
  }

  InputDecoration campoDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF707070)),
      filled: true,
      fillColor: const Color(0xFFE4FBFB), // Azul claro
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none, // Sem linha
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(
            color: Color(0xFF3A7CA5), // Azul título
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3A7CA5)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  40,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(flex: 1, child: SizedBox()),

                  // Campo Email
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: campoDecoration("Email"),
                  ),
                  const SizedBox(height: 16),

                  // Campo Senha
                  TextField(
                    controller: senhaController,
                    decoration: campoDecoration("Senha"),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                  // Botão Entrar
                  ElevatedButton(
                    onPressed: fazerLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7CA5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Entrar",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botão Google
                  ElevatedButton.icon(
                    onPressed: fazerLoginGoogle,
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 20,
                      width: 20,
                    ),
                    label: const Text(
                      "Entrar com Google",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: Colors.grey),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      elevation: 1,
                    ),
                  ),

                  const Flexible(flex: 1, child: SizedBox(height: 20)),

                  // Texto "Não tem login? Registre-se"
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register_principal');
                    },
                    child: const Text(
                      "Não tem login? Registre-se",
                      style: TextStyle(
                        color: Color(0xFFE57373), // Vermelho
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}