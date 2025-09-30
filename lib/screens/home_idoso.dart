import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'idoso_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class HomeIdoso extends StatefulWidget {
  const HomeIdoso({super.key});

  @override
  State<HomeIdoso> createState() => _HomeIdosoState();
}

class _HomeIdosoState extends State<HomeIdoso> {
  late List<_IdosoAction> _actions;

  @override
  void initState() {
    super.initState();
    _actions = [
      _IdosoAction(
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFE57373),
        label: 'Preciso de ajuda!',
        onTap: (ctx) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Notificação de ajuda enviada!')),
          );
        },
      ),
      _IdosoAction(
        icon: Icons.wc,
        color: const Color(0xFFFF9800),
        label: 'Preciso ir ao banheiro',
        onTap: (ctx) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Notificação de banheiro enviada!')),
          );
        },
      ),
      _IdosoAction(
        icon: Icons.local_dining,
        color: const Color(0xFF6DBE81),
        label: 'Quero comer',
        onTap: (ctx) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Notificação de refeição enviada!')),
          );
        },
      ),
      _IdosoAction(
        icon: Icons.medication,
        color: const Color(0xFF3A7CA5),
        label: 'Preciso de remédio',
        onTap: (ctx) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Notificação de remédio enviada!')),
          );
        },
      ),
      _IdosoAction(
        icon: Icons.bed,
        color: const Color(0xFF7C4DFF),
        label: 'Quero deitar',
        onTap: (ctx) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Notificação de descanso enviada!')),
          );
        },
      ),
      _IdosoAction(
        icon: Icons.light_mode,
        color: const Color(0xFF00B8D4), // azul claro
        label: 'Acender luz',
        onTap: (ctx) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Notificação de luz enviada!')),
          );
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

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _actions.removeAt(oldIndex);
      _actions.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    int columnCount = 2;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getIdosoData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/Background3.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Cabeçalho igual ao idoso_page.dart
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
                          // Faça upload para o Firebase Storage
                          final user = await AuthService().getCurrentUser();
                          final storageRef = FirebaseStorage.instance
                              .ref()
                              .child('profile_images/${user!.uid}.jpg');
                          await storageRef.putFile(File(pickedFile.path));
                          final downloadUrl = await storageRef.getDownloadURL();

                          // Atualize o campo fotoUrl no Firestore
                          await FirebaseFirestore.instance
                              .collection('idoso')
                              .doc(user.uid)
                              .update({'fotoUrl': downloadUrl});

                          setState(
                            () {},
                          ); // Atualiza a tela para mostrar a nova foto
                        }
                      },
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white,
                        backgroundImage: fotoUrl != null && fotoUrl.isNotEmpty
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
              // Grid de botões reordenável
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
                    onReorder: _onReorder,
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
              // Botões auxiliares grandes na parte inferior
              Positioned(
                left: 32,
                right: 32,
                bottom: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey,
                        shape: const CircleBorder(),
                        elevation: 4,
                        padding: const EdgeInsets.all(18),
                      ),
                      onPressed: () async {
                        await AuthService().signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      child: const Icon(Icons.logout, size: 36),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF7C4DFF),
                        shape: const CircleBorder(),
                        elevation: 4,
                        padding: const EdgeInsets.all(18),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'Ajuda',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                            content: const Text(
                              'Toque em um dos botões para avisar seu responsável.\n'
                              'Cada botão tem uma função diferente e envia uma notificação apropriada.',
                              style: TextStyle(fontSize: 20),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'OK',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Icon(Icons.info_outline, size: 36),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getIdosoData() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) return null;
    final snap = await FirebaseFirestore.instance
        .collection('idoso')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final data = snap.docs.first.data();
    return data;
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
            color: action.color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: action.color, width: 2),
            boxShadow: [
              BoxShadow(
                color: action.color.withOpacity(0.10),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: action.color, size: 54),
              const SizedBox(height: 16),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: action.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
