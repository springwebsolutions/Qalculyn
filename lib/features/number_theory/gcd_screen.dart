// Qalculyn - GCD / HCF Calculator
// Computes Greatest Common Divisor / Highest Common Factor with Euclidean division steps

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_theory.dart';
import '../../shared/tool_widgets.dart';

class GcdScreen extends StatefulWidget {
  const GcdScreen({super.key});

  @override
  State<GcdScreen> createState() => _GcdScreenState();
}

class _GcdScreenState extends State<GcdScreen> {
  final _inputController = TextEditingController(text: '252, 105');
  bool _showSteps = true;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  List<BigInt> _parseInputs() {
    final text = _inputController.text;
    final parts = text.split(RegExp(r'[,;\s]+')).where((s) => s.trim().isNotEmpty);
    final numbers = <BigInt>[];
    for (final p in parts) {
      final parsed = BigInt.tryParse(p.trim());
      if (parsed != null) {
        numbers.add(parsed);
      }
    }
    return numbers;
  }

  Map<String, dynamic> _calculate(List<BigInt> numbers) {
    if (numbers.isEmpty) {
      return {'error': 'Please enter at least one integer'};
    }
    if (numbers.length == 1) {
      return {
        'gcd': numbers[0].abs(),
        'explanation': 'GCD of a single integer is its absolute value: |${numbers[0]}| = ${numbers[0].abs()}',
        'steps': <String>['Single input: GCD(${numbers[0]}) = ${numbers[0].abs()}'],
      };
    }

    final detailedSteps = <String>[];
    detailedSteps.add('Inputs: ${numbers.join(", ")}');

    if (numbers.length == 2) {
      final res = NumberTheory.gcdDetailed(numbers[0], numbers[1]);
      detailedSteps.add('\nEuclidean Algorithm Steps:');
      if (res.steps.isEmpty) {
        detailedSteps.add('• ${res.explanation}');
      } else {
        for (var i = 0; i < res.steps.length; i++) {
          final s = res.steps[i];
          detailedSteps.add('Step ${i + 1}: ${s.a} = (${s.b} × ${s.quotient}) + ${s.remainder}');
        }
      }

      // Alternative Prime Factorization method
      detailedSteps.add('\nAlternative Method: Prime Factorization:');
      final f1 = NumberTheory.primeFactors(numbers[0]);
      final f2 = NumberTheory.primeFactors(numbers[1]);
      detailedSteps.add('• ${numbers[0]} = ${NumberTheory.formatPrimeFactors(f1)}');
      detailedSteps.add('• ${numbers[1]} = ${NumberTheory.formatPrimeFactors(f2)}');

      final commonPrimes = f1.keys.where((p) => f2.containsKey(p)).toList()..sort();
      if (commonPrimes.isEmpty) {
        detailedSteps.add('• No shared prime factors => Numbers are co-prime (GCD = 1).');
      } else {
        final gTerms = <String>[];
        for (final p in commonPrimes) {
          final exp1 = f1[p]!;
          final exp2 = f2[p]!;
          final minExp = exp1 < exp2 ? exp1 : exp2;
          gTerms.add('$p${minExp > 1 ? "^$minExp" : ""}');
          detailedSteps.add('• Common prime $p: min exponent is $minExp');
        }
        detailedSteps.add('• Common factor product: ${gTerms.join(" × ")} = ${res.gcd}');
      }

      return {
        'gcd': res.gcd,
        'explanation': res.explanation,
        'steps': detailedSteps,
      };
    } else {
      // Multiple inputs
      final resultGcd = NumberTheory.gcdMany(numbers);
      detailedSteps.add('\nPairwise Euclidean Reduction:');
      var runningGcd = numbers[0].abs();
      for (var i = 1; i < numbers.length; i++) {
        final next = numbers[i].abs();
        final prev = runningGcd;
        runningGcd = NumberTheory.gcd(runningGcd, next);
        detailedSteps.add('• GCD($prev, $next) = $runningGcd');
      }

      return {
        'gcd': resultGcd,
        'explanation': 'GCD(${numbers.join(", ")}) = $resultGcd',
        'steps': detailedSteps,
      };
    }
  }

  void _setExample(String ex) {
    setState(() {
      _inputController.text = ex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final numbers = _parseInputs();
    final res = _calculate(numbers);
    final hasError = res.containsKey('error');

    return ToolScaffold(
      title: 'GCD / HCF Calculator',
      disclaimer: 'Greatest Common Divisor (GCD) and Highest Common Factor (HCF) are identical mathematical operations.',
      children: [
        Wrap(
          spacing: QSpacing.sm,
          runSpacing: QSpacing.xs,
          children: [
            ActionChip(
              label: const Text('252, 105'),
              onPressed: () => _setExample('252, 105'),
            ),
            ActionChip(
              label: const Text('54, 24'),
              onPressed: () => _setExample('54, 24'),
            ),
            ActionChip(
              label: const Text('48, 72, 120'),
              onPressed: () => _setExample('48, 72, 120'),
            ),
            ActionChip(
              label: const Text('-84, 140'),
              onPressed: () => _setExample('-84, 140'),
            ),
          ],
        ),
        const SizedBox(height: QSpacing.md),

        ToolTextField(
          controller: _inputController,
          label: 'Enter integers (comma or space separated)',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Greatest Common Divisor (GCD / HCF)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: QColors.primaryPurple,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copy result',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: res['gcd'].toString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('GCD copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: QSpacing.xs),
                SelectableText(
                  res['gcd'].toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: QSpacing.xs),
                Text(
                  res['explanation'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.lg),

          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: _showSteps,
              title: const Text('Euclidean & Factorization Steps', style: TextStyle(fontWeight: FontWeight.w600)),
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
}
