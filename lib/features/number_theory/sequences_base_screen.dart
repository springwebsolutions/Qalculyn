// Qalculyn - Sequences & Base Converter Screen
// Base converter (bases 2-36) and Arithmetic, Geometric, and Fibonacci sequence analysis

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/sequences_base.dart';
import '../../shared/tool_widgets.dart';

class SequencesBaseScreen extends StatefulWidget {
  const SequencesBaseScreen({super.key});

  @override
  State<SequencesBaseScreen> createState() => _SequencesBaseScreenState();
}

class _SequencesBaseScreenState extends State<SequencesBaseScreen> {
  int _selectedMode = 0; // 0: Base Converter, 1: Arithmetic Seq, 2: Geometric Seq, 3: Fibonacci

  // Base converter controllers
  final _valController = TextEditingController(text: '255');
  int _fromBase = 10;
  int _toBase = 16;

  // Sequences controllers
  final _a1Controller = TextEditingController(text: '2');
  final _dOrRController = TextEditingController(text: '3');
  final _nController = TextEditingController(text: '10');

  @override
  void dispose() {
    _valController.dispose();
    _a1Controller.dispose();
    _dOrRController.dispose();
    _nController.dispose();
    super.dispose();
  }

  Map<String, String> _calculate() {
    if (_selectedMode == 0) {
      // Base Converter
      try {
        final input = _valController.text.trim();
        if (input.isEmpty) return {'Error': 'Please enter a number to convert'};

        final converted = BaseConverter.convert(input, _fromBase, _toBase);
        final bin = BaseConverter.convert(input, _fromBase, 2);
        final oct = BaseConverter.convert(input, _fromBase, 8);
        final dec = BaseConverter.convert(input, _fromBase, 10);
        final hex = BaseConverter.convert(input, _fromBase, 16);

        return {
          'Converted Value': converted,
          'Target Base': 'Base $_toBase',
          'Binary (Base 2)': bin,
          'Octal (Base 8)': oct,
          'Decimal (Base 10)': dec,
          'Hexadecimal (Base 16)': hex,
        };
      } catch (e) {
        return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter valid digits for the selected base')};
      }
    } else if (_selectedMode == 1) {
      // Arithmetic
      try {
        final a1 = double.parse(_a1Controller.text.trim());
        final d = double.parse(_dOrRController.text.trim());
        final n = int.parse(_nController.text.trim());

        final res = SequencesEngine.arithmetic(a1: a1, d: d, n: n);
        final preview = (res['preview'] as List<double>).map((v) => v.toString()).join(', ');

        return {
          'n-th Term a_n': res['an'].toString(),
          'Sum of n Terms S_n': res['sn'].toString(),
          'Sequence Preview': '$preview ...',
          'General Term Formula': res['formula'] as String,
        };
      } catch (e) {
        return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter valid sequence parameters')};
      }
    } else if (_selectedMode == 2) {
      // Geometric
      try {
        final a1 = double.parse(_a1Controller.text.trim());
        final r = double.parse(_dOrRController.text.trim());
        final n = int.parse(_nController.text.trim());

        final res = SequencesEngine.geometric(a1: a1, r: r, n: n);
        final preview = (res['preview'] as List<double>).map((v) => v.toString()).join(', ');

        return {
          'n-th Term a_n': res['an'].toString(),
          'Sum of n Terms S_n': res['sn'].toString(),
          'Sequence Preview': '$preview ...',
          'General Term Formula': res['formula'] as String,
        };
      } catch (e) {
        return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter valid sequence parameters')};
      }
    } else {
      // Fibonacci
      try {
        final n = int.parse(_nController.text.trim());
        final res = SequencesEngine.fibonacci(n);
        final seq = (res['sequence'] as List<BigInt>).join(', ');

        return {
          'n-th Fibonacci Term F_$n': res['fn'].toString(),
          'Sequence': '$seq ...',
          'Definition': 'F_0 = 0, F_1 = 1, F_n = F_{n-1} + F_{n-2}',
        };
      } catch (e) {
        return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter a non-negative integer n (0 - 1000)')};
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    return ToolScaffold(
      title: 'Sequences & Bases',
      disclaimer: 'Arbitrary-precision integer base conversion (2-36) and exact sequence summation.',
      children: [
        ToolModeSelector(
          modes: const ['Base Converter', 'Arithmetic Seq', 'Geometric Seq', 'Fibonacci'],
          selected: _selectedMode,
          onChanged: (idx) => setState(() => _selectedMode = idx),
        ),
        const SizedBox(height: QSpacing.md),

        if (_selectedMode == 0) ...[
          ToolTextField(
            controller: _valController,
            label: 'Number Value',
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: QSpacing.md),
          Row(
            children: [
              Expanded(
                child: ToolDropdown<int>(
                  label: 'From Base',
                  value: _fromBase,
                  items: const [2, 8, 10, 16],
                  labelBuilder: (b) => 'Base $b ${_baseName(b)}',
                  onChanged: (v) {
                    if (v != null) setState(() => _fromBase = v);
                  },
                ),
              ),
              const SizedBox(width: QSpacing.md),
              Expanded(
                child: ToolDropdown<int>(
                  label: 'To Base',
                  value: _toBase,
                  items: const [2, 8, 10, 16],
                  labelBuilder: (b) => 'Base $b ${_baseName(b)}',
                  onChanged: (v) {
                    if (v != null) setState(() => _toBase = v);
                  },
                ),
              ),
            ],
          ),
        ] else if (_selectedMode == 1 || _selectedMode == 2) ...[
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                  controller: _a1Controller,
                  label: 'First Term (a1)',
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.md),
              Expanded(
                child: ToolTextField(
                  controller: _dOrRController,
                  label: _selectedMode == 1 ? 'Common Diff (d)' : 'Common Ratio (r)',
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: QSpacing.md),
          ToolTextField(
            controller: _nController,
            label: 'Term Index (n)',
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            onChanged: (_) => setState(() {}),
          ),
        ] else ...[
          ToolTextField(
            controller: _nController,
            label: 'Fibonacci Index (n)',
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            onChanged: (_) => setState(() {}),
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

  String _baseName(int b) {
    switch (b) {
      case 2:
        return '(BIN)';
      case 8:
        return '(OCT)';
      case 10:
        return '(DEC)';
      case 16:
        return '(HEX)';
      default:
        return '';
    }
  }
}
