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
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Como Funciona',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A7CA5),
                          ),
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Notificações',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF3A7CA5),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Esta aba exibe alertas e lembretes importantes sobre o paciente.',
                                style: TextStyle(height: 1.4),
                              ),
                              SizedBox(height: 12),
                              Text(
                                '📋 O que você verá:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '• Avisos de cuidados com o paciente\n'
                                '• Lembretes de consultas\n'
                                '• Alertas de situações importantes',
                                style: TextStyle(height: 1.5),
                              ),
                              SizedBox(height: 12),
                              Text(
                                '🔴 Níveis de Importância:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '• Extrema (vermelho): atenção urgente\n'
                                '• Alta (laranja): prioridade\n'
                                '• Média (azul): atenção normal\n'
                                '• Baixa (verde): informativo',
                                style: TextStyle(height: 1.5),
                              ),
                              SizedBox(height: 12),
                              Text(
                                '✅ Como usar:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Quando uma tarefa for concluída, toque no botão "Feito" para removê-la da lista.',
                                style: TextStyle(height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Entendi'),
                          ),
                        ],
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
