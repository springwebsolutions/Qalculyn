// Qalculyn - SIP & Mutual Fund Calculator
// Calculates Systematic Investment Plan & Lump Sum projections

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_formatter.dart';
import '../../shared/tool_widgets.dart';

class SipScreen extends StatefulWidget {
  const SipScreen({super.key});

  @override
  State<SipScreen> createState() => _SipScreenState();
}

class _SipScreenState extends State<SipScreen> {
  int _selectedMode = 0; // 0: SIP, 1: Lump Sum
  final _amountController = TextEditingController(text: '5000');
  final _rateController = TextEditingController(text: '12');
  final _yearsController = TextEditingController(text: '10');

  final _formatter = NumberFormatter();

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  Map<String, String> _calculate() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    final rate = double.tryParse(_rateController.text);
    final years = double.tryParse(_yearsController.text);

    if (amount == null || rate == null || years == null || amount <= 0 || rate < 0 || years <= 0) {
      return {'Total Value': '—', 'Invested Amount': '—', 'Est. Returns': '—'};
    }

    if (_selectedMode == 0) {
      // SIP
      final n = (years * 12).round();
      final invested = amount * n;
      if (rate == 0) {
        return {
          'Total Value': _formatter.format(invested),
          'Invested Amount': _formatter.format(invested),
          'Est. Returns': _formatter.format(0),
        };
      }

      final i = (rate / 100) / 12;
      final powTerm = pow(1 + i, n);
      final totalValue = amount * ((powTerm - 1) / i) * (1 + i);
      final returns = totalValue - invested;

      return {
        'Total Expected Value': _formatter.format(totalValue),
        'Invested Amount': _formatter.format(invested),
        'Est. Wealth Gain': _formatter.format(returns),
      };
    } else {
      // Lump Sum
      final invested = amount;
      final totalValue = invested * pow(1 + (rate / 100), years);
      final returns = totalValue - invested;

      return {
        'Total Expected Value': _formatter.format(totalValue),
        'Invested Amount': _formatter.format(invested),
        'Est. Wealth Gain': _formatter.format(returns),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    return ToolScaffold(
      title: 'SIP Calculator',
      disclaimer: 'Mutual fund investments are subject to market risks. Read all scheme related documents carefully.',
      children: [
        ToolModeSelector(
          modes: const ['Monthly SIP', 'Lump Sum'],
          selected: _selectedMode,
          onChanged: (idx) {
            setState(() {
              _selectedMode = idx;
              if (idx == 1 && _amountController.text == '5000') {
                _amountController.text = '100000';
              } else if (idx == 0 && _amountController.text == '100000') {
                _amountController.text = '5000';
              }
            });
          },
        ),
        const SizedBox(height: QSpacing.lg),
        ToolTextField(
          controller: _amountController,
          label: _selectedMode == 0 ? 'Monthly Investment' : 'Lump Sum Investment',
          prefix: '₹ / \$ ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _rateController,
          label: 'Expected Annual Return (CAGR)',
          suffix: '% p.a.',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _yearsController,
          label: 'Time Horizon',
          suffix: 'Years',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.xl),
        ToolResultCard(
          title: 'Projection Breakdown',
          results: results,
        ),
      ],
    );
  }
}
