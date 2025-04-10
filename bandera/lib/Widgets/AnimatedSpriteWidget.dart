import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class AnimatedSpriteWidget extends StatefulWidget {
  final ui.Image spriteSheet;
  final int frameWidth;
  final int frameHeight;
  final int framesPerRow;
  final Map<String, AnimationState> animations;
  final String currentAnimation;
  final Duration frameDuration;
  final bool repeat;

  const AnimatedSpriteWidget({
    Key? key,
    required this.spriteSheet,
    required this.frameWidth,
    required this.frameHeight,
    required this.framesPerRow,
    required this.animations,
    required this.currentAnimation,
    this.frameDuration = const Duration(milliseconds: 100),
    this.repeat = true,
  }) : super(key: key);

  @override
  State<AnimatedSpriteWidget> createState() => _AnimatedSpriteWidgetState();
}

class AnimationState {
  final int startFrame;
  final int endFrame;

  AnimationState({
    required this.startFrame,
    required this.endFrame,
  });
}

class _AnimatedSpriteWidgetState extends State<AnimatedSpriteWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentFrame = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.frameDuration * _getFrameCount(),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          _currentFrame = (_animation.value * _getFrameCount()).floor();
        });
      });

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  int _getFrameCount() {
    final animation = widget.animations[widget.currentAnimation]!;
    return animation.endFrame - animation.startFrame + 1;
  }

  @override
  void didUpdateWidget(AnimatedSpriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentAnimation != widget.currentAnimation) {
      _currentFrame = 0;
      _controller.duration = widget.frameDuration * _getFrameCount();
      if (widget.repeat) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = widget.animations[widget.currentAnimation]!;
    final frame = animation.startFrame + _currentFrame;
    final row = (frame / widget.framesPerRow).floor();
    final column = frame % widget.framesPerRow;

    return CustomPaint(
      size: Size(widget.frameWidth.toDouble(), widget.frameHeight.toDouble()),
      painter: SpritePainter(
        spriteSheet: widget.spriteSheet,
        frameWidth: widget.frameWidth,
        frameHeight: widget.frameHeight,
        row: row,
        column: column,
      ),
    );
  }
}

class SpritePainter extends CustomPainter {
  final ui.Image spriteSheet;
  final int frameWidth;
  final int frameHeight;
  final int row;
  final int column;

  SpritePainter({
    required this.spriteSheet,
    required this.frameWidth,
    required this.frameHeight,
    required this.row,
    required this.column,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      column * frameWidth.toDouble(),
      row * frameHeight.toDouble(),
      frameWidth.toDouble(),
      frameHeight.toDouble(),
    );

    final dst = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(spriteSheet, src, dst, Paint());
  }

  @override
  bool shouldRepaint(SpritePainter oldDelegate) {
    return oldDelegate.row != row || oldDelegate.column != column;
  }
}
