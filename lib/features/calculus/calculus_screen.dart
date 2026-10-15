// Qalculyn - Numerical Calculus & Limits Screen
// Derivatives, concavity, tangent/normal lines, Simpson's integration, average function value, and two-sided limits

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/calculus_engine.dart';
import '../../shared/tool_widgets.dart';

class CalculusScreen extends StatefulWidget {
  const CalculusScreen({super.key});

  @override
  State<CalculusScreen> createState() => _CalculusScreenState();
}

class _CalculusScreenState extends State<CalculusScreen> {
  int _selectedMode = 0; // 0: Derivative, 1: Definite Integral, 2: Limit

  final _exprController = TextEditingController(text: 'x^2 + 3*x - 4');
  final _xPointController = TextEditingController(text: '2');
  final _lowerLimitController = TextEditingController(text: '0');
  final _upperLimitController = TextEditingController(text: '3');

  final _engine = CalculusEngine();

  @override
  void dispose() {
    _exprController.dispose();
    _xPointController.dispose();
    _lowerLimitController.dispose();
    _upperLimitController.dispose();
    super.dispose();
  }

  void _setExample(String expr, [String? p1, String? p2]) {
    setState(() {
      _exprController.text = expr;
      if (p1 != null) _xPointController.text = p1;
      if (p1 != null) _lowerLimitController.text = p1;
      if (p2 != null) _upperLimitController.text = p2;
    });
  }

  void _showStepModal(String title, List<String> steps) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.72,
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
                  itemCount: steps.length,
                  itemBuilder: (ctx, i) {
                    final s = steps[i];
                    final isHeader = s.startsWith('Step') || s.startsWith('Conclusion') || s.endsWith(':');
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
    final expr = _exprController.text.trim();
    if (expr.isEmpty) return {'Error': 'Please enter a function f(x)'};

    try {
      if (_selectedMode == 0) {
        // Differentiation
        final x = double.parse(_xPointController.text.trim());
        final res = _engine.differentiate(expr, x);
        final d1 = res['firstDerivative']!;
        final d2 = res['secondDerivative']!;
        final fx = res['fx']!;

        String concavity;
        if (d2 > 1e-4) {
          concavity = 'Concave Up (∪) — minimum tendency';
        } else if (d2 < -1e-4) {
          concavity = 'Concave Down (∩) — maximum tendency';
        } else {
          concavity = 'Potential Inflection Point (f\'\' ≈ 0)';
        }

        // Tangent: y - fx = d1 * (x - x0) => y = d1*x + (fx - d1*x0)
        final tangentC = fx - d1 * x;
        final tanSign = tangentC >= 0 ? '+' : '-';
        final tangentEq = 'y = ${d1.toStringAsFixed(4)}x $tanSign ${tangentC.abs().toStringAsFixed(4)}';

        // Normal: slope = -1 / d1
        String normalEq;
        if (d1.abs() > 1e-6) {
          final mNorm = -1.0 / d1;
          final normC = fx - mNorm * x;
          final normSign = normC >= 0 ? '+' : '-';
          normalEq = 'y = ${mNorm.toStringAsFixed(4)}x $normSign ${normC.abs().toStringAsFixed(4)}';
        } else {
          normalEq = 'Vertical Line: x = $x';
        }

        return {
          'Slope f\'($x)': d1.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), ''),
          'Second Derivative f\'\'($x)': d2.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), ''),
          'Curve Concavity': concavity,
          'Function Value f($x)': fx.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), ''),
          'Tangent Line Equation': tangentEq,
          'Normal Line Equation': normalEq,
        };
      } else if (_selectedMode == 1) {
        // Definite Integration
        final a = double.parse(_lowerLimitController.text.trim());
        final b = double.parse(_upperLimitController.text.trim());
        final area = _engine.integrate(expr, a, b);

        final avgValue = (b - a).abs() > 1e-6 ? (area / (b - a)) : area;

        return {
          'Definite Integral ∫': area.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), ''),
          'Average Function Value': avgValue.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), ''),
          'Interval [a, b]': 'from $a to $b (width = ${(b - a).abs().toStringAsFixed(2)})',
          'Integration Method': 'Composite Simpson\'s 1/3 Rule (N = 1000 parabolic subintervals)',
        };
      } else {
        // Limit
        final c = double.parse(_xPointController.text.trim());
        final res = _engine.evaluateLimit(expr, c);

        final left = res['leftLimit'] as double?;
        final right = res['rightLimit'] as double?;
        final lim = res['limit'] as double?;
        final exists = res['exists'] as bool? ?? false;

        return {
          'Two-Sided Limit': exists ? lim!.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : 'Does not exist / Discontinuous',
          'Left-Hand Limit (x → $c⁻)': left != null ? left.toStringAsFixed(6) : 'Undefined',
          'Right-Hand Limit (x → $c⁺)': right != null ? right.toStringAsFixed(6) : 'Undefined',
          'Target Point (c)': c.toString(),
        };
      }
    } catch (e) {
      return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter a valid function f(x) and evaluate point')};
    }
  }

  List<String>? _getSteps() {
    final expr = _exprController.text.trim();
    if (expr.isEmpty) return null;

    try {
      if (_selectedMode == 0) {
        final x = double.parse(_xPointController.text.trim());
        final res = _engine.differentiate(expr, x);
        final d1 = res['firstDerivative']!;
        final d2 = res['secondDerivative']!;
        final fx = res['fx']!;

        final tangentC = fx - d1 * x;
        final tanSign = tangentC >= 0 ? '+' : '-';

        return [
          'Function: f(x) = $expr at point x = $x',
          'Step 1: Evaluate function value:',
          '  f($x) = $fx',
          'Step 2: 5-Point central difference numerical differentiation:',
          '  f\'($x) = [-f(x+2h) + 8f(x+h) - 8f(x-h) + f(x-2h)] / (12h)',
          '  f\'($x) ≈ ${d1.toStringAsFixed(6)}',
          'Step 3: Evaluate second derivative for curvature / concavity:',
          '  f\'\'($x) = [-f(x+2h) + 16f(x+h) - 30f(x) + 16f(x-h) - f(x-2h)] / (12h²)',
          '  f\'\'($x) ≈ ${d2.toStringAsFixed(6)}',
          'Step 4: Concavity verdict:',
          if (d2 > 1e-4) '  f\'\' > 0 indicates curve is Concave Up (∪).'
          else if (d2 < -1e-4) '  f\'\' < 0 indicates curve is Concave Down (∩).'
          else '  f\'\' ≈ 0 indicates a potential inflection point.',
          'Step 5: Tangent line equation in point-slope form:',
          '  y - f($x) = f\'($x)(x - $x)',
          '  y = ${d1.toStringAsFixed(4)}x $tanSign ${tangentC.abs().toStringAsFixed(4)}',
        ];
      } else if (_selectedMode == 1) {
        final a = double.parse(_lowerLimitController.text.trim());
        final b = double.parse(_upperLimitController.text.trim());
        final area = _engine.integrate(expr, a, b);
        final width = b - a;
        final avgVal = width.abs() > 1e-6 ? area / width : area;

        return [
          'Integral: ∫ from a = $a to b = $b of ($expr) dx',
          'Step 1: Partition interval into N = 1000 parabolic subintervals:',
          '  Step size h = (b - a) / N = ($b - $a) / 1000 = ${(width / 1000).toStringAsFixed(6)}',
          'Step 2: Apply Composite Simpson\'s 1/3 Rule:',
          '  ∫ ≈ (h/3) × [f(a) + 4∑f(odd) + 2∑f(even) + f(b)]',
          'Step 3: Numerical evaluation result:',
          '  ∫ f(x) dx ≈ ${area.toStringAsFixed(6)}',
          'Step 4: Average function value over interval:',
          '  f_avg = (1 / (b - a)) × ∫ f(x) dx = ${avgVal.toStringAsFixed(6)}',
        ];
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();
    final steps = _getSteps();

    return ToolScaffold(
      title: 'Calculus & Limits',
      disclaimer: 'Numerical approximation using high-order finite differences and composite Simpson quadrature.',
      children: [
        ToolModeSelector(
          modes: const ['Derivative f\'(x)', 'Definite Integral ∫', 'Limit lim x→c'],
          selected: _selectedMode,
          onChanged: (idx) => setState(() => _selectedMode = idx),
        ),
        const SizedBox(height: QSpacing.md),

        Wrap(
          spacing: QSpacing.sm,
          runSpacing: QSpacing.xs,
          children: [
            ActionChip(label: const Text('x^2 + 3*x - 4'), onPressed: () => _setExample('x^2 + 3*x - 4', '2', '5')),
            ActionChip(label: const Text('sin(x)'), onPressed: () => _setExample('sin(x)', '0', '3.14159')),
            ActionChip(label: const Text('exp(x)'), onPressed: () => _setExample('exp(x)', '0', '1')),
          ],
        ),
        const SizedBox(height: QSpacing.md),

        ToolTextField(
          controller: _exprController,
          label: 'Function f(x) (e.g. x^2 + 3*x - 4)',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),

        if (_selectedMode == 0 || _selectedMode == 2) ...[
          ToolTextField(
            controller: _xPointController,
            label: _selectedMode == 0 ? 'Evaluate at point x' : 'Target approach point c',
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            onChanged: (_) => setState(() {}),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                  controller: _lowerLimitController,
                  label: 'Lower Limit (a)',
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.md),
              Expanded(
                child: ToolTextField(
                  controller: _upperLimitController,
                  label: 'Upper Limit (b)',
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],

        if (steps != null) ...[
          const SizedBox(height: QSpacing.md),
          ElevatedButton.icon(
            onPressed: () => _showStepModal('Calculus Derivation Steps', steps),
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('View Step-by-Step Derivation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: QColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],

        const SizedBox(height: QSpacing.xl),
        ToolResultCard(
          title: 'Calculus Computation Results',
          results: results,
        ),
      ],
    );
  }
}
