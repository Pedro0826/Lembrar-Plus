import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_menu/circular_menu.dart';
import 'paciente_info.dart';
import 'medicamentos.dart';

class IdosoPage extends StatefulWidget {
  final String idosoId;
  const IdosoPage({super.key, required this.idosoId});

  @override
  State<IdosoPage> createState() => _IdosoPageState();
}

class _IdosoPageState extends State<IdosoPage> {
  Map<String, dynamic>? idosoData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIdoso();
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          idosoData != null
              ? 'Cuidando de: ${idosoData!['apelido'] != null && idosoData!['apelido'].toString().isNotEmpty ? idosoData!['apelido'] : (idosoData!['nome'] ?? '')}'
              : 'Cuidando de:',
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                IdosoInfoPage(idosoId: widget.idosoId),
                          ),
                        );
                      },
                      child: const Text('Ver informações do idoso'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MedicamentosPage(
                              idosoId: widget.idosoId,
                              apelido:
                                  idosoData?['apelido'] ??
                                  idosoData?['nome'] ??
                                  '',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Medicamentos'),
                    ),
                    // Adicione mais botões aqui futuramente
                  ],
                ),
                // ...outros widgets...
              ],
            ),
      floatingActionButton: CircularMenu(
        alignment: Alignment.bottomCenter,
        items: [
          CircularMenuItem(
            icon: Icons.logout,
            color: Colors.grey,
            onTap: () {
              // Pode ser usado para logout futuramente
            },
          ),
          CircularMenuItem(
            icon: Icons.arrow_back,
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
