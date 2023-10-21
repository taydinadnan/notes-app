import 'package:flutter/material.dart';

class CurveLinePainter extends CustomPainter {
  final double startY;
  final double endX;

  CurveLinePainter({required this.startY, required this.endX});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 230, 189, 238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    path.moveTo(endX, startY);

    final controlPoint = Offset(endX + 50.0, startY + 10.0);

    final endPoint = Offset(endX + 20, startY + 100.0);

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    canvas.drawPath(path, paint);

    final arrowPaint = Paint()
      ..color = const Color.fromARGB(255, 230, 189, 238)
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    arrowPath.moveTo(endPoint.dx - 12.0, endPoint.dy);
    arrowPath.lineTo(endPoint.dx + 12.0, endPoint.dy);
    arrowPath.lineTo(endPoint.dx, endPoint.dy + 20.0);

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
