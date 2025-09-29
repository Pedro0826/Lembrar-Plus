import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IdosoInfoPage extends StatelessWidget {
  final String idosoId;
  const IdosoInfoPage({super.key, required this.idosoId});

  Future<Map<String, dynamic>?> fetchIdosoData() async {
    final doc = await FirebaseFirestore.instance.collection('idoso').doc(idosoId).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informações do Idoso')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchIdosoData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final idoso = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                Text('Nome: ${idoso['nome'] ?? ''}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('CPF: ${idoso['cpf'] ?? ''}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('Data de Nascimento: ${idoso['data_nasc'] != null ? (idoso['data_nasc'] is String ? idoso['data_nasc'] : (idoso['data_nasc'] as Timestamp).toDate().toLocal().toString().split(' ')[0]) : ''}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('Telefone: ${idoso['telefone'] ?? ''}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('Convênio: ${idoso['convenio'] ?? ''}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('Tipo Sanguíneo: ${idoso['tipo_sanguineo'] ?? ''}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('Peso: ${idoso['peso'] ?? ''} kg', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('Altura: ${idoso['altura'] ?? ''} cm', style: const TextStyle(fontSize: 18)),
                // Adicione mais campos se necessário
              ],
            ),
          );
        },
      ),
    );
  }
}
