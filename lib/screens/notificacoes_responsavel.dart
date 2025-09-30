import 'package:flutter/material.dart';

class NotificacoesResponsavelPage extends StatelessWidget {
  final String idosoId;
  const NotificacoesResponsavelPage({super.key, required this.idosoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: const Center(
        child: Text(
          'Tela de notificações do responsável',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
