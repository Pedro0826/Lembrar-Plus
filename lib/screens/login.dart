import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController resetEmailController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode senhaFocus = FocusNode();

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailFocus.dispose();
    senhaFocus.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> enviarResetSenha() async {
    final String email = resetEmailController.text.trim().isNotEmpty
        ? resetEmailController.text.trim()
        : emailController.text.trim();

    if (email.isEmpty) {
      mostrarErro('Digite seu e-mail para recuperar a senha.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email de recuperação enviado. Verifique sua caixa de entrada.',
            ),
            backgroundColor: Color(0xFF6DBE81),
          ),
        );
      }
    } catch (e) {
      mostrarErro('Erro ao enviar recuperação: ${e.toString()}');
    }
  }

  void abrirDialogEsqueciSenha() {
    resetEmailController.text = emailController.text.trim();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          title: Row(
            children: const [
              Icon(Icons.lock_open, color: Color(0xFF3A7CA5)),
              SizedBox(width: 8),
              Text(
                'Recuperar Senha',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A7CA5),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enviaremos um link de redefinição para o seu e-mail.',
                style: TextStyle(color: Color(0xFF6B7A8F), fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Seu e-mail',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7A8F),
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: enviarResetSenha,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Enviar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A7CA5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
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
          Navigator.pushReplacementNamed(
            context,
            '/home_paciente',
            arguments: {'idosoId': user.uid},
          );
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
          Navigator.pushReplacementNamed(
            context,
            '/home_paciente',
            arguments: {'idosoId': user.uid},
          );
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
      hintStyle: const TextStyle(
        color: Color(0xFF9E9E9E),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A7CA5), width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Imagem de fundo (mesma do welcome)
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background4.png',
              fit: BoxFit.cover,
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
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 40,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563A5), Color(0xFF3A7CA5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2563A5,
                                  ).withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.white,
                                letterSpacing: 1.5,
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
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
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
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botão Entrar
                      ElevatedButton(
                        onPressed: fazerLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563A5),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF3A7CA5).withOpacity(0.4),
                        ),
                        child: const Text(
                          "Entrar",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Botão Google
                      ElevatedButton.icon(
                        onPressed: fazerLoginGoogle,
                        icon: Image.asset(
                          'assets/images/google_logo.png',
                          height: 22,
                          width: 22,
                        ),
                        label: const Text(
                          "Entrar com Google",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          minimumSize: const Size(double.infinity, 54),
                          side: const BorderSide(
                            color: Color(0xFFBDBDBD),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                      ),

                      const Flexible(flex: 1, child: SizedBox(height: 20)),

                      // Botões de ação: Registrar-se e Esqueci minha senha
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/register_principal',
                                );
                              },
                              icon: const Icon(
                                Icons.person_add_alt_1,
                                size: 20,
                                color: Color(0xFF3A7CA5),
                              ),
                              label: const Text(
                                'Registrar-se',
                                style: TextStyle(
                                  color: Color(0xFF3A7CA5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF3A7CA5),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(
                                    color: Color(0xFF3A7CA5),
                                    width: 2,
                                  ),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: abrirDialogEsqueciSenha,
                              icon: const Icon(Icons.lock_reset, size: 20),
                              label: const Text(
                                'Esqueci minha senha',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563A5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                elevation: 4,
                padding: const EdgeInsets.all(18),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/welcome');
              },
              child: const Icon(Icons.arrow_back, size: 36),
            ),
          ),
        ],
      ),
    );
  }
}
