import 'package:bandera/Widgets/AnimatedSpriteWidget.dart';
import 'package:flutter/material.dart';
import 'package:bandera/Models/Flag.dart';
import 'package:bandera/Models/SpriteSheetData.dart';
import 'package:bandera/Models/AnimationState.dart';

class FlagWidget extends StatelessWidget {
  final Flag flag;
  final double containerWidth;
  final double containerHeight;
  final double gameWidth;  // Width of the game space
  final double gameHeight; // Height of the game space
  
  final SpriteSheetData spriteSheetData = SpriteSheetData(
    spriteSheetPath: 'assets/images/flag.png',
    frameHeight: 60,
    frameWidth: 60,
    framesPerRow: 5,
  );

  FlagWidget({
    Key? key,
    required this.flag,
    required this.containerWidth,
    required this.containerHeight,
    this.gameWidth = 1000.0,  // Default game space width
    this.gameHeight = 1000.0, // Default game space height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double scale = 0.8;

    final double centerX = containerWidth / 2;
    final double centerY = containerHeight / 2;
    final double scaleFactor = containerWidth / gameWidth;
    final double posX = centerX + (flag.x * scaleFactor);
    final double posY = centerY - (flag.y * scaleFactor); // Invert Y-axis
  
    const width = 60.0 * scale;
    const height = 60.0 * scale;

    return Positioned(
      left: posX - (width / 2),
      top: posY - (height / 2),
      child: Container(
        width: width,
        height: height,
        child: Center(
          child: AnimatedSpriteWidget(
            spriteSheetData: [spriteSheetData],
            animations: {
              'wave': AnimationState(spriteSheetIndex: 0, startFrame: 0, endFrame: 4),
            },
            currentAnimation: 'wave',
            frameDuration: const Duration(milliseconds: 200),
          ),
        ),
      ),
    );
  }
} 