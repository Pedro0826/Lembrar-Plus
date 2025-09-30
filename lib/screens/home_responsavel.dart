import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_menu/circular_menu.dart';
import 'paciente_page.dart';

class HomeResponsavel extends StatefulWidget {
  const HomeResponsavel({super.key});

  @override
  State<HomeResponsavel> createState() => _HomeResponsavelState();
}

class _HomeResponsavelState extends State<HomeResponsavel> {
  final TextEditingController codigoController = TextEditingController();

  List<Map<String, dynamic>> idosos = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadIdososVinculados();
  }

  Future<void> _loadIdososVinculados() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        setState(() {
          isLoading = false;
          errorMsg = "Usuário não autenticado.";
        });
        return;
      }

      // Busca o documento do responsável
      final doc = await FirebaseFirestore.instance
          .collection('responsavel')
          .doc(user.uid)
          .get();

      final List<dynamic> ids = doc.data()?['idosos_vinculados'] ?? [];

      if (ids.isEmpty) {
        setState(() {
          idosos = [];
          isLoading = false;
        });
        return;
      }

      // Busca os dados dos idosos vinculados
      final query = await FirebaseFirestore.instance
          .collection('idoso')
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      final idososList = query.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();

      setState(() {
        idosos = idososList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = "Erro ao carregar pacientes.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background cobrindo toda a tela
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background2.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 36),
                // Linha com botão circular à esquerda e frase à direita
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/welcome');
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A7CA5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.90),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: const Text(
                          "PÁGINA DO RESPONSÁVEL",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.2,
                            color: Color(0xFF3A7CA5),
                          ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (isLoading) const Center(child: CircularProgressIndicator()),
                Expanded(
                  child: isLoading
                      ? const SizedBox()
                      : idosos.isEmpty
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 32,
                              horizontal: 24,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Você ainda não tem pacientes cadastrados.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3A7CA5),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6DBE81),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text("Cadastrar paciente"),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/register_codigo_idoso',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: idosos.length + 1,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index < idosos.length) {
                              final idoso = idosos[index];
                              return SizedBox(
                                height: 90, // Garante altura igual para todos
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  color: Colors.white.withOpacity(0.96),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 18,
                                    ),
                                    leading: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage:
                                          (idoso['fotoUrl'] != null &&
                                              idoso['fotoUrl']
                                                  .toString()
                                                  .isNotEmpty)
                                          ? (idoso['isAsset'] == true
                                                    ? AssetImage(
                                                        idoso['fotoUrl'],
                                                      )
                                                    : NetworkImage(
                                                        idoso['fotoUrl'],
                                                      ))
                                                as ImageProvider
                                          : const AssetImage(
                                              'assets/images/default_profile.jpg',
                                            ),
                                    ),
                                    title: Text(
                                      (idoso['apelido'] != null &&
                                              idoso['apelido']
                                                  .toString()
                                                  .isNotEmpty)
                                          ? idoso['apelido'].toString().trim()
                                          : (idoso['nome'] ?? 'Sem nome')
                                                .toString()
                                                .trim(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Color(0xFF3A7CA5),
                                      ),
                                    ),
                                    subtitle: Text(
                                      'CPF: ${(idoso['cpf'] ?? '').toString().trim()}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7A8F),
                                      ),
                                    ),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              IdosoPage(idosoId: idoso['id']),
                                        ),
                                      );
                                    },
                                    trailing: PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) async {},
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'editar_apelido',
                                          child: Text('Definir apelido'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'remover',
                                          child: Text('Remover vínculo'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              // Botão de cadastrar paciente centralizado após a lista
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24.0,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6DBE81),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text("Cadastrar paciente"),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/register_codigo_idoso',
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
          // Menu circular centralizado, um pouco mais alto
          Padding(
            padding: const EdgeInsets.only(bottom: 56),
            child: CircularMenu(
              toggleButtonColor: const Color.fromARGB(255, 108, 81, 182),
              alignment: Alignment.bottomCenter,
              items: [
                CircularMenuItem(
                  icon: Icons.add,
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(context, '/register_codigo_idoso');
                  },
                ),
                CircularMenuItem(
                  icon: Icons.logout,
                  color: Colors.grey,
                  onTap: () async {
                    await AuthService().signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                ),
                CircularMenuItem(
                  icon: Icons.info_outline,
                  color: Colors.red,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
