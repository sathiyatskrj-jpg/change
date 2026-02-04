import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../game/pixel_adventure.dart';
import '../character_data.dart';
import 'platform.dart';

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
    } 
    } else if (other is Platform) {
       if (velocity.y > 0 && position.y + size.y/2 <= other.position.y + other.size.y/2 + 5) {
          if (!isGrounded) {
              gameRef.addScore();
              // Particle omitted for brevity manually, but should be added back
          }
          velocity.y = 0;
          isGrounded = true;
          position.y = other.position.y - other.size.y/2 - size.y/2;
       }
    }
    
    super.onCollision(intersectionPoints, other);
  }
}
