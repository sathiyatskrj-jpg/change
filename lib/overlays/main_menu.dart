import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/pixel_adventure.dart';

class MainMenuOverlay extends StatelessWidget {
  final PixelAdventure game;
  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glassmorphism Background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               // Title
               Text("RAJUBHAI KI GANG", 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    fontSize: 42, 
                    color: Colors.cyanAccent, 
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: Colors.purple, blurRadius: 20, offset: const Offset(0, 0))]
                  )
               ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.5, end: 0),
               
              if (game.highScore > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text("High Score: ${game.highScore}", 
                    style: GoogleFonts.vt323(color: Colors.yellowAccent, fontSize: 28)
                  ).animate().fadeIn(delay: 500.ms),
                ),
                
              const SizedBox(height: 60),
              
              // Animated Start Button
              _buildModernButton("START MISSION", Colors.purpleAccent, () => game.startGame())
                  .animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.8, 0.8)),
              
              const SizedBox(height: 40),
              
              Text("SELECT AGENT", style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 16, letterSpacing: 4))
                  .animate().fadeIn(delay: 1000.ms),
                  
              const SizedBox(height: 20),
              
              // Character Selector
              Wrap(
                spacing: 20, runSpacing: 20,
                alignment: WrapAlignment.center,
                children: game.characters.entries.map((e) {
                  final isSelected = game.currentCharacter == e.key;
                  return _buildCharacterOption(e.key, e.value, isSelected);
                }).toList(),
              ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildModernButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
          boxShadow: [
             BoxShadow(color: color.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)
          ]
        ),
        child: Text(label, style: GoogleFonts.orbitron(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }
  
  Widget _buildCharacterOption(String name, Color color, bool isSelected) {
     return GestureDetector(
       onTap: () => game.setCharacter(name),
       child: AnimatedContainer(
         duration: const Duration(milliseconds: 300),
         width: isSelected ? 60 : 50, height: isSelected ? 60 : 50,
         decoration: BoxDecoration(
           color: color.withOpacity(0.8),
           shape: BoxShape.circle,
           border: isSelected ? Border.all(color: Colors.white, width: 3) : Border.all(color: Colors.white24, width: 1),
           boxShadow: isSelected ? [BoxShadow(color: color, blurRadius: 20)] : []
         ),
         child: Center(
           child: Text(name[0], style: GoogleFonts.vt323(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
         ),
       ),
     );
  }
}
