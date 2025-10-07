import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'register_medicamentos.dart';
import 'package:circular_menu/circular_menu.dart';

class MedicamentosPage extends StatefulWidget {
  final String idosoId;
  final String apelido;

  const MedicamentosPage({
    super.key,
    required this.idosoId,
    required this.apelido,
  });

  @override
  State<MedicamentosPage> createState() => _MedicamentosPageState();
}

class _MedicamentosPageState extends State<MedicamentosPage> {
  final _firestoreService = FirestoreService();

  String _formatDate(dynamic date) {
    if (date == null) return '';
    DateTime dt;
    if (date is Timestamp) {
      dt = date.toDate();
    } else if (date is DateTime) {
      dt = date;
    } else {
      return '';
    }
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicamentos de ${widget.apelido}'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF66B2B2)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getMedicamentosByIdoso(widget.idosoId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Nenhum medicamento cadastrado.',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar medicamento'),
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
                ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data =
                        doc.data()
                            as Map<
                              String,
                              dynamic
                            >?; // Garante que o tipo seja seguro
                    return Card(
                      child: ListTile(
                        title: Text(data?['nome'] ?? 'Sem nome'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((data?.containsKey('dosagem') ?? false) &&
                                (data?.containsKey('unidadeDosagem') ?? false))
                              Text(
                                'Dosagem: ${data?['dosagem']} ${data?['unidadeDosagem']}',
                              ),
                            if (data?.containsKey('prazoDias') ?? false)
                              Text('Prazo: ${data?['prazoDias']} dias'),
                            if (data?.containsKey('dataInicio') ?? false)
                              Text(
                                'Início: ${_formatDate(data?['dataInicio'])}',
                              ),
                            if (data?['dataFim'] != null)
                              Text('Fim: ${_formatDate(data?['dataFim'])}')
                            else
                              Text('Fim: Não informado'),
                            if (data?.containsKey('horarioInicio') ?? false)
                              Text('Horário: ${data?['horarioInicio']}'),
                            if ((data?.containsKey('periodo') ?? false) &&
                                (data?.containsKey('unidadePeriodo') ?? false))
                              Text(
                                'Período: ${data?['periodo']} ${data?['unidadePeriodo']}',
                              ),
                            if (data?['observacoes']?.toString().isNotEmpty ??
                                false)
                              Text('Obs: ${data?['observacoes']}'),
                            if (data?.containsKey('createdAt') ?? false)
                              Text(
                                'Criado em: ${_formatDate(data?['createdAt'])}',
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
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
