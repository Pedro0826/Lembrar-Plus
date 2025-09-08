import '../services/firestore_service.dart';
import 'package:flutter/material.dart';

class RegisterMedicamentosPage extends StatefulWidget {
  final String idosoId;
  const RegisterMedicamentosPage({Key? key, required this.idosoId}) : super(key: key);

  @override
  State<RegisterMedicamentosPage> createState() => _RegisterMedicamentosPageState();
}

class _RegisterMedicamentosPageState extends State<RegisterMedicamentosPage> {
  final _firestoreService = FirestoreService();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController dosagemController = TextEditingController();
  final TextEditingController prazoController = TextEditingController();
  final TextEditingController observacoesController = TextEditingController();
  bool isLoading = false;

  Future<void> adicionarMedicamento() async {
    final nome = nomeController.text.trim();
    final dosagem = dosagemController.text.trim();
    final prazo = int.tryParse(prazoController.text.trim());
    final observacoes = observacoesController.text.trim();
    if (nome.isEmpty || dosagem.isEmpty || prazo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos corretamente!')),
      );
      return;
    }
    setState(() { isLoading = true; });
    await _firestoreService.addMedicamento(
      idosoId: widget.idosoId,
      nome: nome,
      dosagem: dosagem,
      prazoDias: prazo,
      observacoes: observacoes,
    );
    setState(() { isLoading = false; });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Medicamento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome do remédio'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: dosagemController,
              decoration: InputDecoration(labelText: 'Dosagem'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: prazoController,
              decoration: InputDecoration(labelText: 'Prazo em dias'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: observacoesController,
              decoration: InputDecoration(labelText: 'Observações (ex: de 8 em 8h)'),
              maxLines: 2,
            ),
            SizedBox(height: 24),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text('Salvar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: adicionarMedicamento,
                  ),
          ],
        ),
      ),
    );
  }
}
