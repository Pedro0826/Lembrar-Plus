import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'idoso_page.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_idoso_resto.dart';

class RegisterCodigoIdosoPage extends StatefulWidget {
  const RegisterCodigoIdosoPage({super.key});

  @override
  State<RegisterCodigoIdosoPage> createState() => _RegisterCodigoIdosoPageState();
}

class _RegisterCodigoIdosoPageState extends State<RegisterCodigoIdosoPage> {
  final TextEditingController codigoController = TextEditingController();
  String? errorMsg;
  bool isLoading = false;

  Future<void> vincularIdoso() async {
    setState(() { errorMsg = null; isLoading = true; });
    final codigo = codigoController.text.trim();
    if (codigo.isEmpty) {
      setState(() { errorMsg = 'Digite o código do idoso.'; isLoading = false; });
      return;
    }
    final firestore = FirestoreService();
    final idosoSnap = await firestore.getIdosoByCodigo(codigo);
    if (idosoSnap == null) {
      setState(() { errorMsg = 'Idoso não encontrado.'; isLoading = false; });
      return;
    }
    // Vincula idoso ao responsável
    final user = await AuthService().getCurrentUser();
    if (user == null) {
      setState(() { errorMsg = 'Usuário não autenticado.'; isLoading = false; });
      return;
    }
    await firestore.vincularIdosoAoResponsavel(user.email ?? '', idosoSnap['id']);

    // Atualiza o documento do idoso para adicionar o responsável
    final idosoDocRef = FirebaseFirestore.instance.collection('idoso').doc(idosoSnap['id']);
    final idosoDoc = await idosoDocRef.get();
    List<dynamic> responsaveis = idosoDoc.data()?['responsaveis'] ?? [];
    if (!responsaveis.contains(user.email)) {
      responsaveis.add(user.email);
      await idosoDocRef.update({'responsaveis': responsaveis});
    }

    setState(() { isLoading = false; });
    // Navega para tela de informações adicionais
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterIdosoRestoPage(idosoId: idosoSnap['id']),
      ),
    );
    // Se as informações foram salvas, navega para a página do idoso
    if (resultado == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => IdosoPage(idosoId: idosoSnap['id']),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar idoso por código')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: codigoController,
              decoration: const InputDecoration(labelText: 'Código do idoso'),
            ),
            if (errorMsg != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : vincularIdoso,
              child: isLoading ? const CircularProgressIndicator() : const Text('Vincular idoso'),
            ),
          ],
        ),
      ),
    );
  }
}
