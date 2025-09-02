import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:circular_menu/circular_menu.dart';

import '../services/firestore_service.dart';

class HomeResponsavel extends StatefulWidget {
  const HomeResponsavel({super.key});

  @override
  State<HomeResponsavel> createState() => _HomeResponsavelState();
}

class _HomeResponsavelState extends State<HomeResponsavel> {
  final TextEditingController codigoController = TextEditingController();
  List<Map<String, dynamic>> idosos = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchIdososVinculados();
  }

  Future<void> fetchIdososVinculados() async {
    setState(() { isLoading = true; });
    final firestore = FirestoreService();
    final user = await AuthService().getCurrentUser();
    if (user == null) {
      setState(() { isLoading = false; });
      return;
    }
    final responsavelSnap = await firestore.getResponsavelByEmail(user.email ?? '');
    if (responsavelSnap == null) {
      setState(() { isLoading = false; });
      return;
    }
    List<dynamic> ids = responsavelSnap['idosos_vinculados'] ?? [];
    if (ids.isEmpty) {
      setState(() { idosos = []; isLoading = false; });
      return;
    }
    // Buscar dados dos idosos
    final idososSnap = await firestore.getIdososByIds(ids);
    setState(() { idosos = idososSnap; isLoading = false; });
  }

  Future<void> vincularIdoso() async {
    setState(() { errorMsg = null; });
    final codigo = codigoController.text.trim();
    if (codigo.isEmpty) {
      setState(() { errorMsg = 'Digite o código do idoso.'; });
      return;
    }
    final firestore = FirestoreService();
    final idosoSnap = await firestore.getIdosoByCodigo(codigo);
    if (idosoSnap == null) {
      setState(() { errorMsg = 'Idoso não encontrado.'; });
      return;
    }
    final user = await AuthService().getCurrentUser();
    if (user == null) return;
    await firestore.vincularIdosoAoResponsavel(user.email ?? '', idosoSnap['id']);
    codigoController.clear();
    await fetchIdososVinculados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Página do Responsável")),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                TextField(
                  controller: codigoController,
                  decoration: const InputDecoration(labelText: "Código do idoso"),
                ),
                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                  ),
                ElevatedButton(
                  onPressed: vincularIdoso,
                  child: const Text("Vincular idoso"),
                ),
                if (isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (!isLoading && idosos.isEmpty)
                  const Text("Nenhum idoso vinculado.", style: TextStyle(fontSize: 18)),
                if (!isLoading && idosos.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Idosos vinculados:", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      ...idosos.map((idoso) => Card(
                        child: ListTile(
                          title: Text(idoso['nome'] ?? 'Sem nome'),
                          subtitle: Text('CPF: ${idoso['cpf'] ?? ''}'),
                        ),
                      )),
                    ],
                  ),
              ],
            ),
          ),
          CircularMenu(
            alignment: Alignment.bottomCenter,
            items: [
              CircularMenuItem(
                icon: Icons.logout,
                color: Colors.grey,
                onTap: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
              ),
              CircularMenuItem(
                icon: Icons.info_outline,
                color: Colors.red,
                onTap: () {}, // item dummy
              ),
            ],
          ),
        ],
      ),
    );
  }
}
