import 'package:flutter/material.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/register_principal.dart';
import 'screens/register_paciente.dart';
import 'screens/register_responsavel.dart';
import 'screens/home_paciente.dart';
import 'screens/home_responsavel.dart';
import 'screens/register_responsavel_resto.dart';
import 'screens/register_paciente_resto.dart';
import 'screens/paciente_page.dart';
import 'screens/paciente_info.dart';
import 'screens/register_codigo_paciente.dart';
import 'screens/medicamentos.dart';
import 'screens/register_medicamentos.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lembrar+',
      debugShowCheckedModeBanner: false,
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register_principal': (context) => const RegisterPrincipalPage(),
        '/register_paciente': (context) => const RegisterIdosoPage(),
        '/register_responsavel': (context) => const RegisterResponsavelPage(),
        '/register_responsavel_resto': (context) =>
            const RegisterResponsavelRestoPage(nome: '', email: ''),
        '/home_paciente': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final idosoId = args?['idosoId'] ?? '';
          return HomeIdoso(idosoId: idosoId);
        },
        '/home_responsavel': (context) => const HomeResponsavel(),
        '/register_codigo_paciente': (context) =>
            const RegisterCodigoIdosoPage(),
        '/register_paciente_resto': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final idosoId = args?['idosoId'] ?? '';
          return RegisterIdosoRestoPage(idosoId: idosoId);
        },
        '/paciente_page': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final idosoId = args?['idosoId'] ?? '';
          return IdosoPage(idosoId: idosoId);
        },
        '/paciente_info': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final idosoId = args?['idosoId'] ?? '';
          return IdosoInfoPage(idosoId: idosoId);
        },
        '/medicamentos': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final idosoId = args?['idosoId'] ?? '';
          final apelido = args?['apelido'] ?? '';
          return MedicamentosPage(idosoId: idosoId, apelido: apelido);
        },
        '/register_medicamentos': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final idosoId = args?['idosoId'] ?? '';
          return RegisterMedicamentosPage(idosoId: idosoId);
        },
      },
      home: const WelcomePage(),
    );
  }
}
