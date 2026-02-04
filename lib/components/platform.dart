import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

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
