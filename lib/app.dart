
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register_principal.dart';
import 'screens/register_idoso.dart';
import 'screens/register_responsavel.dart';
import 'screens/home_idoso.dart';
import 'screens/home_responsavel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lembrar+',
      debugShowCheckedModeBanner: false,
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register_principal': (context) => const RegisterPrincipalPage(),
        '/register_idoso': (context) => const RegisterIdosoPage(),
        '/register_responsavel': (context) => const RegisterResponsavelPage(),
        '/home_idoso': (context) => const HomeIdoso(),
        '/home_responsavel': (context) => const HomeResponsavel(),
      },
      home: StreamBuilder<User?>(
        stream: AuthService().userChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            // Usuário autenticado, pode customizar para qual home ir
            return const HomeResponsavel();
          } else {
            // Não autenticado
            return const LoginPage();
          }
        },
      ),
    );
  }
}
