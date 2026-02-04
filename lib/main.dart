import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart' hide Image, Draggable;
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const GameWidget<PixelAdventure>.controlled(
      gameFactory: PixelAdventure.new,
    ),
  );
}

class PixelAdventure extends FlameGame with TapDetector, HasCollisionDetection {
  // Character Data
  final Map<String, Color> characters = {
    'Saikat': const Color(0xFFFF0000), // Red
    'Kunal': const Color(0xFF0000FF), // Blue
    'Raziya': const Color(0xFFFF00FF), // Magenta
    'Durga': const Color(0xFFFFD700), // Gold
    'Nashia': const Color(0xFF00FF00), // Green
    'Santoshi': const Color(0xFF00FFFF), // Cyan
    'Ashlee': const Color(0xFFFFA500), // Orange
    'Sathiya': const Color(0xFFA52A2A), // Brown
    'Pobitro': const Color(0xFF800080), // Purple
  };

  late String currentCharacter;
  late Player player;
  
  // Game State
  int score = 0;
  TextComponent? scoreText;

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  @override
  FutureOr<void> onLoad() async {
    // Start with the first character
    currentCharacter = characters.keys.first;

    // Camera setup
    camera.viewfinder.anchor = Anchor.center;
    
    // Add Walls (Screen boundaries)
    add(ScreenHitbox());

    // Add Floors (Procedural-ish)
    _generateFloors();

    // Spawn Player
    _spawnPlayer();

    // UI
    scoreText = TextComponent(
      text: 'Floors: 0  |  Char: $currentCharacter',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
    add(scoreText!); // Fix: Add strictly to the game world if using simple TextComponent, or HUD
    // Ideally use camera.viewport.add for HUD, but for simplicity in Flame 1.x logic:
    camera.viewport.add(scoreText!);

    // Audio
    _playRandomMusic();
    
    return super.onLoad();
  }

  void _spawnPlayer() {
    if (children.contains(player)) {
      player.removeFromParent();
    }
    player = Player(
      color: characters[currentCharacter]!,
      position: Vector2(0, 100), // Centerish
    );
    world.add(player); // Add to world, camera follows world
    camera.follow(player, maxSpeed: 1000, snap: true);
  }

  void _generateFloors() {
    // Generate some basic platforms
    // For simplicity, just some static floors for now
    world.add(Platform(position: Vector2(0, 200), size: Vector2(400, 20)));
    world.add(Platform(position: Vector2(0, 0), size: Vector2(200, 20)));
    world.add(Platform(position: Vector2(0, -200), size: Vector2(400, 20)));
  }

  void _playRandomMusic() async {
    // Try to list files or just play a known one if we could list them dynamically
    // Since we copied blindly, let's try a simple heuristic or user can rename?
    // Actually, flame_audio needs files in assets/audio/music
    // We copied *.m4a there.
    // Let's try to play ANY file if we knew the name. 
    // Since we don't know the exact filenames without listing again (which I did earlier),
    // I will try to load all m4a I saw from the list_dir output earlier.
    // BUt for now, let's skip auto-play or try one specific one if I recall the name.
    // "2510172059789788.m4a" was in the list.
    try {
        await FlameAudio.bgm.play('2510172059789788.m4a');
    } catch (e) {
        print("Audio not found or error: $e");
    }
  }

  @override
  void onTap() {
    // Jump / Change Direction (High Risers style)
    player.jump();
    
    // Debug: Cycle character on tap too? No, that ruins gameplay.
  }
  
  void cycleCharacter() {
    final names = characters.keys.toList();
    final index = names.indexOf(currentCharacter);
    final nextIndex = (index + 1) % names.length;
    currentCharacter = names[nextIndex];
    
    // Respawn with new color
    player.removeFromParent();
    _spawnPlayer();
    scoreText?.text = 'Floors: $score  |  Char: $currentCharacter';
  }
}

class Player extends PositionComponent with CollisionCallbacks, HasGameRef<PixelAdventure> {
  final Color color;
  Vector2 velocity = Vector2(200, 0); // Moving right
  static const double gravity = 1000;
  static const double jumpForce = -400;
  bool isGrounded = false;

  Player({required this.color, required Vector2 position}) 
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  void onLoad() {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = color);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Auto run
    // Apply Gravity
    velocity.y += gravity * dt;
    
    // Apply Velocity
    position += velocity * dt;

    // Floor Collision Check (Simple bounds for now, actual collision in onCollision)
  }

  void jump() {
    if (isGrounded) {
       velocity.y = jumpForce;
       isGrounded = false;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is ScreenHitbox) {
      // Bounce off walls
      if (position.x <= 0 || position.x >= gameRef.size.x) { // Very rough
         velocity.x = -velocity.x;
      }
    } else if (other is Platform) {
       // Land on top
       if (velocity.y > 0 && position.y + size.y/2 <= other.position.y + other.size.y/2) {
          velocity.y = 0;
          isGrounded = true;
          position.y = other.position.y - other.size.y/2 - size.y/2;
       }
    }
    super.onCollision(intersectionPoints, other);
  }
}

class Platform extends PositionComponent with CollisionCallbacks {
  Platform({required Vector2 position, required Vector2 size}) 
      : super(position: position, size: size, anchor: Anchor.center);
      
  @override
  void onLoad() {
    add(RectangleHitbox());
  }
  
  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF555555));
  }
}
