import 'dart:math';

import 'package:flutter/material.dart';

class CircleRevealTransition extends StatefulWidget {
  const CircleRevealTransition({
    super.key,
    required this.backgroundColor,
    required this.contentColor,
    required this.iconColor,
    required this.image,
  });

  final Color backgroundColor;
  final Color contentColor;
  final Color iconColor;
  final String image;

  @override
  State<CircleRevealTransition> createState() => _CircleRevealTransitionState();
}

class _CircleRevealTransitionState extends State<CircleRevealTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

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
        setState(() {});
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
    final size = MediaQuery.sizeOf(context);
    final left = size.width / 2;
    final top = size.height * 4 / 5;

    const imageWidth = 500.0;
    final maxOffset = size.width / 2 + imageWidth / 2;

    double offsetPercent = 1;
    if (_animationController.value <= .25) {
      offsetPercent = -_animationController.value / .25;
    } else if (_animationController.value >= .75) {
      offsetPercent = (1 - _animationController.value) / .25;
    }

    final contentOffset = offsetPercent * maxOffset;
    final contentScale = .6 + (.4 * (1 - offsetPercent.abs()));

    return Stack(
      children: [
        CustomPaint(
          painter: _CircleRevealTransitionPainter(
            backgroundColor: widget.backgroundColor,
            currentCircleColor: widget.contentColor,
            nextCircleColor: Colors.blue,
            circleCenterFinder: (Size size) => Offset(left, top),
            transitionPercent: _animationController.value,
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
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  widget.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        if (_animationController.value > .1 || _animationController.value < .95)
          Positioned(
            left: left - 16,
            top: top - 16,
            child: GestureDetector(
              onTap: () {
                if (_animationController.isCompleted) {
                  _animationController.reverse();
                } else {
                  _animationController.forward();
                }
              },
              child: Icon(
                Icons.arrow_forward_ios,
                size: 32,
                color: widget.iconColor,
              ),
            ),
          ),
      ],
    );
  }
}

class _CircleRevealTransitionPainter extends CustomPainter {
  _CircleRevealTransitionPainter({
    required Color backgroundColor,
    required Color currentCircleColor,
    required Color nextCircleColor,
    required this.circleCenterFinder,
    this.transitionPercent = 0,
    this.baseCircleRadius = 36,
  })  : backgroundPaint = Paint()..color = backgroundColor,
        currentCirclePaint = Paint()..color = currentCircleColor,
        nextCirclePaint = Paint()..color = nextCircleColor;

  final Paint backgroundPaint;
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

    final currentRadius = (maxRadius * slowedExpansionPercent)
        // + baseCircleRadius
        ;

    final currentCircleCenter = Offset(
        circleLeftBound + max(currentRadius, baseCircleRadius),
        baseCircleCenter.dy);

    // Paint the background
    canvas.drawPaint(backgroundPaint);

    // Paint the static circle
    canvas.drawCircle(
      baseCircleCenter,
      baseCircleRadius,
      currentCirclePaint,
    );

    // Paint the new expanding circle
    canvas.drawCircle(
      currentCircleCenter,
      currentRadius,
      nextCirclePaint,
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
    canvas.drawPaint(nextCirclePaint);

    // Paint the circle
    canvas.drawCircle(
      currentCircleCenter,
      currentRadius,
      backgroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
