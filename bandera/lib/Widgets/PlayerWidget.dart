import 'package:bandera/Models/AnimationState.dart';
import 'package:bandera/Models/SpriteSheetData.dart';
import 'package:bandera/Widgets/AnimatedSpriteWidget.dart';
import 'package:flutter/material.dart';
import 'package:bandera/Models/Player.dart';

class PlayerWidget extends StatelessWidget {
  final Player player;
  final double containerWidth;
  final double containerHeight;
  final double gameWidth;  
  final double gameHeight;

  final List<SpriteSheetData> spriteSheetData = [];

  PlayerWidget({
    Key? key,
    required this.player,
    required this.containerWidth,
    required this.containerHeight,
    this.gameWidth = 1000.0, 
    this.gameHeight = 1000.0, 
  }) : super(key: key) {
    // ----------------------------------
    spriteSheetData.add(SpriteSheetData(
      spriteSheetPath: 'assets/images/Characters/Character${player.skinId}/Char_Idle.png',
      frameHeight: 80,
      frameWidth: 80,
      framesPerRow: 6,
    ));
    spriteSheetData.add(SpriteSheetData(
      spriteSheetPath: 'assets/images/Characters/Character${player.skinId}/Char_Walk.png',
      frameHeight: 80,
      frameWidth: 80,
      framesPerRow: 6,
    ));
    // --------------------------------
  }

  @override
  Widget build(BuildContext context) {
    final double scale = 0.8;
    
    final double centerX = containerWidth / 2;
    final double centerY = containerHeight / 2;
    final double scaleFactor = containerWidth / gameWidth;
    final double posX = centerX + (player.x * scaleFactor);
    final double posY = centerY - (player.y * scaleFactor); 
    
    final double spriteWidth = 80 * scale;
    final double spriteHeight = 80 * scale;
    final double widgetWidth = spriteWidth; // Make widget width same as sprite
    final double widgetHeight = spriteHeight + 30; // Add space for nickname

    return Positioned(
      left: posX - (widgetWidth / 2),
      top: posY - (widgetHeight / 2) - 15, // Adjust top position for nickname
      child: SizedBox(
        width: widgetWidth,
        height: widgetHeight,
        child: Stack(
          children: [
            Positioned( // Position the sprite
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                width: spriteWidth,
                height: spriteHeight,
                child: AnimatedSpriteWidget(
                  spriteSheetData: spriteSheetData,
                  animations: {
                    'idle_up': AnimationState(startFrame: 0, endFrame: 5, spriteSheetIndex: 0),
                    'idle_down': AnimationState(startFrame: 6, endFrame: 11, spriteSheetIndex: 0),
                    'idle_left': AnimationState(startFrame: 12, endFrame: 17, spriteSheetIndex: 0),
                    'idle_right': AnimationState(startFrame: 18, endFrame: 23, spriteSheetIndex: 0),
                    'walk_up': AnimationState(startFrame: 0, endFrame: 5, spriteSheetIndex: 1),
                    'walk_down': AnimationState(startFrame: 6, endFrame: 11, spriteSheetIndex: 1),
                    'walk_left': AnimationState(startFrame: 12, endFrame: 17, spriteSheetIndex: 1),
                    'walk_right': AnimationState(startFrame: 18, endFrame: 23, spriteSheetIndex: 1),
                  },
                  currentAnimation: player.getAnimation(),
                  frameDuration: const Duration(milliseconds: 150),
                ),
              ),
            ),
            Positioned( // Position the nickname
              bottom: 40,
              left: 0,
              right: 0,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  player.nickname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    
    // --- Log at end of build ---
    // print('PlayerWidget build END - ID: ${player.id}');
    // -------------------------
  }
}
