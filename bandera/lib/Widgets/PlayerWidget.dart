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
    
    // Get the center point of the container
    final double centerX = containerWidth / 2;
    final double centerY = containerHeight / 2;
    
    // Calculate scaling factor (use the same value for both axes to maintain aspect ratio)
    final double scaleFactor = containerWidth / gameWidth;
    
    // Calculate position with (0,0) at center
    // X-axis: right positive, left negative from center
    // Y-axis: up positive, down negative from center
    final double posX = centerX + (player.x * scaleFactor);
    final double posY = centerY - (player.y * scaleFactor); // Invert Y-axis
    
    // Calculate icon size
    final double iconWidth = 100 * scale;
    final double iconHeight = 100 * scale;
    
    // Position icon so its center is at the calculated position
    return Positioned(
      // Offset by half the icon size to center it on the point
      left: posX - (iconWidth / 2),
      top: posY - (iconHeight / 2),
      child: Container(
        width: iconWidth,
        height: iconHeight,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: const Center(
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
