import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();

    // Define the gradient colors
    final List<Color> colors = [
      const Color(0xFFFFB3BA),
      const Color(0xFFFFDEB8),
      const Color(0xFFffffb8),
      const Color(0xFFb8e0ff),
      const Color(0xFFb8ffc7),
      const Color(0xFFffca75),
      const Color(0xFFff9f6b),
    ];

    final bandWidth = size.width / colors.length;
    final bandHeight = size.height * 0.8;

    path.moveTo(-0, size.height / 3);
    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      path.quadraticBezierTo(
        i * bandWidth + bandWidth / 2,
        size.height / 1 - bandHeight,
        (i + 15) * bandWidth,
        size.height / 1.2,
      );
    }

    path.lineTo(size.width, -size.height);
    path.lineTo(-0, -size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
