

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'idoso_page.dart';

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

  Future<void> editarApelidoIdoso(String idosoId, String apelidoAtual) async {
    final TextEditingController apelidoController = TextEditingController(text: apelidoAtual);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Definir apelido do idoso'),
        content: TextField(
          controller: apelidoController,
          decoration: const InputDecoration(labelText: 'Apelido'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, apelidoController.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (result != null) {
      await FirebaseFirestore.instance.collection('idoso').doc(idosoId).update({'apelido': result});
      await fetchIdososVinculados();
    }
  }

  Future<void> removerVinculoIdoso(String idosoId) async {
  final firestore = FirestoreService();
  final user = await AuthService().getCurrentUser();
  if (user == null) return;
  final responsavelSnap = await firestore.getResponsavelByEmail(user.email ?? '');
  if (responsavelSnap == null) return;
  List<dynamic> ids = responsavelSnap['idosos_vinculados'] ?? [];
  ids.remove(idosoId);
  await FirebaseFirestore.instance.collection('responsavel').doc(responsavelSnap['id']).update({'idosos_vinculados': ids});

  // Remove o responsável da lista 'responsaveis' do idoso e o apelido
  final idosoDocRef = FirebaseFirestore.instance.collection('idoso').doc(idosoId);
  final idosoDoc = await idosoDocRef.get();
  List<dynamic> responsaveis = idosoDoc.data()?['responsaveis'] ?? [];
  responsaveis.remove(user.email);
  await idosoDocRef.update({'responsaveis': responsaveis, 'apelido': FieldValue.delete()});

  await fetchIdososVinculados();
  }

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
                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                  ),
                if (isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (!isLoading && idosos.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Nenhum idoso vinculado.", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text("Cadastrar idoso por código"),
                        onPressed: () {
                          Navigator.pushNamed(context, '/register_codigo_idoso');
                        },
                      ),
                    ],
                  ),
                if (!isLoading && idosos.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Idosos vinculados:", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      ...idosos.map((idoso) => Card(
                        child: ListTile(
                          title: GestureDetector(
                            child: Text(
                              (idoso['apelido'] != null && idoso['apelido'].toString().isNotEmpty)
                                ? idoso['apelido']
                                : (idoso['nome'] ?? 'Sem nome'),
                            ),
                            onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IdosoPage(idosoId: idoso['id']),
                                  ),
                                );
                                await fetchIdososVinculados();
                              },
                          ),
                          subtitle: Text('CPF: ${idoso['cpf'] ?? ''}'),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'remover') {
                                await removerVinculoIdoso(idoso['id']);
                              } else if (value == 'editar_apelido') {
                                await editarApelidoIdoso(idoso['id'], idoso['apelido'] ?? '');
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'editar_apelido',
                                child: Text('Definir apelido'),
                              ),
                              const PopupMenuItem(
                                value: 'remover',
                                child: Text('Remover vínculo'),
                              ),
                            ],
                          ),
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
                icon: Icons.add,
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, '/register_codigo_idoso');
                },
              ),
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
