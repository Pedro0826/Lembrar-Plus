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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Color(0xFF3A7CA5)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Como funciona o cadastro',
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A7CA5),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(height: 6),
              Text(
                'Você pode se registrar como Responsável (cuidador) ou como Paciente. Veja abaixo as diferenças e passos:',
                style: TextStyle(color: Color(0xFF6B7A8F), fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'Responsável (Cuidador):',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A7CA5),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '• Cria e gerencia os pacientes vinculados\n• Define apelidos, atualiza dados e acompanha notificações\n• Pode cadastrar pelo Google ou email/senha',
                style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
              ),
              SizedBox(height: 12),
              Text(
                'Paciente:',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A7CA5),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '• Possui um perfil com informações de saúde básicas\n• Recebe lembretes e registros de medicamentos\n• Pode ser criado pelo responsável usando um código ou diretamente',
                style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
              ),
              SizedBox(height: 12),
              Text(
                'Passos rápidos:',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A7CA5),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '1. Escolha seu tipo de registro\n2. Complete seus dados (nome, email, CPF, data de nascimento)\n3. Vincule pacientes (se for responsável) ou finalize seu perfil (se for paciente)',
                style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
              ),
              SizedBox(height: 12),
              Text(
                'Privacidade:',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A7CA5),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '• Seus dados são protegidos e usados somente para funcionamento do app\n• Você pode editar ou remover vínculos a qualquer momento',
                style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7A8F),
            ),
            child: const Text('Entendi'),
          ),
        ],
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
