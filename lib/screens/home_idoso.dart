import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:circular_menu/circular_menu.dart';

class HomeIdoso extends StatelessWidget {
  const HomeIdoso({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Página do Idoso")),
      body: Stack(
        children: [
          const Center(child: Text("Bem-vindo, Idoso!")),
          CircularMenu(
            alignment: Alignment.bottomRight,
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
  }
}
