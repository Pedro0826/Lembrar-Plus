import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'register_responsavel_resto.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool validarCPF(String cpf) {
  cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
  if (cpf.length != 11 || RegExp(r'(\d)\1{10}').hasMatch(cpf)) return false;
  List<int> digits = cpf.split('').map(int.parse).toList();
  int calc(int n) {
    int sum = 0;
    for (int i = 0; i < n; i++) {
      sum += digits[i] * (n + 1 - i);
    }
    int mod = (sum * 10) % 11;
    return mod == 10 ? 0 : mod;
  }

  return calc(9) == digits[9] && calc(10) == digits[10];
}

class RegisterResponsavelPage extends StatefulWidget {
  const RegisterResponsavelPage({super.key});

  @override
  State<RegisterResponsavelPage> createState() =>
      _RegisterResponsavelPageState();
}

class _RegisterResponsavelPageState extends State<RegisterResponsavelPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  DateTime? dataNascSelecionada;

  final AuthService _authService = AuthService();

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> registrarUsuario() async {
    String nome = nomeController.text;
    String telefone = telefoneController.text;
    String email = emailController.text;
    String senha = senhaController.text;
    String cpf = cpfController.text;
    DateTime? dataNasc = dataNascSelecionada;

    if (dataNasc == null) {
      mostrarErro('Selecione a data de nascimento.');
      return;
    }
    if (!validarCPF(cpf)) {
      mostrarErro('CPF inválido.');
      return;
    }

    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);
      await cred.user?.updateDisplayName(nome);

      final firestoreService = FirestoreService();
      await firestoreService.addResponsavel(
        uid: cred.user!.uid, // Usa o UID do usuário autenticado
        nome: nome,
        telefone: telefone,
        email: email,
        dataNasc: dataNasc,
        cpf: cpf,
      );

      Navigator.pushReplacementNamed(context, '/home_responsavel');
    } catch (e) {
      mostrarErro('Erro ao registrar: ${e.toString()}');
    }
  }

  Future<void> registrarComGoogle() async {
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        String nome = user.displayName ?? '';
        String email = user.email ?? '';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RegisterResponsavelRestoPage(nome: nome, email: email),
          ),
        );
      }
    } catch (e) {
      mostrarErro('Erro ao registrar com Google: ${e.toString()}');
    }
  }

  Widget editBox({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A7CA5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background3.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Center(
                  child: Text(
                    'Registrar como responsável',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF3A7CA5),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                editBox(label: 'Nome', controller: nomeController),
                editBox(
                  label: 'Telefone',
                  controller: telefoneController,
                  keyboardType: TextInputType.phone,
                ),
                editBox(
                  label: 'Email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                editBox(
                  label: 'Senha',
                  controller: senhaController,
                  obscure: true,
                ),
                editBox(
                  label: 'CPF',
                  controller: cpfController,
                  keyboardType: TextInputType.number,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data de Nascimento',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A7CA5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                dataNascSelecionada == null
                                    ? 'Selecione'
                                    : '${dataNascSelecionada!.day.toString().padLeft(2, '0')}/${dataNascSelecionada!.month.toString().padLeft(2, '0')}/${dataNascSelecionada!.year}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(221, 73, 72, 72),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000, 1, 1),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    dataNascSelecionada = picked;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: registrarUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7CA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                    ),
                    child: const Text('Registrar'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: registrarComGoogle,
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                      width: 24,
                    ),
                    label: const Text('Registrar com Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      elevation: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Botão voltar
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
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, size: 36),
            ),
          ),
        ],
      ),
    );
  }
}
