import 'package:circle_reveal_navigating_transition/circle_reveal_transition.dart';
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
          transitionDuration: const Duration(milliseconds: 1500),
          reverseTransitionDuration: const Duration(milliseconds: 1500),
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
      backgroundColor: Color(0xFF1F618D),
      contentColor: Color(0xFFFFFACD),
      image: 'assets/images/image_1.png'),
  const PageData(
      backgroundColor: Color(0xFF3498DB),
      contentColor: Color(0xFFD3D3D3),
      image: 'assets/images/image_2.png'),
  const PageData(
      backgroundColor: Color(0xFF27AE60),
      contentColor: Color(0xFF800000),
      image: 'assets/images/image_3.png'),
  const PageData(
      backgroundColor: Color(0xFFF1C40F),
      contentColor: Color(0xFF2F4F4F),
      image: 'assets/images/image_4.png'),
  const PageData(
      backgroundColor: Color(0xFFE67E22),
      contentColor: Color(0xFF66CCCC),
      image: 'assets/images/image_5.png'),
];

class PageData {
  final Color backgroundColor;
  final Color contentColor;
  final String image;

  const PageData({
    required this.backgroundColor,
    required this.contentColor,
    required this.image,
  });
}
