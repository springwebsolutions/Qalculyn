// Qalculyn - Expression Step-by-Step Explainer
// Generates clean, pure mathematical evaluation steps following PEMDAS order of operations

import 'calculator_engine.dart';

class ExplanationStep {
  final String description;
  final String expressionState;

  const ExplanationStep({required this.description, required this.expressionState});
}

class ExpressionExplainer {
  static final CalculatorEngine _engine = CalculatorEngine();

  /// Generates clean mathematical steps for an expression
  static List<String> explain(String expression) {
    final cleanExpr = expression.trim();
    if (cleanExpr.isEmpty) return ['Empty expression'];

    final steps = <String>[];
    steps.add('Given problem: $cleanExpr');

    // 1. Check for parentheses
    if (cleanExpr.contains('(') && cleanExpr.contains(')')) {
      final parenRegex = RegExp(r'\(([^()]+)\)');
      var match = parenRegex.firstMatch(cleanExpr);
      if (match != null) {
        final inner = match.group(1)!;
        final innerRes = _engine.evaluate(inner);
        if (innerRes.isSuccess) {
          final val = _formatVal(innerRes.value!);
          steps.add('1. Evaluate inside parentheses: ($inner) = $val');
        }
      }
    }

    // 2. Check for functions, powers, factorials
    final funcRegex = RegExp(r'(sin|cos|tan|log|ln|sqrt|cbrt|abs)\(([0-9.]+)\)');
    final funcMatch = funcRegex.firstMatch(cleanExpr);
    if (funcMatch != null) {
      final fRes = _engine.evaluate(funcMatch.group(0)!);
      if (fRes.isSuccess) {
        steps.add('2. Evaluate function: ${funcMatch.group(0)} = ${_formatVal(fRes.value!)}');
      }
    }

    final powRegex = RegExp(r'([0-9.]+)\s*\^\s*([0-9.]+)');
    final powMatch = powRegex.firstMatch(cleanExpr);
    if (powMatch != null) {
      final pRes = _engine.evaluate(powMatch.group(0)!);
      if (pRes.isSuccess) {
        steps.add('2. Evaluate exponentiation: ${powMatch.group(0)} = ${_formatVal(pRes.value!)}');
      }
    }

    final factRegex = RegExp(r'([0-9]+)\s*!');
    final factMatch = factRegex.firstMatch(cleanExpr);
    if (factMatch != null) {
      final fRes = _engine.evaluate(factMatch.group(0)!);
      if (fRes.isSuccess) {
        steps.add('2. Evaluate factorial: ${factMatch.group(0)} = ${_formatVal(fRes.value!)}');
      }
    }

    // 3. Multiplications & Divisions
    final mulDivRegex = RegExp(r'([0-9.]+)\s*([×*÷/])\s*([0-9.]+)');
    final mulDivMatch = mulDivRegex.firstMatch(cleanExpr);
    if (mulDivMatch != null) {
      final mdRes = _engine.evaluate(mulDivMatch.group(0)!);
      if (mdRes.isSuccess) {
        final op = mulDivMatch.group(2) == '×' || mulDivMatch.group(2) == '*' ? 'multiplication' : 'division';
        steps.add('3. Evaluate $op: ${mulDivMatch.group(0)} = ${_formatVal(mdRes.value!)}');
      }
    }

    // 4. Additions & Subtractions
    final addSubRegex = RegExp(r'([0-9.]+)\s*([+\-])\s*([0-9.]+)');
    final addSubMatches = addSubRegex.allMatches(cleanExpr);
    for (final m in addSubMatches) {
      final op = m.group(2) == '+' ? 'addition' : 'subtraction';
      final asRes = _engine.evaluate(m.group(0)!);
      if (asRes.isSuccess) {
        steps.add('4. Evaluate $op: ${m.group(0)} = ${_formatVal(asRes.value!)}');
        break;
      }
    }

    // Final total
    final total = _engine.evaluate(cleanExpr);
    if (total.isSuccess) {
      steps.add('Final Answer = ${_formatVal(total.value!)}');
    }

    // Ensure at least 2 steps exist
    if (steps.length == 1) {
      final res = _engine.evaluate(cleanExpr);
      if (res.isSuccess) {
        steps.add('Evaluated value = ${_formatVal(res.value!)}');
      }
    }

    return steps;
  }

  static String _formatVal(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}
