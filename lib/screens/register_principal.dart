import 'package:flutter/material.dart';
// Removed video background; using static asset image instead

class RegisterPrincipalPage extends StatefulWidget {
  const RegisterPrincipalPage({super.key});

  @override
  State<RegisterPrincipalPage> createState() => _RegisterPrincipalPageState();
}

class _RegisterPrincipalPageState extends State<RegisterPrincipalPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabeçalho colorido
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3A7CA5), Color(0xFF5A9CC5)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Como funciona',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Conteúdo
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        color: const Color(0xFF2563A5),
                        text:
                            'Responsável (Cuidador): Cria e gerencia os pacientes vinculados, define apelidos, atualiza dados e acompanha notificações.',
                      ),
                      const SizedBox(height: 20),
                      _InfoRow(
                        icon: Icons.elderly_rounded,
                        color: const Color(0xFF4CAF50),
                        text:
                            'Paciente: Possui um perfil com informações de saúde básicas e recebe lembretes de medicamentos.',
                      ),
                      const SizedBox(height: 20),
                      _InfoRow(
                        icon: Icons.app_registration_rounded,
                        color: const Color(0xFF3A7CA5),
                        text:
                            'Passos: Escolha seu tipo, complete seus dados (nome, email, CPF, data) e vincule pacientes.',
                      ),
                      const SizedBox(height: 20),
                      _InfoRow(
                        icon: Icons.lock_outline_rounded,
                        color: const Color(0xFF6B7A8F),
                        text:
                            'Privacidade: Seus dados são protegidos e você pode editar ou remover vínculos a qualquer momento.',
                      ),
                    ],
                  ),
                ),
              ),
              // Botão de fechar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A7CA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Entendi!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customRegisterButton({
    required VoidCallback onTap,
    required Color color,
    required String label,
    required String iconAsset,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  iconAsset,
                  height: 28,
                  width: 28,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: color, size: 28),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Imagem de fundo ocupa toda a tela
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background4.png',
              fit: BoxFit.cover,
            ),
          ),
          // Conteúdo por cima do vídeo
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título da página
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 28,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Escolha seu tipo de cadastro',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF3A7CA5),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _customRegisterButton(
                    onTap: () {
                      Navigator.pushNamed(context, '/register_responsavel');
                    },
                    color: const Color(0xFF2563A5),
                    label: 'Registrar-se como Responsável',
                    iconAsset: 'assets/images/registro_responsavel.png',
                  ),
                  const SizedBox(height: 28),
                  _customRegisterButton(
                    onTap: () {
                      Navigator.pushNamed(context, '/register_paciente');
                    },
                    color: const Color(0xFF4CAF50),
                    label: 'Registrar-se como Paciente',
                    iconAsset: 'assets/images/registro_idoso.png',
                  ),
                ],
              ),
            ),
          ),
          // Botão voltar no canto inferior esquerdo
          Positioned(
            left: 24,
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
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Icon(Icons.arrow_back, size: 36),
            ),
          ),
          // Botão informação no canto inferior direito
          Positioned(
            right: 24,
            bottom: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF3A7CA5),
                shape: const CircleBorder(),
                elevation: 4,
                padding: EdgeInsets.zero,
                fixedSize: const Size(56, 56),
              ),
              onPressed: () => _showInfoDialog(context),
              child: const Icon(Icons.info_outline, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
