import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'paciente_info.dart';
import 'medicamentos.dart';
import 'notificacoes_responsavel.dart';
import 'Info_projeto.dart';

class IdosoPage extends StatefulWidget {
  final String idosoId;
  const IdosoPage({super.key, required this.idosoId});

  @override
  State<IdosoPage> createState() => _IdosoPageState();
}

class _IdosoPageState extends State<IdosoPage> {
  Future<void> ligarParaPaciente() async {
    final numero = idosoData?['telefone']?.toString() ?? '';
    if (numero.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número de telefone não disponível.')),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: numero);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o app de telefone.'),
        ),
      );
    }
  }

  bool isOffline = false;
  Map<String, dynamic>? idosoData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchIdoso();
    checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      // Suporte para quando result é uma lista (ex: [ConnectivityResult.none])
      bool offline;
      // ignore: unnecessary_type_check
      if (result is List) {
        offline = result.contains(ConnectivityResult.none);
      } else {
        offline = result == ConnectivityResult.none;
      }
      setState(() {
        isOffline = offline;
      });
    });
  }

  Future<void> checkConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();
    bool offline;
    if (connectivity is List) {
      offline = connectivity.contains(ConnectivityResult.none);
    } else {
      offline = connectivity == ConnectivityResult.none;
    }
    if (mounted) {
      setState(() {
        isOffline = offline;
      });
    }
  }

  Future<void> fetchIdoso() async {
    setState(() {
      isLoading = true;
    });
    final doc = await FirebaseFirestore.instance
        .collection('idoso')
        .doc(widget.idosoId)
        .get();
    setState(() {
      idosoData = doc.data();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final String nomePaciente = idosoData != null
        ? (idosoData!['apelido'] != null &&
                  idosoData!['apelido'].toString().isNotEmpty
              ? idosoData!['apelido']
              : (idosoData!['nome'] ?? ''))
        : '';

    final String? fotoUrl = idosoData?['fotoUrl'];
    final bool isAsset = idosoData?['isAsset'] == true;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background2.png',
              fit: BoxFit.cover,
            ),
          ),
          // Cabeçalho menor, mais longe do topo, nome ao lado de "PACIENTE:"
          Positioned(
            top: 64,
            left: 24,
            right: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    final String url = (idosoData?['fotoUrl'] ?? '').toString();
                    final bool isAsset = idosoData?['isAsset'] == true;
                    final bool hasPhoto = url.isNotEmpty;
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
                              child: hasPhoto
                                  ? CircleAvatar(
                                      backgroundImage: isAsset
                                          ? AssetImage(url)
                                          : NetworkImage(url) as ImageProvider,
                                      radius: 120,
                                    )
                                  : const CircleAvatar(
                                      radius: 120,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 80,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                      transitionBuilder: (context, anim, secondaryAnim, child) {
                        return FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.95,
                              end: 1,
                            ).animate(anim),
                            child: child,
                          ),
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                        ? (isAsset
                              ? AssetImage(fotoUrl)
                              : NetworkImage(fotoUrl) as ImageProvider)
                        : null,
                    child: (fotoUrl == null || fotoUrl.isEmpty)
                        ? const Icon(Icons.person, color: Colors.grey, size: 32)
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
                            text: nomePaciente.toUpperCase(),
                            style: const TextStyle(color: Color(0xFF3A7CA5)),
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
          // Centralização vertical dos botões, maiores e mais acima
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 0),
                  SizedBox(
                    width: 290,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                IdosoInfoPage(idosoId: widget.idosoId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A7CA5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      child: const Text('Ver informações do paciente'),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: 290,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.medication, color: Colors.white),
                      label: const Text('Medicamentos'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MedicamentosPage(
                              idosoId: widget.idosoId,
                              apelido: nomePaciente,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6DBE81),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  if (!isOffline) ...[
                    const SizedBox(height: 22),
                    SizedBox(
                      width: 290,
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text('Ligar'),
                        onPressed: ligarParaPaciente,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE57373),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: 290,
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                        ),
                        label: const Text('Notificações'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificacoesResponsavelPage(
                                idosoId: widget.idosoId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (isOffline) ...[
                    const SizedBox(height: 22),
                    Container(
                      width: 290,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Você está offline. Funcionalidades restritas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Overlay de carregamento removido; build early-return cuida de mostrar único loader
          // Menu circular centralizado, um pouco mais alto
          Padding(
            padding: const EdgeInsets.only(bottom: 56), // sobe o menu circular
            child: CircularMenu(
              alignment: Alignment.bottomCenter,
              toggleButtonColor: Color.fromARGB(255, 108, 81, 182), // Roxo
              toggleButtonIconColor: Colors.white,
              items: [
                CircularMenuItem(
                  icon: Icons.arrow_back,
                  color: Colors.grey,
                  onTap: () {
                    Navigator.pop(context);
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
