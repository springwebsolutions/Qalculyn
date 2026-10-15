// Qalculyn - Dynamic Vector Geometry Canvas
// CustomPainter that visually renders 2D plane figures and 3D isometric solids with labeled dimensions

import 'dart:math' as math;
import 'package:flutter/material.dart';

class GeometryCanvasWidget extends StatelessWidget {
  final int category; // 0: 2D, 1: 3D, 2: Triangle Solver, 3: Questions
  final int shapeIndex;
  final List<double> dimensions;

  const GeometryCanvasWidget({
    super.key,
    required this.category,
    required this.shapeIndex,
    required this.dimensions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF130E20) : const Color(0xFFF3EDFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _GeometryPainter(
            category: category,
            shapeIndex: shapeIndex,
            dimensions: dimensions,
            primaryColor: primary,
            textColor: theme.colorScheme.onSurface,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _GeometryPainter extends CustomPainter {
  final int category;
  final int shapeIndex;
  final List<double> dimensions;
  final Color primaryColor;
  final Color textColor;
  final bool isDark;

  _GeometryPainter({
    required this.category,
    required this.shapeIndex,
    required this.dimensions,
    required this.primaryColor,
    required this.textColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);

    final linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.18 : 0.12)
      ..style = PaintingStyle.fill;

    final dashPaint = Paint()
      ..color = textColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    if (category == 0) {
      _paint2D(canvas, size, center, linePaint, fillPaint, dashPaint);
    } else if (category == 1) {
      _paint3D(canvas, size, center, linePaint, fillPaint, dashPaint);
    } else if (category == 2) {
      _paintTriangle(canvas, size, center, linePaint, fillPaint, dashPaint);
    } else {
      _paintQuestion(canvas, size, center, linePaint, fillPaint, dashPaint);
    }
  }

  void _paint2D(Canvas canvas, Size size, Offset center, Paint line, Paint fill, Paint dash) {
    final d1 = dimensions.isNotEmpty ? dimensions[0] : 5.0;
    final d2 = dimensions.length > 1 ? dimensions[1] : 5.0;

    switch (shapeIndex) {
      case 0: // Circle
        final r = math.min(size.width, size.height) * 0.35;
        canvas.drawCircle(center, r, fill);
        canvas.drawCircle(center, r, line);
        // Radius line
        final edge = Offset(center.dx + r, center.dy);
        canvas.drawLine(center, edge, dash);
        canvas.drawCircle(center, 3, line);
        _drawText(canvas, 'r = ${d1.toStringAsFixed(1)}', Offset(center.dx + r / 2.0, center.dy - 12));
        break;

      case 1: // Sector & Arc
        final r = math.min(size.width, size.height) * 0.36;
        final angleDeg = d2.clamp(10.0, 350.0);
        final sweepRad = angleDeg * math.pi / 180.0;
        final startAngle = -sweepRad / 2.0;

        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(
            Rect.fromCircle(center: center, radius: r),
            startAngle,
            sweepRad,
            false,
          )
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, line);
        _drawText(canvas, '${angleDeg.toStringAsFixed(0)}°', Offset(center.dx + 18, center.dy - 4));
        break;

      case 2: // Annulus
        final rOuter = math.min(size.width, size.height) * 0.38;
        final rInner = rOuter * 0.55;
        canvas.drawCircle(center, rOuter, fill);
        canvas.drawCircle(center, rInner, Paint()..color = isDark ? const Color(0xFF130E20) : const Color(0xFFF3EDFD));
        canvas.drawCircle(center, rOuter, line);
        canvas.drawCircle(center, rInner, line);
        _drawText(canvas, 'R / r', Offset(center.dx, center.dy - 6));
        break;

      case 3: // Ellipse
        final rect = Rect.fromCenter(center: center, width: size.width * 0.65, height: size.height * 0.45);
        canvas.drawOval(rect, fill);
        canvas.drawOval(rect, line);
        _drawText(canvas, 'a × b', Offset(center.dx, center.dy - 6));
        break;

      case 4: // Rectangle
      case 5: // Square
        final isSquare = shapeIndex == 5;
        final w = isSquare ? size.height * 0.55 : size.width * 0.55;
        final h = isSquare ? size.height * 0.55 : size.height * 0.42;
        final rect = Rect.fromCenter(center: center, width: w, height: h);
        canvas.drawRect(rect, fill);
        canvas.drawRect(rect, line);
        _drawText(canvas, isSquare ? 's = ${d1.toStringAsFixed(1)}' : '${d1.toStringAsFixed(1)} × ${d2.toStringAsFixed(1)}', Offset(center.dx, center.dy - 6));
        break;

      case 8: // Right Triangle
        final w = size.width * 0.45;
        final h = size.height * 0.55;
        final p1 = Offset(center.dx - w / 2, center.dy + h / 2);
        final p2 = Offset(center.dx + w / 2, center.dy + h / 2);
        final p3 = Offset(center.dx - w / 2, center.dy - h / 2);
        final path = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, line);
        // Right angle marker
        canvas.drawRect(Rect.fromLTWH(p1.dx, p1.dy - 12, 12, 12), dash);
        _drawText(canvas, 'c = hypotenuse', Offset(center.dx + 4, center.dy - 4));
        break;

      case 15: // Regular Polygon
        final n = d1.clamp(3, 12).toInt();
        final r = math.min(size.width, size.height) * 0.35;
        final path = Path();
        for (int i = 0; i < n; i++) {
          final angle = (i * 2.0 * math.pi / n) - (math.pi / 2.0);
          final x = center.dx + r * math.cos(angle);
          final y = center.dy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, line);
        _drawText(canvas, 'n = $n sides', Offset(center.dx, center.dy - 6));
        break;

      default: // General Polygon / Triangle
        final w = size.width * 0.45;
        final h = size.height * 0.55;
        final p1 = Offset(center.dx, center.dy - h / 2);
        final p2 = Offset(center.dx + w / 2, center.dy + h / 2);
        final p3 = Offset(center.dx - w / 2, center.dy + h / 2);
        final path = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, line);
        _drawText(canvas, 'Triangle', Offset(center.dx, center.dy + 8));
        break;
    }
  }

  void _paint3D(Canvas canvas, Size size, Offset center, Paint line, Paint fill, Paint dash) {
    switch (shapeIndex) {
      case 0: // Sphere
        final r = math.min(size.width, size.height) * 0.35;
        canvas.drawCircle(center, r, fill);
        canvas.drawCircle(center, r, line);
        // Equator ellipse
        final eqRect = Rect.fromCenter(center: center, width: r * 2.0, height: r * 0.65);
        canvas.drawOval(eqRect, dash);
        _drawText(canvas, 'Sphere (r)', Offset(center.dx, center.dy - 6));
        break;

      case 3: // Cylinder
        final w = size.width * 0.35;
        final h = size.height * 0.55;
        final top = center.dy - h / 2.0;
        final bottom = center.dy + h / 2.0;
        final topEllipse = Rect.fromCenter(center: Offset(center.dx, top), width: w, height: w * 0.35);
        final bottomEllipse = Rect.fromCenter(center: Offset(center.dx, bottom), width: w, height: w * 0.35);

        // Body fill
        final bodyPath = Path()
          ..moveTo(center.dx - w / 2.0, top)
          ..lineTo(center.dx + w / 2.0, top)
          ..lineTo(center.dx + w / 2.0, bottom)
          ..lineTo(center.dx - w / 2.0, bottom)
          ..close();
        canvas.drawPath(bodyPath, fill);

        // Edges
        canvas.drawLine(Offset(center.dx - w / 2.0, top), Offset(center.dx - w / 2.0, bottom), line);
        canvas.drawLine(Offset(center.dx + w / 2.0, top), Offset(center.dx + w / 2.0, bottom), line);
        canvas.drawOval(topEllipse, line);
        canvas.drawOval(bottomEllipse, line);
        _drawText(canvas, 'Cylinder', Offset(center.dx, center.dy - 6));
        break;

      case 5: // Cone
        final w = size.width * 0.40;
        final h = size.height * 0.55;
        final apex = Offset(center.dx, center.dy - h / 2.0);
        final baseCenter = Offset(center.dx, center.dy + h / 2.0);
        final baseEllipse = Rect.fromCenter(center: baseCenter, width: w, height: w * 0.35);

        final conePath = Path()
          ..moveTo(apex.dx, apex.dy)
          ..lineTo(center.dx - w / 2.0, baseCenter.dy)
          ..lineTo(center.dx + w / 2.0, baseCenter.dy)
          ..close();
        canvas.drawPath(conePath, fill);
        canvas.drawLine(apex, Offset(center.dx - w / 2.0, baseCenter.dy), line);
        canvas.drawLine(apex, Offset(center.dx + w / 2.0, baseCenter.dy), line);
        canvas.drawOval(baseEllipse, line);
        _drawText(canvas, 'Cone', Offset(center.dx, center.dy + 4));
        break;

      case 7: // Cube (Isometric projection)
      case 8: // Cuboid
        final s = size.height * 0.32;
        final p0 = center;
        final dx = s * math.cos(math.pi / 6.0);
        final dy = s * math.sin(math.pi / 6.0);

        final top1 = Offset(p0.dx, p0.dy - s);
        final top2 = Offset(p0.dx + dx, p0.dy - s + dy);
        final top3 = Offset(p0.dx, p0.dy - s + 2 * dy);
        final top4 = Offset(p0.dx - dx, p0.dy - s + dy);

        final topPath = Path()..moveTo(top1.dx, top1.dy)..lineTo(top2.dx, top2.dy)..lineTo(top3.dx, top3.dy)..lineTo(top4.dx, top4.dy)..close();
        canvas.drawPath(topPath, fill);
        canvas.drawPath(topPath, line);

        // Vertical lines
        canvas.drawLine(top3, Offset(top3.dx, top3.dy + s), line);
        canvas.drawLine(top2, Offset(top2.dx, top2.dy + s), line);
        canvas.drawLine(top4, Offset(top4.dx, top4.dy + s), line);

        // Bottom lines
        canvas.drawLine(Offset(top4.dx, top4.dy + s), Offset(top3.dx, top3.dy + s), line);
        canvas.drawLine(Offset(top3.dx, top3.dy + s), Offset(top2.dx, top2.dy + s), line);
        _drawText(canvas, shapeIndex == 7 ? 'Cube' : 'Prism', Offset(center.dx, center.dy + s * 0.7));
        break;

      default:
        final r = math.min(size.width, size.height) * 0.35;
        canvas.drawCircle(center, r, fill);
        canvas.drawCircle(center, r, line);
        _drawText(canvas, 'Solid 3D', Offset(center.dx, center.dy - 6));
        break;
    }
  }

  void _paintTriangle(Canvas canvas, Size size, Offset center, Paint line, Paint fill, Paint dash) {
    final w = size.width * 0.50;
    final h = size.height * 0.55;
    final pA = Offset(center.dx, center.dy - h / 2.0);
    final pB = Offset(center.dx - w / 2.0, center.dy + h / 2.0);
    final pC = Offset(center.dx + w / 2.0, center.dy + h / 2.0);

    final path = Path()..moveTo(pA.dx, pA.dy)..lineTo(pB.dx, pB.dy)..lineTo(pC.dx, pC.dy)..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, line);

    // Altitude dash
    canvas.drawLine(pA, Offset(pA.dx, pB.dy), dash);

    _drawText(canvas, 'A', Offset(pA.dx, pA.dy - 16));
    _drawText(canvas, 'B', Offset(pB.dx - 12, pB.dy + 4));
    _drawText(canvas, 'C', Offset(pC.dx + 12, pC.dy + 4));
    _drawText(canvas, 'c (base)', Offset(center.dx, pB.dy + 8));
  }

  void _paintQuestion(Canvas canvas, Size size, Offset center, Paint line, Paint fill, Paint dash) {
    final r = math.min(size.width, size.height) * 0.32;
    canvas.drawCircle(center, r, fill);
    canvas.drawCircle(center, r, line);

    // Question mark glyph
    final textPainter = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2.0, center.dy - textPainter.height / 2.0));
  }

  void _drawText(Canvas canvas, String text, Offset position) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
          backgroundColor: isDark ? const Color(0xCC130E20) : const Color(0xCCF3EDFD),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(position.dx - tp.width / 2.0, position.dy - tp.height / 2.0));
  }

  @override
  bool shouldRepaint(covariant _GeometryPainter old) {
    return old.category != category ||
        old.shapeIndex != shapeIndex ||
        old.dimensions != dimensions ||
        old.primaryColor != primaryColor;
  }
}
