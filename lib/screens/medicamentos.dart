import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'package:circular_menu/circular_menu.dart';
import 'register_medicamentos.dart';

class MedicamentosPage extends StatefulWidget {
  final String idosoId;
  final String apelido;
  const MedicamentosPage({
    super.key,
    required this.idosoId,
    required this.apelido,
  });

  @override
  _MedicamentosPageState createState() => _MedicamentosPageState();
}

class _MedicamentosPageState extends State<MedicamentosPage> {
  DateTime _addDays(dynamic date, dynamic dias) {
    DateTime dt;
    if (date is Timestamp) {
      dt = date.toDate();
    } else if (date is DateTime) {
      dt = date;
    } else if (date is String) {
      try {
        dt = DateTime.parse(date);
      } catch (_) {
        return DateTime.now();
      }
    } else {
      return DateTime.now();
    }
    int diasInt = 0;
    if (dias is int) {
      diasInt = dias;
    } else if (dias is String) {
      diasInt = int.tryParse(dias) ?? 0;
    }
    return dt.add(Duration(days: diasInt));
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    DateTime dt;
    if (date is Timestamp) {
      dt = date.toDate();
    } else if (date is DateTime) {
      dt = date;
    } else if (date is String) {
      try {
        dt = DateTime.parse(date);
      } catch (_) {
        return date;
      }
    } else {
      return date.toString();
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medicamentos de ${widget.apelido}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getMedicamentosByIdoso(widget.idosoId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nenhum medicamento cadastrado.',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: Icon(Icons.add),
                    label: Text('Adicionar medicamento'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RegisterMedicamentosPage(idosoId: widget.idosoId),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          return Card(
                            child: ListTile(
                              title: Text(doc['nome'] ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (doc['dosagem'] != null)
                                    Text('Dosagem: ${doc['dosagem']}'),
                                  if (doc['prazoDias'] != null)
                                    Text('Prazo: ${doc['prazoDias']} dias'),
                                  if (doc['observacoes'] != null &&
                                      doc['observacoes'].toString().isNotEmpty)
                                    Text('Obs: ${doc['observacoes']}'),
                                  if (doc['createdAt'] != null)
                                    Text(
                                      'Início: ${_formatDate(doc['createdAt'])}',
                                    ),
                                  if (doc['createdAt'] != null &&
                                      doc['prazoDias'] != null)
                                    Text(
                                      'Fim: ${_formatDate(_addDays(doc['createdAt'], doc['prazoDias']))}',
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  await _firestoreService.removeMedicamentoApp(
                                    doc.id,
                                  );
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: CircularMenu(
                      alignment: Alignment.bottomRight,
                      items: [
                        CircularMenuItem(
                          icon: Icons.add,
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterMedicamentosPage(
                                  idosoId: widget.idosoId,
                                ),
                              ),
                            );
                          },
                        ),
                        CircularMenuItem(
                          icon: Icons.info_outline,
                          color: Colors.grey,
                          onTap: () {
                            // Item extra, pode ser usado para informações ou futuro recurso
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
