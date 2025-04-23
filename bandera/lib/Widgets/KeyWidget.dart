import 'package:bandera/Models/AnimationState.dart';
import 'package:bandera/Models/SpriteSheetData.dart';
import 'package:bandera/Widgets/AnimatedSpriteWidget.dart';
import 'package:flutter/material.dart';
import 'package:bandera/Models/Key.dart' as KeyModel;

class KeyWidget extends StatelessWidget {
  final KeyModel.Key keyModel;
  final double containerWidth;
  final double containerHeight;
  final double gameWidth;  // Width of the game space
  final double gameHeight; // Height of the game space

  final SpriteSheetData spriteSheetData = SpriteSheetData(
    spriteSheetPath: 'assets/images/key.png',
    frameHeight: 32,
    frameWidth: 32,
    framesPerRow: 24,
  );

  KeyWidget({
    Key? key,
    required this.keyModel,
    required this.containerWidth,
    required this.containerHeight,
    this.gameWidth = 1000.0,  // Default game space width
    this.gameHeight = 1000.0, // Default game space height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug print to see if the widget is being created
    print('Building KeyWidget for key: ${keyModel.id} at (${keyModel.x}, ${keyModel.y})');
    
    const double keySize = 10.0; // Fixed size for the key

    final double centerX = containerWidth / 2;
    final double centerY = containerHeight / 2;
    final double scaleFactor = containerWidth / gameWidth;
    final double posX = centerX + (keyModel.x * scaleFactor);
    final double posY = centerY - (keyModel.y * scaleFactor); // Invert Y-axis
  
    print('Key position: left=${posX - (keySize / 2)}, top=${posY - (keySize / 2)}');

    return Positioned(
      left: posX - (keySize / 2),
      top: posY - (keySize / 2),
      child: Container(
        width: keySize,
        height: keySize,
        child: AnimatedSpriteWidget(
            spriteSheetData: [spriteSheetData],
            animations: {
              'idle': AnimationState(spriteSheetIndex: 0, startFrame: 0, endFrame: 23),
            },
            currentAnimation: 'idle',
            frameDuration: const Duration(milliseconds: 200),
          ),
      ),
    );
  }
} 