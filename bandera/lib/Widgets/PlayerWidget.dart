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
    spriteSheetData.add(SpriteSheetData(
      spriteSheetPath: 'images/Characters/Character${player.skinId}/Char_Idle.png',
      frameHeight: 80,
      frameWidth: 80,
      framesPerRow: 6,
    ));
    spriteSheetData.add(SpriteSheetData(
      spriteSheetPath: 'images/Characters/Character${player.skinId}/Char_Walk.png',
      frameHeight: 80,
      frameWidth: 80,
      framesPerRow: 6,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final double scale = 3;
    
    final double centerX = containerWidth / 2;
    final double centerY = containerHeight / 2;
    final double scaleFactor = containerWidth / gameWidth;
    final double posX = centerX + (player.x * scaleFactor);
    final double posY = centerY - (player.y * scaleFactor); 
    
    final double width = 100 * scale;
    final double height = 100 * scale;

    return Positioned(
      left: posX - (width / 2),
      top: posY - (height / 2),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: AnimatedSpriteWidget(spriteSheetData: spriteSheetData,
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
          )
        ),
      ),
    );
  }
}
