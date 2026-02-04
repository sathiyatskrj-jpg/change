import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'pixel_adventure.dart';
import '../overlays/main_menu.dart';
import '../overlays/game_over.dart';
import '../overlays/hud.dart';

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
