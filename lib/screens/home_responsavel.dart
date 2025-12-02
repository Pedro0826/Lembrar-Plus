import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_menu/circular_menu.dart';
import 'paciente_page.dart';
import 'Info_projeto.dart';
// Removed image upload and storage dependencies; using asset-only avatar

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
    // Seta a foto de perfil como um asset local fixo e atualiza o Firestore
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado')),
        );
        return;
      }

      const String assetPath = 'assets/images/default_profile.jpg';

      await FirebaseFirestore.instance
          .collection('responsavel')
          .doc(user.uid)
          .set({
            'fotoUrl': assetPath,
            'isAsset': true,
          }, SetOptions(merge: true));

      setState(() {
        responsavelData = (responsavelData ?? {});
        responsavelData!['fotoUrl'] = assetPath;
        responsavelData!['isAsset'] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil definida como asset.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao definir foto: $e')));
    }
  }

  Future<void> _editarApelido(Map<String, dynamic> idoso) async {
    final TextEditingController apelidoController = TextEditingController();
    apelidoController.text = idoso['apelido'] ?? '';

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
              Icon(Icons.edit, color: Color(0xFF3A7CA5)),
              SizedBox(width: 8),
              Text(
                'Definir Apelido',
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
              TextField(
                controller: apelidoController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Apelido',
                  hintText: 'Digite um apelido para o paciente',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF6B7A8F),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide(color: Color(0xFF3A7CA5), width: 2),
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
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Salvar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6DBE81),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final String novoApelido = apelidoController.text.trim();
                if (novoApelido.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Digite um apelido válido.')),
                  );
                  return;
                }
                try {
                  await FirebaseFirestore.instance
                      .collection('idoso')
                      .doc(idoso['id'])
                      .update({'apelido': novoApelido});
                  Navigator.pop(context);
                  _loadIdososVinculados();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Apelido atualizado com sucesso!'),
                      backgroundColor: Color(0xFF6DBE81),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao atualizar apelido: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removerVinculo(String idosoId) async {
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
              Icon(Icons.link_off, color: Color(0xFFD9534F)),
              SizedBox(width: 8),
              Text(
                'Remover Vínculo',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD9534F),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(height: 4),
              Text(
                'Tem certeza que deseja remover o vínculo com este paciente?\nEsta ação não pode ser desfeita.',
                style: TextStyle(color: Color(0xFF6B7A8F), fontSize: 15),
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
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remover'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9534F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                try {
                  final user = await AuthService().getCurrentUser();
                  if (user == null) return;

                  final firestoreService = FirestoreService();
                  await firestoreService.removerVinculoResponsavelIdoso(
                    user.uid,
                    idosoId,
                  );

                  Navigator.pop(context);
                  _loadIdososVinculados();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vínculo removido com sucesso!'),
                      backgroundColor: Color(0xFF6DBE81),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao remover vínculo: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showProfilePreview() {
    final String defaultAsset = 'assets/images/default_profile.jpg';
    final String url = (responsavelData?['fotoUrl'] ?? '').toString();
    final bool isAsset = responsavelData?['isAsset'] == true;
    final ImageProvider imageProvider = url.isEmpty
        ? AssetImage(defaultAsset)
        : (isAsset ? AssetImage(url) : NetworkImage(url) as ImageProvider);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CircleAvatar(backgroundImage: imageProvider, radius: 120),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1).animate(anim),
            child: child,
          ),
        );
      },
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
                      onTap: _showProfilePreview,
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white,
                        backgroundImage: () {
                          const String defaultAsset =
                              'assets/images/default_profile.jpg';
                          final data = responsavelData;
                          if (data == null)
                            return const AssetImage(defaultAsset);
                          final String url = (data['fotoUrl'] ?? '').toString();
                          final bool isAsset = data['isAsset'] == true;
                          if (url.isEmpty)
                            return const AssetImage(defaultAsset);
                          return isAsset
                              ? AssetImage(url)
                              : NetworkImage(url) as ImageProvider;
                        }(),
                        child: null,
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
                                                                  )
                                                                  as ImageProvider)
                                                      : null,
                                                  child:
                                                      (idoso['fotoUrl'] !=
                                                              null &&
                                                          idoso['fotoUrl']
                                                              .toString()
                                                              .isNotEmpty)
                                                      ? null
                                                      : const Icon(
                                                          Icons.person,
                                                          color: Color(
                                                            0xFF6B7A8F,
                                                          ),
                                                          size: 32,
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InfoProjetoPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
