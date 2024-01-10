import 'package:circle_reveal_navigating_transition/circle_reveal_transition.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const index = 0;
    final (backgroundColor, contentColor, iconColor) = colorPalettes[index];
    const image = 'assets/images/image_${index + 1}.png';
    return Scaffold(
      body: CircleRevealTransition(
        backgroundColor: backgroundColor,
        contentColor: contentColor,
        iconColor: iconColor,
        image: image,
      ),
    );
  }
}

List<(Color backgroundColor, Color contentColor, Color iconColor)>
    colorPalettes = [
  (const Color(0xFFFFFACD), const Color(0xFF1F618D), Colors.white), // Palette 1
  (const Color(0xFFD3D3D3), const Color(0xFF3498DB), Colors.white), // Palette 2
  (const Color(0xFF800000), const Color(0xFF27AE60), Colors.white), // Palette 3
  (const Color(0xFF2F4F4F), const Color(0xFFF1C40F), Colors.black), // Palette 4
  (const Color(0xFF66CCCC), const Color(0xFFE67E22), Colors.black), // Palette 5
];
