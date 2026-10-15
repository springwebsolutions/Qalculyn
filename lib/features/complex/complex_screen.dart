// Qalculyn - Complex Number Calculator
// Rectangular and polar complex number arithmetic, pure mathematical steps, and user explanation system

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/complex_number.dart';
import '../../shared/tool_widgets.dart';

class ComplexScreen extends StatefulWidget {
  const ComplexScreen({super.key});

  @override
  State<ComplexScreen> createState() => _ComplexScreenState();
}

class _ComplexScreenState extends State<ComplexScreen> {
  final _z1Controller = TextEditingController(text: '3 + 4i');
  final _z2Controller = TextEditingController(text: '1 - 2i');
  int _operation = 0; // 0: +, 1: -, 2: *, 3: /, 4: Power, 5: Sqrt
  bool _showExplanation = false;

  String _userExplanation = '';
  final _userExplanationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserExplanation();
  }

  Future<void> _loadUserExplanation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userExplanation = prefs.getString('complex_user_explanation') ?? '';
      _userExplanationController.text = _userExplanation;
    });
  }

  Future<void> _saveUserExplanation(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('complex_user_explanation', text);
    setState(() {
      _userExplanation = text;
    });
  }

  @override
  void dispose() {
    _z1Controller.dispose();
    _z2Controller.dispose();
    _userExplanationController.dispose();
    super.dispose();
  }

  void _setExample(String z1, String z2) {
    setState(() {
      _z1Controller.text = z1;
      _z2Controller.text = z2;
    });
  }

  Map<String, dynamic> _calculate() {
    try {
      final z1 = Complex.parse(_z1Controller.text);
      final z2 = Complex.parse(_z2Controller.text);
      Complex res;
      String opName;
      final steps = <String>[];
      String defaultExplanation;

      final a = z1.real;
      final b = z1.imag;
      final c = z2.real;
      final d = z2.imag;

      switch (_operation) {
        case 0:
          // Addition: (a + bi) + (c + di) = (a + c) + (b + d)i
          res = z1 + z2;
          opName = '($z1) + ($z2)';
          steps.add('1. ($z1) + ($z2)');
          steps.add('2. ($a + $c) + ($b + $d)i');
          steps.add('3. $res');
          defaultExplanation =
              'Formula: (a + bi) + (c + di) = (a + c) + (b + d)i\nGroup and sum the real parts together, then group and sum the imaginary parts together.';

        case 1:
          // Subtraction: (a + bi) - (c + di) = (a - c) + (b - d)i
          res = z1 - z2;
          opName = '($z1) − ($z2)';
          steps.add('1. ($z1) − ($z2)');
          steps.add('2. ($a − $c) + ($b − $d)i');
          steps.add('3. $res');
          defaultExplanation =
              'Formula: (a + bi) − (c + di) = (a − c) + (b − d)i\nSubtract the corresponding real part and imaginary part.';

        case 2:
          // Multiplication: (a + bi)(c + di) = ac + adi + bci + bdi^2 = (ac - bd) + (ad + bc)i
          res = z1 * z2;
          opName = '($z1) × ($z2)';
          steps.add('1. ($z1) × ($z2)');
          steps.add('2. ($a)($c) + ($a)(${d}i) + (${b}i)($c) + (${b}i)(${d}i)');
          steps.add('3. ${a * c} + ${a * d}i + ${b * c}i + ${b * d}i²');
          steps.add('4. ${a * c} + ${a * d + b * c}i + (${b * d})(-1)');
          steps.add('5. (${a * c} − ${b * d}) + (${a * d + b * c})i');
          steps.add('6. $res');
          defaultExplanation =
              'Formula: (a + bi)(c + di) = (ac − bd) + (ad + bc)i\nExpand terms using the FOIL method, then simplify using the fundamental identity i² = −1.';

        case 3:
          // Division: (a + bi)/(c + di)
          if (c == 0 && d == 0) throw const FormatException('Division by zero complex number');
          res = z1 / z2;
          opName = '($z1) ÷ ($z2)';
          final denom = c * c + d * d;
          steps.add('1. ($z1) / ($z2)');
          steps.add('2. [($z1) × ($c − ${d}i)] / [($z2) × ($c − ${d}i)]');
          steps.add('3. [(${a * c + b * d}) + (${b * c - a * d})i] / [($c)² + ($d)²]');
          steps.add('4. [(${a * c + b * d}) + (${b * c - a * d})i] / $denom');
          steps.add('5. ${((a * c + b * d) / denom).toStringAsFixed(4)} + ${((b * c - a * d) / denom).toStringAsFixed(4)}i');
          steps.add('6. $res');
          defaultExplanation =
              'Formula: (a + bi) / (c + di) = [(ac + bd) + (bc − ad)i] / (c² + d²)\nMultiply numerator and denominator by the complex conjugate of the denominator (c − di) to rationalize the denominator into a real number.';

        case 4:
          // Power: z^n via polar form and De Moivre's theorem
          final n = z2.real;
          res = z1.pow(n);
          opName = '($z1) ^ $n';
          final r = z1.modulus;
          final theta = z1.argument;
          steps.add('1. ($z1) ^ $n');
          steps.add('2. r = √[($a)² + ($b)²] = ${r.toStringAsFixed(4)},  θ = atan2($b, $a) = ${theta.toStringAsFixed(4)} rad');
          steps.add('3. z = ${r.toStringAsFixed(4)} × [cos(${theta.toStringAsFixed(4)}) + i sin(${theta.toStringAsFixed(4)})]');
          steps.add('4. z^$n = (${r.toStringAsFixed(4)})^$n × [cos($n × ${theta.toStringAsFixed(4)}) + i sin($n × ${theta.toStringAsFixed(4)})]');
          steps.add('5. ${(res.modulus).toStringAsFixed(4)} × [cos(${(theta * n).toStringAsFixed(4)}) + i sin(${(theta * n).toStringAsFixed(4)})]');
          steps.add('6. $res');
          defaultExplanation =
              'De Moivre\'s Theorem: [r(cos θ + i sin θ)]ⁿ = rⁿ [cos(nθ) + i sin(nθ)]\nConvert the complex base into polar form (r, θ), raise the modulus to exponent n, and multiply the angle by n.';

        case 5:
          // Principal square root
          res = z1.sqrt();
          opName = '√($z1)';
          final r = z1.modulus;
          final theta = z1.argument;
          steps.add('1. √($z1)');
          steps.add('2. r = |z| = ${r.toStringAsFixed(4)},  θ = arg(z) = ${theta.toStringAsFixed(4)} rad');
          steps.add('3. √z = √(${r.toStringAsFixed(4)}) × [cos(${theta.toStringAsFixed(4)} / 2) + i sin(${theta.toStringAsFixed(4)} / 2)]');
          steps.add('4. ${(math.sqrt(r)).toStringAsFixed(4)} × [cos(${(theta / 2).toStringAsFixed(4)}) + i sin(${(theta / 2).toStringAsFixed(4)})]');
          steps.add('5. $res');
          defaultExplanation =
              'Principal Square Root: √z = √r [cos(θ/2) + i sin(θ/2)]\nThe modulus is square-rooted and the argument is halved.';

        default:
          res = z1 + z2;
          opName = '($z1) + ($z2)';
          defaultExplanation = '';
      }

      final summary = {
        'Result (Rectangular)': res.toString(),
        'Result (Polar)': res.toPolarString(),
        'Operation': '$opName = $res',
        'z1 Modulus |z1|': z1.modulus.toStringAsFixed(4),
        'z1 Argument': '${z1.argumentDegrees.toStringAsFixed(2)}° (${z1.argument.toStringAsFixed(4)} rad)',
        'z1 Conjugate z1*': z1.conjugate().toString(),
      };

      return {
        'summary': summary,
        'steps': steps,
        'defaultExplanation': defaultExplanation,
      };
    } catch (e) {
      return {'error': cleanMathErrorMessage(e, fallback: 'Please enter valid complex numbers (e.g. 3 + 4i)')};
    }
  }

  void _showAddExplanationDialog() {
    _userExplanationController.text = _userExplanation;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add / Edit Custom Explanation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add your personal study notes, reminders, or step explanation for complex problems:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: QSpacing.md),
            TextField(
              controller: _userExplanationController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your custom explanation or notes...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (_userExplanation.isNotEmpty)
            TextButton(
              onPressed: () {
                _saveUserExplanation('');
                Navigator.pop(ctx);
              },
              child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
            ),
          ElevatedButton(
            onPressed: () {
              _saveUserExplanation(_userExplanationController.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final res = _calculate();
    final hasError = res.containsKey('error');

    return ToolScaffold(
      title: 'Complex Numbers',
      disclaimer: 'Pure calculation steps without embedded wordy commentary. Tap the Explanation button to reveal theory or attach notes.',
      children: [
        Wrap(
          spacing: QSpacing.sm,
          runSpacing: QSpacing.xs,
          children: [
            ActionChip(label: const Text('(3 + 4i) × (1 - 2i)'), onPressed: () => _setExample('3 + 4i', '1 - 2i')),
            ActionChip(label: const Text('(3 + 4i) ÷ (1 - 2i)'), onPressed: () => _setExample('3 + 4i', '1 - 2i')),
            ActionChip(label: const Text('√(-16)'), onPressed: () => _setExample('-16', '0')),
            ActionChip(label: const Text('(3 + 4i)^2'), onPressed: () => _setExample('3 + 4i', '2')),
          ],
        ),
        const SizedBox(height: QSpacing.md),

        ToolTextField(
          controller: _z1Controller,
          label: 'Complex number z1 (e.g. 3 + 4i)',
          keyboardType: TextInputType.text,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),

        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('+')),
            ButtonSegment(value: 1, label: Text('−')),
            ButtonSegment(value: 2, label: Text('×')),
            ButtonSegment(value: 3, label: Text('÷')),
            ButtonSegment(value: 4, label: Text('z1^n')),
            ButtonSegment(value: 5, label: Text('√z1')),
          ],
          selected: {_operation},
          onSelectionChanged: (selected) => setState(() => _operation = selected.first),
        ),
        const SizedBox(height: QSpacing.md),

        if (_operation != 5) ...[
          ToolTextField(
            controller: _z2Controller,
            label: _operation == 4 ? 'Exponent n (real number)' : 'Complex number z2 (e.g. 1 - 2i)',
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: QSpacing.lg),
        ],

        if (!hasError) ...[
          // Result Summary Card
          ToolResultCard(
            title: 'Complex Arithmetic Summary',
            results: res['summary'] as Map<String, String>,
          ),
          const SizedBox(height: QSpacing.lg),

          // Pure Mathematical Steps Card
          Container(
            decoration: BoxDecoration(
              color: isDark ? QColors.darkCard : QColors.lightElevated,
              borderRadius: QRadius.borderRadiusLg,
              border: Border.all(color: QColors.primaryPurple.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with copy and explanation button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: QSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.format_list_numbered, size: 18, color: QColors.primaryPurple),
                          const SizedBox(width: QSpacing.xs),
                          Text(
                            'Calculation Steps',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Copy Steps
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copy steps',
                            onPressed: () {
                              final stepsText = (res['steps'] as List<String>).join('\n');
                              Clipboard.setData(ClipboardData(text: stepsText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Steps copied to clipboard')),
                              );
                            },
                          ),
                          // Explanation Button
                          OutlinedButton.icon(
                            icon: Icon(_showExplanation ? Icons.visibility_off : Icons.help_outline, size: 14),
                            label: Text(_showExplanation ? 'Hide Explanation' : 'Explanation', style: const TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: QSpacing.sm),
                            ),
                            onPressed: () => setState(() => _showExplanation = !_showExplanation),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Pure steps without explanatory clutter
                Padding(
                  padding: const EdgeInsets.all(QSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (res['steps'] as List<String>).map((step) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SelectableText(
                          step,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Conditional Explanation Section
                if (_showExplanation) ...[
                  const Divider(height: 1),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(QSpacing.md),
                    decoration: BoxDecoration(
                      color: QColors.primaryPurple.withValues(alpha: 0.06),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(QRadius.lg)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mathematical Rule / Concept',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: QColors.primaryPurple,
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.edit_note, size: 16),
                              label: Text(_userExplanation.isEmpty ? 'Add Note' : 'Edit Note', style: const TextStyle(fontSize: 12)),
                              onPressed: _showAddExplanationDialog,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          res['defaultExplanation'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        // Display user's custom note if added
                        if (_userExplanation.isNotEmpty) ...[
                          const SizedBox(height: QSpacing.md),
                          Container(
                            padding: const EdgeInsets.all(QSpacing.sm),
                            decoration: BoxDecoration(
                              color: isDark ? QColors.darkSurfaceVariant : QColors.lightSurface,
                              borderRadius: QRadius.borderRadiusSm,
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.sticky_note_2_outlined, size: 14, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Text('Your Custom Note:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                SelectableText(
                                  _userExplanation,
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
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
}
