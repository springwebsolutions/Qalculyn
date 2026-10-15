// Qalculyn - Statistics & Probability Screen
// Descriptive statistics, quartiles, combinatorics (nPr, nCr), normal distribution, and linear regression

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/statistics_engine.dart';
import '../../shared/tool_widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedMode = 0; // 0: Dataset Statistics, 1: Combinatorics, 2: Normal/Binomial, 3: Linear Regression

  // Dataset input
  final _dataController = TextEditingController(text: '12, 15, 18, 22, 25, 28, 30, 35, 40');

  // Combinatorics inputs
  final _nController = TextEditingController(text: '10');
  final _rController = TextEditingController(text: '3');

  // Probability inputs
  final _xValController = TextEditingController(text: '1.96');
  final _muController = TextEditingController(text: '0');
  final _sigmaController = TextEditingController(text: '1');

  // Linear Regression input
  final _regDataController = TextEditingController(text: '(1, 2), (2, 3), (3, 5), (4, 4), (5, 6)');

  @override
  void dispose() {
    _dataController.dispose();
    _nController.dispose();
    _rController.dispose();
    _xValController.dispose();
    _muController.dispose();
    _sigmaController.dispose();
    _regDataController.dispose();
    super.dispose();
  }

  void _setExample(String ex) {
    setState(() => _dataController.text = ex);
  }

  void _setRegExample(String ex) {
    setState(() => _regDataController.text = ex);
  }

  List<(double, double)> _parsePoints(String text) {
    final points = <(double, double)>[];
    // Match (x, y) or x y or x, y;
    final regex = RegExp(r'\(?\s*(-?\d+\.?\d*)\s*[,;\s]+\s*(-?\d+\.?\d*)\s*\)?');
    for (final m in regex.allMatches(text)) {
      final x = double.tryParse(m.group(1)!);
      final y = double.tryParse(m.group(2)!);
      if (x != null && y != null) {
        points.add((x, y));
      }
    }
    return points;
  }

  void _showRegressionStepsModal(LinearRegressionResult res) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? QColors.darkSurface : QColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(QSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Linear Regression Derivation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: res.steps.length,
                  itemBuilder: (ctx, i) {
                    final s = res.steps[i];
                    final isHeader = s.startsWith('Step') || s.startsWith('Conclusion');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: isHeader ? 14 : 13,
                          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                          color: isHeader ? QColors.primaryPurple : (isDark ? Colors.white70 : Colors.black87),
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, String> _calculate() {
    if (_selectedMode == 0) {
      // Dataset
      try {
        final text = _dataController.text;
        final raw = text
            .split(RegExp(r'[,;\s]+'))
            .where((s) => s.isNotEmpty)
            .map((s) => double.parse(s.trim()))
            .toList();

        if (raw.isEmpty) return {'Error': 'Please enter numeric dataset'};
        final res = StatisticsEngine.describe(raw);

        final modes = res['modes'] as List<double>;
        final modeStr = modes.isEmpty ? 'No unique mode' : modes.map((m) => m.toString()).join(', ');

        return {
          'Count (N)': res['count'].toString(),
          'Mean (Average)': (res['mean'] as double).toStringAsFixed(4),
          'Median': (res['median'] as double).toStringAsFixed(4),
          'Mode(s)': modeStr,
          'Sample Std Dev (s)': (res['sampleStdDev'] as double).toStringAsFixed(4),
          'Population Std Dev (σ)': (res['popStdDev'] as double).toStringAsFixed(4),
          'Sample Variance (s²)': (res['sampleVariance'] as double).toStringAsFixed(4),
          'Population Variance (σ²)': (res['popVariance'] as double).toStringAsFixed(4),
          'First Quartile (Q1)': (res['q1'] as double).toStringAsFixed(4),
          'Third Quartile (Q3)': (res['q3'] as double).toStringAsFixed(4),
          'Interquartile Range (IQR)': (res['iqr'] as double).toStringAsFixed(4),
          'Minimum': (res['min'] as double).toString(),
          'Maximum': (res['max'] as double).toString(),
          'Range': (res['range'] as double).toString(),
          'Sum Σx': (res['sum'] as double).toString(),
        };
      } catch (e) {
        return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter comma-separated numbers')};
      }
    } else if (_selectedMode == 1) {
      // Combinatorics
      try {
        final n = int.parse(_nController.text.trim());
        final r = int.parse(_rController.text.trim());

        final nFact = StatisticsEngine.factorial(n);
        final nPr = StatisticsEngine.permutations(n, r);
        final nCr = StatisticsEngine.combinations(n, r);

        return {
          'Combinations nCr': nCr.toString(),
          'Permutations nPr': nPr.toString(),
          'Factorial n!': nFact.toString(),
          'Formula nCr': '$n! / ($r! × ($n - $r)!)',
          'Formula nPr': '$n! / ($n - $r)!',
        };
      } catch (e) {
        return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter valid integers (0 <= r <= n)')};
      }
    } else if (_selectedMode == 2) {
      // Normal/Binomial
      try {
        final x = double.parse(_xValController.text.trim());
        final mu = double.parse(_muController.text.trim());
        final sigma = double.parse(_sigmaController.text.trim());

        final pdf = StatisticsEngine.normalPdf(x, mu, sigma);
        final cdf = StatisticsEngine.normalCdf(x, mu, sigma);
        final zScore = (x - mu) / sigma;

        return {
          'Z-Score': zScore.toStringAsFixed(4),
          'Probability Density f(x)': pdf.toStringAsFixed(5),
          'Cumulative P(X <= x)': '${(cdf * 100).toStringAsFixed(2)}% ($cdf)',
          'Upper Tail P(X > x)': '${((1.0 - cdf) * 100).toStringAsFixed(2)}% (${1.0 - cdf})',
          'Interpretation': 'Value $x is ${zScore.abs().toStringAsFixed(2)} std deviations ${zScore >= 0 ? "above" : "below"} the mean.',
        };
      } catch (e) {
        return {'Input Note': cleanMathErrorMessage(e, fallback: 'Standard deviation (σ) must be positive')};
      }
    } else {
      // Linear Regression
      try {
        final points = _parsePoints(_regDataController.text);
        if (points.length < 2) {
          return {'Input Note': 'Please enter at least 2 coordinate pairs (e.g. (1, 2), (2, 3))'};
        }
        final res = StatisticsEngine.linearRegression(points);
        return {
          'Best-Fit Trendline': res.equation,
          'Correlation Rating': res.correlationRating,
          'Pearson Correlation (r)': res.r.toStringAsFixed(4),
          'Determination (R²)': '${res.rSquared.toStringAsFixed(4)} (${(res.rSquared * 100).toStringAsFixed(1)}%)',
          'Slope (m)': res.slope.toStringAsFixed(4),
          'Y-Intercept (c)': res.intercept.toStringAsFixed(4),
          'Data Points': '${res.count} points evaluated',
        };
      } catch (e) {
        return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter valid coordinate points')};
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    LinearRegressionResult? regResult;
    if (_selectedMode == 3) {
      try {
        final pts = _parsePoints(_regDataController.text);
        if (pts.length >= 2) {
          regResult = StatisticsEngine.linearRegression(pts);
        }
      } catch (_) {}
    }

    return ToolScaffold(
      title: 'Statistics & Probability',
      disclaimer: 'Sample and population statistics, exact combinatorics, normal distribution, and linear regression.',
      children: [
        ToolModeSelector(
          modes: const ['Descriptive Stats', 'Combinatorics', 'Normal Distribution', 'Linear Regression'],
          selected: _selectedMode,
          onChanged: (idx) => setState(() => _selectedMode = idx),
        ),
        const SizedBox(height: QSpacing.md),

        if (_selectedMode == 0) ...[
          Wrap(
            spacing: QSpacing.sm,
            runSpacing: QSpacing.xs,
            children: [
              ActionChip(label: const Text('12, 15, 18, 22, 25, 28, 30'), onPressed: () => _setExample('12, 15, 18, 22, 25, 28, 30')),
              ActionChip(label: const Text('Normal Sample: 100, 102, 98, 105, 95'), onPressed: () => _setExample('100, 102, 98, 105, 95')),
            ],
          ),
          const SizedBox(height: QSpacing.md),

          ToolTextField(
            controller: _dataController,
            label: 'Enter numbers separated by commas or spaces',
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() {}),
          ),
        ] else if (_selectedMode == 1) ...[
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                  controller: _nController,
                  label: 'Total Items (n)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.md),
              Expanded(
                child: ToolTextField(
                  controller: _rController,
                  label: 'Selected Items (r)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ] else if (_selectedMode == 2) ...[
          ToolTextField(
            controller: _xValController,
            label: 'Value (x)',
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: QSpacing.md),
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                  controller: _muController,
                  label: 'Mean (μ)',
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.md),
              Expanded(
                child: ToolTextField(
                  controller: _sigmaController,
                  label: 'Std Dev (σ)',
                  keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ] else ...[
          // Mode 3: Linear Regression
          Wrap(
            spacing: QSpacing.sm,
            runSpacing: QSpacing.xs,
            children: [
              ActionChip(
                label: const Text('Positive Trend: (1,2), (2,3), (3,5), (4,4), (5,6)'),
                onPressed: () => _setRegExample('(1, 2), (2, 3), (3, 5), (4, 4), (5, 6)'),
              ),
              ActionChip(
                label: const Text('Negative Trend: (1,10), (2,8), (3,7), (4,5), (5,2)'),
                onPressed: () => _setRegExample('(1, 10), (2, 8), (3, 7), (4, 5), (5, 2)'),
              ),
            ],
          ),
          const SizedBox(height: QSpacing.md),

          ToolTextField(
            controller: _regDataController,
            label: 'Coordinate pairs format: (x1, y1), (x2, y2), ...',
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: QSpacing.md),

          if (regResult != null) ...[
            ElevatedButton.icon(
              onPressed: () => _showRegressionStepsModal(regResult!),
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('View Step-by-Step Derivation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: QColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: QSpacing.md),

            // Scatter Plot Canvas
            Container(
              height: 220,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? QColors.darkCard : QColors.lightElevated,
                borderRadius: QRadius.borderRadiusLg,
                border: Border.all(color: QColors.primaryPurple.withValues(alpha: 0.2)),
              ),
              child: CustomPaint(
                painter: _ScatterPlotPainter(
                  points: regResult.points,
                  slope: regResult.slope,
                  intercept: regResult.intercept,
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
              ),
            ),
          ],
        ],

        const SizedBox(height: QSpacing.xl),
        ToolResultCard(
          title: _selectedMode == 3 ? 'Linear Regression Results' : 'Statistical Summary',
          results: results,
        ),
      ],
    );
  }
}

class _ScatterPlotPainter extends CustomPainter {
  final List<(double, double)> points;
  final double slope;
  final double intercept;
  final bool isDark;

  const _ScatterPlotPainter({
    required this.points,
    required this.slope,
    required this.intercept,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final pad = 24.0;
    final w = size.width - 2 * pad;
    final h = size.height - 2 * pad;

    var minX = points.first.$1;
    var maxX = points.first.$1;
    var minY = points.first.$2;
    var maxY = points.first.$2;

    for (final p in points) {
      if (p.$1 < minX) minX = p.$1;
      if (p.$1 > maxX) maxX = p.$1;
      if (p.$2 < minY) minY = p.$2;
      if (p.$2 > maxY) maxY = p.$2;
    }

    // Expand ranges slightly for breathing room
    if ((maxX - minX).abs() < 1e-6) {
      minX -= 1;
      maxX += 1;
    }
    if ((maxY - minY).abs() < 1e-6) {
      minY -= 1;
      maxY += 1;
    }

    final rangeX = (maxX - minX) * 1.15;
    final rangeY = (maxY - minY) * 1.15;
    final centerX = (minX + maxX) / 2.0;
    final centerY = (minY + maxY) / 2.0;

    final actualMinX = centerX - rangeX / 2.0;
    final actualMaxX = centerX + rangeX / 2.0;
    final actualMinY = centerY - rangeY / 2.0;

    double toScreenX(double x) => pad + (x - actualMinX) / rangeX * w;
    double toScreenY(double y) => pad + h - (y - actualMinY) / rangeY * h;

    // Draw Axes Grid
    final axisPaint = Paint()
      ..color = isDark ? Colors.white24 : Colors.black12
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(pad, pad + h), Offset(pad + w, pad + h), axisPaint);
    canvas.drawLine(Offset(pad, pad), Offset(pad, pad + h), axisPaint);

    // Draw Trendline
    final linePaint = Paint()
      ..color = QColors.primaryPurple
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final yAtMinX = slope * actualMinX + intercept;
    final yAtMaxX = slope * actualMaxX + intercept;

    canvas.drawLine(
      Offset(toScreenX(actualMinX), toScreenY(yAtMinX).clamp(pad, pad + h)),
      Offset(toScreenX(actualMaxX), toScreenY(yAtMaxX).clamp(pad, pad + h)),
      linePaint,
    );

    // Draw Data Points
    final dotPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final p in points) {
      final center = Offset(toScreenX(p.$1), toScreenY(p.$2));
      canvas.drawCircle(center, 5.0, dotPaint);
      canvas.drawCircle(center, 5.0, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScatterPlotPainter oldDelegate) => true;
}
