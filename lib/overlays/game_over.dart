import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/pixel_adventure.dart';

class GameOverOverlay extends StatelessWidget {
  final PixelAdventure game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black54),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("MISSION FAILED", 
                  style: GoogleFonts.orbitron(fontSize: 48, color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 2)
              ).animate().fadeIn().shake(),
              
              const SizedBox(height: 30),
              
              Text("Final Score", style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 18)),
              Text("${game.score}", style: GoogleFonts.vt323(fontSize: 60, color: Colors.white))
                  .animate().scale(),
                  
              const SizedBox(height: 50),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton("RETRY", Colors.greenAccent, () => game.resetGame()),
                  const SizedBox(width: 20),
                  _buildActionButton("MENU", Colors.blueAccent, () => game.openMenu()),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
      ),
      child: Text(label, style: GoogleFonts.orbitron(color: color, fontSize: 20)),
    );
  }
}
