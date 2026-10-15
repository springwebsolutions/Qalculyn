// Qalculyn - Smart Math Command Parser & Dispatcher
// Safely parses and evaluates mathematical commands without code execution

import 'big_rational.dart';
import 'number_theory.dart';
import 'algebra_engine.dart';
import 'matrix_vector.dart';
import 'calculus_engine.dart';
import 'statistics_engine.dart';
import 'sequences_base.dart';
import 'natural_language_parser.dart';

class SmartCommandResult {
  final bool isSuccess;
  final String command;
  final String result;
  final String? explanation;
  final String? error;

  const SmartCommandResult.success({
    required this.command,
    required this.result,
    this.explanation,
  })  : isSuccess = true,
        error = null;

  const SmartCommandResult.failure({
    required this.command,
    required this.error,
  })  : isSuccess = false,
        result = '',
        explanation = null;
}

class SmartMathCommand {
  static const List<String> availableCommands = [
    'lcm(a, b, ...)',
    'gcd(a, b, ...)',
    'hcf(a, b, ...)',
    'factor(n or expr)',
    'prime(n)',
    'solve(equation)',
    'simplify(expr)',
    'fib(n)',
    'det([[a,b],[c,d]])',
    'cross([x,y,z], [x,y,z])',
    'dot([x,y,z], [x,y,z])',
    'mean(x1, x2, ...)',
    'ncr(n, r)',
    'npr(n, r)',
    'base(val, fromBase, toBase)',
    'diff(expr, x)',
    'integrate(expr, a, b)',
    'convert(val, fromUnit, toUnit)',
  ];

  static SmartCommandResult execute(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const SmartCommandResult.failure(command: '', error: 'Command is empty');
    }

    final match = RegExp(r'^([a-zA-Z_]+)\s*\((.*)\)$', dotAll: true).firstMatch(trimmed);
    if (match == null) {
      final nlResult = NaturalLanguageParser.parse(trimmed);
      if (nlResult.isMatch) {
        final buffer = StringBuffer();
        if (nlResult.title != null) buffer.writeln('${nlResult.title}\n');
        if (nlResult.formula != null) buffer.writeln('Formula: ${nlResult.formula}\n');
        for (final entry in nlResult.results.entries) {
          buffer.writeln('${entry.key}: ${entry.value}');
        }
        return SmartCommandResult.success(
          command: trimmed,
          result: buffer.toString().trim(),
          explanation: nlResult.explanation,
        );
      }

      return SmartCommandResult.failure(
        command: trimmed,
        error: 'Could not calculate this. Try questions like "lcm of 12 and 18", "area of circle radius 5", or "mrp 1180 with 18% gst".',
      );
    }

    final name = match.group(1)!.toLowerCase();
    final argsStr = match.group(2)!.trim();

    try {
      switch (name) {
        // LCM
        case 'lcm':
          final nums = _parseBigIntList(argsStr);
          if (nums.isEmpty) throw const FormatException('lcm requires at least one integer argument');
          final ans = NumberTheory.lcmMany(nums);
          return SmartCommandResult.success(
            command: 'lcm(${nums.join(", ")})',
            result: ans.toString(),
            explanation: 'Least Common Multiple of ${nums.join(", ")}',
          );

        // GCD / HCF
        case 'gcd':
        case 'hcf':
          final nums = _parseBigIntList(argsStr);
          if (nums.isEmpty) throw const FormatException('gcd/hcf requires at least one integer argument');
          final ans = NumberTheory.gcdMany(nums);
          return SmartCommandResult.success(
            command: '$name(${nums.join(", ")})',
            result: ans.toString(),
            explanation: 'Greatest Common Divisor of ${nums.join(", ")}',
          );

        // Prime check
        case 'prime':
        case 'isprime':
          final n = BigInt.parse(argsStr.trim());
          final isPr = NumberTheory.isPrime(n.abs());
          return SmartCommandResult.success(
            command: 'prime($n)',
            result: isPr ? 'YES (Prime)' : 'NO (Composite)',
            explanation: isPr ? '$n has no divisors other than 1 and itself' : '$n is not prime',
          );

        // Fibonacci
        case 'fib':
        case 'fibonacci':
          final n = int.parse(argsStr.trim());
          final res = SequencesEngine.fibonacci(n);
          return SmartCommandResult.success(
            command: 'fib($n)',
            result: res['fn'].toString(),
            explanation: 'F_$n in the Fibonacci sequence',
          );

        // Factoring (integer or quadratic polynomial)
        case 'factor':
          final bigInt = BigInt.tryParse(argsStr.trim());
          if (bigInt != null) {
            final f = NumberTheory.primeFactors(bigInt);
            return SmartCommandResult.success(
              command: 'factor($bigInt)',
              result: NumberTheory.formatPrimeFactors(f),
              explanation: 'Prime factorization of $bigInt',
            );
          } else {
            // Polynomial factoring
            final poly = Polynomial.parse(argsStr);
            if (poly.degree == 2) {
              final a = poly.coeffs.length > 2 ? poly.coeffs[2] : BigRational.zero;
              final b = poly.coeffs.length > 1 ? poly.coeffs[1] : BigRational.zero;
              final c = poly.coeffs.isNotEmpty ? poly.coeffs[0] : BigRational.zero;
              final ans = EquationSolver.factorQuadratic(a, b, c);
              return SmartCommandResult.success(
                command: 'factor($argsStr)',
                result: ans,
                explanation: 'Factored form of quadratic polynomial',
              );
            } else {
              return SmartCommandResult.success(
                command: 'factor($argsStr)',
                result: poly.toString(),
                explanation: 'Simplified polynomial',
              );
            }
          }

        // Simplify expression / polynomial
        case 'simplify':
          final poly = Polynomial.parse(argsStr);
          return SmartCommandResult.success(
            command: 'simplify($argsStr)',
            result: poly.toString(),
            explanation: 'Canonical collected terms: degree ${poly.degree}',
          );

        // Solve equation: e.g. solve(2*x + 5 = 15) or solve(x^2 - 5x + 6 = 0)
        case 'solve':
          final eqParts = argsStr.split('=');
          if (eqParts.length != 2) {
            throw const FormatException('solve expects an equation with \'=\', e.g. solve(2x + 5 = 15)');
          }
          final lhs = Polynomial.parse(eqParts[0]);
          final rhs = Polynomial.parse(eqParts[1]);
          final diff = lhs - rhs;

          if (diff.degree == 1) {
            final a = diff.coeffs[1];
            final b = diff.coeffs[0];
            final lin = EquationSolver.solveLinear(a, b);
            return SmartCommandResult.success(
              command: 'solve($argsStr)',
              result: 'x = ${lin["root"]}',
              explanation: 'Linear solution',
            );
          } else if (diff.degree == 2) {
            final a = diff.coeffs[2];
            final b = diff.coeffs[1];
            final c = diff.coeffs[0];
            final q = EquationSolver.solveQuadratic(a, b, c);
            final status = q['status'] as String;
            String ans;
            if (status == 'repeated') {
              ans = 'x = ${q["root1"]} (repeated)';
            } else if (status == 'real_exact') {
              ans = 'x₁ = ${q["root1"]}, x₂ = ${q["root2"]}';
            } else if (status == 'complex') {
              ans = '${q["realPart"]} ± ${q["imagPart"]}i';
            } else {
              ans = 'x₁ ≈ ${q["root1Double"]}, x₂ ≈ ${q["root2Double"]}';
            }
            return SmartCommandResult.success(
              command: 'solve($argsStr)',
              result: ans,
              explanation: 'Quadratic roots (Discriminant Δ = ${q["discriminant"]})',
            );
          } else {
            throw FormatException('Equation degree ${diff.degree} is outside standard algebraic solver domain');
          }

        // Determinant: det([[1,2],[3,4]])
        case 'det':
          final mat = Matrix.parse(argsStr);
          final d = mat.determinant();
          return SmartCommandResult.success(
            command: 'det($argsStr)',
            result: d.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), ''),
            explanation: 'Determinant of ${mat.rows}×${mat.cols} matrix',
          );

        // Vector Cross Product: cross([1,0,0], [0,1,0])
        case 'cross':
          final parts = _splitTwoVectors(argsStr);
          final v1 = Vector3D.parse(parts[0]);
          final v2 = Vector3D.parse(parts[1]);
          final ans = v1.cross(v2);
          return SmartCommandResult.success(
            command: 'cross($v1, $v2)',
            result: ans.toString(),
            explanation: '3D Vector Cross Product (perpendicular vector)',
          );

        // Vector Dot Product: dot([1,2,3], [4,5,6])
        case 'dot':
          final parts = _splitTwoVectors(argsStr);
          final v1 = Vector3D.parse(parts[0]);
          final v2 = Vector3D.parse(parts[1]);
          final ans = v1.dot(v2);
          return SmartCommandResult.success(
            command: 'dot($v1, $v2)',
            result: ans.toString(),
            explanation: 'Vector Dot Product (scalar)',
          );

        // Statistics Mean: mean(1, 2, 3, 4, 5)
        case 'mean':
        case 'avg':
          final nums = _parseDoubleList(argsStr);
          final desc = StatisticsEngine.describe(nums);
          return SmartCommandResult.success(
            command: 'mean(${nums.join(", ")})',
            result: (desc['mean'] as double).toString(),
            explanation: 'Arithmetic mean of ${nums.length} values',
          );

        // Combinations: ncr(10, 3)
        case 'ncr':
          final parts = argsStr.split(RegExp(r'[,;\s]+')).where((s) => s.isNotEmpty).toList();
          final n = int.parse(parts[0]);
          final r = int.parse(parts[1]);
          final ans = StatisticsEngine.combinations(n, r);
          return SmartCommandResult.success(
            command: 'nCr($n, $r)',
            result: ans.toString(),
            explanation: 'Combinations of $n items taken $r at a time',
          );

        // Permutations: npr(10, 3)
        case 'npr':
          final parts = argsStr.split(RegExp(r'[,;\s]+')).where((s) => s.isNotEmpty).toList();
          final n = int.parse(parts[0]);
          final r = int.parse(parts[1]);
          final ans = StatisticsEngine.permutations(n, r);
          return SmartCommandResult.success(
            command: 'nPr($n, $r)',
            result: ans.toString(),
            explanation: 'Permutations of $n items taken $r at a time',
          );

        // Base Conversion: base(255, 10, 16)
        case 'base':
          final parts = argsStr.split(RegExp(r'[,;\s]+')).where((s) => s.isNotEmpty).toList();
          final val = parts[0];
          final b1 = int.parse(parts[1]);
          final b2 = int.parse(parts[2]);
          final ans = BaseConverter.convert(val, b1, b2);
          return SmartCommandResult.success(
            command: 'base($val, $b1, $b2)',
            result: ans,
            explanation: 'Converted from base $b1 to base $b2',
          );

        // Numerical Derivative: diff(x^2, 3)
        case 'diff':
        case 'derivative':
          final parts = argsStr.split(',');
          final expr = parts[0].trim();
          final x = double.parse(parts[1].trim());
          final calc = CalculusEngine();
          final res = calc.differentiate(expr, x);
          return SmartCommandResult.success(
            command: 'diff($expr, $x)',
            result: res['firstDerivative']!.toStringAsFixed(4),
            explanation: 'Numerical derivative f\'($x)',
          );

        // Numerical Integration: integrate(x^2, 0, 3)
        case 'integrate':
        case 'int':
          final parts = argsStr.split(',');
          final expr = parts[0].trim();
          final a = double.parse(parts[1].trim());
          final b = double.parse(parts[2].trim());
          final calc = CalculusEngine();
          final res = calc.integrate(expr, a, b);
          return SmartCommandResult.success(
            command: 'integrate($expr, $a, $b)',
            result: res.toStringAsFixed(4),
            explanation: 'Definite integral from $a to $b',
          );

        // Unit conversion: convert(100, cm, m)
        case 'convert':
          final parts = argsStr.split(RegExp(r'[,;\s]+')).where((s) => s.isNotEmpty).toList();
          final val = double.parse(parts[0]);
          final u1 = parts[1].toLowerCase();
          final u2 = parts[2].toLowerCase();
          final ans = _simpleConvert(val, u1, u2);
          return SmartCommandResult.success(
            command: 'convert($val, $u1, $u2)',
            result: '$ans $u2',
            explanation: '$val $u1 = $ans $u2',
          );

        default:
          return SmartCommandResult.failure(
            command: trimmed,
            error: 'Unknown function "$name". You can use commands like lcm, gcd, factor, solve, fib, prime, or plain English questions.',
          );
      }
    } catch (e) {
      var cleanMsg = e.toString().replaceAll('FormatException: ', '').replaceAll('Exception: ', '').trim();
      if (cleanMsg.contains('Invalid radix-10') || cleanMsg.contains('Invalid double') || cleanMsg.contains('Could not parse')) {
        cleanMsg = 'Please enter valid numbers in the command arguments';
      } else if (cleanMsg.contains('Division by zero')) {
        cleanMsg = 'Cannot divide by zero';
      }
      final atIdx = cleanMsg.indexOf(' (at character');
      if (atIdx != -1) {
        cleanMsg = cleanMsg.substring(0, atIdx).trim();
      }
      return SmartCommandResult.failure(
        command: trimmed,
        error: cleanMsg.isNotEmpty ? cleanMsg : 'Please check your calculation inputs',
      );
    }
  }

  static List<BigInt> _parseBigIntList(String s) {
    return s.split(RegExp(r'[,;\s]+')).where((t) => t.isNotEmpty).map((t) => BigInt.parse(t.trim())).toList();
  }

  static List<double> _parseDoubleList(String s) {
    return s.split(RegExp(r'[,;\s]+')).where((t) => t.isNotEmpty).map((t) => double.parse(t.trim())).toList();
  }

  static List<String> _splitTwoVectors(String s) {
    // Looks for two bracketed vectors: [1,2,3], [4,5,6]
    final matches = RegExp(r'\[([^\]]+)\]').allMatches(s).toList();
    if (matches.length == 2) {
      return [matches[0].group(0)!, matches[1].group(0)!];
    }
    // Fallback: split by comma in middle
    final idx = s.indexOf('],');
    if (idx != -1) {
      return [s.substring(0, idx + 1).trim(), s.substring(idx + 2).trim()];
    }
    throw const FormatException('Expected two vector arguments, e.g. [1,0,0], [0,1,0]');
  }

  static double _simpleConvert(double val, String from, String to) {
    // Length conversion lookup table to meters
    const lengthToM = {
      'm': 1.0,
      'cm': 0.01,
      'mm': 0.001,
      'km': 1000.0,
      'in': 0.0254,
      'ft': 0.3048,
      'yd': 0.9144,
      'mi': 1609.344,
    };

    if (lengthToM.containsKey(from) && lengthToM.containsKey(to)) {
      final meters = val * lengthToM[from]!;
      return meters / lengthToM[to]!;
    }

    // Mass conversion lookup table to kg
    const massToKg = {
      'kg': 1.0,
      'g': 0.001,
      'mg': 1e-6,
      'lb': 0.45359237,
      'oz': 0.028349523,
    };

    if (massToKg.containsKey(from) && massToKg.containsKey(to)) {
      final kg = val * massToKg[from]!;
      return kg / massToKg[to]!;
    }

    throw FormatException('Conversion between \'$from\' and \'$to\' is not supported in quick command');
  }
}
