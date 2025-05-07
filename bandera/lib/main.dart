import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:bandera/Utils/ServerUtils.dart';
import 'package:bandera/Providers/PlayerProvider.dart';
import 'package:bandera/Providers/KeyProvider.dart';
import 'package:bandera/Widgets/PlayerWidget.dart';
import 'package:bandera/Widgets/KeyWidget.dart';
import 'package:bandera/Widgets/FlagWidget.dart';
import 'package:bandera/Providers/FlagProvider.dart';
import 'package:bandera/Providers/TimerProvider.dart';
import 'package:flame/flame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flame and load images
  await Flame.device.fullScreen();
  await Flame.images.loadAll(['key.png', 'background.png']);  // Added background.png

  final getIt = GetIt.instance;
  getIt.registerSingleton<PlayerProvider>(PlayerProvider());
  getIt.registerSingleton<KeyProvider>(KeyProvider());
  getIt.registerSingleton<FlagProvider>(FlagProvider());
  getIt.registerSingleton<TimerProvider>(TimerProvider());

  // Initialize the key provider with a default key for testing
  KeyProvider keyProvider = getIt<KeyProvider>();
  keyProvider.initialize();
  print('KeyProvider initialized with keys: ${keyProvider.keys}');

  ServerUtils.connectToServer(onDisconnect: () {
    print("Desconectado del servidor.");
  });

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => getIt<PlayerProvider>()),
      ChangeNotifierProvider(create: (_) => getIt<KeyProvider>()),
      ChangeNotifierProvider(create: (_) => getIt<FlagProvider>()),
      ChangeNotifierProvider(create: (_) => getIt<TimerProvider>()),
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
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
          actions: [
            // Timer display in appbar
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Consumer<TimerProvider>(
                  builder: (context, timerProvider, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        timerProvider.formattedTimer,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
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
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      offset: Offset(4, 4),
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
                          // Background image
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/background.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          
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
                              // Keys
                              Consumer<KeyProvider>(
                                builder: (context, keyProvider, child) {
                                  print('KeyProvider Consumer rebuilding with ${keyProvider.keys.length} keys');
                                  
                                  if (keyProvider.keys.isEmpty) {
                                    // If no keys, create a visual debug indicator
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.red,
                                      child: Center(
                                        child: Text(
                                          'No keys',
                                          style: TextStyle(color: Colors.white, fontSize: 10),
                                        ),
                                      ),
                                    );
                                  }
                                  
                                  return Stack(
                                    children: keyProvider.keys.values.map((key) {
                                      print('Creating KeyWidget for key: ${key.id}');
                                      return KeyWidget(
                                        keyModel: key,
                                        containerWidth: MediaQuery.of(context).size.width * 0.4,
                                        containerHeight: MediaQuery.of(context).size.width * 0.4,
                                        gameWidth: 4550.0,
                                        gameHeight: 3500.0,
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                              
                              // Flags
                              Consumer<FlagProvider>(
                                builder: (context, flagProvider, child) {
                                  return Stack(
                                    children: flagProvider.flags.values.map((flag) {
                                      return FlagWidget(
                                        flag: flag,
                                        containerWidth: MediaQuery.of(context).size.width * 0.4,
                                        containerHeight: MediaQuery.of(context).size.width * 0.4,
                                        gameWidth: 4550.0,
                                        gameHeight: 3500.0,
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                              
                              // Players
                              Consumer<PlayerProvider>(
                                builder: (context, playerProvider, child) {
                                  return Stack(
                                    children: playerProvider.players.values.map((player) {
                                      return PlayerWidget(
                                        player: player,
                                        containerWidth: MediaQuery.of(context).size.width * 0.4,
                                        containerHeight: MediaQuery.of(context).size.width * 0.4,
                                        gameWidth: 4550.0,
                                        gameHeight: 3500.0,
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
