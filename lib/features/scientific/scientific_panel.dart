// Qalculyn - Scientific Calculator Panel
// Expandable panel with scientific functions, memory, and constants

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/calculator_engine.dart';

class ScientificPanel extends StatelessWidget {
  final Function(String) onButtonPressed;
  final AngleMode angleMode;
  final bool hasMemory;

  const ScientificPanel({
    super.key,
    required this.onButtonPressed,
    required this.angleMode,
    required this.hasMemory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: QSpacing.sm, vertical: QSpacing.xs),
      child: Column(
        children: [
          // Memory row
          _buildRow(context, isDark, ['MC', 'MR', 'M+', 'M-', 'MS']),
          const SizedBox(height: 2),
          // Scientific row 1
          _buildRow(context, isDark, ['sin(', 'cos(', 'tan(', 'π', 'e']),
          const SizedBox(height: 2),
          // Scientific row 2
          _buildRow(context, isDark, ['asin(', 'acos(', 'atan(', 'ln(', 'log(']),
          const SizedBox(height: 2),
          // Scientific row 3
          _buildRow(context, isDark, ['sqrt(', 'x²', 'x³', '^', '!']),
          const SizedBox(height: 2),
          // Scientific row 4
          _buildRow(context, isDark, ['abs(', 'exp(', '1/x', 'mod', 'nCr(']),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, bool isDark, List<String> labels) {
    return Row(
      children: labels.map((label) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(1.5),
            child: _ScientificButton(
              label: _displayLabel(label),
              isDark: isDark,
              onPressed: () => _handlePress(label),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _displayLabel(String label) {
    return switch (label) {
      'sin(' => 'sin',
      'cos(' => 'cos',
      'tan(' => 'tan',
      'asin(' => 'sin⁻¹',
      'acos(' => 'cos⁻¹',
      'atan(' => 'tan⁻¹',
      'ln(' => 'ln',
      'log(' => 'log',
      'sqrt(' => '√',
      'abs(' => '|x|',
      'exp(' => 'eˣ',
      'nCr(' => 'nCr',
      'x²' => 'x²',
      'x³' => 'x³',
      '1/x' => '1/x',
      'mod' => 'mod',
      _ => label,
    };
  }

  void _handlePress(String label) {
    switch (label) {
      case 'x²':
        onButtonPressed('^');
        onButtonPressed('2');
      case 'x³':
        onButtonPressed('^');
        onButtonPressed('3');
      case '1/x':
        // Wrap current expression in reciprocal
        onButtonPressed('1');
        onButtonPressed('÷');
      case 'mod':
        // Use modulo via the expression
        onButtonPressed('%');
      default:
        onButtonPressed(label);
    }
  }
}

class _ScientificButton extends StatefulWidget {
  final String label;
  final bool isDark;
  final VoidCallback onPressed;

  const _ScientificButton({
    required this.label,
    required this.isDark,
    required this.onPressed,
  });

  @override
  State<_ScientificButton> createState() => _ScientificButtonState();
}

class _ScientificButtonState extends State<_ScientificButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMemory = ['MC', 'MR', 'M+', 'M-', 'MS'].contains(widget.label);
    final isConstant = ['π', 'e'].contains(widget.label);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Semantics(
          label: widget.label,
          button: true,
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: isMemory
                  ? QColors.accentViolet.withValues(alpha: 0.12)
                  : isConstant
                      ? QColors.primaryPurple.withValues(alpha: 0.12)
                      : (widget.isDark ? QColors.darkFunctionButton : QColors.lightFunctionButton),
              borderRadius: QRadius.borderRadiusSm,
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isMemory
                      ? QColors.accentViolet
                      : isConstant
                          ? QColors.primaryPurple
                          : (widget.isDark ? QColors.darkTextSecondary : QColors.lightTextSecondary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
