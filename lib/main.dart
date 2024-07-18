import 'package:circle_reveal_navigating_transition/circle_reveal_screen.dart';
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
      builder: (context, state) => const CircleRevealScreen(),
    ),
  ],
);

List<PageData> pages = [
  const PageData(
    backgroundColor: Color(0xFFe57482),
    contentColor: Color(0xFFfffacd),
    image: 'assets/images/image_1.jpg',
    name: 'Ahri',
  ),
  const PageData(
    backgroundColor: Color(0xFF84a0c2),
    contentColor: Color(0xFFe6e6e6),
    image: 'assets/images/image_2.jpg',
    name: 'Ashe',
  ),
  const PageData(
    backgroundColor: Color(0xFF7a775f),
    contentColor: Color(0xFFb4b4b4),
    image: 'assets/images/image_3.jpg',
    name: 'LeeSin',
  ),
  const PageData(
    backgroundColor: Color(0xFF588bae),
    contentColor: Color(0xFFf2d025),
    image: 'assets/images/image_4.jpg',
    name: 'Yasuo',
  ),
];

class PageData {
  final Color backgroundColor;
  final Color contentColor;
  final String image;
  final String name;

  const PageData({
    required this.backgroundColor,
    required this.contentColor,
    required this.image,
    required this.name,
  });
}
