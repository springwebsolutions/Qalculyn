// Qalculyn - Fractions & Ratios Screen
// Exact fraction simplification, arithmetic, rational GCD/LCM, and ratio reduction with step derivations

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/big_rational.dart';
import '../../core/math/number_theory.dart';
import '../../shared/tool_widgets.dart';

class FractionScreen extends StatefulWidget {
  const FractionScreen({super.key});

  @override
  State<FractionScreen> createState() => _FractionScreenState();
}

class _FractionScreenState extends State<FractionScreen> {
  int _selectedMode = 0; // 0: Simplify, 1: Arithmetic, 2: Fraction LCM/GCD, 3: Ratio Simplifier

  // Simplify controllers
  final _numController = TextEditingController(text: '48');
  final _denController = TextEditingController(text: '64');

  // Arithmetic & LCM/GCD controllers
  final _f1Controller = TextEditingController(text: '2/3');
  final _f2Controller = TextEditingController(text: '4/9');
  int _arithmeticOp = 0; // 0: +, 1: -, 2: *, 3: /

  // Ratio controller
  final _ratioController = TextEditingController(text: '12 : 18 : 24');

  @override
  void dispose() {
    _numController.dispose();
    _denController.dispose();
    _f1Controller.dispose();
    _f2Controller.dispose();
    _ratioController.dispose();
    super.dispose();
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

  List<String> _getSimplifySteps(BigInt n, BigInt d) {
    final g = NumberTheory.gcd(n, d);
    final simplifiedN = n ~/ g;
    final simplifiedD = d ~/ g;
    final fN = NumberTheory.primeFactors(n);
    final fD = NumberTheory.primeFactors(d);

    return [
      'Original Fraction: $n / $d',
      'Step 1: Compute prime factors:',
      '  Numerator $n = ${NumberTheory.formatPrimeFactors(fN)}',
      '  Denominator $d = ${NumberTheory.formatPrimeFactors(fD)}',
      'Step 2: Find Greatest Common Divisor GCD($n, $d):',
      '  GCD($n, $d) = $g',
      'Step 3: Divide numerator and denominator by $g:',
      '  $n ÷ $g = $simplifiedN',
      '  $d ÷ $g = $simplifiedD',
      'Final Simplified Fraction: $simplifiedN / $simplifiedD',
    ];
  }

  List<String> _getArithmeticSteps(BigRational f1, BigRational f2, int op) {
    final a = f1.num;
    final b = f1.den;
    final c = f2.num;
    final d = f2.den;

    if (op == 0 || op == 1) {
      // + or -
      final isAdd = op == 0;
      final opSym = isAdd ? '+' : '−';
      final commonDenom = NumberTheory.lcm(b, d);
      final scale1 = commonDenom ~/ b;
      final scale2 = commonDenom ~/ d;
      final newNum1 = a * scale1;
      final newNum2 = c * scale2;
      final combinedNum = isAdd ? (newNum1 + newNum2) : (newNum1 - newNum2);
      final res = isAdd ? (f1 + f2) : (f1 - f2);
      final g = NumberTheory.gcd(combinedNum, commonDenom);

      return [
        'Problem: ($f1) $opSym ($f2)',
        'Step 1: Find least common denominator LCM of denominators $b and $d:',
        '  LCM($b, $d) = $commonDenom',
        'Step 2: Convert to equivalent fractions with denominator $commonDenom:',
        '  Fraction 1: ($a × $scale1) / ($b × $scale1) = $newNum1 / $commonDenom',
        '  Fraction 2: ($c × $scale2) / ($d × $scale2) = $newNum2 / $commonDenom',
        'Step 3: Combine numerators:',
        '  ($newNum1 $opSym $newNum2) / $commonDenom = $combinedNum / $commonDenom',
        if (g > BigInt.one) ...[
          'Step 4: Simplify by dividing by GCD($combinedNum, $commonDenom) = $g:',
          '  $combinedNum ÷ $g = ${res.num}',
          '  $commonDenom ÷ $g = ${res.den}',
        ],
        'Final Answer: $res',
        if (res.toMixedFraction().contains(' ')) 'Mixed Fraction: ${res.toMixedFraction()}',
      ];
    } else if (op == 2) {
      // *
      final rawNum = a * c;
      final rawDen = b * d;
      final res = f1 * f2;
      final g = NumberTheory.gcd(rawNum, rawDen);

      return [
        'Problem: ($f1) × ($f2)',
        'Step 1: Multiply numerators:',
        '  $a × $c = $rawNum',
        'Step 2: Multiply denominators:',
        '  $b × $d = $rawDen',
        'Raw product: $rawNum / $rawDen',
        if (g > BigInt.one) ...[
          'Step 3: Simplify by dividing by GCD($rawNum, $rawDen) = $g:',
          '  $rawNum ÷ $g = ${res.num}',
          '  $rawDen ÷ $g = ${res.den}',
        ],
        'Final Answer: $res',
        if (res.toMixedFraction().contains(' ')) 'Mixed Fraction: ${res.toMixedFraction()}',
      ];
    } else {
      // /
      final invNum = d;
      final invDen = c;
      final rawNum = a * invNum;
      final rawDen = b * invDen;
      final res = f1 / f2;
      final g = NumberTheory.gcd(rawNum, rawDen);

      return [
        'Problem: ($f1) ÷ ($f2)',
        'Step 1: Invert the divisor to multiply by reciprocal:',
        '  Reciprocal of $f2 is $invNum / $invDen',
        'Step 2: Multiply ($f1) × ($invNum / $invDen):',
        '  Numerator: $a × $invNum = $rawNum',
        '  Denominator: $b × $invDen = $rawDen',
        'Raw quotient: $rawNum / $rawDen',
        if (g > BigInt.one) ...[
          'Step 3: Simplify by dividing by GCD($rawNum, $rawDen) = $g:',
          '  $rawNum ÷ $g = ${res.num}',
          '  $rawDen ÷ $g = ${res.den}',
        ],
        'Final Answer: $res',
        if (res.toMixedFraction().contains(' ')) 'Mixed Fraction: ${res.toMixedFraction()}',
      ];
    }
  }

  Map<String, String> _calculate() {
    if (_selectedMode == 0) {
      // Simplify
      final n = BigInt.tryParse(_numController.text.trim());
      final d = BigInt.tryParse(_denController.text.trim());
      if (n == null || d == null) return {'Error': 'Please enter valid integers for numerator and denominator'};
      if (d == BigInt.zero) return {'Error': 'Denominator cannot be zero'};

      final frac = BigRational(n, d);
      final gcdVal = NumberTheory.gcd(n, d);

      return {
        'Simplified Fraction': frac.toString(),
        'Mixed Fraction': frac.toMixedFraction(),
        'Decimal Value': frac.toDouble().toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), ''),
        'Common Divisor (GCD)': gcdVal.toString(),
        'Original Fraction': '$n / $d',
      };
    } else if (_selectedMode == 1) {
      // Arithmetic
      try {
        final f1 = BigRational.parse(_f1Controller.text.trim());
        final f2 = BigRational.parse(_f2Controller.text.trim());
        BigRational result;
        String opSymbol;

        switch (_arithmeticOp) {
          case 0:
            result = f1 + f2;
            opSymbol = '+';
          case 1:
            result = f1 - f2;
            opSymbol = '−';
          case 2:
            result = f1 * f2;
            opSymbol = '×';
          case 3:
            result = f1 / f2;
            opSymbol = '÷';
          default:
            result = f1 + f2;
            opSymbol = '+';
        }

        return {
          'Result': result.toString(),
          'Mixed Fraction': result.toMixedFraction(),
          'Decimal Value': result.toDouble().toString(),
          'Operation': '$f1 $opSymbol $f2 = $result',
        };
      } catch (e) {
        return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter valid fractions (e.g. 3/4 or 1.5)')};
      }
    } else if (_selectedMode == 2) {
      // Fraction LCM/GCD
      try {
        final f1 = BigRational.parse(_f1Controller.text.trim());
        final f2 = BigRational.parse(_f2Controller.text.trim());

        final gcdResult = NumberTheory.fractionGcd(f1, f2);
        final lcmResult = NumberTheory.fractionLcm(f1, f2);

        return {
          'Fraction GCD': gcdResult.toString(),
          'Fraction LCM': lcmResult.toString(),
          'GCD Formula': 'GCD(a/b, c/d) = GCD(a, c) / LCM(b, d)',
          'LCM Formula': 'LCM(a/b, c/d) = LCM(a, c) / GCD(b, d)',
          'Inputs': '$f1 and $f2',
        };
      } catch (e) {
        return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter valid fractions (e.g. 3/4 or 1.5)')};
      }
    } else {
      // Ratio Simplifier
      final text = _ratioController.text;
      final parts = text.split(RegExp(r'[:,\s]+')).where((s) => s.trim().isNotEmpty);
      final numbers = <BigInt>[];
      for (final p in parts) {
        final parsed = BigInt.tryParse(p.trim());
        if (parsed != null) numbers.add(parsed);
      }

      if (numbers.length < 2) return {'Input Note': 'Please enter at least 2 numbers in ratio (e.g. 12 : 18 : 24)'};

      final simplified = NumberTheory.simplifyRatio(numbers);
      final g = NumberTheory.gcdMany(numbers);

      return {
        'Simplified Ratio': simplified.join(' : '),
        'Greatest Common Factor': g.toString(),
        'Original Ratio': numbers.join(' : '),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    List<String>? currentSteps;
    String modalTitle = 'Fraction Derivation';
    if (_selectedMode == 0) {
      final n = BigInt.tryParse(_numController.text.trim());
      final d = BigInt.tryParse(_denController.text.trim());
      if (n != null && d != null && d != BigInt.zero) {
        currentSteps = _getSimplifySteps(n, d);
        modalTitle = 'Fraction Simplification Steps';
      }
    } else if (_selectedMode == 1) {
      try {
        final f1 = BigRational.parse(_f1Controller.text.trim());
        final f2 = BigRational.parse(_f2Controller.text.trim());
        currentSteps = _getArithmeticSteps(f1, f2, _arithmeticOp);
        modalTitle = 'Fraction Arithmetic Steps';
      } catch (_) {}
    }

    return ToolScaffold(
      title: 'Fractions & Ratios',
      disclaimer: 'Calculations use exact rational arithmetic with zero rounding error. Fraction GCD/LCM applies the standard integer numerator/denominator definition.',
      children: [
        ToolModeSelector(
          modes: const ['Simplify', 'Arithmetic', 'Fraction LCM/GCD', 'Ratio Simplifier'],
          selected: _selectedMode,
          onChanged: (idx) => setState(() => _selectedMode = idx),
        ),
        const SizedBox(height: QSpacing.lg),

        if (_selectedMode == 0) ...[
          // Simplify inputs
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                  controller: _numController,
                  label: 'Numerator',
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: QSpacing.md),
                child: Text('/', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ToolTextField(
                  controller: _denController,
                  label: 'Denominator',
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ] else if (_selectedMode == 1 || _selectedMode == 2) ...[
          // Fraction 1 & 2 inputs
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                  controller: _f1Controller,
                  label: 'Fraction 1 (e.g. 2/3)',
                  keyboardType: TextInputType.text,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.md),
              Expanded(
                child: ToolTextField(
                  controller: _f2Controller,
                  label: 'Fraction 2 (e.g. 4/9)',
                  keyboardType: TextInputType.text,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          if (_selectedMode == 1) ...[
            const SizedBox(height: QSpacing.md),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('+')),
                ButtonSegment(value: 1, label: Text('−')),
                ButtonSegment(value: 2, label: Text('×')),
                ButtonSegment(value: 3, label: Text('÷')),
              ],
              selected: {_arithmeticOp},
              onSelectionChanged: (selected) => setState(() => _arithmeticOp = selected.first),
            ),
          ],
        ] else ...[
          // Ratio input
          ToolTextField(
            controller: _ratioController,
            label: 'Enter Ratio (e.g. 12 : 18 : 24)',
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() {}),
          ),
        ],

        if (currentSteps != null) ...[
          const SizedBox(height: QSpacing.md),
          ElevatedButton.icon(
            onPressed: () => _showStepModal(modalTitle, currentSteps!),
            icon: const Icon(Icons.format_list_numbered),
            label: const Text('View Step-by-Step Derivation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: QColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],

        const SizedBox(height: QSpacing.xl),
        ToolResultCard(
          title: 'Calculation Summary',
          results: results,
        ),
      ],
    );
  }
}
