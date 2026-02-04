import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart'; // For screen shake/visual effects
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart'; // For particles
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart' hide Image, Draggable;
import 'character_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rajubhai Ki Gang',
      theme: ThemeData(
        fontFamily: 'Baloo', // Pixel-ish font fallback
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      home: const SplashPage(),
    );
  }
}

// -------------------- SPLASH SCREEN --------------------
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       duration: const Duration(seconds: 2), vsync: this
    )..forward();
    
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GamePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.purpleAccent, blurRadius: 20, spreadRadius: 5)
                  ]
                ),
                child: const Icon(Icons.rocket_launch, size: 60, color: Colors.purple),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Rajubhai Ki Gang",
               style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4),
            ),
            const SizedBox(height: 10),
            const Text(
              "High Risers Edition",
               style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- GAME PAGE & OVERLAYS --------------------
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late PixelAdventure game;

  @override
  void initState() {
    super.initState();
    game = PixelAdventure();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'MainMenu': (context, PixelAdventure game) => MainMenuOverlay(game: game),
          'GameOver': (context, PixelAdventure game) => GameOverOverlay(game: game),
          'HUD': (context, PixelAdventure game) => HudOverlay(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    );
  }
}

class MainMenuOverlay extends StatelessWidget {
  final PixelAdventure game;
  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Rajubhai Ki Gang", style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), backgroundColor: Colors.purpleAccent),
              onPressed: () {
                game.startGame();
              }, 
              child: const Text("PLAY GAME", style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 20),
            const Text("Select Character:", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: game.characters.entries.map((e) {
                return GestureDetector(
                  onTap: () {
                     game.setCharacter(e.key);
                     // Visual feedback needed here practically, but simplified for now
                  },
                  child: Container(
                    width: 40, height: 40,
                    color: e.value,
                    child: Center(child: Text(e.key[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  final PixelAdventure game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("GAME OVER", style: TextStyle(fontSize: 40, color: Colors.redAccent, fontWeight: FontWeight.bold)),
            Text("Score: ${game.score}", style: const TextStyle(fontSize: 30, color: Colors.white)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => game.resetGame(), 
              child: const Text("RETRY"),
            ),
          ],
        ),
      ),
    );
  }
}

class HudOverlay extends StatelessWidget {
  final PixelAdventure game;
  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // In a real app we'd use ValueListenableBuilder or StreamBuilder for score
    // For now, static or polling. Flame UI integration is tricky without state management pkg.
    // We will let the Flame Engine draw the score to keep it synced perfectly.
    return const SizedBox.shrink(); 
  }
}


// -------------------- FLAME GAME LOGIC --------------------

class PixelAdventure extends FlameGame with TapDetector, HasCollisionDetection {
  // Config
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
  TextComponent? scoreComponent;
  bool isPlaying = false;
  
  // Shake effect
  final Random _rnd = Random();

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  @override
  FutureOr<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    add(ScreenHitbox());
    
    // Audio (Preload)
    // FlameAudio.bgm.initialize(); 
    
    return super.onLoad();
  }

  void startGame() {
    overlays.remove('MainMenu');
    overlays.remove('GameOver');
    overlays.add('HUD');
    
    resetGame();
  }

  void resetGame() {
    isPlaying = true;
    score = 0;
    
    // Cleanup
    children.whereType<Player>().forEach((p) => p.removeFromParent());
    children.whereType<Platform>().forEach((p) => p.removeFromParent());
    
    // Level Gen
    _generateFloors();
    
    // Player
    player = Player(
      color: characters[currentCharacter]!,
      position: Vector2(0, 0),
    );
    world.add(player!);
    camera.follow(player!, maxSpeed: 1000, snap: true);
    
    // Score UI
    if (scoreComponent != null) scoreComponent!.removeFromParent();
    scoreComponent = TextComponent(
      text: '0', 
      position: Vector2(0, -250), // localized
      anchor: Anchor.center,
      scale: Vector2.all(2),
    );
    // Ideally add to viewport, but camera.viewport doesn't easily accept Components in v1.16 without bells/whistles
    // We'll add it to world but fixed position logic is harder. 
    // Let's rely on Overlay for HUD if we wanted, but Flame text is nicer for "in-game" feel
    world.add(scoreComponent!);
    
    // Music
    try {
      FlameAudio.bgm.play('2510172059789788.m4a');
    } catch(e) {}
    
    overlays.remove('GameOver');
    overlays.remove('MainMenu');
  }

  void setCharacter(String name) {
    currentCharacter = name;
  }
  
  void gameOver() {
    isPlaying = false;
    overlays.add('GameOver');
    FlameAudio.bgm.stop();
  }
  
  void addScore() {
    score++;
    scoreComponent?.text = '$score';
    // Visual pop
    scoreComponent?.add(
      ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 0.1, reverseDuration: 0.1))
    );
  }

  void shakeCamera() {
    // Simple manual shake
    camera.viewfinder.position += Vector2((_rnd.nextDouble() - 0.5) * 10, (_rnd.nextDouble() - 0.5) * 10);
    // EffectController would be better, but manual jerk is "naive" but works for simple feedback
  }

  @override
  void onTap() {
    if (isPlaying && player != null) {
      player!.jump();
    }
  }

  void _generateFloors() {
    // Infinite generator logic placeholder
    // Currently static
    for(int i = -10; i < 50; i++) {
        world.add(Platform(position: Vector2(0, i * -200.0 + 200), size: Vector2(size.x > 0 ? size.x : 400, 20)));
    }
  }
}

class Player extends PositionComponent with CollisionCallbacks, HasGameRef<PixelAdventure> {
  final Color color;
  Vector2 velocity = Vector2(300, 0); 
  static const double gravity = 1200;
  static const double jumpForce = -600;
  bool isGrounded = false;

  Player({required this.color, required Vector2 position}) 
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  void onLoad() {
    add(RectangleHitbox());
    // Trail effect
    add(
      ParticleSystemComponent(
        particle: ComputedParticle(
          renderer: (canvas, particle) {
             canvas.drawRect(Rect.fromLTWH(0, 0, 10 * particle.progress, 10 * particle.progress), Paint()..color = color.withOpacity(1 - particle.progress));
          },
          lifespan: 0.5,
        ),
      )
    );
  }

  @override
  void render(Canvas canvas) {
    if (humanSpriteGrid.isEmpty) return;
    
    final pixelW = size.x / humanSpriteGrid[0].length;
    final pixelH = size.y / humanSpriteGrid.length;

    for (int y = 0; y < humanSpriteGrid.length; y++) {
      for (int x = 0; x < humanSpriteGrid[y].length; x++) {
        final pixelType = humanSpriteGrid[y][x];
        if (pixelType == 0) continue;

        final paint = Paint();
        switch (pixelType) {
          case 1: // Outline
            paint.color = Colors.black;
            break;
          case 2: // Skin
            paint.color = const Color(0xFFFFC080);
            break;
          case 3: // Hair
            paint.color = Colors.brown.shade900;
            break;
          case 4: // Shirt (Main Character Color)
            paint.color = color;
            break;
          case 5: // Pants
            paint.color = Colors.blueGrey.shade800;
            break;
          case 6: // Shoes
            paint.color = Colors.white;
            break;
          case 7: // Eyes
            paint.color = Colors.white;
            break;
        }
        
        canvas.drawRect(
          Rect.fromLTWH(x * pixelW, y * pixelH, pixelW, pixelH),
          paint,
        );
        
        // Add pupil for eyes
        if (pixelType == 7) {
           canvas.drawRect(
             Rect.fromLTWH(x * pixelW + pixelW*0.5, y * pixelH + pixelH*0.2, pixelW*0.3, pixelH*0.3),
             Paint()..color = Colors.black
           );
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameRef.isPlaying) return;
    
    velocity.y += gravity * dt;
    position += velocity * dt;
    
    // Death check
    if (position.y > 1000) { // Fell too far
       gameRef.gameOver();
    }
    
    // Emit particles
    if (gameRef.isPlaying) {
        gameRef.world.add(
            ParticleSystemComponent(
                position: position,
                particle: AcceleratedParticle(
                    acceleration: Vector2(0, 100),
                    speed: Vector2.random() * 50 - Vector2(25, 25),
                    child: CircleParticle(radius: 2, paint: Paint()..color = color.withOpacity(0.5))
                )
            )
        );
    }
  }

  void jump() {
    if (isGrounded) {
       velocity.y = jumpForce;
       isGrounded = false;
       // Jump sound
       // FlameAudio.play('sfx.m4a');
       
       // Squeeze effect
       add(ScaleEffect.by(Vector2(0.8, 1.2), EffectController(duration: 0.1, reverseDuration: 0.1)));
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is ScreenHitbox) {
      if (position.x <= -gameRef.size.x/2 || position.x >= gameRef.size.x/2) { 
         velocity.x = -velocity.x;
         gameRef.shakeCamera();
         // Flip visual
         scale.x = -scale.x;
      }
    } else if (other is Platform) {
       if (velocity.y > 0 && position.y + size.y/2 <= other.position.y + other.size.y/2 + 5) {
          if (!isGrounded) {
              // Landed
              gameRef.addScore();
              // Land particle splash
               gameRef.world.add(
                ParticleSystemComponent(
                    position: position + Vector2(0, size.y/2),
                    particle: CircleParticle(radius: 10, paint: Paint()..color = Colors.white.withOpacity(0.8), lifespan: 0.2)
                )
            );
          }
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
    // Neon style platform
    canvas.drawRect(size.toRect(), Paint()..color = Colors.cyanAccent..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawRect(size.toRect(), Paint()..color = Colors.black.withOpacity(0.5));
  }
}
