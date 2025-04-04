import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Inicializa el controlador de la animación
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Duración de la animación
      vsync: this,
    )..repeat(reverse: true); // Hace que la animación repita (hacia adelante y hacia atrás)

    // Escala de la animación
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Efecto de aceleración/desaceleración
    ));
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera los recursos del controlador cuando ya no se necesite
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

              // Container con animación de escala
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
                        "http://localhost:8080/qrcode.png", // URL del QR, cambiar a la del servidor
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

              // Botón con el círculo rojo en la esquina superior derecha
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
                  // Círculo rojo fuera del botón, en la esquina superior derecha
                  Positioned(
                    top: -8, 
                    right: -8,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
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
