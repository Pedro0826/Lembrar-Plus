import 'package:flutter/material.dart';

class HomeResponsavel extends StatelessWidget {
  const HomeResponsavel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Página do Responsável")),
      body: Center(child: Text("Bem-vindo, Responsável!")),
    );
  }
}
