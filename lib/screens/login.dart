import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode senhaFocus = FocusNode();

  final AuthService _authService = AuthService();

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.asset('assets/videos/background.mp4')
          ..setLooping(true)
          ..setVolume(0)
          ..initialize().then((_) {
            setState(() {});
            _videoController.play();
          });
  }

  @override
  void dispose() {
    emailFocus.dispose();
    senhaFocus.dispose();
    emailController.dispose();
    senhaController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> fazerLogin() async {
    try {
      User? user = await _authService.signIn(
        emailController.text,
        senhaController.text,
      );
      if (user != null) {
        final firestore = FirestoreService();
        if (await firestore.isResponsavelByEmail(user.email ?? '')) {
          Navigator.pushReplacementNamed(context, '/home_responsavel');
          return;
        }
        if (await firestore.isIdosoByEmail(user.email ?? '')) {
          Navigator.pushReplacementNamed(context, '/home_idoso');
          return;
        }
        mostrarErro('Usuário não encontrado como responsável ou paciente.');
      }
    } catch (e) {
      mostrarErro('Falha no login: ${e.toString()}');
    }
  }

  Future<void> fazerLoginGoogle() async {
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        final firestore = FirestoreService();
        if (await firestore.isResponsavelByEmail(user.email ?? '')) {
          Navigator.pushReplacementNamed(context, '/home_responsavel');
          return;
        }
        if (await firestore.isIdosoByEmail(user.email ?? '')) {
          Navigator.pushReplacementNamed(context, '/home_idoso');
          return;
        }
        mostrarErro('Usuário não encontrado como responsável ou paciente.');
      }
    } catch (e) {
      mostrarErro('Falha no login com Google: ${e.toString()}');
    }
  }

  InputDecoration campoDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF707070)),
      filled: true,
      fillColor: const Color(0xFFE4FBFB), // Azul claro
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none, // Sem linha
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .transparent, // Deixe transparente para o background ocupar tudo
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Vídeo de fundo ocupa toda a tela
          if (_videoController.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      40,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(flex: 1, child: SizedBox()),

                      // Título Login em caixa de texto centralizada
                      Padding(
                        padding: const EdgeInsets.only(bottom: 28.0),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF3A7CA5),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Campo Email
                      AutofillGroup(
                        child: TextField(
                          controller: emailController,
                          focusNode: emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: campoDecoration("Email"),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo Senha
                      AutofillGroup(
                        child: TextField(
                          controller: senhaController,
                          focusNode: senhaFocus,
                          decoration: campoDecoration("Senha"),
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botão Entrar
                      ElevatedButton(
                        onPressed: fazerLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A7CA5),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Entrar",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Botão Google
                      ElevatedButton.icon(
                        onPressed: fazerLoginGoogle,
                        icon: Image.asset(
                          'assets/images/google_logo.png',
                          height: 20,
                          width: 20,
                        ),
                        label: const Text(
                          "Entrar com Google",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: Colors.grey),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          elevation: 1,
                        ),
                      ),

                      const Flexible(flex: 1, child: SizedBox(height: 20)),

                      // Texto "Não tem login? Registre-se" em negrito
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register_principal');
                        },
                        child: const Text(
                          "Não tem login? Registre-se",
                          style: TextStyle(
                            color: Color(0xFFE57373), // Vermelho
                            fontSize: 16,
                            fontWeight: FontWeight.bold, // Negrito
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Botão voltar no canto inferior esquerdo
          Positioned(
            left: 24,
            bottom: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey,
                shape: const CircleBorder(),
                elevation: 3,
                padding: const EdgeInsets.all(10),
                minimumSize: const Size(40, 40),
                maximumSize: const Size(40, 40),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/welcome');
              },
              child: const Icon(Icons.arrow_back, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
