import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game/game_page.dart';

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
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.rajdhaniTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..forward();
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_,__,___) => const GamePage(),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 1000)
             // "Ultimate Transition" - slow fade
          ),
        );
      }
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
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Neon Glow Logo
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.purple.withOpacity(0.8), blurRadius: 60, spreadRadius: 10),
                  BoxShadow(color: Colors.blue.withOpacity(0.6), blurRadius: 30, spreadRadius: 5),
                ]
              ),
              child: const Icon(Icons.rocket_launch, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 40),
            Text("RAJUBHAI KI GANG", 
              style: GoogleFonts.orbitron(
                fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4,
                shadows: [const Shadow(color: Colors.blue, blurRadius: 20)]
              )
            ),
          ],
        ),
      ),
    );
  }
}
