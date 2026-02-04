import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/pixel_adventure.dart';

class HudOverlay extends StatelessWidget {
  final PixelAdventure game;
  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20, left: 20,
      child: SafeArea(
        child: Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               color: Colors.black.withOpacity(0.6), 
               borderRadius: BorderRadius.circular(30), 
               border: Border.all(color: Colors.white24)
             ),
             child: Row(
               children: [
                 const Icon(Icons.rocket, color: Colors.cyanAccent, size: 18),
                 const SizedBox(width: 8),
                 Text(game.currentCharacter, 
                    style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                 ),
               ],
             ),
           ),
      ),
    );
  }
}
