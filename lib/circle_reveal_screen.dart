import 'dart:math';

import 'package:circle_reveal_navigating_transition/main.dart';
import 'package:flutter/material.dart';

class CircleRevealScreen extends StatefulWidget {
  const CircleRevealScreen({
    super.key,
  });

  @override
  State<CircleRevealScreen> createState() => _CircleRevealScreenState();
}

class _CircleRevealScreenState extends State<CircleRevealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  var pageIndex = 0;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reset();
          setState(() {
            pageIndex = (pageIndex + 1) % pages.length;
          });
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationValue = _animationController.value;

    final currentPage = pages[pageIndex];
    final nextPage = pages[(pageIndex + 1) % pages.length];

    final imagePath = animationValue < .5 ? currentPage.image : nextPage.image;

    final size = MediaQuery.sizeOf(context);

    final circlePositionLeft = size.width / 2;
    final circlePositionTop = size.height * 4 / 5;
    const circleRadius = 36.0;

    final imageWidth = size.width / 2;
    final maxOffset = size.width / 2 + imageWidth / 2;

    late final double offsetPercent;
    if (animationValue <= .25) {
      offsetPercent = -animationValue / .25;
    } else if (animationValue >= .75) {
      offsetPercent = (1 - animationValue) / .25;
    }

    final contentOffset = offsetPercent * maxOffset;
    final contentScale = .6 + (.4 * (1 - offsetPercent.abs()));

    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: _CircleRevealTransitionPainter(
              currentBackgroundColor: currentPage.backgroundColor,
              currentCircleColor: currentPage.contentColor,
              nextCircleColor: nextPage.contentColor,
              nextBackgroundColor: nextPage.backgroundColor,
              circleCenterFinder: (Size size) =>
                  Offset(circlePositionLeft, circlePositionTop),
              transitionPercent: animationValue,
              baseCircleRadius: circleRadius,
            ),
            size: size,
          ),
          Align(
            alignment: const Alignment(0, -.5),
            child: Transform(
              transform: Matrix4.translationValues(contentOffset, 0, 0)
                ..scale(contentScale, contentScale),
              alignment: Alignment.center,
              child: SizedBox(
                width: imageWidth,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    imagePath,
                  ),
                ),
              ),
            ),
          ),
          if (animationValue < .1 || animationValue > .95)
            Positioned(
              left: circlePositionLeft - circleRadius,
              top: circlePositionTop - circleRadius,
              child: GestureDetector(
                onTap: () {
                  _animationController.forward();
                },
                child: Container(
                  color: Colors.transparent,
                  width: circleRadius * 2,
                  height: circleRadius * 2,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 32,
                    color: animationValue < .1
                        ? currentPage.backgroundColor
                        : nextPage.backgroundColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleRevealTransitionPainter extends CustomPainter {
  _CircleRevealTransitionPainter({
    required Color currentBackgroundColor,
    required Color nextBackgroundColor,
    required Color currentCircleColor,
    required Color nextCircleColor,
    required this.circleCenterFinder,
    this.transitionPercent = 0,
    this.baseCircleRadius = 36,
  })  : currentBackgroundPaint = Paint()..color = currentBackgroundColor,
        nextBackgroundPaint = Paint()..color = nextBackgroundColor,
        currentCirclePaint = Paint()..color = currentCircleColor,
        nextCirclePaint = Paint()..color = nextCircleColor;

  final Paint currentBackgroundPaint;
  final Paint nextBackgroundPaint;
  final Paint currentCirclePaint;
  final Paint nextCirclePaint;
  final double transitionPercent;
  final Offset Function(Size size) circleCenterFinder;
  final double baseCircleRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (transitionPercent < 0.5) {
      final expansionPercent = transitionPercent * 2;
      _paintExpansion(canvas, size, expansionPercent);
    } else {
      final contractionPercent = (transitionPercent - .5) * 2;
      _paintContraction(canvas, size, contractionPercent);
    }
  }

  void _paintExpansion(Canvas canvas, Size size, double expansionPercent) {
    // The max radius that the circle will grow to
    final maxRadius = size.height * 200;

    // The original center position of the circle
    final Offset baseCircleCenter = circleCenterFinder(size);

    // The left side of the circle, which never moves during expansion
    final circleLeftBound = baseCircleCenter.dx - baseCircleRadius;

    // Apply exponential reduction to the expansion rate so that the circle
    // expands much, much slower
    final slowedExpansionPercent = pow(expansionPercent, 8);

    final currentRadius = (maxRadius * slowedExpansionPercent);

    final currentCircleCenter = Offset(
        circleLeftBound + max(currentRadius, baseCircleRadius),
        baseCircleCenter.dy);

    // Paint the background
    canvas.drawPaint(currentBackgroundPaint);

    // Paint the static circle
    canvas.drawCircle(
      baseCircleCenter,
      baseCircleRadius,
      currentCirclePaint,
    );

    // Paint the new super expanding circle
    canvas.drawCircle(
      currentCircleCenter,
      currentRadius,
      nextBackgroundPaint,
    );
  }

  void _paintContraction(Canvas canvas, Size size, double contractionPercent) {
    // The max radius that the circle will grow to
    final maxRadius = size.height * 200;

    // The original center position of the circle
    final Offset baseCircleCenter = circleCenterFinder(size);

    // The intitial right side of the circle, which becomes the left side of the
    // circle by the end of the animation
    final circleStartingRightSide = baseCircleCenter.dx - baseCircleRadius;

    // The final right side of the circle
    final circleEndingRightSide = baseCircleCenter.dx + baseCircleRadius;

    // Apply exponential reduction to the expansion rate so that the circle contracts
    // much, much slower

    // Apply exponential reduction to the expansion rate so that the circle
    // expands much, much slower
    final inverseContractionPercent = 1 - contractionPercent;
    final slowedInversedContractionPercent = pow(inverseContractionPercent, 8);

    final currentRadius =
        (maxRadius * slowedInversedContractionPercent) + baseCircleRadius;

    // Calculate the current right side of the circle
    final circleCurrentRightSide = circleStartingRightSide +
        ((circleEndingRightSide - circleStartingRightSide) *
            contractionPercent);
    final circleCurrentCenterX = circleCurrentRightSide - currentRadius;

    final currentCircleCenter =
        Offset(circleCurrentCenterX, baseCircleCenter.dy);

    // Paint the background
    canvas.drawPaint(nextBackgroundPaint);

    // Paint the circle
    canvas.drawCircle(
      currentCircleCenter,
      currentRadius,
      currentBackgroundPaint,
    );

    // Paint the static circle
    if (contractionPercent > .9) {
      final newCircleContractionPercent = (contractionPercent - .9) / .1;
      final newCircleRadius = baseCircleRadius * newCircleContractionPercent;
      canvas.drawCircle(
        baseCircleCenter,
        newCircleRadius,
        nextCirclePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
