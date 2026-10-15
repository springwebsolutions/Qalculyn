// Qalculyn - Main Calculator Screen
// Premium calculator with full keypad, expression display, and live preview

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/theme.dart';
import '../../core/providers/calculator_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/math/calculator_engine.dart' show AngleMode;
import '../history/history_sheet.dart';
import '../scientific/scientific_panel.dart';
import '../tools/tools_screen.dart';
import '../settings/settings_screen.dart';
import 'explain_sheet.dart';
import '../tools/constants_screen.dart';
import '../algebra/linear_system_screen.dart';
import '../algebra/polynomial_division_screen.dart';
import '../geometry/geometry_screen.dart';
import '../graphing/graphing_screen.dart';
import '../gst/gst_screen.dart';
import '../converters/converter_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> with TickerProviderStateMixin {
  late AnimationController _resultAnimController;
  late Animation<double> _resultScaleAnim;
  bool _showScientific = false;

  @override
  void initState() {
    super.initState();
    _resultAnimController = AnimationController(
      duration: QDurations.fast,
      vsync: this,
    );
    _resultScaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _resultAnimController, curve: QCurves.standard),
    );
  }

  @override
  void dispose() {
    _resultAnimController.dispose();
    super.dispose();
  }

  void _onButtonPressed(String value, CalculatorProvider calc, SettingsProvider settings) {
    if (settings.hapticFeedback) {
      HapticFeedback.lightImpact();
    }

    switch (value) {
      case 'C':
        calc.clear();
      case 'CE':
        calc.clearEntry();
      case '⌫':
        calc.backspace();
      case '=':
        _resultAnimController.forward().then((_) => _resultAnimController.reverse());
        calc.evaluate();
      case '.':
        calc.inputDecimal();
      case '±':
        calc.toggleSign();
      case '%':
        calc.inputPercent();
      case '( )':
        calc.inputParenthesis();
      case '+':
      case '-':
      case '×':
      case '÷':
        calc.inputOperator(value);
      case '^':
        calc.inputPower();
      case '!':
        calc.inputFactorial();
      case 'π':
      case 'e':
        calc.inputConstant(value);
      case 'MC':
        calc.memoryClear();
      case 'MR':
        calc.memoryRecall();
      case 'M+':
        calc.memoryAdd();
      case 'M-':
        calc.memorySubtract();
      case 'MS':
        calc.memoryStore();
      default:
        if (value.endsWith('(')) {
          calc.inputFunction(value.substring(0, value.length - 1));
        } else {
          calc.inputDigit(value);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) => _handleKeyEvent(node, event, calc),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar
              _buildTopBar(context, calc, settings),

              // Display area
              Expanded(
                flex: isLandscape ? 2 : 3,
                child: _buildDisplay(context, calc, isDark),
              ),

              // Quick Tools Bar
              _buildQuickToolsBar(context),

              // Scientific panel (expandable)
              if (_showScientific || settings.scientificMode)
                ScientificPanel(
                  onButtonPressed: (v) => _onButtonPressed(v, calc, settings),
                  angleMode: settings.angleMode,
                  hasMemory: calc.hasMemory,
                ),

              // Keypad
              Expanded(
                flex: isLandscape ? 3 : 5,
                child: _buildKeypad(context, calc, settings, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, CalculatorProvider calc, SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: QSpacing.xs),
      child: Row(
        children: [
          // Scientific toggle
          _TopBarButton(
            icon: Icons.science_outlined,
            isActive: _showScientific || settings.scientificMode,
            semanticLabel: 'Toggle scientific mode',
            onTap: () {
              setState(() => _showScientific = !_showScientific);
            },
          ),
          const SizedBox(width: QSpacing.xs),

          // Angle mode indicator
          if (_showScientific || settings.scientificMode)
            GestureDetector(
              onTap: () {
                final newMode = settings.angleMode == AngleMode.degrees
                    ? AngleMode.radians
                    : AngleMode.degrees;
                settings.setAngleMode(newMode);
                calc.updateSettings();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: QSpacing.sm, vertical: QSpacing.xs),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: QRadius.borderRadiusSm,
                ),
                child: Text(
                  settings.angleMode == AngleMode.degrees ? 'DEG' : 'RAD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),

          // Memory indicator
          if (calc.hasMemory)
            Padding(
              padding: const EdgeInsets.only(left: QSpacing.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: QSpacing.sm, vertical: QSpacing.xs),
                decoration: BoxDecoration(
                  color: QColors.accentViolet.withValues(alpha: 0.15),
                  borderRadius: QRadius.borderRadiusSm,
                ),
                child: Text(
                  'M',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: QColors.accentViolet,
                  ),
                ),
              ),
            ),

          const Spacer(),

          // Explain
          _TopBarButton(
            icon: Icons.auto_awesome,
            semanticLabel: 'Explain calculation steps',
            onTap: () {
              final expr = calc.expression.isNotEmpty ? calc.expression : calc.displayResult;
              _showExplain(context, expr, calc.displayResult);
            },
          ),
          const SizedBox(width: QSpacing.xs),

          // History
          _TopBarButton(
            icon: Icons.history,
            semanticLabel: 'Calculation history',
            onTap: () => _showHistory(context),
          ),
          const SizedBox(width: QSpacing.xs),

          // Tools
          _TopBarButton(
            icon: Icons.grid_view_rounded,
            semanticLabel: 'Calculator tools',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ToolsScreen()),
              );
            },
          ),
          const SizedBox(width: QSpacing.xs),

          // Settings
          _TopBarButton(
            icon: Icons.settings_outlined,
            semanticLabel: 'Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay(BuildContext context, CalculatorProvider calc, bool isDark) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 80) {
          HapticFeedback.lightImpact();
          calc.backspace();
        }
      },
      onLongPress: () async {
        await calc.copyResult();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Result copied'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
              shape: RoundedRectangleBorder(borderRadius: QRadius.borderRadiusMd),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: QSpacing.xxl, vertical: QSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Expression with interactive tap-to-edit cursor
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: _buildExpressionWithCursor(context, calc, primary),
            ),
            const SizedBox(height: QSpacing.sm),

            // Result
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: ScaleTransition(
                scale: _resultScaleAnim,
                child: AnimatedDefaultTextStyle(
                  duration: QDurations.normal,
                  style: QTypography.calcResult(context).copyWith(
                    fontSize: calc.displayResult.length > 12 ? 36 : 52,
                    color: calc.hasError
                        ? QColors.error
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  child: Text(
                    calc.hasError ? calc.errorMessage : calc.displayResult,
                    semanticsLabel: 'Result: ${calc.displayResult}',
                    maxLines: 1,
                  ),
                ),
              ),
            ),

            // Preview
            if (calc.previewResult.isNotEmpty && !calc.resultDisplayed)
              Padding(
                padding: const EdgeInsets.only(top: QSpacing.xs),
                child: AnimatedOpacity(
                  duration: QDurations.fast,
                  opacity: 1.0,
                  child: Text(
                    '= ${calc.previewResult}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                    ),
                    semanticsLabel: 'Preview: ${calc.previewResult}',
                  ),
                ),
              ),

            // Actions & Copy hint
            Padding(
              padding: const EdgeInsets.only(top: QSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (calc.expression.isNotEmpty || calc.resultDisplayed)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.auto_awesome, size: 14),
                      label: const Text('Explain', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)),
                      ),
                      onPressed: () {
                        final expr = calc.expression.isNotEmpty ? calc.expression : calc.displayResult;
                        _showExplain(context, expr, calc.displayResult);
                      },
                    )
                  else
                    const SizedBox.shrink(),
                  if (calc.resultDisplayed)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy_outlined,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Long press to copy',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpressionWithCursor(BuildContext context, CalculatorProvider calc, Color primary) {
    if (calc.expression.isEmpty) {
      return const Text(' ', semanticsLabel: 'Empty expression');
    }

    final expr = calc.expression;
    final cursor = calc.cursorPosition;
    final textStyle = QTypography.calcExpression(context).copyWith(
      color: calc.hasError
          ? QColors.error.withValues(alpha: 0.7)
          : Theme.of(context).colorScheme.onSurfaceVariant,
    );

    final spans = <InlineSpan>[];
    for (int i = 0; i < expr.length; i++) {
      if (i == cursor && !calc.resultDisplayed) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            width: 2.5,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ));
      }
      final charIndex = i;
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            calc.setCursorPosition(charIndex + 1);
          },
          child: Text(expr[i], style: textStyle),
        ),
      ));
    }

    // Cursor at the very end
    if (cursor >= expr.length && !calc.resultDisplayed) {
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          width: 2.5,
          height: 22,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
      semanticsLabel: 'Expression: ${calc.expression}',
      maxLines: 1,
    );
  }

  Widget _buildQuickToolsBar(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final quickTools = [
      ('Constants', Icons.menu_book, () => const ConstantsScreen()),
      ('Simultaneous', Icons.compare_arrows, () => const LinearSystemScreen()),
      ('Polynomials', Icons.alt_route, () => const PolynomialDivisionScreen()),
      ('Geometry', Icons.architecture, () => const GeometryScreen()),
      ('Graphing', Icons.show_chart, () => const GraphingScreen()),
      ('GST', Icons.receipt_long_outlined, () => const GstScreen()),
      ('Units', Icons.swap_horiz, () => const ConverterScreen()),
    ];

    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: QSpacing.xs),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: QSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: quickTools.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (ctx, idx) {
          final t = quickTools[idx];
          return ActionChip(
            avatar: Icon(t.$2, size: 14, color: primary),
            label: Text(t.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => t.$3()));
            },
          );
        },
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event, CalculatorProvider calc) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final char = event.character;
    if (char != null && '0123456789'.contains(char)) {
      calc.inputDigit(char);
      return KeyEventResult.handled;
    }
    if (char == '+') { calc.inputOperator('+'); return KeyEventResult.handled; }
    if (char == '-') { calc.inputOperator('-'); return KeyEventResult.handled; }
    if (char == '*' || char == 'x' || char == 'X') { calc.inputOperator('×'); return KeyEventResult.handled; }
    if (char == '/') { calc.inputOperator('÷'); return KeyEventResult.handled; }
    if (char == '.' || char == ',') { calc.inputDecimal(); return KeyEventResult.handled; }
    if (char == '(' || char == ')') { calc.inputParenthesis(); return KeyEventResult.handled; }
    if (char == '%') { calc.inputPercent(); return KeyEventResult.handled; }
    if (char == '^') { calc.inputPower(); return KeyEventResult.handled; }
    if (char == '!') { calc.inputFactorial(); return KeyEventResult.handled; }

    if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      calc.evaluate();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      calc.backspace();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      calc.clear();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      calc.setCursorPosition(calc.cursorPosition - 1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      calc.setCursorPosition(calc.cursorPosition + 1);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Widget _buildKeypad(BuildContext context, CalculatorProvider calc, SettingsProvider settings, bool isDark) {
    final buttons = [
      ['C', '( )', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['±', '0', '.', '='],
    ];

    return Padding(
      padding: const EdgeInsets.all(QSpacing.sm),
      child: Column(
        children: buttons.map((row) {
          return Expanded(
            child: Row(
              children: row.map((label) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: _CalcButton(
                      label: label,
                      isDark: isDark,
                      primaryColor: Theme.of(context).colorScheme.primary,
                      cornerRadius: settings.keypadCornerRadius,
                      onPressed: () => _onButtonPressed(label, calc, settings),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showExplain(BuildContext context, String expression, String result) {
    if (expression.trim().isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExplainSheet(
        expression: expression,
        result: result,
      ),
    );
  }

  void _showHistory(BuildContext context) {
    final calc = context.read<CalculatorProvider>();
    calc.loadHistory();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: calc,
        child: const HistorySheet(),
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final String semanticLabel;
  final VoidCallback onTap;

  const _TopBarButton({
    required this.icon,
    this.isActive = false,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: QRadius.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.all(QSpacing.sm),
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: QRadius.borderRadiusMd,
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

enum _ButtonType { number, operator, function_, equals }

class _CalcButton extends StatefulWidget {
  final String label;
  final bool isDark;
  final Color primaryColor;
  final double cornerRadius;
  final VoidCallback onPressed;

  const _CalcButton({
    required this.label,
    required this.isDark,
    required this.primaryColor,
    required this.cornerRadius,
    required this.onPressed,
  });

  @override
  State<_CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<_CalcButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _ButtonType get _type {
    if (widget.label == '=') return _ButtonType.equals;
    if ('+-×÷'.contains(widget.label)) return _ButtonType.operator;
    if ('C CE % ( ) ± ⌫'.split(' ').contains(widget.label) || widget.label == '( )') {
      return _ButtonType.function_;
    }
    return _ButtonType.number;
  }

  Color get _backgroundColor {
    final isDark = widget.isDark;
    return switch (_type) {
      _ButtonType.equals => widget.primaryColor,
      _ButtonType.operator => isDark ? QColors.darkOperatorButton : QColors.lightOperatorButton,
      _ButtonType.function_ => isDark ? QColors.darkFunctionButton : QColors.lightFunctionButton,
      _ButtonType.number => isDark ? QColors.darkNumberButton : QColors.lightNumberButton,
    };
  }

  Color get _textColor {
    return switch (_type) {
      _ButtonType.equals => Colors.white,
      _ButtonType.operator => widget.primaryColor,
      _ButtonType.function_ => widget.isDark ? widget.primaryColor.withValues(alpha: 0.9) : widget.primaryColor,
      _ButtonType.number => widget.isDark ? QColors.darkTextPrimary : QColors.lightTextPrimary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Semantics(
          label: _semanticLabel,
          button: true,
          child: Container(
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(widget.cornerRadius),
              boxShadow: _type == _ButtonType.equals
                  ? [
                      BoxShadow(
                        color: widget.primaryColor.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: widget.label == '⌫'
                  ? Icon(Icons.backspace_outlined, color: _textColor, size: 22)
                  : Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: _type == _ButtonType.function_ ? 18 : 24,
                        fontWeight: FontWeight.w500,
                        color: _textColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String get _semanticLabel => switch (widget.label) {
    'C' => 'Clear',
    'CE' => 'Clear entry',
    '⌫' => 'Backspace',
    '±' => 'Toggle sign',
    '( )' => 'Parentheses',
    '×' => 'Multiply',
    '÷' => 'Divide',
    '=' => 'Equals',
    '%' => 'Percent',
    '.' => 'Decimal point',
    _ => widget.label,
  };
}


