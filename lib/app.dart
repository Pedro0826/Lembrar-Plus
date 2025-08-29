
import 'package:flutter/material.dart';
// ...existing code...
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register_principal.dart';
import 'screens/register_idoso.dart';
import 'screens/register_responsavel.dart';
import 'screens/home_idoso.dart';
import 'screens/home_responsavel.dart';
import 'screens/register_responsavel_resto.dart';

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
        '/register_responsavel_resto': (context) => const RegisterResponsavelRestoPage(nome: '', email: ''),
        '/home_idoso': (context) => const HomeIdoso(),
        '/home_responsavel': (context) => const HomeResponsavel(),
      },
      home: const WelcomePage(),
    );
  }
}
