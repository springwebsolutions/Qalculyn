// Qalculyn - Polynomial Long Division Screen
// Step-by-step long division and synthetic division tableau viewer

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/polynomial_division.dart';
import '../../shared/tool_widgets.dart';

class PolynomialDivisionScreen extends StatefulWidget {
  const PolynomialDivisionScreen({super.key});

  @override
  State<PolynomialDivisionScreen> createState() => _PolynomialDivisionScreenState();
}

class _PolynomialDivisionScreenState extends State<PolynomialDivisionScreen> {
  final _dividendController = TextEditingController(text: '2x^3 - 3x^2 + 4x - 5');
  final _divisorController = TextEditingController(text: 'x - 2');

  PolynomialDivisionResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _computeDivision();
  }

  @override
  void dispose() {
    _dividendController.dispose();
    _divisorController.dispose();
    super.dispose();
  }

  void _computeDivision() {
    try {
      final divStr = _dividendController.text.trim();
      final dvrStr = _divisorController.text.trim();

      if (divStr.isEmpty || dvrStr.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter both dividend and divisor polynomials';
          _result = null;
        });
        return;
      }

      final res = PolynomialDivisionEngine.divide(divStr, dvrStr);
      setState(() {
        _result = res;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = cleanMathErrorMessage(e, fallback: 'Please check your polynomial expression (e.g. 2x^3 - 4x + 1)');
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polynomial Division'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(QSpacing.lg),
        children: [
          // Preset Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Presets: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ActionChip(
                  label: const Text('(2x³-3x²+4x-5) ÷ (x-2)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    _dividendController.text = '2x^3 - 3x^2 + 4x - 5';
                    _divisorController.text = 'x - 2';
                    _computeDivision();
                  },
                ),
                const SizedBox(width: QSpacing.xs),
                ActionChip(
                  label: const Text('(x³ - 8) ÷ (x - 2)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    _dividendController.text = 'x^3 - 8';
                    _divisorController.text = 'x - 2';
                    _computeDivision();
                  },
                ),
                const SizedBox(width: QSpacing.xs),
                ActionChip(
                  label: const Text('(x⁴ - 1) ÷ (x² + 1)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    _dividendController.text = 'x^4 - 1';
                    _divisorController.text = 'x^2 + 1';
                    _computeDivision();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.md),

          // Input Card
          Container(
            padding: const EdgeInsets.all(QSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? QColors.darkCard : QColors.lightCard,
              borderRadius: QRadius.borderRadiusLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dividend Polynomial P(x)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
                const SizedBox(height: QSpacing.xs),
                TextField(
                  controller: _dividendController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 2x^3 - 3x^2 + 4x - 5',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: QSpacing.md),

                Text('Divisor Polynomial D(x)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
                const SizedBox(height: QSpacing.xs),
                TextField(
                  controller: _divisorController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. x - 2 or x^2 + 1',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: QSpacing.md),

                ElevatedButton.icon(
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Divide Polynomials'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                  onPressed: _computeDivision,
                ),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.lg),

          // Error or Results
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(QSpacing.md),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.12),
                borderRadius: QRadius.borderRadiusMd,
              ),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
            )
          else if (_result != null)
            _buildResultCard(context, _result!),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, PolynomialDivisionResult res) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final qStr = res.quotient.toString();
    final rStr = res.remainder.isZero ? '0' : res.remainder.toString();

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
              Text('DIVISION RESULT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primary, letterSpacing: 1.0)),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 16),
                tooltip: 'Copy results',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: 'Quotient: $qStr\nRemainder: $rStr'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Result copied to clipboard')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: QSpacing.sm),

          // Quotient Block
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
                Text('Quotient Q(x):', style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(qStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.sm),

          // Remainder Block
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
                Text('Remainder R(x):', style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(rStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.md),

          // Synthetic Division Table if applicable
          if (res.isSyntheticApplicable && res.syntheticTable != null) ...[
            Container(
              padding: const EdgeInsets.all(QSpacing.md),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: QRadius.borderRadiusMd,
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.table_chart_outlined, size: 16, color: primary),
                      const SizedBox(width: 6),
                      Text('Synthetic Division (Root c = ${res.syntheticRoot})',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(color: primary.withValues(alpha: 0.3)),
                    ),
                    children: res.syntheticTable!.map((row) {
                      return TableRow(
                        children: row.map((cell) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Text(cell, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                        )).toList(),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: QSpacing.md),
          ],

          // View Steps Modal Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.auto_awesome, size: 14),
                label: const Text('View Step-by-Step Tableau', style: TextStyle(fontSize: 12)),
                onPressed: () => _showStepsModal(context, res),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStepsModal(BuildContext context, PolynomialDivisionResult res) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
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
                  const Text('Long Division Step-by-Step', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: res.textSteps.length,
                  itemBuilder: (_, idx) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      res.textSteps[idx],
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
