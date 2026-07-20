import 'dart:math';
import 'package:flutter/material.dart';

class BudgetRingPainter extends CustomPainter {
  final num percentage; 
  final bool isExceeded;

  BudgetRingPainter({required this.percentage, required this.isExceeded});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 4;
    const strokeWidth = 6.0;

    final trackPaint = Paint()
      ..color = const Color(0xFFE9E4F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = isExceeded ? const Color(0xFFE64A4A) : const Color(0xFFF5A623)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final clampedPercent = isExceeded ? 100 : percentage.clamp(0, 100);
    final sweepAngle = 2 * pi * (clampedPercent / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BudgetRingPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.isExceeded != isExceeded;
  }
}