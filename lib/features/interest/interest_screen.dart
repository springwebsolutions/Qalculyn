// Qalculyn - Simple & Compound Interest Calculator

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_formatter.dart';
import '../../shared/tool_widgets.dart';

class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  int _selectedMode = 0; // 0: Simple, 1: Compound
  final _principalController = TextEditingController(text: '50000');
  final _rateController = TextEditingController(text: '7');
  final _timeController = TextEditingController(text: '5');
  int _compoundingFrequency = 1; // 1: Annual, 2: Semi-annual, 4: Quarterly, 12: Monthly, 365: Daily

  final _formatter = NumberFormatter();

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Map<String, String> _calculate() {
    final p = double.tryParse(_principalController.text.replaceAll(',', ''));
    final r = double.tryParse(_rateController.text);
    final t = double.tryParse(_timeController.text);

    if (p == null || r == null || t == null || p < 0 || r < 0 || t < 0) {
      return {'Interest Earned': '—', 'Total Amount': '—'};
    }

    if (_selectedMode == 0) {
      // Simple Interest
      final interest = (p * r * t) / 100;
      final total = p + interest;
      return {
        'Interest Earned': _formatter.format(interest),
        'Principal Amount': _formatter.format(p),
        'Total Future Value': _formatter.format(total),
      };
    } else {
      // Compound Interest
      final n = _compoundingFrequency.toDouble();
      final rateDecimal = r / 100;
      final total = p * pow(1 + (rateDecimal / n), n * t);
      final interest = total - p;
      return {
        'Compound Interest': _formatter.format(interest),
        'Principal Amount': _formatter.format(p),
        'Total Future Value': _formatter.format(total),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    return ToolScaffold(
      title: 'Interest Calculator',
      children: [
        ToolModeSelector(
          modes: const ['Simple Interest', 'Compound Interest'],
          selected: _selectedMode,
          onChanged: (idx) => setState(() => _selectedMode = idx),
        ),
        const SizedBox(height: QSpacing.lg),
        ToolTextField(
          controller: _principalController,
          label: 'Principal Amount',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _rateController,
          label: 'Annual Interest Rate',
          suffix: '% p.a.',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _timeController,
          label: 'Time Period',
          suffix: 'Years',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        if (_selectedMode == 1) ...[
          const SizedBox(height: QSpacing.md),
          ToolDropdown<int>(
            label: 'Compounding Frequency',
            value: _compoundingFrequency,
            items: const [1, 2, 4, 12, 365],
            labelBuilder: (freq) {
              switch (freq) {
                case 1:
                  return 'Annually (1/yr)';
                case 2:
                  return 'Semi-Annually (2/yr)';
                case 4:
                  return 'Quarterly (4/yr)';
                case 12:
                  return 'Monthly (12/yr)';
                case 365:
                  return 'Daily (365/yr)';
                default:
                  return '$freq times per year';
              }
            },
            onChanged: (val) {
              if (val != null) setState(() => _compoundingFrequency = val);
            },
          ),
        ],
        const SizedBox(height: QSpacing.xl),
        ToolResultCard(
          title: 'Calculation Summary',
          results: results,
        ),
      ],
    );
  }
}
