import 'package:flutter/material.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home_idoso.dart';
import 'screens/home_responsavel.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Idoso',
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home_idoso': (context) => const HomeIdoso(),
        '/home_responsavel': (context) => const HomeResponsavel(),
      },
    );
  }
}
