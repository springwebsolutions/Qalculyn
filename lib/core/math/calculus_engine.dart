// Qalculyn - Numerical Calculus Engine
// Numerical derivatives, definite integrals (Simpson's 1/3 rule), and limit evaluations

import 'calculator_engine.dart';

class CalculusEngine {
  final CalculatorEngine _calc = CalculatorEngine();

  /// Evaluate expression string f(x) at a specific numeric x
  double evaluate(String expression, double x) {
    // Replace variable x (case-insensitive) with numeric value in parentheses
    // Careful with functions like exp, max!
    // Replace standalone 'x' or 'X' preceded/followed by operators or boundaries
    final processed = expression.replaceAllMapped(
      RegExp(r'(^|[^a-zA-Z0-9_])([xX])($|[^a-zA-Z0-9_])'),
      (m) => '${m.group(1)}($x)${m.group(3)}',
    );

    final res = _calc.evaluate(processed);
    if (res.isError || res.value == null) {
      throw FormatException(res.error ?? 'Error evaluating f($x)');
    }
    return res.value!;
  }

  /// Numerical 1st and 2nd derivative at x using central difference
  Map<String, double> differentiate(String expression, double x, {double h = 1e-5}) {
    final fxPlus = evaluate(expression, x + h);
    final fxMinus = evaluate(expression, x - h);
    final fx = evaluate(expression, x);

    final d1 = (fxPlus - fxMinus) / (2.0 * h);
    final d2 = (fxPlus - 2.0 * fx + fxMinus) / (h * h);

    return {
      'fx': fx,
      'firstDerivative': (d1.abs() < 1e-10) ? 0.0 : d1,
      'secondDerivative': (d2.abs() < 1e-8) ? 0.0 : d2,
    };
  }

  /// Composite Simpson's 1/3 rule for definite numerical integration: \int_a^b f(x) dx
  double integrate(String expression, double a, double b, {int n = 1000}) {
    if (n % 2 != 0) n++; // Ensure even number of subintervals
    final h = (b - a) / n;

    var sum = evaluate(expression, a) + evaluate(expression, b);

    for (var i = 1; i < n; i++) {
      final x = a + i * h;
      final y = evaluate(expression, x);
      if (y.isNaN || y.isInfinite) {
        throw FormatException('Singularity encountered at x = $x');
      }
      sum += (i % 2 == 1) ? 4.0 * y : 2.0 * y;
    }

    final result = (h / 3.0) * sum;
    return (result.abs() < 1e-12) ? 0.0 : result;
  }

  /// Estimate limit of f(x) as x -> c from left, right, and two-sided
  Map<String, dynamic> evaluateLimit(String expression, double c) {
    const deltas = [1e-3, 1e-4, 1e-5, 1e-6];

    double? leftVal;
    double? rightVal;

    try {
      leftVal = evaluate(expression, c - deltas.last);
    } catch (_) {}

    try {
      rightVal = evaluate(expression, c + deltas.last);
    } catch (_) {}

    if (leftVal == null && rightVal == null) {
      return {'status': 'undefined', 'message': 'Function is undefined in neighborhood of $c'};
    }

    final isContinuous = leftVal != null && rightVal != null && (leftVal - rightVal).abs() < 1e-4;
    final limit = isContinuous ? (leftVal + rightVal) / 2.0 : null;

    return {
      'leftLimit': leftVal,
      'rightLimit': rightVal,
      'limit': limit,
      'exists': isContinuous,
    };
  }
}
