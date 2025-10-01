import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_menu/circular_menu.dart';
import 'paciente_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class HomeResponsavel extends StatefulWidget {
  const HomeResponsavel({super.key});

  @override
  State<HomeResponsavel> createState() => _HomeResponsavelState();
}

class _HomeResponsavelState extends State<HomeResponsavel> {
  final TextEditingController codigoController = TextEditingController();

  List<Map<String, dynamic>> idosos = [];
  Map<String, dynamic>? responsavelData;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadIdososVinculados();
  }

  Future<void> _loadIdososVinculados() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        setState(() {
          isLoading = false;
          errorMsg = "Usuário não autenticado.";
        });
        return;
      }

      // Busca o documento do responsável
      final doc = await FirebaseFirestore.instance
          .collection('responsavel')
          .doc(user.uid)
          .get();

      // Salva os dados do responsável
      setState(() {
        responsavelData = doc.data();
      });

      final List<dynamic> ids = doc.data()?['idosos_vinculados'] ?? [];

      if (ids.isEmpty) {
        setState(() {
          idosos = [];
          isLoading = false;
        });
        return;
      }

      // Busca os dados dos idosos vinculados
      final query = await FirebaseFirestore.instance
          .collection('idoso')
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      final idososList = query.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();

      setState(() {
        idosos = idososList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = "Erro ao carregar pacientes.";
        isLoading = false;
      });
    }
  }

  Future<void> _atualizarFotoPerfil() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final user = await AuthService().getCurrentUser();
        if (user == null) return;

        // Upload para o Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child(
          'profile_images/responsavel_${user.uid}.jpg',
        );
        await storageRef.putFile(File(pickedFile.path));
        final downloadUrl = await storageRef.getDownloadURL();

        // Atualiza o campo fotoUrl no Firestore
        await FirebaseFirestore.instance
            .collection('responsavel')
            .doc(user.uid)
            .update({'fotoUrl': downloadUrl});

        // Atualiza os dados locais e recarrega a tela
        setState(() {
          if (responsavelData != null) {
            responsavelData!['fotoUrl'] = downloadUrl;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar foto: $e')));
    }
  }

  Future<void> _editarApelido(Map<String, dynamic> idoso) async {
    final TextEditingController apelidoController = TextEditingController();
    apelidoController.text = idoso['apelido'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Definir Apelido'),
        content: TextField(
          controller: apelidoController,
          decoration: const InputDecoration(
            labelText: 'Apelido',
            hintText: 'Digite um apelido para o paciente',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('idoso')
                    .doc(idoso['id'])
                    .update({'apelido': apelidoController.text});
                Navigator.pop(context);
                _loadIdososVinculados(); // Recarrega a lista
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Apelido atualizado com sucesso!'),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao atualizar apelido: $e')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _removerVinculo(String idosoId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Vínculo'),
        content: const Text(
          'Tem certeza que deseja remover o vínculo com este paciente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final user = await AuthService().getCurrentUser();
                if (user == null) return;

                // Remove vínculo usando o serviço
                final firestoreService = FirestoreService();
                await firestoreService.removerVinculoResponsavelIdoso(
                  user.uid,
                  idosoId,
                );

                Navigator.pop(context);
                _loadIdososVinculados(); // Recarrega a lista
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vínculo removido com sucesso!'),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao remover vínculo: $e')),
                );
              }
            },
            child: const Text('Remover'),
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
          // Background cobrindo toda a tela
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background2.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Linha com botão circular à esquerda e frase à direita
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _atualizarFotoPerfil,
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            responsavelData != null &&
                                responsavelData!['fotoUrl'] != null &&
                                responsavelData!['fotoUrl']
                                    .toString()
                                    .isNotEmpty
                            ? (responsavelData!['isAsset'] == true
                                      ? AssetImage(responsavelData!['fotoUrl'])
                                      : NetworkImage(
                                          responsavelData!['fotoUrl'],
                                        ))
                                  as ImageProvider
                            : null,
                        child:
                            responsavelData == null ||
                                responsavelData!['fotoUrl'] == null ||
                                responsavelData!['fotoUrl'].toString().isEmpty
                            ? const Icon(
                                Icons.camera_alt,
                                color: Colors.grey,
                                size: 32,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.90),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              letterSpacing: 1.1,
                              color: Color(0xFF3A7CA5),
                            ),
                            children: [
                              const TextSpan(text: 'RESPONSÁVEL: '),
                              TextSpan(
                                text:
                                    responsavelData != null &&
                                        responsavelData!['nome'] != null
                                    ? responsavelData!['nome']
                                          .toString()
                                          .toUpperCase()
                                    : 'USUÁRIO',
                                style: const TextStyle(
                                  color: Color(0xFF3A7CA5),
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Exibição de erros
                if (errorMsg != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                // Aviso de nenhum paciente logo abaixo do cabeçalho
                if (!isLoading && idosos.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 24,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Você ainda não tem pacientes cadastrados.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A7CA5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6DBE81),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text("Cadastrar paciente"),
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                '/register_codigo_paciente',
                              );
                              _loadIdososVinculados();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                // Loading indicator
                if (isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                // Conteúdo principal quando não está carregando
                if (!isLoading)
                  Expanded(
                    child: Column(
                      children: [
                        // Lista de pacientes quando há pacientes
                        if (idosos.isNotEmpty)
                          Expanded(
                            child: Column(
                              children: [
                                // Lista propriamente dita
                                Expanded(
                                  child: RefreshIndicator(
                                    onRefresh: _loadIdososVinculados,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      itemCount: idosos.length + 1,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        if (index < idosos.length) {
                                          final idoso = idosos[index];
                                          return SizedBox(
                                            height: 90,
                                            child: Card(
                                              elevation: 3,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              color: Colors.white.withOpacity(
                                                0.96,
                                              ),
                                              child: ListTile(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 18,
                                                    ),
                                                leading: CircleAvatar(
                                                  radius: 28,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  backgroundImage:
                                                      (idoso['fotoUrl'] !=
                                                              null &&
                                                          idoso['fotoUrl']
                                                              .toString()
                                                              .isNotEmpty)
                                                      ? (idoso['isAsset'] ==
                                                                    true
                                                                ? AssetImage(
                                                                    idoso['fotoUrl'],
                                                                  )
                                                                : NetworkImage(
                                                                    idoso['fotoUrl'],
                                                                  ))
                                                            as ImageProvider
                                                      : const AssetImage(
                                                          'assets/images/default_profile.jpg',
                                                        ),
                                                ),
                                                title: Text(
                                                  (idoso['apelido'] != null &&
                                                          idoso['apelido']
                                                              .toString()
                                                              .isNotEmpty)
                                                      ? idoso['apelido']
                                                            .toString()
                                                            .trim()
                                                      : (idoso['nome'] ??
                                                                'Sem nome')
                                                            .toString()
                                                            .trim(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: Color(0xFF3A7CA5),
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  'CPF: ${(idoso['cpf'] ?? '').toString().trim()}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF6B7A8F),
                                                  ),
                                                ),
                                                onTap: () async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          IdosoPage(
                                                            idosoId:
                                                                idoso['id'],
                                                          ),
                                                    ),
                                                  );
                                                },
                                                trailing: PopupMenuButton<String>(
                                                  icon: const Icon(
                                                    Icons.more_vert,
                                                  ),
                                                  onSelected: (value) async {
                                                    if (value ==
                                                        'editar_apelido') {
                                                      _editarApelido(idoso);
                                                    } else if (value ==
                                                        'remover') {
                                                      _removerVinculo(
                                                        idoso['id'],
                                                      );
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem(
                                                      value: 'editar_apelido',
                                                      child: Text(
                                                        'Definir apelido',
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'remover',
                                                      child: Text(
                                                        'Remover vínculo',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Botão de adicionar paciente como último item da lista
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                              horizontal: 16.0,
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 48,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF6DBE81,
                                                  ),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  textStyle: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                icon: const Icon(Icons.add),
                                                label: const Text(
                                                  "Cadastrar novo paciente",
                                                ),
                                                onPressed: () async {
                                                  await Navigator.pushNamed(
                                                    context,
                                                    '/register_codigo_paciente',
                                                  );
                                                  _loadIdososVinculados();
                                                },
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
          // Menu circular centralizado, um pouco mais alto
          Padding(
            padding: const EdgeInsets.only(bottom: 56),
            child: CircularMenu(
              toggleButtonColor: const Color.fromARGB(255, 108, 81, 182),
              alignment: Alignment.bottomCenter,
              items: [
                CircularMenuItem(
                  icon: Icons.add,
                  color: Colors.green,
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      '/register_codigo_paciente',
                    );
                    _loadIdososVinculados();
                  },
                ),
                CircularMenuItem(
                  icon: Icons.logout,
                  color: Colors.grey,
                  onTap: () async {
                    await AuthService().signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                ),
                CircularMenuItem(
                  icon: Icons.info_outline,
                  color: Colors.red,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
