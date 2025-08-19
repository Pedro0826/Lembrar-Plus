import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  String userType = "idoso"; // flag inicial

  void fazerLogin() {
    // Aqui futuramente você vai chamar o Firebase
    if (userType == "idoso") {
      Navigator.pushReplacementNamed(context, '/home_idoso');
    } else {
      Navigator.pushReplacementNamed(context, '/home_responsavel');
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

            // Alternar tipo de usuário
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: "idoso",
                  groupValue: userType,
                  onChanged: (value) {
                    setState(() => userType = value!);
                  },
                ),
                const Text("Idoso"),
                Radio<String>(
                  value: "responsavel",
                  groupValue: userType,
                  onChanged: (value) {
                    setState(() => userType = value!);
                  },
                ),
                const Text("Responsável"),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: fazerLogin, child: const Text("Entrar")),
          ],
        ),
      ),
    );
  }
}
