
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
import 'screens/register_idoso_resto.dart';
import 'screens/idoso_page.dart';
import 'screens/idoso_info.dart';
import 'screens/register_codigo_idoso.dart';
import 'screens/medicamentos.dart';
import 'screens/register_medicamentos.dart';

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
        '/register_codigo_idoso': (context) => const RegisterCodigoIdosoPage(),
        '/register_idoso_resto': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final idosoId = args?['idosoId'] ?? '';
          return RegisterIdosoRestoPage(idosoId: idosoId);
        },
        '/idoso_page': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final idosoId = args?['idosoId'] ?? '';
          return IdosoPage(idosoId: idosoId);
        },
        '/idoso_info': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final idosoId = args?['idosoId'] ?? '';
          return IdosoInfoPage(idosoId: idosoId);
        },
        '/medicamentos': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final idosoId = args?['idosoId'] ?? '';
          final apelido = args?['apelido'] ?? '';
          return MedicamentosPage(idosoId: idosoId, apelido: apelido);
        },
        '/register_medicamentos': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final idosoId = args?['idosoId'] ?? '';
          return RegisterMedicamentosPage(idosoId: idosoId);
        },
      },
      home: const WelcomePage(),
    );
  }
}
