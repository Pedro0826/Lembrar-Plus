import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Caixa de edição no mesmo estilo do paciente_info
class _EditBox extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _EditBox({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A7CA5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 64, 161, 108),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditarPacientePage extends StatefulWidget {
  final String idosoId;
  final Map<String, dynamic> dados;
  const EditarPacientePage({super.key, required this.idosoId, required this.dados});

  @override
  State<EditarPacientePage> createState() => _EditarPacientePageState();
}

class _EditarPacientePageState extends State<EditarPacientePage> {
  late TextEditingController nomeController;
  late TextEditingController apelidoController;
  late TextEditingController cpfController;
  late TextEditingController dataNascController;
  late TextEditingController telefoneController;
  late TextEditingController convenioController;
  late TextEditingController tipoSanguineoController;
  late TextEditingController pesoController;
  late TextEditingController alturaController;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.dados['nome'] ?? '');
    apelidoController = TextEditingController(text: widget.dados['apelido'] ?? '');
    cpfController = TextEditingController(text: widget.dados['cpf'] ?? '');
    dataNascController = TextEditingController(
      text: _formatDataNasc(widget.dados['data_nasc']),
    );
    telefoneController = TextEditingController(text: widget.dados['telefone'] ?? '');
    convenioController = TextEditingController(text: widget.dados['convenio'] ?? '');
    tipoSanguineoController = TextEditingController(text: widget.dados['tipo_sanguineo'] ?? '');
    pesoController = TextEditingController(text: widget.dados['peso']?.toString() ?? '');
    alturaController = TextEditingController(text: widget.dados['altura']?.toString() ?? '');
  }

  String _formatDataNasc(dynamic dataNasc) {
    if (dataNasc == null) return '';
    if (dataNasc is String) return dataNasc;
    if (dataNasc is Timestamp) {
      final date = dataNasc.toDate();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return dataNasc.toString();
  }

  Future<void> salvarEdicao() async {
    try {
      await FirebaseFirestore.instance.collection('idoso').doc(widget.idosoId).update({
        'nome': nomeController.text.trim(),
        'apelido': apelidoController.text.trim(),
        'cpf': cpfController.text.trim(),
        'data_nasc': dataNascController.text.trim(),
        'telefone': telefoneController.text.trim(),
        'convenio': convenioController.text.trim(),
        'tipo_sanguineo': tipoSanguineoController.text.trim(),
        'peso': double.tryParse(pesoController.text.trim()),
        'altura': double.tryParse(alturaController.text.trim()),
      });
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background3.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Center(
                  child: Text(
                    'Editar Paciente',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF3A7CA5),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _EditBox(label: 'Nome', controller: nomeController),
                _EditBox(label: 'Apelido', controller: apelidoController),
                _EditBox(label: 'CPF', controller: cpfController),
                _EditBox(label: 'Data de Nascimento', controller: dataNascController),
                _EditBox(label: 'Telefone', controller: telefoneController),
                _EditBox(label: 'Convênio', controller: convenioController),
                _EditBox(label: 'Tipo Sanguíneo', controller: tipoSanguineoController),
                _EditBox(label: 'Peso (kg)', controller: pesoController),
                _EditBox(label: 'Altura (cm)', controller: alturaController),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7CA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    onPressed: salvarEdicao,
                    child: const Text('Salvar Alterações'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Botão voltar igual ao paciente_info
          Positioned(
            left: 32,
            bottom: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey,
                shape: const CircleBorder(),
                elevation: 4,
                padding: const EdgeInsets.all(18),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, size: 36),
            ),
          ),
        ],
      ),
    );
  }
}
