// Qalculyn - Calculator State Provider
// Manages calculator state including expression, result, memory, and history

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../math/calculator_engine.dart';
import '../math/number_formatter.dart';
import '../models.dart';
import '../storage/history_repository.dart';
import 'settings_provider.dart';

class CalculatorProvider extends ChangeNotifier {
  final HistoryRepository _historyRepo = HistoryRepository();
  late CalculatorEngine _engine;
  late NumberFormatter _formatter;
  final SettingsProvider _settings;

  String _expression = '';
  int _cursorPosition = 0;
  String _displayResult = '0';
  String _previewResult = '';
  bool _hasError = false;
  String _errorMessage = '';
  bool _resultDisplayed = false;
  List<HistoryEntry> _history = [];
  bool _historyLoaded = false;

  // Memory
  double? _memoryValue;
  bool get hasMemory => _memoryValue != null;
  double? get memoryValue => _memoryValue;

  CalculatorProvider(this._settings) {
    _engine = CalculatorEngine(angleMode: _settings.angleMode);
    _formatter = NumberFormatter(config: _settings.numberFormatConfig);
  }

  String get expression => _expression;
  int get cursorPosition => _cursorPosition.clamp(0, _expression.length);
  String get displayResult => _displayResult;
  String get previewResult => _previewResult;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get resultDisplayed => _resultDisplayed;
  List<HistoryEntry> get history => _history;
  bool get historyLoaded => _historyLoaded;

  void setCursorPosition(int pos) {
    _cursorPosition = pos.clamp(0, _expression.length);
    notifyListeners();
  }

  void _insertText(String text) {
    if (_resultDisplayed) {
      _expression = text;
      _cursorPosition = text.length;
      _resultDisplayed = false;
      return;
    }
    final pos = cursorPosition;
    _expression = _expression.substring(0, pos) + text + _expression.substring(pos);
    _cursorPosition = pos + text.length;
  }

  void updateSettings() {
    _engine = CalculatorEngine(
      angleMode: _settings.angleMode,
      memoryValue: _memoryValue,
    );
    _formatter = NumberFormatter(config: _settings.numberFormatConfig);
    // Re-evaluate if there's a current expression
    if (_expression.isNotEmpty) {
      _evaluatePreview();
    }
    notifyListeners();
  }

  // Input handling
  void inputDigit(String digit) {
    _insertText(digit);
    _hasError = false;
    _evaluatePreview();
    notifyListeners();
  }

  void inputOperator(String op) {
    if (_resultDisplayed) {
      _expression = _displayResult.replaceAll(',', '') + op;
      _cursorPosition = _expression.length;
      _resultDisplayed = false;
    } else if (_expression.isNotEmpty) {
      final pos = cursorPosition;
      if (pos > 0 && '+-×÷'.contains(_expression[pos - 1])) {
        _expression = _expression.substring(0, pos - 1) + op + _expression.substring(pos);
      } else {
        _insertText(op);
      }
    } else if (op == '-') {
      _insertText(op);
    }
    _hasError = false;
    _previewResult = '';
    notifyListeners();
  }

  void inputDecimal() {
    if (_resultDisplayed) {
      _expression = '0.';
      _cursorPosition = 2;
      _resultDisplayed = false;
    } else {
      final pos = cursorPosition;
      final before = _expression.substring(0, pos);
      final parts = before.split(RegExp(r'[+\-×÷(]'));
      final lastPart = parts.isNotEmpty ? parts.last : '';
      if (!lastPart.contains('.')) {
        if (pos == 0 || '+-×÷('.contains(_expression[pos - 1])) {
          _insertText('0.');
        } else {
          _insertText('.');
        }
      }
    }
    _hasError = false;
    _evaluatePreview();
    notifyListeners();
  }

  void inputParenthesis() {
    if (_resultDisplayed) {
      _expression = '(';
      _cursorPosition = 1;
      _resultDisplayed = false;
    } else {
      final pos = cursorPosition;
      final before = _expression.substring(0, pos);
      final openCount = before.split('(').length - 1;
      final closeCount = before.split(')').length - 1;

      if (pos == 0 || '+-×÷('.contains(_expression[pos - 1])) {
        _insertText('(');
      } else if (openCount > closeCount) {
        _insertText(')');
      } else {
        _insertText('×(');
      }
    }
    _hasError = false;
    _evaluatePreview();
    notifyListeners();
  }

  void inputPercent() {
    if (_expression.isNotEmpty) {
      _insertText('%');
      _hasError = false;
      _evaluatePreview();
      notifyListeners();
    }
  }

  void inputFunction(String funcName) {
    if (_resultDisplayed) {
      _expression = '$funcName(${_displayResult.replaceAll(',', '')})';
      _cursorPosition = _expression.length;
      _resultDisplayed = false;
    } else {
      _insertText('$funcName(');
    }
    _hasError = false;
    _evaluatePreview();
    notifyListeners();
  }

  void inputConstant(String constant) {
    if (_resultDisplayed) {
      _expression = constant;
      _cursorPosition = constant.length;
      _resultDisplayed = false;
    } else {
      final pos = cursorPosition;
      if (pos > 0 && '0123456789.)πe'.contains(_expression[pos - 1])) {
        _insertText('×$constant');
      } else {
        _insertText(constant);
      }
    }
    _hasError = false;
    _evaluatePreview();
    notifyListeners();
  }

  void inputPower() {
    if (_expression.isNotEmpty) {
      _insertText('^');
      _hasError = false;
      notifyListeners();
    }
  }

  void inputFactorial() {
    if (_expression.isNotEmpty) {
      _insertText('!');
      _hasError = false;
      _evaluatePreview();
      notifyListeners();
    }
  }

  void toggleSign() {
    if (_resultDisplayed && _displayResult != '0') {
      final val = double.tryParse(_displayResult.replaceAll(',', ''));
      if (val != null) {
        _expression = _formatter.formatForExpression(-val);
        _displayResult = _formatter.format(-val);
        _resultDisplayed = true;
        notifyListeners();
        return;
      }
    }

    if (_expression.isEmpty) return;

    // If expression ends with '(-', toggling sign simply reverses and removes it cleanly
    if (_expression.endsWith('(-')) {
      _expression = _expression.substring(0, _expression.length - 2);
      _hasError = false;
      _evaluatePreview();
      notifyListeners();
      return;
    }

    // Check if the entire expression is wrapped in (-...) or -(...)
    if (_expression.startsWith('(-') && _expression.endsWith(')')) {
      _expression = _expression.substring(2, _expression.length - 1);
      _hasError = false;
      _evaluatePreview();
      notifyListeners();
      return;
    }

    if (_expression.startsWith('-(') && _expression.endsWith(')')) {
      _expression = _expression.substring(2, _expression.length - 1);
      _hasError = false;
      _evaluatePreview();
      notifyListeners();
      return;
    }

    // Check if expression ends with (-<number>)
    final negBracketMatch = RegExp(r'\(-([0-9.]+|π|e)\)$').firstMatch(_expression);
    if (negBracketMatch != null) {
      final innerNum = negBracketMatch.group(1)!;
      _expression = _expression.substring(0, negBracketMatch.start) + innerNum;
      _hasError = false;
      _evaluatePreview();
      notifyListeners();
      return;
    }

    // If expression ends with an operator (+, -, ×, ÷, (), append '(-' to start negative operand
    if ('+-×÷('.contains(_expression[_expression.length - 1])) {
      _expression += '(-';
      _hasError = false;
      _evaluatePreview();
      notifyListeners();
      return;
    }

    // Check if expression ends with a trailing positive number e.g. "2 + 5" or "5"
    final posNumberMatch = RegExp(r'([0-9.]+|π|e)$').firstMatch(_expression);
    if (posNumberMatch != null) {
      final numStr = posNumberMatch.group(1)!;
      final before = _expression.substring(0, posNumberMatch.start);

      if (before.isEmpty) {
        _expression = '(-$numStr)';
      } else if (before.endsWith('-') && (before.length == 1 || '+-×÷('.contains(before[before.length - 2]))) {
        _expression = before.substring(0, before.length - 1) + numStr;
      } else {
        _expression = '$before(-$numStr)';
      }
      _hasError = false;
      _evaluatePreview();
      notifyListeners();
      return;
    }

    // Single negative number
    if (_expression.startsWith('-') && RegExp(r'^-[0-9.]+$').hasMatch(_expression)) {
      _expression = _expression.substring(1);
      _hasError = false;
      _evaluatePreview();
      notifyListeners();
      return;
    }

    // Fallback
    _expression = '(-$_expression)';
    _hasError = false;
    _evaluatePreview();
    notifyListeners();
  }

  void backspace() {
    if (_resultDisplayed) {
      clear();
      return;
    }
    if (_expression.isEmpty) return;
    final pos = cursorPosition;
    if (pos == 0) return;

    final before = _expression.substring(0, pos);
    final funcPattern = RegExp(r'(sin|cos|tan|asin|acos|atan|sinh|cosh|tanh|asinh|acosh|atanh|log|ln|exp|sqrt|cbrt|abs|floor|ceil|round|nPr|nCr)\($');
    final match = funcPattern.firstMatch(before);
    if (match != null && match.end == pos) {
      _expression = _expression.substring(0, match.start) + _expression.substring(pos);
      _cursorPosition = match.start;
    } else {
      _expression = _expression.substring(0, pos - 1) + _expression.substring(pos);
      _cursorPosition = pos - 1;
    }
    _hasError = false;
    _evaluatePreview();
    notifyListeners();
  }

  void clear() {
    _expression = '';
    _cursorPosition = 0;
    _displayResult = '0';
    _previewResult = '';
    _hasError = false;
    _errorMessage = '';
    _resultDisplayed = false;
    notifyListeners();
  }

  void clearEntry() {
    // Remove last number or last operator
    if (_expression.isEmpty) return;

    // Find last operator position
    int lastOpPos = -1;
    for (int i = _expression.length - 1; i >= 0; i--) {
      if ('+-×÷'.contains(_expression[i]) && i > 0) {
        lastOpPos = i;
        break;
      }
    }

    if (lastOpPos > 0) {
      _expression = _expression.substring(0, lastOpPos);
    } else {
      _expression = '';
    }
    _hasError = false;
    _evaluatePreview();
    notifyListeners();
  }

  Future<void> evaluate() async {
    if (_expression.isEmpty) return;

    // Auto-close parentheses
    var expr = _expression;
    final openCount = expr.split('(').length - 1;
    final closeCount = expr.split(')').length - 1;
    for (int i = 0; i < openCount - closeCount; i++) {
      expr += ')';
    }

    // Remove trailing operator
    while (expr.isNotEmpty && '+-×÷'.contains(expr[expr.length - 1])) {
      expr = expr.substring(0, expr.length - 1);
    }

    if (expr.isEmpty) return;

    final result = _engine.evaluate(expr);

    if (result.isSuccess) {
      final formattedResult = _formatter.format(result.value!);
      _displayResult = formattedResult;
      _previewResult = '';
      _hasError = false;
      _resultDisplayed = true;

      // Save to history
      final entry = HistoryEntry(
        expression: _expression,
        result: formattedResult,
        resultValue: result.value,
        timestamp: DateTime.now(),
      );

      try {
        await _historyRepo.insert(entry);
        await loadHistory();
      } catch (_) {
        // Don't crash the calculator if history fails
      }
    } else {
      _hasError = true;
      _errorMessage = result.error ?? 'Calculation error';
      _previewResult = '';
    }

    notifyListeners();
  }

  void _evaluatePreview() {
    if (_expression.isEmpty) {
      _previewResult = '';
      return;
    }

    // Auto-close parentheses for preview
    var expr = _expression;
    final openCount = expr.split('(').length - 1;
    final closeCount = expr.split(')').length - 1;
    for (int i = 0; i < openCount - closeCount; i++) {
      expr += ')';
    }

    // Remove trailing operator for preview
    while (expr.isNotEmpty && '+-×÷'.contains(expr[expr.length - 1])) {
      expr = expr.substring(0, expr.length - 1);
    }

    if (expr.isEmpty) {
      _previewResult = '';
      return;
    }

    final result = _engine.evaluate(expr);
    if (result.isSuccess) {
      _previewResult = _formatter.format(result.value!);
    } else {
      _previewResult = '';
    }
  }

  // Memory operations
  void memoryClear() {
    _memoryValue = null;
    _engine.memoryValue = null;
    notifyListeners();
  }

  void memoryRecall() {
    if (_memoryValue != null) {
      final val = _formatter.formatForExpression(_memoryValue!);
      if (_resultDisplayed) {
        _expression = val;
        _resultDisplayed = false;
      } else {
        _expression += val;
      }
      _evaluatePreview();
      notifyListeners();
    }
  }

  void memoryAdd() {
    final val = _getCurrentValue();
    if (val != null) {
      _memoryValue = (_memoryValue ?? 0) + val;
      _engine.memoryValue = _memoryValue;
      notifyListeners();
    }
  }

  void memorySubtract() {
    final val = _getCurrentValue();
    if (val != null) {
      _memoryValue = (_memoryValue ?? 0) - val;
      _engine.memoryValue = _memoryValue;
      notifyListeners();
    }
  }

  void memoryStore() {
    final val = _getCurrentValue();
    if (val != null) {
      _memoryValue = val;
      _engine.memoryValue = _memoryValue;
      notifyListeners();
    }
  }

  double? _getCurrentValue() {
    if (_resultDisplayed) {
      return double.tryParse(_displayResult.replaceAll(',', ''));
    }
    if (_previewResult.isNotEmpty) {
      return double.tryParse(_previewResult.replaceAll(',', ''));
    }
    return null;
  }

  // History
  Future<void> loadHistory({String? search}) async {
    try {
      _history = await _historyRepo.getAll(search: search);
      _historyLoaded = true;
      notifyListeners();
    } catch (e) {
      _history = [];
      _historyLoaded = true;
      notifyListeners();
    }
  }

  Future<void> deleteHistoryEntry(int id) async {
    await _historyRepo.delete(id);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await _historyRepo.deleteAll();
    _history = [];
    notifyListeners();
  }

  void reuseExpression(String expr) {
    _expression = expr;
    _cursorPosition = expr.length;
    _resultDisplayed = false;
    _hasError = false;
    _evaluatePreview();
    notifyListeners();
  }

  void reuseResult(String result) {
    _expression = result.replaceAll(',', '');
    _cursorPosition = _expression.length;
    _displayResult = result;
    _resultDisplayed = true;
    _hasError = false;
    notifyListeners();
  }

  // Copy result to clipboard
  Future<void> copyResult() async {
    final text = _resultDisplayed ? _displayResult : _previewResult;
    if (text.isNotEmpty && text != '0') {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }

  void setExpression(String expr) {
    _expression = expr;
    _cursorPosition = expr.length;
    _resultDisplayed = false;
    _hasError = false;
    _evaluatePreview();
    notifyListeners();
  }
}
