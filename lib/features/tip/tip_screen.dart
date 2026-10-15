// Qalculyn - Tip & Bill Split Calculator

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_formatter.dart';
import '../../shared/tool_widgets.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  final _billCtrl = TextEditingController();
  final _customTipCtrl = TextEditingController();
  final _peopleCtrl = TextEditingController(text: '1');
  final _formatter = const NumberFormatter();
  double _tipPercent = 15;
  bool _useCustomTip = false;
  bool _roundUp = false;

  @override
  void dispose() {
    _billCtrl.dispose();
    _customTipCtrl.dispose();
    _peopleCtrl.dispose();
    super.dispose();
  }

  double get _effectiveTip {
    if (_useCustomTip) return double.tryParse(_customTipCtrl.text) ?? 0;
    return _tipPercent;
  }

  Map<String, String> _calculate() {
    final bill = double.tryParse(_billCtrl.text);
    final people = int.tryParse(_peopleCtrl.text) ?? 1;

    if (bill == null || bill <= 0) return {};
    if (people <= 0) return {'Error': 'Number of people must be at least 1'};

    final tip = _effectiveTip;
    final tipAmount = bill * tip / 100;
    var total = bill + tipAmount;

    if (_roundUp) {
      total = total.ceilToDouble();
    }

    final perPerson = total / people;
    final tipPerPerson = tipAmount / people;

    return {
      'Bill amount': '₹${_formatter.format(bill)}',
      'Tip (${_formatter.format(tip)}%)': '₹${_formatter.format(tipAmount)}',
      'Total': '₹${_formatter.format(total)}',
      if (people > 1) 'Per person': '₹${_formatter.format(perPerson)}',
      if (people > 1) 'Tip per person': '₹${_formatter.format(tipPerPerson)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();
    return ToolScaffold(
      title: 'Tip & Bill Split',
      children: [
        ToolTextField(
          controller: _billCtrl,
          label: 'Bill amount',
          prefix: '₹ ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.lg),

        // Tip presets
        Text('Tip percentage', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: QSpacing.sm),
        Wrap(
          spacing: QSpacing.sm,
          runSpacing: QSpacing.sm,
          children: [
            for (final pct in [10.0, 12.0, 15.0, 18.0, 20.0, 25.0])
              ChoiceChip(
                label: Text('${pct.toInt()}%'),
                selected: !_useCustomTip && _tipPercent == pct,
                onSelected: (_) => setState(() {
                  _tipPercent = pct;
                  _useCustomTip = false;
                }),
                selectedColor: QColors.primaryPurple.withValues(alpha: 0.2),
              ),
            ChoiceChip(
              label: const Text('Custom'),
              selected: _useCustomTip,
              onSelected: (_) => setState(() => _useCustomTip = true),
              selectedColor: QColors.primaryPurple.withValues(alpha: 0.2),
            ),
          ],
        ),

        if (_useCustomTip) ...[
          const SizedBox(height: QSpacing.md),
          ToolTextField(
            controller: _customTipCtrl,
            label: 'Custom tip percentage',
            suffix: '%',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
        ],

        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _peopleCtrl,
          label: 'Number of people',
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: QSpacing.md),
        SwitchListTile(
          title: const Text('Round up total'),
          value: _roundUp,
          onChanged: (v) => setState(() => _roundUp = v),
          contentPadding: EdgeInsets.zero,
        ),

        if (results.isNotEmpty) ...[
          const SizedBox(height: QSpacing.lg),
          ToolResultCard(results: results, title: 'Bill Breakdown'),
        ],
      ],
    );
  }
}
