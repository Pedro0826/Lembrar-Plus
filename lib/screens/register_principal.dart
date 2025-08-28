import 'package:flutter/material.dart';

class RegisterPrincipalPage extends StatelessWidget {
  const RegisterPrincipalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha o tipo de registro')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/register_responsavel');
                },
                icon: Image.asset(
                  'assets/registro_responsavel.png',
                  height: 32,
                  width: 32,
                ),
                label: const Text('Registrar-se como Responsável'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/register_idoso');
                },
                icon: Image.asset(
                  'assets/registro_idoso.png',
                  height: 32,
                  width: 32,
                ),
                label: const Text('Registrar-se como Idoso'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
