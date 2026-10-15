// Qalculyn - Simultaneous Linear Equations Solver Screen
// Solves 2x2 and 3x3 systems with step-by-step Cramer's rule, elimination, and fraction representations

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/linear_system_solver.dart';
import '../../shared/tool_widgets.dart';

class LinearSystemScreen extends StatefulWidget {
  const LinearSystemScreen({super.key});

  @override
  State<LinearSystemScreen> createState() => _LinearSystemScreenState();
}

class _LinearSystemScreenState extends State<LinearSystemScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 2x2 inputs
  final _a1 = TextEditingController(text: '2');
  final _b1 = TextEditingController(text: '3');
  final _c1 = TextEditingController(text: '8');
  final _a2 = TextEditingController(text: '1');
  final _b2 = TextEditingController(text: '-1');
  final _c2 = TextEditingController(text: '-1');

  // 3x3 inputs
  final _a31 = TextEditingController(text: '1');
  final _b31 = TextEditingController(text: '1');
  final _c31 = TextEditingController(text: '1');
  final _d31 = TextEditingController(text: '6');

  final _a32 = TextEditingController(text: '0');
  final _b32 = TextEditingController(text: '2');
  final _c32 = TextEditingController(text: '5');
  final _d32 = TextEditingController(text: '-4');

  final _a33 = TextEditingController(text: '2');
  final _b33 = TextEditingController(text: '5');
  final _c33 = TextEditingController(text: '-1');
  final _d33 = TextEditingController(text: '27');

  LinearSystemResult? _result2x2;
  LinearSystemResult? _result3x3;
  String? _error2x2;
  String? _error3x3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _solve2x2();
    _solve3x3();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _a1.dispose(); _b1.dispose(); _c1.dispose();
    _a2.dispose(); _b2.dispose(); _c2.dispose();
    _a31.dispose(); _b31.dispose(); _c31.dispose(); _d31.dispose();
    _a32.dispose(); _b32.dispose(); _c32.dispose(); _d32.dispose();
    _a33.dispose(); _b33.dispose(); _c33.dispose(); _d33.dispose();
    super.dispose();
  }

  void _solve2x2() {
    try {
      final a1 = double.parse(_a1.text.trim());
      final b1 = double.parse(_b1.text.trim());
      final c1 = double.parse(_c1.text.trim());
      final a2 = double.parse(_a2.text.trim());
      final b2 = double.parse(_b2.text.trim());
      final c2 = double.parse(_c2.text.trim());

      setState(() {
        _result2x2 = LinearSystemSolver.solve2x2(a1, b1, c1, a2, b2, c2);
        _error2x2 = null;
      });
    } catch (e) {
      setState(() {
        _error2x2 = cleanMathErrorMessage(e, fallback: 'Please enter valid numbers for all coefficients');
        _result2x2 = null;
      });
    }
  }

  void _solve3x3() {
    try {
      final a1 = double.parse(_a31.text.trim());
      final b1 = double.parse(_b31.text.trim());
      final c1 = double.parse(_c31.text.trim());
      final d1 = double.parse(_d31.text.trim());

      final a2 = double.parse(_a32.text.trim());
      final b2 = double.parse(_b32.text.trim());
      final c2 = double.parse(_c32.text.trim());
      final d2 = double.parse(_d32.text.trim());

      final a3 = double.parse(_a33.text.trim());
      final b3 = double.parse(_b33.text.trim());
      final c3 = double.parse(_c33.text.trim());
      final d3 = double.parse(_d33.text.trim());

      setState(() {
        _result3x3 = LinearSystemSolver.solve3x3(
          a1, b1, c1, d1,
          a2, b2, c2, d2,
          a3, b3, c3, d3,
        );
        _error3x3 = null;
      });
    } catch (e) {
      setState(() {
        _error3x3 = cleanMathErrorMessage(e, fallback: 'Please enter valid numbers for all coefficients');
        _result3x3 = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simultaneous Equations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '2 Variables (x, y)'),
            Tab(text: '3 Variables (x, y, z)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _build2x2Tab(context),
          _build3x3Tab(context),
        ],
      ),
    );
  }

  Widget _build2x2Tab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.all(QSpacing.lg),
      children: [
        // Presets
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text('Presets: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ActionChip(
                label: const Text('Standard (1, 2)', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  _a1.text = '2'; _b1.text = '3'; _c1.text = '8';
                  _a2.text = '1'; _b2.text = '-1'; _c2.text = '-1';
                  _solve2x2();
                },
              ),
              const SizedBox(width: QSpacing.xs),
              ActionChip(
                label: const Text('Parallel (No Sol)', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  _a1.text = '2'; _b1.text = '4'; _c1.text = '6';
                  _a2.text = '1'; _b2.text = '2'; _c2.text = '8';
                  _solve2x2();
                },
              ),
              const SizedBox(width: QSpacing.xs),
              ActionChip(
                label: const Text('Fractional (1/3, 5/2)', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  _a1.text = '3'; _b1.text = '2'; _c1.text = '6';
                  _a2.text = '6'; _b2.text = '-4'; _c2.text = '-8';
                  _solve2x2();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: QSpacing.md),

        // System representation card
        Container(
          padding: const EdgeInsets.all(QSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? QColors.darkCard : QColors.lightCard,
            borderRadius: QRadius.borderRadiusLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter Equation Coefficients', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
              const SizedBox(height: QSpacing.md),

              // Eq 1 row
              Row(
                children: [
                  Expanded(child: _buildInput(_a1, 'a₁')),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('x +')),
                  Expanded(child: _buildInput(_b1, 'b₁')),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('y =')),
                  Expanded(child: _buildInput(_c1, 'c₁')),
                ],
              ),
              const SizedBox(height: QSpacing.md),

              // Eq 2 row
              Row(
                children: [
                  Expanded(child: _buildInput(_a2, 'a₂')),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('x +')),
                  Expanded(child: _b2Input()),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('y =')),
                  Expanded(child: _buildInput(_c2, 'c₂')),
                ],
              ),
              const SizedBox(height: QSpacing.md),

              ElevatedButton.icon(
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Solve System'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
                onPressed: _solve2x2,
              ),
            ],
          ),
        ),
        const SizedBox(height: QSpacing.lg),

        // Results
        if (_error2x2 != null)
          Container(
            padding: const EdgeInsets.all(QSpacing.md),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.12),
              borderRadius: QRadius.borderRadiusMd,
            ),
            child: Text(_error2x2!, style: const TextStyle(color: Colors.redAccent)),
          )
        else if (_result2x2 != null)
          _buildResultCard(context, _result2x2!),
      ],
    );
  }

  Widget _b2Input() => _buildInput(_b2, 'b₂');

  Widget _build3x3Tab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.all(QSpacing.lg),
      children: [
        // Presets
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text('Presets: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ActionChip(
                label: const Text('Standard (3, 2, 1)', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  _a31.text = '1'; _b31.text = '1'; _c31.text = '1'; _d31.text = '6';
                  _a32.text = '0'; _b32.text = '2'; _c32.text = '5'; _d32.text = '-4';
                  _a33.text = '2'; _b33.text = '5'; _c33.text = '-1'; _d33.text = '27';
                  _solve3x3();
                },
              ),
              const SizedBox(width: QSpacing.xs),
              ActionChip(
                label: const Text('Simple (1, 1, 1)', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  _a31.text = '1'; _b31.text = '0'; _c31.text = '0'; _d31.text = '1';
                  _a32.text = '0'; _b32.text = '1'; _c32.text = '0'; _d32.text = '1';
                  _a33.text = '0'; _b33.text = '0'; _c33.text = '1'; _d33.text = '1';
                  _solve3x3();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: QSpacing.md),

        Container(
          padding: const EdgeInsets.all(QSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? QColors.darkCard : QColors.lightCard,
            borderRadius: QRadius.borderRadiusLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter 3x3 Equation Coefficients', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
              const SizedBox(height: QSpacing.md),

              // Row 1
              _build3x3Row(_a31, 'a₁', _b31, 'b₁', _c31, 'c₁', _d31, 'd₁'),
              const SizedBox(height: 8),
              // Row 2
              _build3x3Row(_a32, 'a₂', _b32, 'b₂', _c32, 'c₂', _d32, 'd₂'),
              const SizedBox(height: 8),
              // Row 3
              _build3x3Row(_a33, 'a₃', _b33, 'b₃', _c33, 'c₃', _d33, 'd₃'),
              const SizedBox(height: QSpacing.md),

              ElevatedButton.icon(
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Solve 3x3 System'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                onPressed: _solve3x3,
              ),
            ],
          ),
        ),
        const SizedBox(height: QSpacing.lg),

        if (_error3x3 != null)
          Container(
            padding: const EdgeInsets.all(QSpacing.md),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.12),
              borderRadius: QRadius.borderRadiusMd,
            ),
            child: Text(_error3x3!, style: const TextStyle(color: Colors.redAccent)),
          )
        else if (_result3x3 != null)
          _buildResultCard(context, _result3x3!),
      ],
    );
  }

  Widget _build3x3Row(
    TextEditingController a, String la,
    TextEditingController b, String lb,
    TextEditingController c, String lc,
    TextEditingController d, String ld,
  ) {
    return Row(
      children: [
        Expanded(child: _buildInput(a, la)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Text('x+')),
        Expanded(child: _buildInput(b, lb)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Text('y+')),
        Expanded(child: _buildInput(c, lc)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: Text('z=')),
        Expanded(child: _buildInput(d, ld)),
      ],
    );
  }

  Widget _buildInput(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, LinearSystemResult res) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(QSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? QColors.darkCard : QColors.lightCard,
        borderRadius: QRadius.borderRadiusLg,
        border: Border.all(color: primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SOLUTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primary, letterSpacing: 1.0)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: res.status == SystemSolutionStatus.unique
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  res.status == SystemSolutionStatus.unique ? 'Consistent & Unique' : 'Special Case',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: res.status == SystemSolutionStatus.unique ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: QSpacing.sm),

          Text(
            res.statusDescription,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: QSpacing.md),

          // Values grid
          if (res.status == SystemSolutionStatus.unique)
            Wrap(
              spacing: QSpacing.md,
              runSpacing: QSpacing.sm,
              children: res.solution.entries.map((e) {
                final frac = res.exactFractions[e.key] ?? '${e.value}';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? QColors.darkSurfaceVariant : QColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${e.key} = ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary),
                      ),
                      Text(
                        frac,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (frac != e.value.toString())
                        Text(
                          ' (${e.value.toStringAsFixed(4)})',
                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: QSpacing.md),

          // Show step derivations button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.auto_awesome, size: 14),
                label: const Text('Cramer\'s Rule Steps', style: TextStyle(fontSize: 12)),
                onPressed: () => _showStepsModal(context, 'Cramer\'s Rule Derivation', res.cramerSteps),
              ),
              const SizedBox(width: QSpacing.xs),
              OutlinedButton.icon(
                icon: const Icon(Icons.alt_route, size: 14),
                label: const Text('Elimination Steps', style: TextStyle(fontSize: 12)),
                onPressed: () => _showStepsModal(context, 'Elimination Derivation', res.eliminationSteps),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStepsModal(BuildContext context, String title, List<String> steps) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(QSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: steps.length,
                  itemBuilder: (_, idx) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      steps[idx],
                      style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
