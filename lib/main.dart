import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/widgets.dart';

void main() {
  // Ensure the binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run the GameWidget with our PixelAdventure game
  runApp(
    GameWidget(
      game: PixelAdventure(),
    ),
  );
}

class PixelAdventure extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF211F30); // Dark pixel art background

  @override
  FutureOr<void> onLoad() async {
    // Configure the camera for pixel art if needed. 
    // For a modern "HD Pixelated" feel (high resolution, but pixel art assets), 
    // we mostly just ensure assets are not anti-aliased.
    
    // Example: Add a simple pixel-square as a placeholder player
    // In a real app, we would load images with FilterQuality.none
    
    add(PlayerPlaceholder());
    
    return super.onLoad();
  }
}

class PlayerPlaceholder extends PositionComponent {
  static final _paint = BasicPalette.red.paint()..filterQuality = FilterQuality.none;

  PlayerPlaceholder() : super(size: Vector2.all(32.0), position: Vector2(100, 100), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    // Draw a strict rect to represent a pixel character
    canvas.drawRect(size.toRect(), _paint);
  }
}
