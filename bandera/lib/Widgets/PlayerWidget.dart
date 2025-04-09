import 'package:flutter/material.dart';
import 'package:bandera/Models/Player.dart';

class PlayerWidget extends StatelessWidget {
  final Player player;
  final double containerWidth;
  final double containerHeight;
  final double gameWidth;  // Width of the game space
  final double gameHeight; // Height of the game space

  const PlayerWidget({
    Key? key,
    required this.player,
    required this.containerWidth,
    required this.containerHeight,
    this.gameWidth = 1000.0,  // Default game space width
    this.gameHeight = 1000.0, // Default game space height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double scale = 0.15;
    
    final double scaledX = player.x * (containerWidth / gameWidth);
    final double scaledY = player.y * (containerHeight / gameHeight);
    
    // Determine if this is a player or a key based on ID
    final bool isKey = player.id.toString().startsWith('key_');
    
    return Positioned(
      left: scaledX,
      top: scaledY,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 100, // Increased from 50 to 100
          height: 100, // Increased from 50 to 100
          decoration: BoxDecoration(
            color: isKey ? Colors.yellow : Colors.blue,
            shape: isKey ? BoxShape.rectangle : BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: isKey 
            ? const Icon(Icons.key, color: Colors.black, size: 60) // Increased icon size
            : const Icon(Icons.person, color: Colors.white, size: 60), // Increased icon size
        ),
      ),
    );
  }
}
