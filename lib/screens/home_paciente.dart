import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'paciente_info.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class HomeIdoso extends StatefulWidget {
  final String idosoId;

  const HomeIdoso({super.key, required this.idosoId});
  @override
  State<HomeIdoso> createState() => _HomeIdosoState();
}

class _HomeIdosoState extends State<HomeIdoso> {
  late List<_IdosoAction> _actions;
  final _firestoreService = FirestoreService();

  Future<void> enviarNotificacao({
    required String conteudo,
    required String importancia,
  }) async {
    try {
      print('🔹 [DEBUG] Iniciando enviarNotificacao...');
      final codigoIdoso = widget.idosoId;
      print('🔹 [DEBUG] código do idoso: $codigoIdoso');

      // Buscar o documento do idoso
      print('🔹 [DEBUG] Buscando documento do idoso...');
      final idosoSnapshot = await FirebaseFirestore.instance
          .collection('idoso')
          .doc(codigoIdoso)
          .get();

      if (!idosoSnapshot.exists) {
        print('⚠️ Documento do idoso não encontrado.');
        throw Exception('Documento do idoso não encontrado.');
      }

      final idosoData = idosoSnapshot.data();
      print('🔹 [DEBUG] Dados do idoso: $idosoData');

      // Obter a lista de emails dos responsáveis
      final responsaveisEmails = (idosoData?['responsaveis'] as List<dynamic>?)
          ?.map((email) => email as String)
          .toList();

      if (responsaveisEmails == null || responsaveisEmails.isEmpty) {
        print('⚠️ Nenhum responsável encontrado para este idoso.');
        throw Exception('Nenhum responsável encontrado para este idoso.');
      }

      print(
        '🔹 [DEBUG] Lista de e-mails dos responsáveis: $responsaveisEmails',
      );

      // Criar uma única notificação
      print('🔹 [DEBUG] Criando notificação...');
      await _firestoreService.criarNotificacao(
        codigoIdoso: codigoIdoso,
        conteudo: conteudo,
        hora: DateTime.now(),
        importancia: importancia,
        status: false,
      );
      print('✅ [DEBUG] Notificação criada com sucesso.');

      print('✅ [DEBUG] Função enviarNotificacao finalizada com sucesso.');
    } catch (e, stack) {
      print('❌ [ERRO] enviarNotificacao falhou: $e');
      print('📜 Stack trace: $stack');
      rethrow;
    }
  }

  @override
  void initState() {
    print('🟢 ID do idoso logado: ${widget.idosoId}');
    super.initState();
    _actions = [
      _IdosoAction(
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFE57373),
        label: 'Preciso de ajuda!',
        onTap: (ctx) async {
          try {
            print('🔹 [DEBUG] Botão "Preciso de ajuda!" clicado.');
            await enviarNotificacao(
              conteudo: 'Preciso de ajuda!',
              importancia: 'Extrema',
            );
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Notificação de ajuda enviada!')),
            );
          } catch (e) {
            print('❌ [ERRO] Falha ao enviar notificação: $e');
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Erro ao enviar notificação!')),
            );
          }
        },
      ),
      _IdosoAction(
        icon: Icons.wc,
        color: const Color(0xFFFF9800),
        label: 'Preciso ir ao banheiro',
        onTap: (ctx) async {
          try {
            await enviarNotificacao(
              conteudo: 'Preciso ir ao banheiro',
              importancia: 'Alta',
            );
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Notificação de banheiro enviada!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Erro ao enviar notificação!')),
            );
          }
        },
      ),
      _IdosoAction(
        icon: Icons.local_dining,
        color: const Color(0xFF6DBE81),
        label: 'Quero comer',
        onTap: (ctx) async {
          try {
            await enviarNotificacao(
              conteudo: 'Quero comer',
              importancia: 'Média',
            );
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Notificação de refeição enviada!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Erro ao enviar notificação!')),
            );
          }
        },
      ),
      _IdosoAction(
        icon: Icons.medication,
        color: const Color(0xFF3A7CA5),
        label: 'Preciso de remédio',
        onTap: (ctx) async {
          try {
            await enviarNotificacao(
              conteudo: 'Preciso de remédio',
              importancia: 'Alta',
            );
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Notificação de remédio enviada!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Erro ao enviar notificação!')),
            );
          }
        },
      ),
      _IdosoAction(
        icon: Icons.bed,
        color: const Color(0xFF7C4DFF),
        label: 'Quero deitar',
        onTap: (ctx) async {
          try {
            await enviarNotificacao(
              conteudo: 'Quero deitar',
              importancia: 'Baixa',
            );
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Notificação de descanso enviada!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Erro ao enviar notificação!')),
            );
          }
        },
      ),
      _IdosoAction(
        icon: Icons.light_mode,
        color: const Color(0xFF00B8D4),
        label: 'Acender luz',
        onTap: (ctx) async {
          try {
            await enviarNotificacao(
              conteudo: 'Acender luz',
              importancia: 'Baixa',
            );
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Notificação de luz enviada!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Erro ao enviar notificação!')),
            );
          }
        },
      ),
      _IdosoAction(
        icon: Icons.info,
        color: const Color(0xFF3A7CA5),
        label: 'Informações Médicas',
        onTap: (ctx) async {
          final user = await AuthService().getCurrentUser();
          if (user != null) {
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (context) => IdosoInfoPage(idosoId: user.uid),
              ),
            );
          }
        },
      ),
    ];
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int columnCount = 2;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getIdosoData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Erro ao carregar os dados: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Nenhum dado encontrado.')),
          );
        }

        final idoso = snapshot.data!;
        final codigo = idoso['codigo'] ?? '';
        final responsaveis = idoso['responsaveis'] ?? [];
        final temResponsavel = responsaveis.isNotEmpty;
        final nome =
            idoso['apelido'] != null && (idoso['apelido'] as String).isNotEmpty
            ? idoso['apelido']
            : (idoso['nome'] ?? '');
        final fotoUrl = idoso['fotoUrl'] as String?;
        final isAsset = idoso['isAsset'] == true;

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/Background3.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 64,
                      left: 24,
                      right: 24,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                final user = await AuthService()
                                    .getCurrentUser();
                                final storageRef = FirebaseStorage.instance
                                    .ref()
                                    .child('profile_images/${user!.uid}.jpg');
                                await storageRef.putFile(File(pickedFile.path));
                                final downloadUrl = await storageRef
                                    .getDownloadURL();

                                await FirebaseFirestore.instance
                                    .collection('idoso')
                                    .doc(user.uid)
                                    .update({'fotoUrl': downloadUrl});

                                setState(() {});
                              }
                            },
                            child: CircleAvatar(
                              radius: 34,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  fotoUrl != null && fotoUrl.isNotEmpty
                                  ? (isAsset
                                            ? AssetImage(fotoUrl)
                                            : NetworkImage(fotoUrl))
                                        as ImageProvider
                                  : null,
                              child: fotoUrl == null || fotoUrl.isEmpty
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.90),
                                borderRadius: BorderRadius.circular(38),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
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
                                    const TextSpan(text: 'PACIENTE: '),
                                    TextSpan(
                                      text: nome.toUpperCase(),
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
                    ),
                    if (temResponsavel)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 180,
                          left: 12,
                          right: 12,
                          bottom: 90,
                        ),
                        child: ReorderableGridView.count(
                          crossAxisCount: columnCount,
                          mainAxisSpacing: 28,
                          crossAxisSpacing: 28,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              final item = _actions.removeAt(oldIndex);
                              _actions.insert(newIndex, item);
                            });
                          },
                          childAspectRatio: 1,
                          children: List.generate(
                            _actions.length,
                            (index) => _IdosoActionButton(
                              key: ValueKey(_actions[index].label),
                              action: _actions[index],
                            ),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: 24,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
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
                                "Você não tem responsável vinculado.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3A7CA5),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "O responsável deverá usar o código abaixo para te adicionar:",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF3A7CA5),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SelectableText(
                                codigo,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getIdosoData() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }

      final snap = await FirebaseFirestore.instance
          .collection('idoso')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        throw Exception('Dados do idoso não encontrados.');
      }

      return snap.docs.first.data();
    } catch (e) {
      rethrow;
    }
  }
}

class _IdosoAction {
  final IconData icon;
  final Color color;
  final String label;
  final void Function(BuildContext) onTap;

  _IdosoAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
}

class _IdosoActionButton extends StatelessWidget {
  final _IdosoAction action;
  const _IdosoActionButton({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () => action.onTap(context),
        child: Container(
          decoration: BoxDecoration(
            color: action.color,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
