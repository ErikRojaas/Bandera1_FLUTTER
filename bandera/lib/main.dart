import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:bandera/Utils/ServerUtils.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final getIt = GetIt.instance;
  //TODO: add providers here to getIt
  //exemple: getIt.registerSingleton<PlayerProvider>(PlayerProvider());
  ServerUtils.connectToServer(onDisconnect: null);

  runApp(MultiProvider(
    providers: [],
    child: const MyApp(),
  ));
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    // Inicializa el controlador de la animación del QR
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true); // Repite la animación (ida y vuelta)

    // Animación de escala para el QR
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Animación de color para el círculo rojo
    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(71, 238, 21, 5).withOpacity(0.6),
      end: const Color.fromARGB(255, 243, 3, 3).withOpacity(1.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Arial',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "BANDERA 1",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Escanea el código QR y descarga la APK \npara unirte a la partida!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // QR con animación de escala
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent, width: 4),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: const Offset(4, 4),
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: Image.network(
                        "https://bandera1.ieti.site/qrcode.png",
                        width: 250,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const CircularProgressIndicator();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Text("No se pudo cargar el QR.");
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Botón con círculo animado
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topRight,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      print("Ir a Ver Partida en Directo");
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Ver Partida en Directo",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),

                  // Círculo rojo animado en la esquina superior derecha
                  Positioned(
                    top: -8,
                    right: -8,
                    child: AnimatedBuilder(
                      animation: _colorAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _colorAnimation.value,
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
