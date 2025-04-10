import 'package:flutter/material.dart';
import 'dart:math';

class MyGraphPainter extends CustomPainter {

  final List<double> values;

  MyGraphPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    final paintY = Paint()
    ..color = Colors.grey
    ..strokeWidth = 1;

    final Paint textPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    final maxY = values.reduce(max);
    final minY = values.reduce(min);
    final scaleY = size.height / (maxY - minY);
    final double stepX = size.width / (values.length - 1);
    Set<int> yValues = <int>{};
    for (int i = 0; i < values.length - 1; i++) {
      yValues.add((values[i] / 100).round() * 100);
    }
    for (int value in yValues) {
      canvas.drawLine(
        Offset(-(size.width * 0.15), size.height - (value - minY) * scaleY),
        Offset(size.width * 1.08, size.height - (value - minY) * scaleY),
        paintY,
      );

      final TextSpan span = TextSpan(
        text: '$value',
        style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
      );

      final TextPainter textPainter = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(-(size.width * 0.15), size.height * 0.95 - (value - minY) * scaleY));
    }
    for (int i = 0; i < values.length - 1; i++) {
      final p1 = Offset(i * stepX, size.height - (values[i] - minY) * scaleY);
      final p2 = Offset((i + 1) * stepX, size.height - (values[i + 1] - minY) * scaleY);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MyGraphPainter oldDelegate) {
    return true;
  }
}