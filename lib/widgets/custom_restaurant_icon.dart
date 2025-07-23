import 'package:flutter/material.dart';

class CustomRestaurantIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const CustomRestaurantIcon({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: RestaurantIconPainter(color: color ?? Colors.grey),
    );
  }
}

class RestaurantIconPainter extends CustomPainter {
  final Color color;

  RestaurantIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 24.0; // 24pxを基準とするスケール

    // フォーク（左側）
    final forkX = center.dx - 6 * scale;
    final forkTop = center.dy - 8 * scale;
    final forkBottom = center.dy + 8 * scale;

    // フォークの柄
    canvas.drawLine(
      Offset(forkX, forkTop + 3 * scale),
      Offset(forkX, forkBottom),
      paint,
    );

    // フォークの歯（3本）
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(forkX + i * 1.5 * scale, forkTop),
        Offset(forkX + i * 1.5 * scale, forkTop + 4 * scale),
        paint,
      );
    }

    // フォークの歯を柄に接続
    canvas.drawLine(
      Offset(forkX - 1.5 * scale, forkTop + 3 * scale),
      Offset(forkX + 1.5 * scale, forkTop + 3 * scale),
      paint,
    );

    // 日本風の反縁（右側）- 線のみで描かれた半円状のお皿
    final plateX = center.dx + 6 * scale;
    final plateY = center.dy + 2 * scale;
    final plateRadius = 6 * scale;

    // お皿の半円（下半分のみ）
    final platePath = Path();
    platePath.addArc(
      Rect.fromCenter(
        center: Offset(plateX, plateY),
        width: plateRadius * 2,
        height: plateRadius * 2,
      ),
      0, // 0度から
      3.14159, // 180度まで（半円）
    );
    
    canvas.drawPath(platePath, paint);

    // お皿の縁（上部の直線）
    canvas.drawLine(
      Offset(plateX - plateRadius, plateY),
      Offset(plateX + plateRadius, plateY),
      paint,
    );

    // お皿の装飾的な内側の線（日本風）
    final innerPlateRadius = plateRadius * 0.7;
    final innerPlatePath = Path();
    innerPlatePath.addArc(
      Rect.fromCenter(
        center: Offset(plateX, plateY),
        width: innerPlateRadius * 2,
        height: innerPlateRadius * 2,
      ),
      0.2, // 少し角度をつけて
      2.7, // 約3/4の円弧
    );
    
    canvas.drawPath(innerPlatePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}