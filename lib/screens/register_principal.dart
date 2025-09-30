import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class RegisterPrincipalPage extends StatefulWidget {
  const RegisterPrincipalPage({super.key});

  @override
  State<RegisterPrincipalPage> createState() => _RegisterPrincipalPageState();
}

class _RegisterPrincipalPageState extends State<RegisterPrincipalPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/background.mp4')
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Escolha o tipo de registro',
          style: TextStyle(
            color: Color(0xFF3A7CA5),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Selecione se deseja se registrar como Responsável ou como Paciente.',
          style: TextStyle(fontSize: 17),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontSize: 16)),
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
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  iconAsset,
                  height: 24,
                  width: 24,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 18),
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
          // Vídeo de fundo ocupa toda a tela
          if (_controller.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          // Conteúdo por cima do vídeo
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _customRegisterButton(
                    onTap: () {
                      Navigator.pushNamed(context, '/register_responsavel');
                    },
                    color: const Color(0xFF3A7CA5),
                    label: 'Registrar-se como Responsável',
                    iconAsset: 'assets/images/registro_responsavel.png',
                  ),
                  const SizedBox(height: 24),
                  _customRegisterButton(
                    onTap: () {
                      Navigator.pushNamed(context, '/register_paciente');
                    },
                    color: const Color(0xFF6DBE81),
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
                elevation: 3,
                padding: const EdgeInsets.all(10),
                minimumSize: const Size(40, 40),
                maximumSize: const Size(40, 40),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Icon(Icons.arrow_back, size: 22),
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
                elevation: 3,
                padding: const EdgeInsets.all(10),
                minimumSize: const Size(40, 40),
                maximumSize: const Size(40, 40),
              ),
              onPressed: () => _showInfoDialog(context),
              child: const Icon(Icons.info_outline, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
