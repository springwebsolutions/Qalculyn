// Qalculyn - Polynomial Operations Screen
// Polynomial Euclidean GCD & LCM, Long Division with Remainder, and Product Expansion in Q[x]

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/algebra_engine.dart';
import '../../shared/tool_widgets.dart';

class PolynomialScreen extends StatefulWidget {
  const PolynomialScreen({super.key});

  @override
  State<PolynomialScreen> createState() => _PolynomialScreenState();
}

class _PolynomialScreenState extends State<PolynomialScreen> {
  int _selectedMode = 0; // 0: GCD & LCM, 1: Long Division, 2: Product Expansion
  final _p1Controller = TextEditingController(text: 'x^2 - 1');
  final _p2Controller = TextEditingController(text: 'x^2 - 2*x + 1');
  bool _showSteps = true;

  @override
  void dispose() {
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  void _setExample(String p1, String p2) {
    setState(() {
      _p1Controller.text = p1;
      _p2Controller.text = p2;
    });
  }

  Map<String, dynamic> _calculate() {
    final s1 = _p1Controller.text.trim();
    final s2 = _p2Controller.text.trim();

    if (s1.isEmpty || s2.isEmpty) {
      return {'error': 'Please enter both polynomial expressions'};
    }

    try {
      final p1 = Polynomial.parse(s1);
      final p2 = Polynomial.parse(s2);
      final steps = <String>[];

      steps.add('Polynomial 1: P(x) = $p1 (Degree: ${p1.degree})');
      steps.add('Polynomial 2: Q(x) = $p2 (Degree: ${p2.degree})');

      if (_selectedMode == 0) {
        // GCD & LCM
        steps.add('\nMethod: Euclidean Algorithm in Q[x]');
        var a = p1;
        var b = p2;
        var stepNum = 1;

        while (!b.isZero) {
          final (q, r) = a.divideWithRemainder(b);
          steps.add('Step $stepNum: ($a) = [($b) × ($q)] + ($r)');
          a = b;
          b = r;
          stepNum++;
        }

        final monicGcd = p1.isZero && p2.isZero ? Polynomial.zero() : a.toMonic();
        final monicLcm = Polynomial.lcm(p1, p2);

        steps.add('\nResults:');
        steps.add('• Monic GCD: $monicGcd');
        steps.add('• Integer Primitive GCD: ${a.toPrimitiveInteger()}');
        steps.add('• Monic LCM: $monicLcm');
        steps.add('• Identity: GCD(P, Q) × LCM(P, Q) = P(x) × Q(x) (up to scalar normalization)');

        return {
          'title1': 'Polynomial GCD (Monic)',
          'val1': monicGcd.toString(),
          'title2': 'Polynomial LCM (Monic)',
          'val2': monicLcm.toString(),
          'steps': steps,
        };
      } else if (_selectedMode == 1) {
        // Long Division
        if (p2.isZero) {
          return {'error': 'Division by zero polynomial is undefined'};
        }
        final (quotient, remainder) = p1.divideWithRemainder(p2);
        steps.add('\nPolynomial Long Division:');
        steps.add('• Dividend: P(x) = $p1');
        steps.add('• Divisor: Q(x) = $p2');
        steps.add('• Quotient: Q_out(x) = $quotient');
        steps.add('• Remainder: R(x) = $remainder (deg: ${remainder.degree})');
        steps.add('\nVerification Identity:');
        steps.add('($p2) × ($quotient) + ($remainder) = ${(p2 * quotient) + remainder}');

        return {
          'title1': 'Quotient Q(x)',
          'val1': quotient.toString(),
          'title2': 'Remainder R(x)',
          'val2': remainder.toString(),
          'steps': steps,
        };
      } else {
        // Product Expansion
        final product = p1 * p2;
        steps.add('\nPolynomial Product:');
        steps.add('($p1) × ($p2) = $product');
        steps.add('• Degree of product = ${p1.degree} + ${p2.degree} = ${product.degree}');

        return {
          'title1': 'Expanded Product',
          'val1': product.toString(),
          'title2': 'Product Degree',
          'val2': product.degree.toString(),
          'steps': steps,
        };
      }
    } catch (e) {
      return {'error': cleanMathErrorMessage(e, fallback: 'Please enter valid polynomial expressions (e.g. x^2 - 1)')};
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final res = _calculate();
    final hasError = res.containsKey('error');

    return ToolScaffold(
      title: 'Polynomial Operations',
      disclaimer: 'Operates over Q[x] with exact rational arithmetic. Normalizes GCD/LCM to monic form (leading coefficient 1).',
      children: [
        ToolModeSelector(
          modes: const ['GCD & LCM', 'Division P ÷ Q', 'Product P × Q'],
          selected: _selectedMode,
          onChanged: (idx) => setState(() => _selectedMode = idx),
        ),
        const SizedBox(height: QSpacing.md),

        Wrap(
          spacing: QSpacing.sm,
          runSpacing: QSpacing.xs,
          children: [
            ActionChip(
              label: const Text('x^2 - 1 & x^2 - 2x + 1'),
              onPressed: () => _setExample('x^2 - 1', 'x^2 - 2*x + 1'),
            ),
            ActionChip(
              label: const Text('6x^2 + 12x & 9x^2 + 18x'),
              onPressed: () => _setExample('6*x^2 + 12*x', '9*x^2 + 18*x'),
            ),
            ActionChip(
              label: const Text('x^3 - 8 & x^2 - 4'),
              onPressed: () => _setExample('x^3 - 8', 'x^2 - 4'),
            ),
          ],
        ),
        const SizedBox(height: QSpacing.md),

        ToolTextField(
          controller: _p1Controller,
          label: 'Polynomial P(x) (e.g. x^2 - 1)',
          keyboardType: TextInputType.text,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _p2Controller,
          label: 'Polynomial Q(x) (e.g. x^2 - 2*x + 1)',
          keyboardType: TextInputType.text,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.lg),

        if (!hasError) ...[
          Container(
            padding: const EdgeInsets.all(QSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? QColors.darkCard : QColors.lightElevated,
              borderRadius: QRadius.borderRadiusLg,
              border: Border.all(color: QColors.primaryPurple.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                _buildResultRow(context, res['title1'] as String, res['val1'] as String),
                const Divider(height: QSpacing.xl),
                _buildResultRow(context, res['title2'] as String, res['val2'] as String),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.lg),

          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: _showSteps,
              title: const Text('Exact Division & Euclidean Steps', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy steps',
                    onPressed: () {
                      final steps = (res['steps'] as List<String>).join('\n');
                      Clipboard.setData(ClipboardData(text: steps));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Steps copied to clipboard')),
                      );
                    },
                  ),
                  Icon(_showSteps ? Icons.expand_less : Icons.expand_more),
                ],
              ),
              onExpansionChanged: (val) => setState(() => _showSteps = val),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(QSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? QColors.darkSurfaceVariant : QColors.lightSurfaceVariant,
                    borderRadius: QRadius.borderRadiusMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (res['steps'] as List<String>).map((step) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: SelectableText(
                          step,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ToolResultCard(
            title: 'Calculation Note',
            results: {'Notice': res['error'] as String},
          ),
        ],
      ],
    );
  }

  Widget _buildResultRow(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: QColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          tooltip: 'Copy',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title copied to clipboard')),
            );
          },
        ),
      ],
    );
  }
}
