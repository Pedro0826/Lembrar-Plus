import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeIdoso extends StatelessWidget {
  const HomeIdoso({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getIdosoData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final idoso = snapshot.data!;
        final codigo = idoso['codigo'] ?? '';
        final responsaveis = idoso['responsaveis'] ?? [];
        final temResponsavel = responsaveis.isNotEmpty;
        return Scaffold(
          appBar: AppBar(title: const Text("Página do Idoso")),
          body: Stack(
            children: [
              Center(
                child: temResponsavel
                  ? const Text("Bem-vindo, Idoso!")
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Você não tem responsável vinculado.",
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "O responsável deverá usar o código abaixo para te adicionar:",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          codigo,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
              ),
              CircularMenu(
                alignment: Alignment.bottomCenter,
                items: [
                  CircularMenuItem(
                    icon: Icons.logout,
                    color: Colors.grey,
                    onTap: () async {
                      await AuthService().signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    },
                  ),
                  CircularMenuItem(
                    icon: Icons.info_outline,
                    color: Colors.red,
                    onTap: () {}, // item dummy
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getIdosoData() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) return null;
    final snap = await FirebaseFirestore.instance.collection('idoso').where('email', isEqualTo: user.email).limit(1).get();
    if (snap.docs.isEmpty) return null;
    final data = snap.docs.first.data();
    // Supondo que o campo 'responsaveis' seja uma lista de IDs/emails dos responsáveis
    return data;
  }
}
