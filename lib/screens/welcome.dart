import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool isLoading = true;
  String? userType;
  int _current = 0; // Para o indicador das bolinhas

  final List<String> carouselImages = [
    'assets/images/Carrosel1.png',
    'assets/images/Carrosel2.png',
    'assets/images/Carrosel3.png',
    'assets/images/Carrosel4.png',
  ];

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  Future<void> _checkUserLoggedIn() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      userType = null;
      isLoading = false;
    });

    if (userType == "idoso") {
      Navigator.pushReplacementNamed(context, '/home_idoso');
    } else if (userType == "responsavel") {
      Navigator.pushReplacementNamed(context, '/home_responsavel');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/Background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Conteúdo principal centralizado
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: size.height * 0.13, // Reduziu o espaço do topo
                    ),
                    // Carrossel centralizado
                    Container(
                      width: size.width * 0.92,
                      height: size.height * 0.55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB3D9F7).withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: CarouselSlider.builder(
                          itemCount: carouselImages.length,
                          options: CarouselOptions(
                            height: double.infinity,
                            autoPlay: true,
                            enlargeCenterPage: false,
                            viewportFraction: 1.0,
                            enableInfiniteScroll: true,
                            autoPlayInterval: const Duration(seconds: 3),
                            onPageChanged: (index, reason) {
                              setState(() {
                                _current = index;
                              });
                            },
                          ),
                          itemBuilder: (context, index, realIdx) {
                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    carouselImages[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Bolinhas por cima da imagem, alinhadas embaixo
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 18,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      carouselImages.length,
                                      (dotIdx) {
                                        return AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: _current == dotIdx ? 14 : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _current == dotIdx
                                                ? const Color(0xFF3A7CA5)
                                                : const Color(0xFFB3D9F7),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 28,
                    ), // Reduziu o espaço abaixo do carrossel
                    // Botão centralizado
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6DBE81),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              letterSpacing: 1,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text("ENTRAR/REGISTRAR"),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
