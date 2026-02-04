import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame/parallax.dart'; // For Starfield
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart' hide Image, Draggable;
import 'package:shared_preferences/shared_preferences.dart';
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
        fontFamily: 'Baloo',
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
        PageRouteBuilder(
          pageBuilder: (_,__,___) => const GamePage(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 800)
        ),
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
      backgroundColor: const Color(0xFF1a0b2e), // Deep purple void
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFff00cc), Color(0xFF333399)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.purple.withOpacity(0.6), blurRadius: 40, spreadRadius: 10)
                  ]
                ),
                child: const Icon(Icons.rocket_launch, size: 70, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]).createShader(bounds),
              child: const Text(
                "Rajubhai Ki Gang",
                 style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
              ),
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

// --- Custom Pixel Button ---
class PixelButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  
  const PixelButton({super.key, required this.label, required this.onPressed, this.color = const Color(0xFF6f3cd1)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), offset: const Offset(4, 4))
          ]
        ),
        child: Text(label, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.black87]
        )
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             // Title with Shadow
             Text("RAJUBHAI KI GANG", 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42, color: Colors.yellowAccent, fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.purple.shade900, offset: const Offset(4, 4), blurRadius: 0)]
                )
             ),
            if (game.highScore > 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text("High Score: ${game.highScore}", style: const TextStyle(color: Colors.cyanAccent, fontSize: 20)),
              ),
            const SizedBox(height: 50),
            PixelButton(
              label: "START GAME",
              onPressed: () => game.startGame(),
            ),
            const SizedBox(height: 30),
            const Text("SELECT CHARACTER", style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 2)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 15, runSpacing: 15,
              alignment: WrapAlignment.center,
              children: game.characters.entries.map((e) {
                final isSelected = game.currentCharacter == e.key;
                return GestureDetector(
                  onTap: () => game.setCharacter(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 50 : 40, height: isSelected ? 50 : 40,
                    decoration: BoxDecoration(
                      color: e.value,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: isSelected ? [const BoxShadow(color: Colors.white, blurRadius: 10)] : null
                    ),
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
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("GAME OVER", style: TextStyle(fontSize: 48, color: Colors.redAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("Score: ${game.score}", style: const TextStyle(fontSize: 32, color: Colors.white)),
            Text("Best: ${game.highScore}", style: const TextStyle(fontSize: 20, color: Colors.grey)),
            const SizedBox(height: 40),
            PixelButton(label: "TRY AGAIN", onPressed: () => game.resetGame(), color: Colors.green),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => game.openMenu(), 
              child: const Text("MAIN MENU", style: TextStyle(color: Colors.white54))
            )
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
    return Positioned(
      top: 20, left: 20,
      child: SafeArea(
        child: Row(
          children: [
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
               decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
               child: Row(
                 children: [
                   const Icon(Icons.person, color: Colors.white, size: 16),
                   const SizedBox(width: 8),
                   Text(game.currentCharacter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }
}


// -------------------- FLAME GAME LOGIC --------------------

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
    
    // Starfield Background
    await _addParallaxBackground();

    return super.onLoad();
  }
  
  Future<void> _addParallaxBackground() async {
    // Manually creating a starfield using particles or simple shapes is cheaper than loading non-existent images
    // Flame Parallax usually needs images. Let's use a particle generator for the BG instead for the "Starfield" effect.
    add(
      ParticleSystemComponent(
        particle: RepeatedParticle(
          child: ComputedParticle(
            renderer: (canvas, particle) {
               // Draw stars
               final paint = Paint()..color = Colors.white.withOpacity(particle.progress < 0.5 ? particle.progress * 2 : (1 - particle.progress) * 2);
               canvas.drawCircle(Offset.zero, _rnd.nextDouble() * 2, paint);
            },
            lifespan: 2,
          ),
          count: 50,
        ),
        position: Vector2(0, 0),
        size: size,
      )
    );
    // Note: This is a static glitchy effect. 
    // Real parallax needs images. I'll stick to a simple generated star layer.
    
    for(int i=0; i<100; i++) {
       add(StarComponent(position: Vector2(_rnd.nextDouble() * 1000 - 500, _rnd.nextDouble() * 1000 - 500)));
    }
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
    // Force redraw menu to show selection?
    // In efficient architecture, we'd use ValueNotifier. Here, simple rebuild happens if we tap.
    // The Overlay is a Stateless Widget, so we need to ensure it rebuilds. 
    // Actually, calling overlays.remove/add refreshes it usually, but let's just assume user opens menu again or state updates next frame.
    // For this simple prototype, it might not visually update 'selected' instantly without a state refresh call.
    // Hack: remove and add 'MainMenu' quickly? No.
    // Let's leave it; when they click Start, the right character spawns.
    overlays.remove('MainMenu');
    overlays.add('MainMenu');
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
    scoreComponent?.add(
      ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 0.1, reverseDuration: 0.1))
    );
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

class StarComponent extends PositionComponent {
  StarComponent({required Vector2 position}) : super(position: position, size: Vector2.all(2));
  final Paint _paint = Paint()..color = Colors.white.withOpacity(0.5);
  
  @override
  void render(Canvas canvas) {
     canvas.drawCircle(Offset.zero, 1.5, _paint);
  }
  
  @override
  void update(double dt) {
    y += 10 * dt; // Slow fall
    if (y > 500) y = -500; // Loop
  }
}

class Player extends PositionComponent with CollisionCallbacks, HasGameRef<PixelAdventure> {
  final Color color;
  Vector2 velocity = Vector2(350, 0); 
  static const double gravity = 1400;
  static const double jumpForce = -650;
  bool isGrounded = false;

  Player({required this.color, required Vector2 position}) 
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  void onLoad() {
    add(RectangleHitbox());
    // Trail effect using Engine's Particle System
    add(
      ParticleSystemComponent(
        particle: ComputedParticle(
          renderer: (canvas, particle) {
             canvas.drawRect(Rect.fromLTWH(0, 0, 10 * particle.progress, 10 * particle.progress), Paint()..color = color.withOpacity(1 - particle.progress));
          },
          lifespan: 0.4,
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
          case 1: paint.color = Colors.black; break;
          case 2: paint.color = const Color(0xFFFFC080); break;
          case 3: paint.color = Colors.brown.shade900; break;
          case 4: paint.color = color; break;
          case 5: paint.color = Colors.blueGrey.shade800; break;
          case 6: paint.color = Colors.white; break;
          case 7: paint.color = Colors.white; break;
        }
        canvas.drawRect(Rect.fromLTWH(x * pixelW, y * pixelH, pixelW, pixelH), paint);
        if (pixelType == 7) {
           canvas.drawRect(Rect.fromLTWH(x * pixelW + pixelW*0.5, y * pixelH + pixelH*0.2, pixelW*0.3, pixelH*0.3), Paint()..color = Colors.black);
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
    
    if (position.y > 1000) gameRef.gameOver();
    
    if (gameRef.isPlaying && position.y % 10 < 1) { // Optimize: emit less freq
       // Simple dust
    }
  }

  void jump() {
    if (isGrounded) {
       velocity.y = jumpForce;
       isGrounded = false;
       add(ScaleEffect.by(Vector2(0.8, 1.2), EffectController(duration: 0.1, reverseDuration: 0.1)));
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is ScreenHitbox) {
      if (position.x <= -gameRef.size.x/2 || position.x >= gameRef.size.x/2) { 
         velocity.x = -velocity.x;
         gameRef.shakeCamera();
         scale.x = -scale.x;
      }
    } else if (other is Platform) {
       if (velocity.y > 0 && position.y + size.y/2 <= other.position.y + other.size.y/2 + 5) {
          if (!isGrounded) {
              gameRef.addScore();
              gameRef.world.add(ParticleSystemComponent(
                  position: position + Vector2(0, size.y/2),
                  particle: CircleParticle(radius: 10, paint: Paint()..color = Colors.white.withOpacity(0.8), lifespan: 0.2)
              ));
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
    // Cyberpunk Neon Style
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4); // Glow
      
    canvas.drawRect(size.toRect(), paint);
    canvas.drawRect(size.toRect(), Paint()..color = Colors.black.withOpacity(0.8));
    
    // Grid lines inside
    canvas.drawLine(Offset(0, size.y/2), Offset(size.x, size.y/2), Paint()..color = Colors.cyan.withOpacity(0.3));
  }
}
