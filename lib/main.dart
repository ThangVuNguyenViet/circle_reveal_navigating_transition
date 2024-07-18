import 'package:circle_reveal_navigating_transition/circle_reveal_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  GoRouter.optionURLReflectsImperativeAPIs = true;
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
  redirect: (context, state) {
    final index = int.tryParse(state.pathParameters['index'] ?? '');
    if (index == null) return '/0';
    return null;
  },
  routes: [
    GoRoute(
      path: '/:index',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: ValueKey(
              '/${state.pathParameters['index']} ${state.pageKey.value}'),
          transitionDuration: const Duration(milliseconds: 1000),
          reverseTransitionDuration: const Duration(milliseconds: 1000),
          child: const SizedBox(),
          transitionsBuilder:
              (context, primaryAnimation, secondaryAnimation, child) {
            final animation =
                secondaryAnimation.status == AnimationStatus.forward
                    ? secondaryAnimation
                    : primaryAnimation;

            return Visibility(
              visible: primaryAnimation.status == AnimationStatus.reverse ||
                  (secondaryAnimation.status == AnimationStatus.forward ||
                      primaryAnimation.isCompleted &&
                          secondaryAnimation.isDismissed),
              child: CircleRevealScreen(
                animation: animation,
              ),
            );
          },
        );
      },
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
