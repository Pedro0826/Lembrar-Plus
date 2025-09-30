import 'package:flutter/material.dart';

class LigarIdosoPage extends StatelessWidget {
  final String idosoId;
  const LigarIdosoPage({super.key, required this.idosoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ligar para o paciente')),
      body: const Center(
        child: Text(
          'Tela de ligação para o paciente',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
