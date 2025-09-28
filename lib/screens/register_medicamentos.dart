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

  InputDecoration campoDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Color(0xFF707070)),
      filled: true,
      fillColor: const Color(0xFFD8F8E1),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none, // sem borda
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none, // sem borda
      ),
    );
  }

  Future<void> adicionarMedicamento() async {
    final nome = nomeController.text.trim();
    final dosagem = dosagemController.text.trim();
    final prazo = int.tryParse(prazoController.text.trim());
    final observacoes = observacoesController.text.trim();

    if (nome.isEmpty || dosagem.isEmpty || prazo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _firestoreService.addMedicamento(
        idosoId: widget.idosoId,
        nome: nome,
        dosagem: dosagem,
        prazoDias: prazo,
        observacoes: observacoes,
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text(
          'Adicionar Medicamento',
          style: TextStyle(
            color: Color(0xFF66B2B2),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF66B2B2)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomeController,
                decoration: campoDecoration('Nome do remédio'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dosagemController,
                decoration: campoDecoration('Dosagem'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: prazoController,
                decoration: campoDecoration('Prazo em dias'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: observacoesController,
                decoration: campoDecoration('Observações (ex: de 8 em 8h)'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : adicionarMedicamento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66B2B2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}