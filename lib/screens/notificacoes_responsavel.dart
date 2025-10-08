import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificacoesResponsavelPage extends StatelessWidget {
  final String idosoId;
  const NotificacoesResponsavelPage({super.key, required this.idosoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notificacao')
            .where('codigoIdoso', isEqualTo: idosoId)
            .orderBy('hora', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhuma notificação encontrada.'));
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      : const Text('Feito', style: TextStyle(color: Colors.green)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
