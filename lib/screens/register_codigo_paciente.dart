import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'register_paciente_resto.dart';
import '../services/auth_service.dart';

class RegisterCodigoIdosoPage extends StatefulWidget {
  const RegisterCodigoIdosoPage({super.key});

  @override
  State<RegisterCodigoIdosoPage> createState() =>
      _RegisterCodigoIdosoPageState();
}

class _RegisterCodigoIdosoPageState extends State<RegisterCodigoIdosoPage> {
  final TextEditingController codigoController = TextEditingController();
  String? errorMsg;
  bool isLoading = false;

  // Caixa de entrada no mesmo estilo de EditarPaciente
  Widget _editBox({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A7CA5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_2, color: Color(0xFF3A7CA5)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    maxLength: 8,
                    decoration: const InputDecoration(
                      hintText: 'Digite o código',
                      hintStyle: TextStyle(color: Color(0xFF707070)),
                      border: InputBorder.none,
                      isDense: true,
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> vincularIdoso() async {
    setState(() {
      errorMsg = null;
      isLoading = true;
    });
    final codigo = codigoController.text.trim();
    if (codigo.isEmpty) {
      setState(() {
        errorMsg = 'Digite o código do paciente.';
        isLoading = false;
      });
      return;
    }
    final firestore = FirestoreService();
    final idosoSnap = await firestore.getIdosoByCodigo(codigo);
    if (idosoSnap == null) {
      setState(() {
        errorMsg = 'Paciente não encontrado.';
        isLoading = false;
      });
      return;
    }
    // Vincula idoso ao responsável
    final user = await AuthService().getCurrentUser();
    if (user == null) {
      setState(() {
        errorMsg = 'Usuário não autenticado.';
        isLoading = false;
      });
      return;
    }

    // Atualiza o documento do idoso para adicionar o responsável
    final idosoDocRef = FirebaseFirestore.instance
        .collection('idoso')
        .doc(idosoSnap['id']);
    final idosoDoc = await idosoDocRef.get();
    List<dynamic> responsaveis = idosoDoc.data()?['responsaveis'] ?? [];
    if (!responsaveis.contains(user.email)) {
      responsaveis.add(user.email);
      await idosoDocRef.update({'responsaveis': responsaveis});
    }

    // Atualiza o documento do responsável para adicionar o idoso ao array 'idosos_vinculados'
    final responsavelDocRef = FirebaseFirestore.instance
        .collection('responsavel')
        .doc(user.uid);
    await responsavelDocRef.set({
      'idosos_vinculados': FieldValue.arrayUnion([idosoSnap['id']]),
    }, SetOptions(merge: true));

    setState(() {
      isLoading = false;
    });

    // Navega para completar o cadastro do idoso, garantindo que o widget está montado
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RegisterIdosoRestoPage(idosoId: idosoSnap['id']),
        ),
      );
    }
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
                    'Cadastrar Paciente',
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
                _editBox(
                  label: 'Código do paciente',
                  controller: codigoController,
                ),
                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      errorMsg!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7CA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    onPressed: isLoading ? null : vincularIdoso,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Vincular paciente'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Removido overlay global para evitar dupla de loaders ao voltar
          Positioned(
            left: 32,
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
