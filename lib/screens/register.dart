import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  String userType = "idoso"; // valor padrão

  void registrarUsuario() {
    String nome = nomeController.text;
    String email = emailController.text;
    String senha = senhaController.text;

    // Aqui futuramente vai entrar a lógica do Firebase
    print("Novo usuário:");
    print("Nome: $nome");
    print("Email: $email");
    print("Senha: $senha");
    print("Tipo: $userType");

    // Redireciona após registro
    if (userType == "idoso") {
      Navigator.pushReplacementNamed(context, '/home_idoso');
    } else {
      Navigator.pushReplacementNamed(context, '/home_responsavel');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar")),
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

              // Seleção de tipo
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

              ElevatedButton(
                onPressed: registrarUsuario,
                child: const Text("Registrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
