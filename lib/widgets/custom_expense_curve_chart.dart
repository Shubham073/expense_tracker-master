import 'package:flutter/material.dart';
import 'dart:math';

class CustomExpenseCurveChart extends StatefulWidget {
  final List<double> data;
  final List<Color> gradientColors;

  const CustomExpenseCurveChart({
    super.key,
    required this.data,
    this.gradientColors = const [Colors.blue, Colors.purple],
  });

  @override
  State<CustomExpenseCurveChart> createState() => _CustomExpenseCurveChartState();
}

class _CustomExpenseCurveChartState extends State<CustomExpenseCurveChart> {
  int? touchedIndex;
  Offset? touchPosition;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (details) {
            _handleTouch(details.localPosition);
          },
          onPanUpdate: (details) {
            _handleTouch(details.localPosition);
          },
          onPanEnd: (_) {
            setState(() {
              touchedIndex = null;
              touchPosition = null;
            });
          },
          child: CustomPaint(
            painter: _CurveChartPainter(
              widget.data,
              widget.gradientColors,
              touchedIndex,
            ),
            size: const Size(double.infinity, 180),
          ),
        ),
        if (touchedIndex != null && touchPosition != null)
          Positioned(
            left: touchPosition!.dx - 40,
            top: touchPosition!.dy - 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '₹${widget.data[touchedIndex!].toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleTouch(Offset position) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final dx = size.width / (widget.data.length - 1);
    final index = (position.dx / dx).round().clamp(0, widget.data.length - 1);

    setState(() {
      touchedIndex = index;
      touchPosition = position;
    });
  }
}

class _CurveChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> gradientColors;
  final int? touchedIndex;

  _CurveChartPainter(this.data, this.gradientColors, this.touchedIndex);

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
    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - ((data[i] - minY) / scaleY * size.height * 0.8 + size.height * 0.1);
      final isTouched = touchedIndex == i;
      final pointPaint = Paint()
        ..color = isTouched ? Colors.yellow : gradientColors.last
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), isTouched ? 8 : 5, pointPaint);
      
      // Draw border for touched point
      if (isTouched) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(Offset(x, y), 8, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
