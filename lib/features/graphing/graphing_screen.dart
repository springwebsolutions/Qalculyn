// Qalculyn - 2D Cartesian Function Graphing & Analysis Studio
// Multi-curve function plotter with intersections, root tracing, extrema, and definite integral shading

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/graphing_engine.dart';
import '../../core/math/calculus_engine.dart';
import '../../shared/tool_widgets.dart';

class GraphingScreen extends StatefulWidget {
  const GraphingScreen({super.key});

  @override
  State<GraphingScreen> createState() => _GraphingScreenState();
}

class _GraphingScreenState extends State<GraphingScreen> {
  // Up to 3 function expressions
  final _expr1Controller = TextEditingController(text: 'x^2 - 4');
  final _expr2Controller = TextEditingController(text: '2*x + 1');
  final _expr3Controller = TextEditingController(text: '-x^2 + 6');

  bool _enableCurve2 = true;
  bool _enableCurve3 = false;

  final _graphingEngine = GraphingEngine();
  final _calculusEngine = CalculusEngine();

  double _xMin = -6.0;
  double _xMax = 6.0;
  double _yMin = -6.0;
  double _yMax = 6.0;

  double? _cursorX;
  bool _shadeIntegral = false;
  final double _intA = 0.0;
  final double _intB = 2.0;

  static const _presets = [
    'x^2 - 4',
    'sin(x)',
    'cos(x)',
    'x^3 - 3*x',
    '1 / x',
    'sqrt(x)',
  ];

  static const _curveColors = [
    Color(0xFF8B5CF6), // Curve 1: Primary Purple
    Color(0xFF00E5FF), // Curve 2: Cyan
    Color(0xFFFFB300), // Curve 3: Amber
  ];

  void _zoom(double factor) {
    setState(() {
      final xCenter = (_xMin + _xMax) / 2.0;
      final yCenter = (_yMin + _yMax) / 2.0;
      final xSpan = (_xMax - _xMin) * factor / 2.0;
      final ySpan = (_yMax - _yMin) * factor / 2.0;
      _xMin = xCenter - xSpan;
      _xMax = xCenter + xSpan;
      _yMin = yCenter - ySpan;
      _yMax = yCenter + ySpan;
    });
  }

  void _resetView() {
    setState(() {
      _xMin = -6.0;
      _xMax = 6.0;
      _yMin = -6.0;
      _yMax = 6.0;
      _cursorX = null;
    });
  }

  @override
  void dispose() {
    _expr1Controller.dispose();
    _expr2Controller.dispose();
    _expr3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final expr1 = _expr1Controller.text.trim();
    final expr2 = _expr2Controller.text.trim();
    final expr3 = _expr3Controller.text.trim();

    final points1 = _graphingEngine.sample(expr1, _xMin, _xMax, sampleCount: 250);
    final points2 = _enableCurve2 && expr2.isNotEmpty
        ? _graphingEngine.sample(expr2, _xMin, _xMax, sampleCount: 250)
        : <GraphPoint>[];
    final points3 = _enableCurve3 && expr3.isNotEmpty
        ? _graphingEngine.sample(expr3, _xMin, _xMax, sampleCount: 250)
        : <GraphPoint>[];

    final analysis = _graphingEngine.analyze(expr1, _xMin, _xMax);

    // Compute intersections between active curves
    final intersections = <GraphPoint>[];
    if (_enableCurve2 && expr2.isNotEmpty) {
      intersections.addAll(_graphingEngine.findIntersections(expr1, expr2, _xMin, _xMax));
    }
    if (_enableCurve3 && expr3.isNotEmpty) {
      intersections.addAll(_graphingEngine.findIntersections(expr1, expr3, _xMin, _xMax));
      if (_enableCurve2 && expr2.isNotEmpty) {
        intersections.addAll(_graphingEngine.findIntersections(expr2, expr3, _xMin, _xMax));
      }
    }

    double? cursorY;
    double? cursorSlope;
    if (_cursorX != null) {
      try {
        cursorY = _calculusEngine.evaluate(expr1, _cursorX!);
        final diff = _calculusEngine.differentiate(expr1, _cursorX!);
        cursorSlope = diff['firstDerivative'];
      } catch (_) {}
    }

    double? integralValue;
    if (_shadeIntegral) {
      try {
        integralValue = _calculusEngine.integrate(expr1, _intA, _intB);
      } catch (_) {}
    }

    return ToolScaffold(
      title: 'Function Graphing Studio',
      disclaimer: 'Plot up to 3 simultaneous curves, find exact intersection points, trace slopes, and detect roots.',
      children: [
        // Function 1 (Primary)
        ToolTextField(
          controller: _expr1Controller,
          label: 'Curve 1: f₁(x) (Purple)',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.xs),

        // Quick Presets for Curve 1
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _presets.map((p) {
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: ActionChip(
                  label: Text(p, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  backgroundColor: isDark ? QColors.darkCard : QColors.lightCard,
                  onPressed: () => setState(() => _expr1Controller.text = p),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: QSpacing.md),

        // Curve 2 Toggle & Field
        Row(
          children: [
            Checkbox(
              value: _enableCurve2,
              activeColor: _curveColors[1],
              onChanged: (v) => setState(() => _enableCurve2 = v ?? false),
            ),
            Expanded(
              child: ToolTextField(
                controller: _expr2Controller,
                label: 'Curve 2: f₂(x) (Cyan)',
                enabled: _enableCurve2,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: QSpacing.sm),

        // Curve 3 Toggle & Field
        Row(
          children: [
            Checkbox(
              value: _enableCurve3,
              activeColor: _curveColors[2],
              onChanged: (v) => setState(() => _enableCurve3 = v ?? false),
            ),
            Expanded(
              child: ToolTextField(
                controller: _expr3Controller,
                label: 'Curve 3: f₃(x) (Amber)',
                enabled: _enableCurve3,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: QSpacing.md),

        // Interactive Graph Canvas Card
        Container(
          height: 320,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F0A1C) : const Color(0xFFF7F4FD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _curveColors[0].withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox?;
                final w = box?.size.width ?? 350.0;
                final norm = (details.localPosition.dx / w).clamp(0.0, 1.0);
                setState(() {
                  _cursorX = _xMin + norm * (_xMax - _xMin);
                });
              },
              child: CustomPaint(
                painter: _MultiGraphPainter(
                  curves: [
                    _CurveData(points1, _curveColors[0]),
                    if (_enableCurve2 && points2.isNotEmpty) _CurveData(points2, _curveColors[1]),
                    if (_enableCurve3 && points3.isNotEmpty) _CurveData(points3, _curveColors[2]),
                  ],
                  intersections: intersections,
                  xMin: _xMin,
                  xMax: _xMax,
                  yMin: _yMin,
                  yMax: _yMax,
                  primaryColor: _curveColors[0],
                  textColor: theme.colorScheme.onSurface,
                  isDark: isDark,
                  cursorX: _cursorX,
                  cursorY: cursorY,
                  cursorSlope: cursorSlope,
                  shadeIntegral: _shadeIntegral,
                  intA: _intA,
                  intB: _intB,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: QSpacing.sm),

        // Viewport Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.zoom_in, size: 18),
              label: const Text('Zoom In'),
              onPressed: () => _zoom(0.7),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.zoom_out, size: 18),
              label: const Text('Zoom Out'),
              onPressed: () => _zoom(1.4),
            ),
            TextButton.icon(
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Reset'),
              onPressed: _resetView,
            ),
          ],
        ),
        const SizedBox(height: QSpacing.md),

        // Intersections Display Banner
        if (intersections.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(QSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.adjust, size: 18, color: Color(0xFF00E5FF)),
                    SizedBox(width: 8),
                    Text(
                      'Curve Intersections',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: intersections.map((p) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? QColors.darkCard : QColors.lightCard,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '(${p.x.toStringAsFixed(3)}, ${p.y.toStringAsFixed(3)})',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.md),
        ],

        // Cursor Metrics Banner
        if (_cursorX != null && cursorY != null)
          Container(
            padding: const EdgeInsets.all(QSpacing.md),
            decoration: BoxDecoration(
              color: _curveColors[0].withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _curveColors[0].withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'x: ${_cursorX!.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'f₁(x): ${cursorY.toStringAsFixed(3)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: _curveColors[0], fontSize: 13),
                ),
                if (cursorSlope != null)
                  Text(
                    'Slope m: ${cursorSlope.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
              ],
            ),
          ),
        const SizedBox(height: QSpacing.md),

        // Integral Shading Toggle & Parameters
        SwitchListTile(
          title: const Text('Shade Definite Integral (Curve 1)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: integralValue != null
              ? Text('∫ f₁(x) dx = ${integralValue.toStringAsFixed(4)} (from $_intA to $_intB)')
              : const Text('Visualize area under Curve 1'),
          value: _shadeIntegral,
          activeTrackColor: _curveColors[0],
          onChanged: (val) => setState(() => _shadeIntegral = val),
        ),
        const SizedBox(height: QSpacing.md),

        // Function Analysis Results
        ToolResultCard(
          title: 'Curve 1 Analysis: Extrema & Roots',
          results: {
            'Roots (x-intercepts)': analysis.roots.isEmpty
                ? 'None found in viewport'
                : analysis.roots.map((r) => r.toStringAsFixed(4)).join(', '),
            'y-intercept': analysis.yIntercept != null ? '(0, ${analysis.yIntercept!.toStringAsFixed(4)})' : 'Undefined',
            'Local Minima': analysis.localMinima.isEmpty
                ? 'None in viewport'
                : analysis.localMinima.map((m) => '(${m.x.toStringAsFixed(2)}, ${m.y.toStringAsFixed(2)})').join('; '),
            'Local Maxima': analysis.localMaxima.isEmpty
                ? 'None in viewport'
                : analysis.localMaxima.map((m) => '(${m.x.toStringAsFixed(2)}, ${m.y.toStringAsFixed(2)})').join('; '),
          },
        ),
      ],
    );
  }
}

class _CurveData {
  final List<GraphPoint> points;
  final Color color;
  const _CurveData(this.points, this.color);
}

class _MultiGraphPainter extends CustomPainter {
  final List<_CurveData> curves;
  final List<GraphPoint> intersections;
  final double xMin, xMax, yMin, yMax;
  final Color primaryColor;
  final Color textColor;
  final bool isDark;
  final double? cursorX;
  final double? cursorY;
  final double? cursorSlope;
  final bool shadeIntegral;
  final double intA, intB;

  _MultiGraphPainter({
    required this.curves,
    required this.intersections,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.primaryColor,
    required this.textColor,
    required this.isDark,
    this.cursorX,
    this.cursorY,
    this.cursorSlope,
    this.shadeIntegral = false,
    this.intA = 0.0,
    this.intB = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double toCanvasX(double x) => ((x - xMin) / (xMax - xMin)) * size.width;
    double toCanvasY(double y) => size.height - (((y - yMin) / (yMax - yMin)) * size.height);

    // 1. Grid Lines
    final gridPaint = Paint()
      ..color = textColor.withValues(alpha: isDark ? 0.08 : 0.06)
      ..strokeWidth = 1.0;

    for (int gx = xMin.ceil(); gx <= xMax.floor(); gx++) {
      final cx = toCanvasX(gx.toDouble());
      canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), gridPaint);
    }
    for (int gy = yMin.ceil(); gy <= yMax.floor(); gy++) {
      final cy = toCanvasY(gy.toDouble());
      canvas.drawLine(Offset(0, cy), Offset(size.width, cy), gridPaint);
    }

    // 2. Axes
    final axisPaint = Paint()
      ..color = textColor.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;

    final yAxisX = toCanvasX(0.0).clamp(0.0, size.width);
    final xAxisY = toCanvasY(0.0).clamp(0.0, size.height);
    canvas.drawLine(Offset(0, xAxisY), Offset(size.width, xAxisY), axisPaint);
    canvas.drawLine(Offset(yAxisX, 0), Offset(yAxisX, size.height), axisPaint);

    // 3. Shaded Integral Area (on first curve)
    if (shadeIntegral && curves.isNotEmpty && curves.first.points.isNotEmpty) {
      final areaPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;

      final areaPath = Path();
      final subPoints = curves.first.points.where((p) => p.isValid && p.x >= intA && p.x <= intB).toList();
      if (subPoints.isNotEmpty) {
        areaPath.moveTo(toCanvasX(subPoints.first.x), toCanvasY(0.0));
        for (final p in subPoints) {
          areaPath.lineTo(toCanvasX(p.x), toCanvasY(p.y.clamp(yMin, yMax)));
        }
        areaPath.lineTo(toCanvasX(subPoints.last.x), toCanvasY(0.0));
        areaPath.close();
        canvas.drawPath(areaPath, areaPaint);
      }
    }

    // 4. Draw All Active Function Curves
    for (final curve in curves) {
      final curvePaint = Paint()
        ..color = curve.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final curvePath = Path();
      bool isFirst = true;

      for (final p in curve.points) {
        if (!p.isValid) {
          isFirst = true;
          continue;
        }
        final cx = toCanvasX(p.x);
        final cy = toCanvasY(p.y.clamp(yMin * 1.5, yMax * 1.5));

        if (isFirst) {
          curvePath.moveTo(cx, cy);
          isFirst = false;
        } else {
          curvePath.lineTo(cx, cy);
        }
      }
      canvas.drawPath(curvePath, curvePaint);
    }

    // 5. Draw Intersection Points
    for (final ip in intersections) {
      if (ip.x >= xMin && ip.x <= xMax && ip.y >= yMin && ip.y <= yMax) {
        final icx = toCanvasX(ip.x);
        final icy = toCanvasY(ip.y);

        // Glowing outer halo
        canvas.drawCircle(Offset(icx, icy), 8.0, Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.4));
        canvas.drawCircle(Offset(icx, icy), 5.0, Paint()..color = const Color(0xFF00E5FF));
        canvas.drawCircle(Offset(icx, icy), 2.5, Paint()..color = Colors.white);
      }
    }

    // 6. Cursor & Tangent Line (on Curve 1)
    if (cursorX != null && cursorY != null) {
      final cx = toCanvasX(cursorX!);
      final cy = toCanvasY(cursorY!.clamp(yMin, yMax));

      // Tangent line
      if (cursorSlope != null) {
        final tanPaint = Paint()
          ..color = primaryColor.withValues(alpha: 0.5)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        const dx = 1.5;
        final x1 = cursorX! - dx;
        final y1 = cursorY! - cursorSlope! * dx;
        final x2 = cursorX! + dx;
        final y2 = cursorY! + cursorSlope! * dx;
        canvas.drawLine(Offset(toCanvasX(x1), toCanvasY(y1)), Offset(toCanvasX(x2), toCanvasY(y2)), tanPaint);
      }

      // Cursor dot
      canvas.drawCircle(Offset(cx, cy), 6.0, Paint()..color = primaryColor);
      canvas.drawCircle(Offset(cx, cy), 3.0, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _MultiGraphPainter old) => true;
}
