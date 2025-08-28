import 'package:flutter/material.dart';

class RegisterResponsavelRestoPage extends StatefulWidget {
  final String nome;
  final String email;
  const RegisterResponsavelRestoPage({super.key, required this.nome, required this.email});

  @override
  State<RegisterResponsavelRestoPage> createState() => _RegisterResponsavelRestoPageState();
}

class _RegisterResponsavelRestoPageState extends State<RegisterResponsavelRestoPage> {
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  DateTime? dataNascSelecionada;

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> salvarDados() async {
    String telefone = telefoneController.text;
    String cpf = cpfController.text;
    DateTime? dataNasc = dataNascSelecionada;
    if (telefone.isEmpty || cpf.isEmpty || dataNasc == null) {
      mostrarErro('Preencha todos os campos.');
      return;
    }
    Navigator.pushReplacementNamed(context, '/home_responsavel');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completar dados do responsável')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Nome: ${widget.nome}'),
            Text('Email: ${widget.email}'),
            TextField(
              controller: telefoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: cpfController,
              decoration: const InputDecoration(labelText: 'CPF'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Data de Nascimento: '),
                Text(dataNascSelecionada == null
                    ? 'Selecione'
                    : '${dataNascSelecionada!.day}/${dataNascSelecionada!.month}/${dataNascSelecionada!.year}'),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        dataNascSelecionada = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvarDados,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
