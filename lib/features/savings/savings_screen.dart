// Qalculyn - Savings / Investment Growth Calculator

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_formatter.dart';
import '../../shared/tool_widgets.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final _initialController = TextEditingController(text: '10000');
  final _monthlyController = TextEditingController(text: '5000');
  final _rateController = TextEditingController(text: '8');
  final _yearsController = TextEditingController(text: '10');

  final _formatter = NumberFormatter();

  @override
  void dispose() {
    _initialController.dispose();
    _monthlyController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  Map<String, String> _calculate() {
    final initial = double.tryParse(_initialController.text.replaceAll(',', '')) ?? 0.0;
    final monthly = double.tryParse(_monthlyController.text.replaceAll(',', '')) ?? 0.0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final years = double.tryParse(_yearsController.text) ?? 0.0;

    if (years <= 0 || (initial <= 0 && monthly <= 0)) {
      return {'Future Value': '—', 'Total Invested': '—', 'Wealth Gain': '—'};
    }

    final months = (years * 12).round();
    final totalInvested = initial + (monthly * months);

    if (rate <= 0) {
      return {
        'Future Value': _formatter.format(totalInvested),
        'Total Invested': _formatter.format(totalInvested),
        'Wealth Gain': _formatter.format(0),
      };
    }

    final i = (rate / 100) / 12;
    final powTerm = pow(1 + i, months);

    // Initial deposit growth
    final futureInitial = initial * powTerm;

    // Monthly annuity growth (beginning of period)
    final futureMonthly = monthly > 0 ? monthly * ((powTerm - 1) / i) * (1 + i) : 0.0;

    final futureTotal = futureInitial + futureMonthly;
    final wealthGain = futureTotal - totalInvested;

    return {
      'Total Accumulated': _formatter.format(futureTotal),
      'Total Invested': _formatter.format(totalInvested),
      'Wealth Gain': _formatter.format(wealthGain),
    };
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    return ToolScaffold(
      title: 'Savings & Growth',
      disclaimer: 'Returns are compounded monthly. Actual investment returns fluctuate with market conditions.',
      children: [
        ToolTextField(
          controller: _initialController,
          label: 'Initial Lump Sum',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _monthlyController,
          label: 'Monthly Deposit',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _rateController,
          label: 'Expected Annual Return',
          suffix: '% p.a.',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _yearsController,
          label: 'Investment Period',
          suffix: 'Years',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.xl),
        ToolResultCard(
          title: 'Projected Wealth',
          results: results,
        ),
      ],
    );
  }
}
