import 'package:flutter/material.dart';

class HomeIdoso extends StatelessWidget {
  const HomeIdoso({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Página do Idoso")),
      body: Center(child: Text("Bem-vindo, Idoso!")),
    );
  }
}
