import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class RegisterResponsavelRestoPage extends StatefulWidget {
  final String nome;
  final String email;
  const RegisterResponsavelRestoPage({
    super.key,
    required this.nome,
    required this.email,
  });

  @override
  State<RegisterResponsavelRestoPage> createState() =>
      _RegisterResponsavelRestoPageState();
}

class _RegisterResponsavelRestoPageState
    extends State<RegisterResponsavelRestoPage> {
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  DateTime? dataNascSelecionada;
  bool isLoading = false;

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

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

  Future<void> salvarDados() async {
    String telefone = telefoneController.text.trim();
    String cpf = cpfController.text.trim();
    DateTime? dataNasc = dataNascSelecionada;

    if (telefone.isEmpty || cpf.isEmpty || dataNasc == null) {
      mostrarErro('Preencha todos os campos.');
      return;
    }
    if (!validarCPF(cpf)) {
      mostrarErro('CPF inválido.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        mostrarErro('Usuário não autenticado.');
        return;
      }

      final firestoreService = FirestoreService();
      await firestoreService.addResponsavel(
        uid: user.uid, // Usa o UID do usuário autenticado
        nome: widget.nome,
        telefone: telefone,
        email: widget.email,
        dataNasc: dataNasc,
        cpf: cpf,
      );
      Navigator.pushReplacementNamed(context, '/home_responsavel');
    } catch (e) {
      mostrarErro('Erro ao salvar dados: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget editBox({required String label, required Widget child}) {
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
            child: child,
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
                    'Completar dados do cuidador',
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
                editBox(
                  label: 'Telefone',
                  child: TextField(
                    controller: telefoneController,
                    keyboardType: TextInputType.phone,
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
                editBox(
                  label: 'CPF',
                  child: TextField(
                    controller: cpfController,
                    keyboardType: TextInputType.number,
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
                editBox(
                  label: 'Data de Nascimento',
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dataNascSelecionada == null
                              ? 'Selecione'
                              : '${dataNascSelecionada!.day.toString().padLeft(2, '0')}/${dataNascSelecionada!.month.toString().padLeft(2, '0')}/${dataNascSelecionada!.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF3A7CA5),
                        ),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : salvarDados,
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
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Salvar'),
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
