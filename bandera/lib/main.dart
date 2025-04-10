import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:bandera/Utils/ServerUtils.dart';
import 'package:bandera/Providers/PlayerProvider.dart';
import 'package:bandera/Providers/KeyProvider.dart';
import 'package:bandera/Widgets/PlayerWidget.dart';
import 'package:bandera/Widgets/KeyWidget.dart';
import 'package:flame/flame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flame and load images
  await Flame.device.fullScreen();
  await Flame.images.loadAll(['key.png']);  // Just the filename, not the path

  final getIt = GetIt.instance;
  getIt.registerSingleton<PlayerProvider>(PlayerProvider());
  getIt.registerSingleton<KeyProvider>(KeyProvider());

  ServerUtils.connectToServer(onDisconnect: () {
    print("Desconectado del servidor.");
  });

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => getIt<PlayerProvider>()),
      ChangeNotifierProvider(create: (_) => getIt<KeyProvider>()),
    ],
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 100),
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                  "https://bandera1.ieti.site/public/qrcode.png",
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
                          alignment: Alignment.center,
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
                            Positioned(
                              top: -8,
                              left: -8,
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

                // Cuadro derecho expandido
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.4,
                      child: Stack(
                        children: [
                          // Game container
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                          
                          // Coordinate axes
                          CustomPaint(
                            size: Size(MediaQuery.of(context).size.width * 0.4, MediaQuery.of(context).size.width * 0.4),
                            painter: CoordinatesPainter(),
                          ),
                          
                          // Players and Keys
                          Stack(
                            children: [
                              // Players
                              Consumer<PlayerProvider>(
                                builder: (context, playerProvider, child) {
                                  return Stack(
                                    children: playerProvider.players.values.map((player) {
                                      return PlayerWidget(
                                        player: player,
                                        containerWidth: MediaQuery.of(context).size.width * 0.4,
                                        containerHeight: MediaQuery.of(context).size.width * 0.4,
                                        gameWidth: 1000.0,
                                        gameHeight: 1000.0,
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                              
                              // Keys
                              Consumer<KeyProvider>(
                                builder: (context, keyProvider, child) {
                                  return Stack(
                                    children: keyProvider.keys.values.map((key) {
                                      return KeyWidget(
                                        keyModel: key,
                                        containerWidth: MediaQuery.of(context).size.width * 0.4,
                                        containerHeight: MediaQuery.of(context).size.width * 0.4,
                                        gameWidth: 1000.0,
                                        gameHeight: 1000.0,
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Add this class at the end of the file, outside of existing classes
class CoordinatesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
      
    // Draw X axis
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    
    // Draw Y axis
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
