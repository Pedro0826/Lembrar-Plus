import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editar_paciente.dart';

class IdosoInfoPage extends StatefulWidget {
  final String idosoId;
  const IdosoInfoPage({super.key, required this.idosoId});

  @override
  State<IdosoInfoPage> createState() => _IdosoInfoPageState();
}

class _IdosoInfoPageState extends State<IdosoInfoPage> {
  Map<String, dynamic>? idosoData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIdosoData();
  }

  Future<void> fetchIdosoData() async {
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

  String _formatCpf(String cpf) {
    // Remove tudo que não for número
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }

  String _formatDataNasc(dynamic dataNasc) {
    if (dataNasc == null) return '';
    if (dataNasc is String) return dataNasc;
    if (dataNasc is Timestamp) {
      final date = dataNasc.toDate();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }
    return dataNasc.toString();
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
            child: isLoading || idosoData == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      // Cabeçalho com foto, nome e menu de edição
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                idosoData!['fotoUrl'] != null &&
                                    (idosoData!['fotoUrl'] as String).isNotEmpty
                                ? (idosoData!['isAsset'] == true
                                          ? AssetImage(idosoData!['fotoUrl'])
                                          : NetworkImage(idosoData!['fotoUrl']))
                                      as ImageProvider
                                : null,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.90),
                                borderRadius: BorderRadius.circular(38),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    letterSpacing: 1.1,
                                    color: Color(0xFF3A7CA5),
                                  ),
                                  children: [
                                    const TextSpan(text: 'PACIENTE: '),
                                    TextSpan(
                                      text:
                                          (idosoData!['apelido'] != null &&
                                                      (idosoData!['apelido']
                                                              as String)
                                                          .isNotEmpty
                                                  ? idosoData!['apelido']
                                                  : (idosoData!['nome'] ?? ''))
                                              .toString()
                                              .toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF3A7CA5),
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _InfoBox(
                        label: 'Data de Nascimento',
                        value: _formatDataNasc(idosoData!['data_nasc']),
                      ),
                      _InfoBox(
                        label: 'CPF',
                        value: _formatCpf(idosoData!['cpf'] ?? ''),
                      ),
                      _InfoBox(
                        label: 'Telefone',
                        value: idosoData!['telefone'] ?? '',
                      ),
                      _InfoBox(
                        label: 'Convênio',
                        value: idosoData!['convenio'] ?? '',
                      ),
                      _InfoBox(
                        label: 'Tipo Sanguíneo',
                        value: idosoData!['tipo_sanguineo'] ?? '',
                      ),
                      _InfoBox(
                        label: 'Peso',
                        value: idosoData!['peso'] != null
                            ? '${idosoData!['peso']} kg'
                            : '',
                      ),
                      _InfoBox(
                        label: 'Altura',
                        value: idosoData!['altura'] != null
                            ? '${idosoData!['altura']} cm'
                            : '',
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
          ),
          // Botão voltar na parte inferior esquerda
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
          // Botão editar na parte inferior direita
          Positioned(
            right: 32,
            bottom: 24,
            child: Builder(
              builder: (context) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  shape: const CircleBorder(),
                  elevation: 4,
                  padding: const EdgeInsets.all(18),
                ),
                onPressed: () async {
                  // Busca os dados atuais do paciente
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarPacientePage(
                          idosoId: widget.idosoId,
                          dados: idosoData ?? {},
                        ),
                      ),
                    ).then((value) {
                      if (value == true && mounted) {
                        fetchIdosoData();
                      }
                    });
                  }
                },
                child: const Icon(Icons.edit, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBox({required this.label, required this.value});

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
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
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
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
