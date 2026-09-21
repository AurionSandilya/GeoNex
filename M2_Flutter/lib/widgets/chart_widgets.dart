import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class RiskTrendSparkline extends StatelessWidget {
  final List<double> values;
  final Color lineColor;
  final double height;

  const RiskTrendSparkline({
    super.key,
    required this.values,
    this.lineColor = AppColors.riskHigh,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(height: height);
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SparklinePainter(values: values, lineColor: lineColor),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  _SparklinePainter({required this.values, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final double minVal = values.reduce(min);
    final double maxVal = values.reduce(max);
    final double range = max(1.0, maxVal - minVal);

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final normY = (values[i] - minVal) / range;
      final y = size.height - (normY * (size.height - 8)) - 4;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withAlpha(60),
          lineColor.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Draw point at end
    final lastX = size.width;
    final lastNormY = (values.last - minVal) / range;
    final lastY = size.height - (lastNormY * (size.height - 8)) - 4;

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(lastX, lastY), 4.0, dotPaint);
    canvas.drawCircle(Offset(lastX, lastY), 2.5, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}

class MiniBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color barColor;
  final double height;

  const MiniBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.barColor = AppColors.primary,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return SizedBox(height: height);
    final double maxVal = values.reduce(max);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final double factor = maxVal > 0 ? (values[i] / maxVal).clamp(0.05, 1.0) : 0.05;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${values[i].toInt()}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: (height - 35) * factor,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels.length > i ? labels[i] : '',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
