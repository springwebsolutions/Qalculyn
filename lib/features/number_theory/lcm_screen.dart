// Qalculyn - LCM Calculator
// Computes Least Common Multiple for 2 or more integers with step-by-step prime factorization

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_theory.dart';
import '../../shared/tool_widgets.dart';

class LcmScreen extends StatefulWidget {
  const LcmScreen({super.key});

  @override
  State<LcmScreen> createState() => _LcmScreenState();
}

class _LcmScreenState extends State<LcmScreen> {
  final _inputController = TextEditingController(text: '12, 18, 24');
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
        'lcm': numbers[0].abs(),
        'explanation': 'LCM of a single integer is its absolute value: |${numbers[0]}| = ${numbers[0].abs()}',
        'steps': <String>['Single input: LCM(${numbers[0]}) = ${numbers[0].abs()}'],
      };
    }

    // Check zero rule
    if (numbers.any((n) => n == BigInt.zero)) {
      return {
        'lcm': BigInt.zero,
        'explanation': 'LCM is 0 because at least one input is 0. By integer definition, any common multiple with 0 is 0.',
        'steps': <String>[
          'Input contains zero: ${numbers.join(", ")}',
          'Standard convention: If any a_i = 0, then LCM(a_1, ..., a_n) = 0.',
        ],
      };
    }

    final detailedSteps = <String>[];
    detailedSteps.add('Inputs: ${numbers.join(", ")}');

    // Prime factorizations
    detailedSteps.add('\nPrime Factorization of each input:');
    final allPrimes = <BigInt>{};
    final maxPrimePowers = <BigInt, int>{};

    for (final n in numbers) {
      final factors = NumberTheory.primeFactors(n);
      detailedSteps.add('• $n = ${NumberTheory.formatPrimeFactors(factors)}');
      for (final entry in factors.entries) {
        allPrimes.add(entry.key);
        final currentMax = maxPrimePowers[entry.key] ?? 0;
        if (entry.value > currentMax) {
          maxPrimePowers[entry.key] = entry.value;
        }
      }
    }

    // Step by step LCM calculation via pairwise or prime powers
    final resultLcm = NumberTheory.lcmMany(numbers);

    detailedSteps.add('\nMethod: Maximum power of every prime factor:');
    final formulaParts = <String>[];
    for (final p in (allPrimes.toList()..sort())) {
      final maxP = maxPrimePowers[p] ?? 1;
      formulaParts.add('$p${maxP > 1 ? "^$maxP" : ""}');
      detailedSteps.add('• Prime $p: max exponent is $maxP');
    }

    detailedSteps.add('LCM = ${formulaParts.join(" × ")} = $resultLcm');

    // Pairwise verification
    var runningLcm = numbers[0].abs();
    detailedSteps.add('\nPairwise Reduction:');
    for (var i = 1; i < numbers.length; i++) {
      final next = numbers[i].abs();
      final prev = runningLcm;
      runningLcm = NumberTheory.lcm(runningLcm, next);
      detailedSteps.add('• LCM($prev, $next) = ($prev × $next) / GCD($prev, $next) = $runningLcm');
    }

    return {
      'lcm': resultLcm,
      'explanation': 'LCM(${numbers.join(", ")}) = $resultLcm',
      'steps': detailedSteps,
      'factors': maxPrimePowers,
    };
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
      title: 'LCM Calculator',
      disclaimer: 'Overflow-safe BigInt arithmetic. If any input is 0, LCM is 0 by mathematical convention.',
      children: [
        // Example chips
        Wrap(
          spacing: QSpacing.sm,
          runSpacing: QSpacing.xs,
          children: [
            ActionChip(
              label: const Text('12, 18, 24'),
              onPressed: () => _setExample('12, 18, 24'),
            ),
            ActionChip(
              label: const Text('45, 60'),
              onPressed: () => _setExample('45, 60'),
            ),
            ActionChip(
              label: const Text('14, 21, 35'),
              onPressed: () => _setExample('14, 21, 35'),
            ),
            ActionChip(
              label: const Text('-16, 24'),
              onPressed: () => _setExample('-16, 24'),
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

        // Result Card
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
                      'Least Common Multiple (LCM)',
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
                        Clipboard.setData(ClipboardData(text: res['lcm'].toString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('LCM copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: QSpacing.xs),
                SelectableText(
                  res['lcm'].toString(),
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

          // Steps Expander
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: _showSteps,
              title: const Text('Step-by-Step Solution', style: TextStyle(fontWeight: FontWeight.w600)),
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
