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

  InputDecoration campoDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Color(0xFF707070)),
      filled: true,
      fillColor: const Color(0xFFE4FBFB),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Cadastrar paciente por código',
          style: TextStyle(
            color: Color(0xFF3A7CA5),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3A7CA5)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: codigoController,
              decoration: campoDecoration('Código do paciente'),
            ),
            if (errorMsg != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMsg!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : vincularIdoso,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A7CA5),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Vincular paciente'),
            ),
          ],
        ),
      ),
    );
  }
}
