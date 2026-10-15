// Qalculyn - Number Properties Screen
// Parity, Perfect square/cube, Divisibility rules, and Modulo/Remainder arithmetic

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_theory.dart';
import '../../shared/tool_widgets.dart';

class NumberPropertiesScreen extends StatefulWidget {
  const NumberPropertiesScreen({super.key});

  @override
  State<NumberPropertiesScreen> createState() => _NumberPropertiesScreenState();
}

class _NumberPropertiesScreenState extends State<NumberPropertiesScreen> {
  final _numController = TextEditingController(text: '144');
  final _modController = TextEditingController(text: '7');

  @override
  void dispose() {
    _numController.dispose();
    _modController.dispose();
    super.dispose();
  }

  void _setExample(String n, String m) {
    setState(() {
      _numController.text = n;
      _modController.text = m;
    });
  }

  Map<String, String> _calculate() {
    final textN = _numController.text.trim();
    final textM = _modController.text.trim();

    if (textN.isEmpty) return {'Error': 'Please enter an integer'};
    final n = BigInt.tryParse(textN);
    if (n == null) return {'Error': 'Invalid integer input'};

    final m = textM.isNotEmpty ? BigInt.tryParse(textM) : null;

    final isEven = n % BigInt.two == BigInt.zero;
    final (isSq, sqRoot) = NumberTheory.isPerfectSquare(n);
    final (isCube, cubeRoot) = NumberTheory.isPerfectCube(n);

    final results = <String, String>{
      'Parity': isEven ? 'Even number' : 'Odd number',
      'Sign': n > BigInt.zero ? 'Positive (+)' : (n < BigInt.zero ? 'Negative (−)' : 'Zero (0)'),
      'Perfect Square?': isSq ? 'YES (√$n = $sqRoot)' : 'NO',
      'Perfect Cube?': isCube ? 'YES (∛$n = $cubeRoot)' : 'NO',
    };

    if (m != null && m != BigInt.zero) {
      final quotient = n ~/ m;
      final remainder = n % m;
      // Euclidean remainder (always non-negative)
      var euclideanRem = remainder;
      if (euclideanRem < BigInt.zero) {
        euclideanRem += m.abs();
      }

      results['Quotient (n ÷ m)'] = quotient.toString();
      results['Remainder (n % m)'] = remainder.toString();
      results['Euclidean Modulo (r ≥ 0)'] = euclideanRem.toString();
      results['Divisibility by $m'] = (remainder == BigInt.zero) ? 'Divisible (No remainder)' : 'Not divisible';
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    return ToolScaffold(
      title: 'Number Properties',
      disclaimer: 'Arbitrary-precision integer analysis including parity, perfect powers, and modular arithmetic.',
      children: [
        Wrap(
          spacing: QSpacing.sm,
          runSpacing: QSpacing.xs,
          children: [
            ActionChip(label: const Text('144 & 7'), onPressed: () => _setExample('144', '7')),
            ActionChip(label: const Text('1728 (Cube)'), onPressed: () => _setExample('1728', '12')),
            ActionChip(label: const Text('-49 & 5'), onPressed: () => _setExample('-49', '5')),
            ActionChip(label: const Text('1024 & 16'), onPressed: () => _setExample('1024', '16')),
          ],
        ),
        const SizedBox(height: QSpacing.md),

        ToolTextField(
          controller: _numController,
          label: 'Enter Integer N',
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _modController,
          label: 'Enter Modulus / Divisor M (Optional)',
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.xl),

        ToolResultCard(
          title: 'Properties & Modular Breakdown',
          results: results,
        ),
      ],
    );
  }
}
