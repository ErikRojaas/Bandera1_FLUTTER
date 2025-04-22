import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:bandera/Models/AnimationState.dart';
import 'package:bandera/Models/SpriteSheetData.dart';
import 'dart:ui' as ui;
import 'dart:async';

class AnimatedSpriteWidget extends StatefulWidget {
  final List<SpriteSheetData> spriteSheetData;
  final Map<String, AnimationState> animations;
  final String currentAnimation;
  final Duration frameDuration;
  final bool repeat;

  const AnimatedSpriteWidget({
    Key? key,
    required this.spriteSheetData,
    required this.animations,
    required this.currentAnimation,
    this.frameDuration = const Duration(milliseconds: 100),
    this.repeat = true,
  }) : super(key: key);

  @override
  State<AnimatedSpriteWidget> createState() => _AnimatedSpriteWidgetState();
}

class _AnimatedSpriteWidgetState extends State<AnimatedSpriteWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentFrame = 0;
  List<ui.Image?> _loadedImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
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

  Future<void> _loadImages() async {
    _loadedImages = List.filled(widget.spriteSheetData.length, null);
    
    for (int i = 0; i < widget.spriteSheetData.length; i++) {
      final data = widget.spriteSheetData[i];
      print('Loading image: ${data.spriteSheetPath}');
      
      final imageProvider = AssetImage(data.spriteSheetPath);
      final imageStream = imageProvider.resolve(ImageConfiguration());
      final completer = Completer<ui.Image>();
      
      final listener = ImageStreamListener((ImageInfo info, bool _) {
        print('Image loaded successfully: ${data.spriteSheetPath}');
        completer.complete(info.image);
      }, onError: (exception, stackTrace) {
        print('Error loading image ${data.spriteSheetPath}: $exception');
        print(stackTrace);
        completer.completeError(exception);
      });
      
      imageStream.addListener(listener);
      
      try {
        _loadedImages[i] = await completer.future;
        print('Image assigned to loadedImages: ${data.spriteSheetPath}');
        imageStream.removeListener(listener);
      } catch (e) {
        print('Error loading image ${data.spriteSheetPath}: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        print('AnimatedSpriteWidget loading finished, isLoading: $_isLoading');
        print('Loaded images count: ${_loadedImages.where((img) => img != null).length}/${_loadedImages.length}');
      });
    }
  }

  int _getFrameCount() {
  final animationState = widget.animations[widget.currentAnimation];
  if (animationState == null) {
    print('Warning: Animation "${widget.currentAnimation}" not found');
    return 1;
  }
  return animationState.endFrame - animationState.startFrame + 1;
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

  int _getCurrentSpriteSheetIndex() {
    return widget.animations[widget.currentAnimation]!.spriteSheetIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      print('AnimatedSpriteWidget is still loading, returning empty widget');
      return Container(
        width: 20,
        height: 20,
        color: Colors.yellow,
        child: const Center(child: Text('Loading...', style: TextStyle(fontSize: 8))),
      );
    }

    final animation = widget.animations[widget.currentAnimation]!;
    final frame = animation.startFrame + _currentFrame;
    final spriteSheetIndex = _getCurrentSpriteSheetIndex();
    final spriteSheetData = widget.spriteSheetData[spriteSheetIndex];
    final spriteSheet = _loadedImages[spriteSheetIndex];
    
    if (spriteSheet == null) {
      print('Sprite sheet is null for ${spriteSheetData.spriteSheetPath}, animation: ${widget.currentAnimation}');
      return Container(
        width: 20,
        height: 20,
        color: Colors.red,
        child: const Center(child: Text('No image', style: TextStyle(fontSize: 8))),
      );
    }
    
    final row = (frame / spriteSheetData.framesPerRow).floor();
    final column = frame % spriteSheetData.framesPerRow;

    return CustomPaint(
      size: Size(
        spriteSheetData.frameWidth.toDouble(),
        spriteSheetData.frameHeight.toDouble()
      ),
      painter: SpritePainter(
        spriteSheet: spriteSheet,
        frameWidth: spriteSheetData.frameWidth,
        frameHeight: spriteSheetData.frameHeight,
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
