import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_menu/circular_menu.dart';
import 'idoso_info.dart';

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
    setState(() { isLoading = true; });
    final doc = await FirebaseFirestore.instance.collection('idoso').doc(widget.idosoId).get();
    setState(() {
      idosoData = doc.data();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                            builder: (context) => IdosoInfoPage(idosoId: widget.idosoId),
                          ),
                        );
                      },
                      child: const Text('Ver informações do idoso'),
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
              Navigator.pop(context);
            },
          ),
          CircularMenuItem(
            icon: Icons.info_outline,
            color: Colors.red,
            onTap: () {}, // item dummy
          ),
        ],
      ),
    );
  }
}
