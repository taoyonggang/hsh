import 'package:flutter/material.dart';
import '../../../controllers/fortune_controller.dart';
import '../../../models/fortune/fortune_models.dart';
import 'dart:math' as math;

class ElementDistributionChart extends StatelessWidget {
  final ElementDistribution distribution;
  final FortuneController controller;

  const ElementDistributionChart({
    super.key,
    required this.distribution,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ElementChartPainter(distribution, controller));
  }
}

class _ElementChartPainter extends CustomPainter {
  final ElementDistribution distribution;
  final FortuneController controller;

  _ElementChartPainter(this.distribution, this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final elements = [
      {
        'name': '木',
        'value': distribution.distribution['木'] ?? 0,
        'color': controller.getElementColor('木'),
      },
      {
        'name': '火',
        'value': distribution.distribution['火'] ?? 0,
        'color': controller.getElementColor('火'),
      },
      {
        'name': '土',
        'value': distribution.distribution['土'] ?? 0,
        'color': controller.getElementColor('土'),
      },
      {
        'name': '金',
        'value': distribution.distribution['金'] ?? 0,
        'color': controller.getElementColor('金'),
      },
      {
        'name': '水',
        'value': distribution.distribution['水'] ?? 0,
        'color': controller.getElementColor('水'),
      },
    ];

    double startAngle = -math.pi / 2;

    // 绘制饼图
    for (var element in elements) {
      final double value = element['value'] as double;
      final Color color = element['color'] as Color;

      if (value <= 0) continue;

      final sweepAngle = 2 * math.pi * value;

      final paint =
          Paint()
            ..style = PaintingStyle.fill
            ..color = color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // 绘制中心圆形
    final centerPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.white;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(_ElementChartPainter oldDelegate) =>
      oldDelegate.distribution != distribution;
}
