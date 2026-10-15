// Qalculyn - Prime Factorization & Divisors Screen
// Prime check, prime power factorization, divisor enumeration, and multiples generator

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_theory.dart';
import '../../shared/tool_widgets.dart';

class PrimeScreen extends StatefulWidget {
  const PrimeScreen({super.key});

  @override
  State<PrimeScreen> createState() => _PrimeScreenState();
}

class _PrimeScreenState extends State<PrimeScreen> {
  int _selectedMode = 0; // 0: Prime Factorization, 1: Divisors & Factors, 2: Multiples Generator
  final _inputController = TextEditingController(text: '360');
  int _multiplesCount = 10;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _setExample(String ex) {
    setState(() => _inputController.text = ex);
  }

  Map<String, dynamic> _calculate() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return {'error': 'Please enter an integer'};

    final n = BigInt.tryParse(text);
    if (n == null) return {'error': 'Invalid integer input'};

    final absN = n.abs();
    final isPr = NumberTheory.isPrime(absN);

    if (_selectedMode == 0) {
      // Prime Factorization
      if (absN <= BigInt.one) {
        return {
          'isPrime': false,
          'factorization': '$n is neither prime nor composite.',
          'details': {'Value': n.toString(), 'Classification': absN == BigInt.one ? 'Unit (neither prime nor composite)' : 'Zero'},
        };
      }

      final factors = NumberTheory.primeFactors(absN);
      final formatted = NumberTheory.formatPrimeFactors(factors);

      final breakdown = <String, String>{
        'Is Prime?': isPr ? 'YES (Prime Number)' : 'NO (Composite Number)',
        'Prime Factorization': formatted,
        'Distinct Primes': factors.length.toString(),
      };

      return {
        'isPrime': isPr,
        'factorization': formatted,
        'details': breakdown,
      };
    } else if (_selectedMode == 1) {
      // Divisors & Factors
      if (absN == BigInt.zero) {
        return {'error': '0 has infinitely many divisors'};
      }

      final divs = NumberTheory.divisors(absN);
      var sum = BigInt.zero;
      for (final d in divs) {
        sum += d;
      }

      return {
        'count': divs.length.toString(),
        'sum': sum.toString(),
        'divisors': divs.join(', '),
        'details': {
          'Number of Divisors τ(n)': divs.length.toString(),
          'Sum of Divisors σ(n)': sum.toString(),
          'Proper Divisors Sum': (sum - absN).toString(),
          'Is Perfect Number?': (sum - absN == absN) ? 'YES' : 'NO',
        },
      };
    } else {
      // Multiples Generator
      final multiples = <String>[];
      for (var i = 1; i <= _multiplesCount; i++) {
        multiples.add('${n * BigInt.from(i)}');
      }

      return {
        'multiples': multiples.join(', '),
        'details': {
          'Base Number': n.toString(),
          'Count': _multiplesCount.toString(),
          'Range': '1× to $_multiplesCount×',
        },
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final res = _calculate();
    final hasError = res.containsKey('error');

    return ToolScaffold(
      title: 'Primes & Divisors',
      disclaimer: 'Uses deterministic and Miller-Rabin tests for arbitrary-precision integers.',
      children: [
        ToolModeSelector(
          modes: const ['Factorization', 'Divisors & Factors', 'Multiples Generator'],
          selected: _selectedMode,
          onChanged: (idx) => setState(() => _selectedMode = idx),
        ),
        const SizedBox(height: QSpacing.md),

        Wrap(
          spacing: QSpacing.sm,
          runSpacing: QSpacing.xs,
          children: [
            ActionChip(label: const Text('360'), onPressed: () => _setExample('360')),
            ActionChip(label: const Text('997 (Prime)'), onPressed: () => _setExample('997')),
            ActionChip(label: const Text('28 (Perfect)'), onPressed: () => _setExample('28')),
            ActionChip(label: const Text('7560'), onPressed: () => _setExample('7560')),
          ],
        ),
        const SizedBox(height: QSpacing.md),

        ToolTextField(
          controller: _inputController,
          label: 'Enter Integer N',
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          onChanged: (_) => setState(() {}),
        ),

        if (_selectedMode == 2) ...[
          const SizedBox(height: QSpacing.md),
          ToolDropdown<int>(
            label: 'Number of multiples',
            value: _multiplesCount,
            items: const [10, 25, 50, 100],
            labelBuilder: (v) => 'First $v multiples',
            onChanged: (v) {
              if (v != null) setState(() => _multiplesCount = v);
            },
          ),
        ],

        const SizedBox(height: QSpacing.lg),

        if (!hasError) ...[
          ToolResultCard(
            title: _selectedMode == 0
                ? 'Factorization Summary'
                : (_selectedMode == 1 ? 'Divisor Analysis' : 'Multiples Sequence'),
            results: res['details'] as Map<String, String>,
          ),
          const SizedBox(height: QSpacing.lg),

          if (_selectedMode == 1 && res.containsKey('divisors')) ...[
            Container(
              padding: const EdgeInsets.all(QSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? QColors.darkCard : QColors.lightElevated,
                borderRadius: QRadius.borderRadiusLg,
                border: Border.all(color: QColors.primaryPurple.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Positive Divisors (Sorted)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: QColors.primaryPurple,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'Copy divisors',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: res['divisors'] as String));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Divisors copied')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: QSpacing.xs),
                  SelectableText(
                    res['divisors'] as String,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ],

          if (_selectedMode == 2 && res.containsKey('multiples')) ...[
            Container(
              padding: const EdgeInsets.all(QSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? QColors.darkCard : QColors.lightElevated,
                borderRadius: QRadius.borderRadiusLg,
                border: Border.all(color: QColors.primaryPurple.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Generated Multiples',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: QColors.primaryPurple,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'Copy multiples',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: res['multiples'] as String));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Multiples copied')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: QSpacing.xs),
                  SelectableText(
                    res['multiples'] as String,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ] else ...[
          ToolResultCard(results: {'Error': res['error'] as String}),
        ],
      ],
    );
  }
}
