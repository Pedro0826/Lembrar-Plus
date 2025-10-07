import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_menu/circular_menu.dart';
import 'paciente_info.dart';
import 'medicamentos.dart';
import 'ligar_paciente.dart';

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
    final String nomePaciente = idosoData != null
        ? (idosoData!['apelido'] != null &&
                  idosoData!['apelido'].toString().isNotEmpty
              ? idosoData!['apelido']
              : (idosoData!['nome'] ?? ''))
        : '';

    final String? fotoUrl = idosoData?['fotoUrl'];
    final bool isAsset = idosoData?['isAsset'] == true;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background2.png',
              fit: BoxFit.cover,
            ),
          ),
          // Cabeçalho menor, mais longe do topo, nome ao lado de "PACIENTE:"
          if (!isLoading && fotoUrl != null && fotoUrl.isNotEmpty)
            Positioned(
              top: 64, // mais longe do topo/câmera
              left: 24,
              right: 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 34, // Aumentado
                    backgroundColor: Colors.white,
                    backgroundImage: isAsset
                        ? AssetImage(fotoUrl)
                        : NetworkImage(fotoUrl) as ImageProvider,
                  ),
                  const SizedBox(width: 18), // Espaço um pouco maior
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
                            fontSize: 17, // Fonte maior
                            letterSpacing: 1.1,
                            color: Color(0xFF3A7CA5),
                          ),
                          children: [
                            const TextSpan(text: 'PACIENTE: '),
                            TextSpan(
                              text: nomePaciente.toUpperCase(),
                              style: const TextStyle(color: Color(0xFF3A7CA5)),
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
            ),
          // Centralização vertical dos botões, maiores e mais acima
          if (!isLoading)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 0), // espaço para não colar no topo
                    SizedBox(
                      width: 290,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  IdosoInfoPage(idosoId: widget.idosoId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A7CA5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        child: const Text('Ver informações do paciente'),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: 290,
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.medication,
                          color: Colors.white,
                        ), // Ícone de remédio
                        label: const Text('Medicamentos'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicamentosPage(
                                idosoId: widget.idosoId,
                                apelido: nomePaciente,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6DBE81),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: 290,
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text('Ligar'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LigarIdosoPage(idosoId: widget.idosoId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE57373),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
          // Menu circular centralizado, um pouco mais alto
          Padding(
            padding: const EdgeInsets.only(bottom: 56), // sobe o menu circular
            child: CircularMenu(
              alignment: Alignment.bottomCenter,
              toggleButtonColor: Color.fromARGB(255, 108, 81, 182), // Roxo
              toggleButtonIconColor: Colors.white,
              items: [
                CircularMenuItem(
                  icon: Icons.arrow_back,
                  color: Colors.grey,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                CircularMenuItem(
                  icon: Icons.info_outline,
                  color: Colors.red,
                  onTap: () {
                    // Exemplo: abrir informações extras
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
