import 'package:bandera/Widgets/AnimatedSpriteWidget.dart';
import 'package:flutter/material.dart';
import 'package:bandera/Models/Key.dart' as KeyModel;
import 'dart:ui' as ui;
import 'dart:async';

class KeyWidget extends StatefulWidget {
  final KeyModel.Key keyModel;
  final double containerWidth;
  final double containerHeight;
  final double gameWidth;  // Width of the game space
  final double gameHeight; // Height of the game space

  const KeyWidget({
    Key? key,
    required this.keyModel,
    required this.containerWidth,
    required this.containerHeight,
    this.gameWidth = 1000.0,  // Default game space width
    this.gameHeight = 1000.0, // Default game space height
  }) : super(key: key);

  @override
  State<KeyWidget> createState() => _KeyWidgetState();
}

class _KeyWidgetState extends State<KeyWidget> {
  ui.Image? keyImage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final imageProvider = AssetImage('assets/images/key.png');
    final imageStream = imageProvider.resolve(ImageConfiguration());
    final completer = Completer<ui.Image>();
    
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    });
    
    imageStream.addListener(listener);
    
    keyImage = await completer.future;
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    
    imageStream.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    const double scale = 3;

    final double centerX = widget.containerWidth / 2;
    final double centerY = widget.containerHeight / 2;
    final double scaleFactor = widget.containerWidth / widget.gameWidth;
    final double posX = centerX + (widget.keyModel.x * scaleFactor);
    final double posY = centerY - (widget.keyModel.y * scaleFactor); // Invert Y-axis
  
    const width = 100 * scale;
    const height = 100 * scale;

    return Positioned(
      left: posX - (width / 2),
      top: posY - (height / 2),
      child: Container(
        width: width,
        height: height,
        child: Center(
          child: isLoading || keyImage == null
              ? const SizedBox.shrink()
              : AnimatedSpriteWidget(
                  spriteSheet: keyImage!,
                  frameWidth: 32,
                  frameHeight: 32, 
                  framesPerRow: 24,
                  animations: {
                    'idle': AnimationState(startFrame: 0, endFrame: 23),
                  },
                  currentAnimation: 'idle',
                  frameDuration: const Duration(milliseconds: 150),
                ),
        ),
      ),
    );
  }
} 