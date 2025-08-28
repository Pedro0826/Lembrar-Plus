import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool isLoading = true;
  String? userType; // pode ser "idoso" ou "responsavel"

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  Future<void> _checkUserLoggedIn() async {
    // Simulação de delay (como se fosse consultar Firebase)
    await Future.delayed(const Duration(seconds: 2));

    // Aqui você faria: FirebaseAuth.instance.currentUser
    // Por enquanto, vou deixar como "null" (ninguém logado)
    setState(() {
      userType = null; // troque para "idoso" ou "responsavel" para testar
      isLoading = false;
    });

    // Se já tiver logado, redireciona
    if (userType == "idoso") {
      Navigator.pushReplacementNamed(context, '/home_idoso');
    } else if (userType == "responsavel") {
      Navigator.pushReplacementNamed(context, '/home_responsavel');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Caso não esteja logado
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Bem-vindo ao Lembrar+",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text("Já tenho conta (Login)"),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Registrar como:'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // fecha o dialog
                              Navigator.pushNamed(context, '/register', arguments: 'idoso');
                            },
                            child: const Text('Idoso'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/register', arguments: 'responsavel');
                            },
                            child: const Text('Responsável'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text("Sou novo aqui (Registrar)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
