import 'package:flutter/material.dart';
import 'dart:math';

class CustomExpenseCurveChart extends StatelessWidget {
  final List<double> data;
  final List<Color> gradientColors;

  const CustomExpenseCurveChart({
    super.key,
    required this.data,
    this.gradientColors = const [Colors.blue, Colors.purple],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CurveChartPainter(data, gradientColors),
      size: const Size(double.infinity, 180),
    );
  }
}

class _CurveChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> gradientColors;

  _CurveChartPainter(this.data, this.gradientColors);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..shader = LinearGradient(
        colors: gradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final minY = data.reduce(min);
    final maxY = data.reduce(max);
    final scaleY = maxY - minY == 0 ? 1 : maxY - minY;
    final dx = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - ((data[i] - minY) / scaleY * size.height * 0.8 + size.height * 0.1);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()..color = gradientColors.last..style = PaintingStyle.fill;
    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - ((data[i] - minY) / scaleY * size.height * 0.8 + size.height * 0.1);
      canvas.drawCircle(Offset(x, y), 5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
