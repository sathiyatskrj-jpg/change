import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/player.dart';
import '../components/platform.dart';

class PixelAdventure extends FlameGame with TapDetector, HasCollisionDetection {
  final Map<String, Color> characters = {
    'Saikat': const Color(0xFFFF0000), 
    'Kunal': const Color(0xFF0000FF), 
    'Raziya': const Color(0xFFFF00FF), 
    'Durga': const Color(0xFFFFD700), 
    'Nashia': const Color(0xFF00FF00), 
    'Santoshi': const Color(0xFF00FFFF), 
    'Ashlee': const Color(0xFFFFA500), 
    'Sathiya': const Color(0xFFA52A2A), 
    'Pobitro': const Color(0xFF800080), 
  };
  
  String currentCharacter = 'Saikat';
  Player? player;
  
  int score = 0;
  int highScore = 0;
  
  TextComponent? scoreComponent;
  bool isPlaying = false;
  final Random _rnd = Random();

  @override
  Color backgroundColor() => const Color(0xFF100a1c); // Dark Space

  @override
  FutureOr<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    add(ScreenHitbox());
    
    // Load High Score
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('high_score') ?? 0;
    
    // Static Starfield (Simple)
    for(int i=0; i<100; i++) {
        // Simple star generic component
        add(CircleComponent(
            radius: 1.5, 
            position: Vector2(_rnd.nextDouble() * 1000 - 500, _rnd.nextDouble() * 1000 - 500),
            paint: Paint()..color = Colors.white.withOpacity(0.5)
        ));
    }

    return super.onLoad();
  }

  void startGame() {
    overlays.remove('MainMenu');
    overlays.remove('GameOver');
    overlays.add('HUD');
    resetGame();
  }
  
  void openMenu() {
    overlays.remove('GameOver');
    overlays.remove('HUD');
    overlays.add('MainMenu');
  }

  void resetGame() {
    isPlaying = true;
    score = 0;
    
    children.whereType<Player>().forEach((p) => p.removeFromParent());
    children.whereType<Platform>().forEach((p) => p.removeFromParent());
    
    _generateFloors();
    
    player = Player(
      color: characters[currentCharacter]!,
      position: Vector2(0, 0),
    );
    world.add(player!);
    camera.follow(player!, maxSpeed: 1000, snap: true);
    
    if (scoreComponent != null) scoreComponent!.removeFromParent();
    scoreComponent = TextComponent(
      text: '0', 
      textRenderer: TextPaint(style: const TextStyle(fontSize: 48, color: Colors.white, shadows: [Shadow(color: Colors.purple, offset: Offset(2,2))])),
      position: Vector2(0, -300), 
      anchor: Anchor.center,
    );
    world.add(scoreComponent!);
    
    try {
      FlameAudio.bgm.play('2510172059789788.m4a');
    } catch(e) {}
    
    overlays.remove('GameOver');
    overlays.remove('MainMenu');
  }

  void setCharacter(String name) {
    currentCharacter = name;
    // Trigger UI update if needed
  }
  
  void gameOver() async {
    isPlaying = false;
    if (score > highScore) {
      highScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('high_score', highScore);
    }
    overlays.add('GameOver');
    FlameAudio.bgm.stop();
  }
  
  void addScore() {
    score++;
    scoreComponent?.text = '$score';
  }

  void shakeCamera() {
    camera.viewfinder.position += Vector2((_rnd.nextDouble() - 0.5) * 15, (_rnd.nextDouble() - 0.5) * 15);
  }

  @override
  void onTap() {
    if (isPlaying && player != null) {
      player!.jump();
    }
  }

  void _generateFloors() {
    for(int i = -10; i < 50; i++) {
        world.add(Platform(position: Vector2(0, i * -240.0 + 200), size: Vector2(size.x > 0 ? size.x : 400, 20)));
    }
  }
}
