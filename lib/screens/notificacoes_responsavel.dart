import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_menu/circular_menu.dart';

class NotificacoesResponsavelPage extends StatefulWidget {
  final String idosoId;
  const NotificacoesResponsavelPage({super.key, required this.idosoId});

  @override
  State<NotificacoesResponsavelPage> createState() =>
      _NotificacoesResponsavelPageState();
}

class _NotificacoesResponsavelPageState
    extends State<NotificacoesResponsavelPage> {
  Map<String, dynamic>? idosoData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchIdoso();
  }

  Future<void> _fetchIdoso() async {
    setState(() {
      // Evitar overlay duplicado, deixar builders cuidarem do loading
      isLoading = false;
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background2.png',
              fit: BoxFit.cover,
            ),
          ),
          // Cabeçalho com avatar e texto centralizado
          if (!isLoading)
            Positioned(
              top: 64,
              left: 24,
              right: 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        (idosoData?['fotoUrl'] != null &&
                            idosoData!['fotoUrl'].toString().isNotEmpty)
                        ? (idosoData!['isAsset'] == true
                              ? AssetImage(idosoData!['fotoUrl'])
                              : NetworkImage(idosoData!['fotoUrl'])
                                    as ImageProvider)
                        : null,
                    child:
                        (idosoData?['fotoUrl'] == null ||
                            idosoData!['fotoUrl'].toString().isEmpty)
                        ? const Icon(Icons.person, color: Colors.grey, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 40,
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
                        child: const Center(
                          child: Text(
                            'NOTIFICAÇÕES',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              letterSpacing: 1.1,
                              color: Color(0xFF3A7CA5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 140),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notificacao')
                  .where('codigoIdoso', isEqualTo: widget.idosoId)
                  .orderBy('hora', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Align(
                      alignment: const Alignment(0, -0.12),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.82,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 48,
                              color: const Color(0xFF3A7CA5),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Nenhuma notificação encontrada.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3A7CA5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final notificacoes = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: notificacoes.length,
                  itemBuilder: (context, index) {
                    final doc = notificacoes[index];
                    final conteudo = doc['conteudo'] ?? '';
                    final importancia = doc['importancia'] ?? '';
                    final status = doc['status'] ?? false;
                    final hora = (doc['hora'] as Timestamp?)?.toDate();
                    final horaFormatada = hora != null
                        ? '${hora.day.toString().padLeft(2, '0')}/${hora.month.toString().padLeft(2, '0')}/${hora.year} - ${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}'
                        : '';

                    Color importanciaColor;
                    switch (importancia.toLowerCase()) {
                      case 'extrema':
                        importanciaColor = Colors.red;
                        break;
                      case 'alta':
                        importanciaColor = Colors.orange;
                        break;
                      case 'média':
                        importanciaColor = Colors.blue;
                        break;
                      case 'baixa':
                        importanciaColor = Colors.green;
                        break;
                      default:
                        importanciaColor = Colors.black;
                    }

                    return Card(
                      color: status ? Colors.white : const Color(0xFFFFF3E0),
                      elevation: status ? 1 : 4,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          status ? Icons.check_circle : Icons.error_outline,
                          color: status ? Colors.green : importanciaColor,
                          size: 32,
                        ),
                        title: Text(
                          conteudo,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: importanciaColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Importância: $importancia'),
                            Text('Horário: $horaFormatada'),
                          ],
                        ),
                        trailing: !status
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('notificacao')
                                      .doc(doc.id)
                                      .delete();
                                },
                                child: const Text('Feito'),
                              )
                            : const Text(
                                'Feito',
                                style: TextStyle(color: Colors.green),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Removido overlay de carregamento para evitar dois ícones simultâneos
          // Menu circular
          Padding(
            padding: const EdgeInsets.only(bottom: 56),
            child: CircularMenu(
              alignment: Alignment.bottomCenter,
              toggleButtonColor: const Color.fromARGB(255, 108, 81, 182),
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
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 400,
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Cabeçalho colorido
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                  horizontal: 24,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 226, 83, 81),
                                      Color.fromARGB(255, 223, 113, 111),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.notifications_active_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Notificações',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Conteúdo
                              Flexible(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      _NotifInfoRow(
                                        icon: Icons.info_outline_rounded,
                                        color: const Color(0xFF3A7CA5),
                                        text:
                                            'Esta aba exibe alertas e lembretes importantes sobre o paciente.',
                                      ),
                                      const SizedBox(height: 20),
                                      _NotifInfoRow(
                                        icon: Icons.list_alt_rounded,
                                        color: const Color(0xFF6DBE81),
                                        text:
                                            'O que você verá: Avisos de cuidados, lembretes de consultas e alertas de situações importantes.',
                                      ),
                                      const SizedBox(height: 20),
                                      _NotifInfoRow(
                                        icon: Icons.priority_high_rounded,
                                        color: const Color(0xFFE57373),
                                        text:
                                            'Níveis: Extrema (vermelho), Alta (laranja), Média (azul), Baixa (verde).',
                                      ),
                                      const SizedBox(height: 20),
                                      _NotifInfoRow(
                                        icon:
                                            Icons.check_circle_outline_rounded,
                                        color: const Color(0xFF4CAF50),
                                        text:
                                            'Como usar: Toque no botão "Feito" para remover notificações concluídas.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Botão de fechar
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  0,
                                  24,
                                  24,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        226,
                                        83,
                                        81,
                                      ),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Entendi!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

class _NotifInfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _NotifInfoRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
