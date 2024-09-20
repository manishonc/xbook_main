import 'package:flutter/material.dart';

class AbstractBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Background
    paint.color = const Color(0xFFEEF2FF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Grid
    paint.color = const Color(0xFFE0E7FF);
    paint.strokeWidth = 0.5;
    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(
          Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    for (var i = 0; i < size.height; i += 20) {
      canvas.drawLine(
          Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }

    // Circles
    paint.color = const Color(0x33818CF8);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 50, paint);
    paint.color = const Color(0x1A4F46E5);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 100, paint);

    // Curves
    paint.color = const Color(0xFF6366F1);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    var path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.25,
        size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.75, size.width, size.height * 0.5);
    canvas.drawPath(path, paint);

    paint.color = const Color(0xFFA5B4FC);
    paint.strokeWidth = 3;
    path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.6, size.width, size.height * 0.8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
