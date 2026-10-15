// Qalculyn - Algebra Toolkit & Equation Solver
// Solves linear and quadratic equations with exact discriminant, factors polynomials, and evaluates expressions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/big_rational.dart';
import '../../core/math/algebra_engine.dart';
import '../../shared/tool_widgets.dart';

class AlgebraScreen extends StatefulWidget {
  const AlgebraScreen({super.key});

  @override
  State<AlgebraScreen> createState() => _AlgebraScreenState();
}

class _AlgebraScreenState extends State<AlgebraScreen> {
  int _selectedMode = 0; // 0: Quadratic Solver, 1: Linear Solver, 2: Factoring, 3: Evaluator

  // Quadratic coefficients: a*x^2 + b*x + c = 0
  final _aController = TextEditingController(text: '1');
  final _bController = TextEditingController(text: '-5');
  final _cController = TextEditingController(text: '6');

  // Linear equation: ax + b = cx + d
  final _linAController = TextEditingController(text: '3');
  final _linBController = TextEditingController(text: '7');
  final _linCController = TextEditingController(text: '1');
  final _linDController = TextEditingController(text: '15');

  // Evaluator: P(x) at x = val
  final _polyController = TextEditingController(text: '2x^2 - 3x + 1');
  final _xValController = TextEditingController(text: '4');

  bool _showSteps = true;
  String _userExplanation = '';
  final _userExplanationController = TextEditingController();

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    _linAController.dispose();
    _linBController.dispose();
    _linCController.dispose();
    _linDController.dispose();
    _polyController.dispose();
    _xValController.dispose();
    _userExplanationController.dispose();
    super.dispose();
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
              'Add your personal notes, reminders, or step explanation:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: QSpacing.sm),
            TextField(
              controller: _userExplanationController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g. Remember to check discriminant Δ >= 0 for real roots...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _userExplanation = '');
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _userExplanation = _userExplanationController.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  void _setQuadExample(String a, String b, String c) {
    setState(() {
      _aController.text = a;
      _bController.text = b;
      _cController.text = c;
    });
  }

  Map<String, dynamic> _calculate() {
    if (_selectedMode == 0) {
      // Quadratic Solver
      try {
        final a = BigRational.parse(_aController.text.trim());
        final b = BigRational.parse(_bController.text.trim());
        final c = BigRational.parse(_cController.text.trim());

        final res = EquationSolver.solveQuadratic(a, b, c);
        final status = res['status'] as String;
        final steps = res['steps'] as List<String>;

        String rootDisplay;
        if (status == 'repeated') {
          rootDisplay = 'x = ${res['root1']} (repeated root)';
        } else if (status == 'real_exact') {
          rootDisplay = 'x₁ = ${res['root1']},  x₂ = ${res['root2']}';
        } else if (status == 'real_approx') {
          rootDisplay = 'x₁ ≈ ${(res['root1Double'] as double).toStringAsFixed(6)},  x₂ ≈ ${(res['root2Double'] as double).toStringAsFixed(6)}';
        } else if (status == 'complex') {
          final real = (res['realPart'] as double).toStringAsFixed(4);
          final imag = (res['imagPart'] as double).toStringAsFixed(4);
          rootDisplay = 'x = $real ± ${imag}i (Complex roots)';
        } else {
          rootDisplay = 'x = ${res['root']}';
        }

        return {
          'title': 'Quadratic Roots',
          'value': rootDisplay,
          'subtitle': 'Discriminant Δ = ${res['discriminant']}',
          'steps': steps,
        };
      } catch (e) {
        return {'error': cleanMathErrorMessage(e, fallback: 'Please enter valid coefficients')};
      }
    } else if (_selectedMode == 1) {
      // Linear Solver: ax + b = cx + d => (a - c)x = (d - b)
      try {
        final a = BigRational.parse(_linAController.text.trim());
        final b = BigRational.parse(_linBController.text.trim());
        final c = BigRational.parse(_linCController.text.trim());
        final d = BigRational.parse(_linDController.text.trim());

        final netA = a - c;
        final netB = b - d; // netA*x + netB = 0 => netA*x = -netB = (d - b)
        final res = EquationSolver.solveLinear(netA, netB);

        final status = res['status'] as String;
        if (status == 'single') {
          final root = res['root'] as BigRational;
          return {
            'title': 'Linear Solution',
            'value': 'x = $root',
            'subtitle': 'Decimal: ${root.toDouble()}',
            'steps': res['steps'] as List<String>,
          };
        } else {
          return {
            'title': 'Linear Solution',
            'value': status == 'infinite' ? 'Infinitely many solutions' : 'No solution (contradiction)',
            'subtitle': res['explanation'] as String,
            'steps': <String>[res['explanation'] as String],
          };
        }
      } catch (e) {
        return {'error': cleanMathErrorMessage(e, fallback: 'Please enter valid linear equation coefficients')};
      }
    } else if (_selectedMode == 2) {
      // Factoring
      try {
        final a = BigRational.parse(_aController.text.trim());
        final b = BigRational.parse(_bController.text.trim());
        final c = BigRational.parse(_cController.text.trim());

        final factored = EquationSolver.factorQuadratic(a, b, c);
        return {
          'title': 'Factored Form',
          'value': factored,
          'subtitle': 'Expression: ($a)x² + ($b)x + ($c)',
          'steps': <String>[
            'Original: ($a)x² + ($b)x + ($c)',
            'Factored: $factored',
          ],
        };
      } catch (e) {
        return {'error': cleanMathErrorMessage(e, fallback: 'Please enter valid quadratic coefficients')};
      }
    } else {
      // Polynomial Evaluator
      try {
        final poly = Polynomial.parse(_polyController.text.trim());
        final xVal = BigRational.parse(_xValController.text.trim());
        final result = poly.evaluate(xVal);

        return {
          'title': 'Evaluated Value P($xVal)',
          'value': result.toString(),
          'subtitle': 'Decimal: ${result.toDouble()}',
          'steps': <String>[
            'Polynomial: P(x) = $poly',
            'Substitution: x = $xVal',
            'Result: P($xVal) = $result',
          ],
        };
      } catch (e) {
        return {'error': cleanMathErrorMessage(e, fallback: 'Please enter a valid polynomial and x value')};
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final res = _calculate();
    final hasError = res.containsKey('error');

    return ToolScaffold(
      title: 'Algebra & Equations',
      disclaimer: 'Calculates exact roots using analytical formulas. Solves linear and quadratic equations over real and complex domains.',
      children: [
        ToolModeSelector(
          modes: const ['Quadratic Solver', 'Linear Solver', 'Factoring', 'P(x) Evaluator'],
          selected: _selectedMode,
          onChanged: (idx) => setState(() => _selectedMode = idx),
        ),
        const SizedBox(height: QSpacing.md),

        if (_selectedMode == 0 || _selectedMode == 2) ...[
          // Quadratic inputs a, b, c
          Wrap(
            spacing: QSpacing.sm,
            runSpacing: QSpacing.xs,
            children: [
              ActionChip(label: const Text('x² - 5x + 6 = 0'), onPressed: () => _setQuadExample('1', '-5', '6')),
              ActionChip(label: const Text('2x² + 4x - 6 = 0'), onPressed: () => _setQuadExample('2', '4', '-6')),
              ActionChip(label: const Text('x² + 4 = 0 (Complex)'), onPressed: () => _setQuadExample('1', '0', '4')),
            ],
          ),
          const SizedBox(height: QSpacing.md),
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                  controller: _aController,
                  label: 'a (x² coeff)',
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.sm),
              Expanded(
                child: ToolTextField(
                  controller: _bController,
                  label: 'b (x coeff)',
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.sm),
              Expanded(
                child: ToolTextField(
                  controller: _cController,
                  label: 'c (constant)',
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ] else if (_selectedMode == 1) ...[
          // Linear inputs: ax + b = cx + d
          Text('Equation form: ax + b = cx + d', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: QSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                  controller: _linAController,
                  label: 'a',
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.sm),
              Expanded(
                child: ToolTextField(
                  controller: _linBController,
                  label: 'b',
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: QSpacing.xs),
                child: Text('=', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ToolTextField(
                  controller: _linCController,
                  label: 'c',
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.sm),
              Expanded(
                child: ToolTextField(
                  controller: _linDController,
                  label: 'd',
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ] else ...[
          // Polynomial Evaluator inputs
          ToolTextField(
            controller: _polyController,
            label: 'Polynomial P(x) (e.g. 2x^2 - 3x + 1)',
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: QSpacing.md),
          ToolTextField(
            controller: _xValController,
            label: 'Evaluate at x =',
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            onChanged: (_) => setState(() {}),
          ),
        ],

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
                      res['title'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: QColors.primaryPurple,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copy',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: res['value'] as String));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: QSpacing.xs),
                SelectableText(
                  res['value'] as String,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: QSpacing.xs),
                Text(
                  res['subtitle'] as String,
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
              title: const Text('Analytical Solution Steps', style: TextStyle(fontWeight: FontWeight.w600)),
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
                    children: [
                      ...(res['steps'] as List<String>).map((step) {
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
                      }),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step Explanation',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.edit_note, size: 16),
                            label: Text(_userExplanation.isEmpty ? 'Add Explanation' : 'Edit Explanation', style: const TextStyle(fontSize: 12)),
                            onPressed: _showAddExplanationDialog,
                          ),
                        ],
                      ),
                      if (_userExplanation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(QSpacing.sm),
                          decoration: BoxDecoration(
                            color: isDark ? QColors.darkCard : QColors.lightCard,
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
