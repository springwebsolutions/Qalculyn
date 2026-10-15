// Qalculyn - Monomial LCM & GCD/HCF Calculator
// Computes exact GCD and LCM of algebraic monomials with step-by-step breakdown

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/algebra_engine.dart';
import '../../core/math/number_theory.dart';
import '../../shared/tool_widgets.dart';

class MonomialScreen extends StatefulWidget {
  const MonomialScreen({super.key});

  @override
  State<MonomialScreen> createState() => _MonomialScreenState();
}

class _MonomialScreenState extends State<MonomialScreen> {
  final _m1Controller = TextEditingController(text: '6*x^2*y');
  final _m2Controller = TextEditingController(text: '9*x*y^3');
  final _m3Controller = TextEditingController();
  bool _showSteps = true;

  @override
  void dispose() {
    _m1Controller.dispose();
    _m2Controller.dispose();
    _m3Controller.dispose();
    super.dispose();
  }

  void _setExample(String m1, String m2, [String? m3]) {
    setState(() {
      _m1Controller.text = m1;
      _m2Controller.text = m2;
      _m3Controller.text = m3 ?? '';
    });
  }

  Map<String, dynamic> _calculate() {
    final m1Str = _m1Controller.text.trim();
    final m2Str = _m2Controller.text.trim();
    final m3Str = _m3Controller.text.trim();

    if (m1Str.isEmpty || m2Str.isEmpty) {
      return {'error': 'Please enter at least two monomials'};
    }

    final m1 = Monomial.parse(m1Str);
    final m2 = Monomial.parse(m2Str);
    final monomials = [m1, m2];
    if (m3Str.isNotEmpty) {
      monomials.add(Monomial.parse(m3Str));
    }

    final steps = <String>[];
    steps.add('Canonical Monomials:');
    for (var i = 0; i < monomials.length; i++) {
      steps.add('• Monomial ${i + 1}: ${monomials[i]} (Coeff: ${monomials[i].coefficient}, Variables: ${monomials[i].variables})');
    }

    // Coefficients calculation
    final coeffs = monomials.map((m) => m.coefficient).toList();
    final coeffGcd = NumberTheory.gcdMany(coeffs);
    final coeffLcm = NumberTheory.lcmMany(coeffs);

    steps.add('\n1. Coefficient Calculations:');
    steps.add('• Coefficients: [${coeffs.join(", ")}]');
    steps.add('• Coefficient GCD = $coeffGcd');
    steps.add('• Coefficient LCM = $coeffLcm');

    // Variable exponents
    final allVars = <String>{};
    for (final m in monomials) {
      allVars.addAll(m.variables.keys);
    }
    final sortedVars = allVars.toList()..sort();

    steps.add('\n2. Variable Exponent Rules:');
    steps.add('• For GCD: take minimum exponent across all monomials (missing variable = 0).');
    steps.add('• For LCM: take maximum exponent across all monomials.');

    final gcdVars = <String, int>{};
    final lcmVars = <String, int>{};

    for (final v in sortedVars) {
      final exps = monomials.map((m) => m.variables[v] ?? 0).toList();
      final minE = exps.reduce((a, b) => a < b ? a : b);
      final maxE = exps.reduce((a, b) => a > b ? a : b);

      if (minE > 0) gcdVars[v] = minE;
      if (maxE > 0) lcmVars[v] = maxE;

      steps.add('• Variable \'$v\': exponents = [${exps.join(", ")}] => min = $minE (GCD), max = $maxE (LCM)');
    }

    var gcdMon = Monomial(coefficient: coeffGcd, variables: gcdVars);
    var lcmMon = Monomial(coefficient: coeffLcm, variables: lcmVars);

    // Pairwise reduction
    if (monomials.length == 2) {
      gcdMon = Monomial.gcd(m1, m2);
      lcmMon = Monomial.lcm(m1, m2);
    }

    steps.add('\n3. Assembled Results:');
    steps.add('• GCD = $gcdMon');
    steps.add('• LCM = $lcmMon');

    return {
      'gcd': gcdMon.toString(),
      'lcm': lcmMon.toString(),
      'steps': steps,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final res = _calculate();
    final hasError = res.containsKey('error');

    return ToolScaffold(
      title: 'Monomial LCM & GCD',
      disclaimer: 'Calculates coefficient GCD/LCM using exact integers and extracts variable exponents (min for GCD, max for LCM).',
      children: [
        Wrap(
          spacing: QSpacing.sm,
          runSpacing: QSpacing.xs,
          children: [
            ActionChip(
              label: const Text('6*x^2*y & 9*x*y^3'),
              onPressed: () => _setExample('6*x^2*y', '9*x*y^3'),
            ),
            ActionChip(
              label: const Text('12a^2b^3 & 18a^3b^2'),
              onPressed: () => _setExample('12*a^2*b^3', '18*a^3*b^2'),
            ),
            ActionChip(
              label: const Text('4x^3y^2z & 6x^2y^4 & 8xy^3'),
              onPressed: () => _setExample('4*x^3*y^2*z', '6*x^2*y^4', '8*x*y^3'),
            ),
          ],
        ),
        const SizedBox(height: QSpacing.md),

        ToolTextField(
          controller: _m1Controller,
          label: 'Monomial 1 (e.g. 6*x^2*y)',
          keyboardType: TextInputType.text,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _m2Controller,
          label: 'Monomial 2 (e.g. 9*x*y^3)',
          keyboardType: TextInputType.text,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _m3Controller,
          label: 'Monomial 3 (Optional)',
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
                _buildResultRow(context, 'Greatest Common Divisor (GCD)', res['gcd'] as String),
                const Divider(height: QSpacing.xl),
                _buildResultRow(context, 'Least Common Multiple (LCM)', res['lcm'] as String),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.lg),

          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: _showSteps,
              title: const Text('Detailed Algebraic Steps', style: TextStyle(fontWeight: FontWeight.w600)),
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
          ToolResultCard(results: {'Error': res['error'] as String}),
        ],
      ],
    );
  }

  Widget _buildResultRow(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
