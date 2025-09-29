import 'package:flutter/material.dart';

class RegisterPrincipalPage extends StatelessWidget {
  const RegisterPrincipalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // fundo branco
      appBar: AppBar(
        title: const Text(
          'Escolha o tipo de registro',
          style: TextStyle(
            color: Color(0xFF2F2F2F),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2F2F2F)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
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
                  'assets/images/registro_responsavel.png',
                  height: 32,
                  width: 32,
                  color: Colors.white,
                ),
                label: const Text(
                  'Registrar-se como Responsável',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A7CA5), // azul
                  minimumSize: const Size(double.infinity, 56),
                  textStyle: const TextStyle(fontSize: 18),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/register_paciente');
                },
                icon: Image.asset(
                  'assets/images/registro_idoso.png',
                  height: 32,
                  width: 32,
                  color: Colors.white,
                ),
                label: const Text(
                  'Registrar-se como Paciente',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6DBE81), // verde
                  minimumSize: const Size(double.infinity, 56),
                  textStyle: const TextStyle(fontSize: 18),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
