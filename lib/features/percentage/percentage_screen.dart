// Qalculyn - Percentage Calculator
// All percentage calculation modes: X% of Y, what % is X of Y, increase, decrease, change, reverse

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_formatter.dart';
import '../../shared/tool_widgets.dart';

class PercentageScreen extends StatefulWidget {
  const PercentageScreen({super.key});

  @override
  State<PercentageScreen> createState() => _PercentageScreenState();
}

class _PercentageScreenState extends State<PercentageScreen> {
  int _mode = 0;
  final _ctrl1 = TextEditingController();
  final _ctrl2 = TextEditingController();
  final _formatter = const NumberFormatter();

  static const _modes = [
    'X% of Y',
    'X is what % of Y',
    '% Increase',
    '% Decrease',
    '% Change',
    'Reverse %',
  ];

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    super.dispose();
  }

  Map<String, String> _calculate() {
    final v1 = double.tryParse(_ctrl1.text);
    final v2 = double.tryParse(_ctrl2.text);

    if (v1 == null || v2 == null) return {};

    switch (_mode) {
      case 0: // X% of Y
        final result = v1 * v2 / 100;
        return {'Result': _formatter.format(result)};
      case 1: // X is what % of Y
        if (v2 == 0) return {'Error': 'Cannot divide by zero'};
        final result = (v1 / v2) * 100;
        return {'Percentage': '${_formatter.format(result)}%'};
      case 2: // % Increase
        final result = v1 * (1 + v2 / 100);
        final increase = v1 * v2 / 100;
        return {
          'Increase': _formatter.format(increase),
          'New value': _formatter.format(result),
        };
      case 3: // % Decrease
        final result = v1 * (1 - v2 / 100);
        final decrease = v1 * v2 / 100;
        return {
          'Decrease': _formatter.format(decrease),
          'New value': _formatter.format(result),
        };
      case 4: // % Change
        if (v1 == 0) return {'Error': 'Original value cannot be zero'};
        final change = ((v2 - v1) / v1) * 100;
        return {
          'Change': '${_formatter.format(change)}%',
          'Direction': change >= 0 ? 'Increase' : 'Decrease',
        };
      case 5: // Reverse %
        if (v2 == 100) return {'Error': 'Cannot reverse 100% discount'};
        final original = v1 / (1 - v2 / 100);
        return {'Original value': _formatter.format(original)};
      default:
        return {};
    }
  }

  String _label1() => switch (_mode) {
    0 => 'Percentage (X)',
    1 => 'Value (X)',
    2 || 3 => 'Original value',
    4 => 'Original value',
    5 => 'Final value',
    _ => 'Value',
  };

  String _label2() => switch (_mode) {
    0 => 'Value (Y)',
    1 => 'Total (Y)',
    2 || 3 => 'Percentage',
    4 => 'New value',
    5 => 'Percentage applied',
    _ => 'Value',
  };

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    return ToolScaffold(
      title: 'Percentage Calculator',
      children: [
        // Mode selector
        ToolModeSelector(
          modes: _modes,
          selected: _mode,
          onChanged: (i) {
            setState(() {
              _mode = i;
              _ctrl1.clear();
              _ctrl2.clear();
            });
          },
        ),
        const SizedBox(height: QSpacing.xl),

        // Inputs
        ToolTextField(
          controller: _ctrl1,
          label: _label1(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _ctrl2,
          label: _label2(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          onChanged: (_) => setState(() {}),
        ),

        // Results
        if (results.isNotEmpty) ...[
          const SizedBox(height: QSpacing.xxl),
          ToolResultCard(results: results),
        ],
      ],
    );
  }
}
