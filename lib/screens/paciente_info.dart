import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editar_paciente.dart';

class IdosoInfoPage extends StatelessWidget {
  final String idosoId;
  const IdosoInfoPage({super.key, required this.idosoId});

  Future<Map<String, dynamic>?> fetchIdosoData() async {
    final doc = await FirebaseFirestore.instance
        .collection('idoso')
        .doc(idosoId)
        .get();
    return doc.data();
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
      // Usa o background3 como fundo
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background3.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: fetchIdosoData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final idoso = snapshot.data!;
                final nome =
                    idoso['apelido'] != null &&
                        (idoso['apelido'] as String).isNotEmpty
                    ? idoso['apelido']
                    : (idoso['nome'] ?? '');
                final fotoUrl = idoso['fotoUrl'] as String?;
                final isAsset = idoso['isAsset'] == true;

                return ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    // Cabeçalho com foto, nome e menu de edição
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white,
                          backgroundImage: fotoUrl != null && fotoUrl.isNotEmpty
                              ? (isAsset
                                    ? AssetImage(fotoUrl)
                                    : NetworkImage(fotoUrl))
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
                                    text: nome.toUpperCase(),
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
                        // ...
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Informações em caixas de texto
                    _InfoBox(
                      label: 'Data de Nascimento',
                      value: _formatDataNasc(idoso['data_nasc']),
                    ),
                    _InfoBox(
                      label: 'CPF',
                      value: _formatCpf(idoso['cpf'] ?? ''),
                    ),
                    _InfoBox(label: 'Telefone', value: idoso['telefone'] ?? ''),
                    _InfoBox(label: 'Convênio', value: idoso['convenio'] ?? ''),
                    _InfoBox(
                      label: 'Tipo Sanguíneo',
                      value: idoso['tipo_sanguineo'] ?? '',
                    ),
                    _InfoBox(
                      label: 'Peso',
                      value: idoso['peso'] != null ? '${idoso['peso']} kg' : '',
                    ),
                    _InfoBox(
                      label: 'Altura',
                      value: idoso['altura'] != null
                          ? '${idoso['altura']} cm'
                          : '',
                    ),
                    const SizedBox(height: 100),
                    // Adicione mais campos conforme necessário
                  ],
                );
              },
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
                  final doc = await FirebaseFirestore.instance.collection('idoso').doc(idosoId).get();
                  final dados = doc.data() ?? {};
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarPacientePage(
                          idosoId: idosoId,
                          dados: dados,
                        ),
                      ),
                    ).then((value) {
                      if (value == true) {
                        // Atualiza a tela após edição
                        (context as Element).markNeedsBuild();
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
