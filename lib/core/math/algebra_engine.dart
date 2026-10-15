// Qalculyn - Algebra & Symbolic Mathematics Engine
// Implements Monomial LCM/GCD, Polynomial Euclidean GCD/LCM, Factoring, and Equation Solvers

import 'dart:math' as math;
import 'big_rational.dart';
import 'number_theory.dart';

/// Represents a single algebraic monomial: c * x1^e1 * x2^e2 ...
class Monomial {
  final BigInt coefficient;
  final Map<String, int> variables; // Variable name -> non-negative exponent

  const Monomial({
    required this.coefficient,
    required this.variables,
  });

  static final Monomial zero = Monomial(coefficient: BigInt.zero, variables: const {});
  static final Monomial one = Monomial(coefficient: BigInt.one, variables: const {});

  bool get isZero => coefficient == BigInt.zero;
  bool get isConstant => variables.isEmpty;

  /// Parse a monomial string like "6*x^2*y", "-9*x*y^3", "12a^2b^3", "-x", "5"
  static Monomial parse(String input) {
    var str = input.replaceAll(' ', '').trim();
    if (str.isEmpty) return Monomial.zero;

    // Check negative
    var isNeg = false;
    if (str.startsWith('-')) {
      isNeg = true;
      str = str.substring(1);
    } else if (str.startsWith('+')) {
      str = str.substring(1);
    }

    if (str.isEmpty) return Monomial.zero;

    // Extract leading numeric coefficient
    final coeffMatch = RegExp(r'^(\d+)').firstMatch(str);
    BigInt coeff;
    var remainder = str;

    if (coeffMatch != null) {
      coeff = BigInt.parse(coeffMatch.group(1)!);
      remainder = str.substring(coeffMatch.end);
      if (remainder.startsWith('*')) {
        remainder = remainder.substring(1);
      }
    } else {
      coeff = BigInt.one;
    }

    if (isNeg) coeff = -coeff;

    // Parse variables and exponents
    final vars = <String, int>{};
    if (remainder.isNotEmpty) {
      final varRegex = RegExp(r'\*?([a-zA-Z])(?:\^(\d+))?');
      for (final match in varRegex.allMatches(remainder)) {
        final varName = match.group(1)!;
        final expStr = match.group(2);
        final exp = expStr != null ? int.parse(expStr) : 1;
        vars[varName] = (vars[varName] ?? 0) + exp;
      }
    }

    // Sort variable names canonically
    final sortedVars = Map.fromEntries(
      vars.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    return Monomial(coefficient: coeff, variables: sortedVars);
  }

  /// Monomial GCD
  static Monomial gcd(Monomial m1, Monomial m2) {
    if (m1.isZero) return m2.abs();
    if (m2.isZero) return m1.abs();

    final coeffGcd = NumberTheory.gcd(m1.coefficient, m2.coefficient);
    final allVars = {...m1.variables.keys, ...m2.variables.keys};
    final resVars = <String, int>{};

    for (final v in allVars) {
      final e1 = m1.variables[v] ?? 0;
      final e2 = m2.variables[v] ?? 0;
      final minExp = math.min(e1, e2);
      if (minExp > 0) {
        resVars[v] = minExp;
      }
    }

    final sortedVars = Map.fromEntries(
      resVars.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    return Monomial(coefficient: coeffGcd, variables: sortedVars);
  }

  /// Monomial LCM
  static Monomial lcm(Monomial m1, Monomial m2) {
    if (m1.isZero || m2.isZero) return Monomial.zero;

    final coeffLcm = NumberTheory.lcm(m1.coefficient, m2.coefficient);
    final allVars = {...m1.variables.keys, ...m2.variables.keys};
    final resVars = <String, int>{};

    for (final v in allVars) {
      final e1 = m1.variables[v] ?? 0;
      final e2 = m2.variables[v] ?? 0;
      final maxExp = math.max(e1, e2);
      if (maxExp > 0) {
        resVars[v] = maxExp;
      }
    }

    final sortedVars = Map.fromEntries(
      resVars.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    return Monomial(coefficient: coeffLcm, variables: sortedVars);
  }

  Monomial abs() => Monomial(coefficient: coefficient.abs(), variables: variables);

  @override
  String toString() {
    if (isZero) return '0';
    final sb = StringBuffer();

    if (variables.isEmpty) {
      return coefficient.toString();
    }

    if (coefficient == -BigInt.one) {
      sb.write('-');
    } else if (coefficient != BigInt.one) {
      sb.write(coefficient);
    }

    for (final entry in variables.entries) {
      sb.write(entry.key);
      if (entry.value > 1) {
        sb.write('^${entry.value}');
      }
    }

    return sb.toString();
  }
}

/// Univariate Polynomial in Q[x] with exact rational coefficients
class Polynomial {
  final String variable;
  // Coefficients: index i corresponds to coefficient of variable^i
  final List<BigRational> coeffs;

  Polynomial(List<BigRational> coefficients, {this.variable = 'x'})
      : coeffs = _cleanCoeffs(coefficients);

  static List<BigRational> _cleanCoeffs(List<BigRational> raw) {
    var len = raw.length;
    while (len > 0 && raw[len - 1].isZero) {
      len--;
    }
    return raw.sublist(0, len);
  }

  static Polynomial zero({String variable = 'x'}) => Polynomial(const [], variable: variable);
  static Polynomial one({String variable = 'x'}) => Polynomial([BigRational.one], variable: variable);

  int get degree => coeffs.isEmpty ? -1 : coeffs.length - 1;
  bool get isZero => coeffs.isEmpty;
  bool get isConstant => degree <= 0;

  BigRational get leadingCoeff => isZero ? BigRational.zero : coeffs.last;

  /// Parse polynomial like "x^2 - 2*x + 1", "6x^2 + 12x", "x^3 - 8"
  static Polynomial parse(String input, {String variable = 'x'}) {
    var str = input.replaceAll(' ', '').trim();
    if (str.isEmpty) return Polynomial.zero(variable: variable);

    // Normalize signs: replace '-' with '+-'
    final terms = <String>[];
    var current = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      final ch = str[i];
      if ((ch == '+' || ch == '-') && i > 0 && str[i - 1] != '^' && str[i - 1] != '(' && str[i - 1] != '*') {
        terms.add(current.toString());
        current = StringBuffer(ch);
      } else {
        current.write(ch);
      }
    }
    if (current.isNotEmpty) {
      terms.add(current.toString());
    }

    final coeffMap = <int, BigRational>{};

    for (var term in terms) {
      term = term.trim();
      if (term.isEmpty || term == '+') continue;
      var isNeg = false;
      if (term.startsWith('+')) term = term.substring(1);
      if (term.startsWith('-')) {
        isNeg = true;
        term = term.substring(1);
      }

      if (!term.contains(variable)) {
        // Pure constant term
        final val = BigRational.parse(term);
        coeffMap[0] = (coeffMap[0] ?? BigRational.zero) + (isNeg ? -val : val);
      } else {
        // Contains variable
        final vIdx = term.indexOf(variable);
        final coeffStr = term.substring(0, vIdx).replaceAll('*', '');
        final expPart = term.substring(vIdx + variable.length);

        var c = BigRational.one;
        if (coeffStr.isNotEmpty) {
          try {
            c = BigRational.parse(coeffStr);
          } catch (_) {
            c = BigRational.one;
          }
        }
        if (isNeg) c = -c;

        var exp = 1;
        if (expPart.startsWith('^')) {
          final expDigits = expPart.substring(1).trim();
          exp = int.tryParse(expDigits) ?? 1;
        } else if (expPart.isNotEmpty) {
          exp = int.tryParse(expPart.trim()) ?? 1;
        }

        coeffMap[exp] = (coeffMap[exp] ?? BigRational.zero) + c;
      }
    }

    final maxDegree = coeffMap.keys.isEmpty ? 0 : coeffMap.keys.reduce(math.max);
    final resultList = List<BigRational>.filled(maxDegree + 1, BigRational.zero);
    for (final entry in coeffMap.entries) {
      resultList[entry.key] = entry.value;
    }

    return Polynomial(resultList, variable: variable);
  }

  Polynomial operator +(Polynomial other) {
    final maxLen = math.max(coeffs.length, other.coeffs.length);
    final res = <BigRational>[];
    for (var i = 0; i < maxLen; i++) {
      final c1 = i < coeffs.length ? coeffs[i] : BigRational.zero;
      final c2 = i < other.coeffs.length ? other.coeffs[i] : BigRational.zero;
      res.add(c1 + c2);
    }
    return Polynomial(res, variable: variable);
  }

  Polynomial operator -(Polynomial other) {
    final maxLen = math.max(coeffs.length, other.coeffs.length);
    final res = <BigRational>[];
    for (var i = 0; i < maxLen; i++) {
      final c1 = i < coeffs.length ? coeffs[i] : BigRational.zero;
      final c2 = i < other.coeffs.length ? other.coeffs[i] : BigRational.zero;
      res.add(c1 - c2);
    }
    return Polynomial(res, variable: variable);
  }

  Polynomial operator *(Polynomial other) {
    if (isZero || other.isZero) return Polynomial.zero(variable: variable);
    final totalLen = coeffs.length + other.coeffs.length - 1;
    final res = List<BigRational>.filled(totalLen, BigRational.zero);
    for (var i = 0; i < coeffs.length; i++) {
      for (var j = 0; j < other.coeffs.length; j++) {
        res[i + j] = res[i + j] + (coeffs[i] * other.coeffs[j]);
      }
    }
    return Polynomial(res, variable: variable);
  }

  Polynomial scale(BigRational scalar) {
    if (scalar.isZero) return Polynomial.zero(variable: variable);
    return Polynomial(coeffs.map((c) => c * scalar).toList(), variable: variable);
  }

  /// Polynomial division with remainder: returns (Quotient, Remainder) such that A = Q * B + R with deg(R) < deg(B)
  (Polynomial, Polynomial) divideWithRemainder(Polynomial divisor) {
    if (divisor.isZero) {
      throw const FormatException('Division by zero polynomial');
    }
    if (degree < divisor.degree) {
      return (Polynomial.zero(variable: variable), this);
    }

    var remainder = Polynomial(List.of(coeffs), variable: variable);
    final quotientCoeffs = List<BigRational>.filled(degree - divisor.degree + 1, BigRational.zero);
    final divLead = divisor.leadingCoeff;

    while (!remainder.isZero && remainder.degree >= divisor.degree) {
      final degDiff = remainder.degree - divisor.degree;
      final factor = remainder.leadingCoeff / divLead;
      quotientCoeffs[degDiff] = factor;

      // Subtract factor * x^degDiff * divisor
      final subCoeffs = List<BigRational>.filled(degDiff + divisor.coeffs.length, BigRational.zero);
      for (var i = 0; i < divisor.coeffs.length; i++) {
        subCoeffs[degDiff + i] = divisor.coeffs[i] * factor;
      }
      remainder = remainder - Polynomial(subCoeffs, variable: variable);
    }

    return (Polynomial(quotientCoeffs, variable: variable), remainder);
  }

  /// Make monic (leading coefficient = 1)
  Polynomial toMonic() {
    if (isZero) return this;
    final lead = leadingCoeff;
    if (lead == BigRational.one) return this;
    return scale(lead.inverse());
  }

  /// Normalize to integer coefficients with positive leading coefficient
  Polynomial toPrimitiveInteger() {
    if (isZero) return this;
    // Find LCM of denominators
    var denLcm = BigInt.one;
    for (final c in coeffs) {
      if (!c.isZero) denLcm = NumberTheory.lcm(denLcm, c.den);
    }
    final intCoeffs = coeffs.map((c) => (c.num * denLcm) ~/ c.den).toList();
    // Find GCD of numerators
    final numGcd = NumberTheory.gcdMany(intCoeffs);
    var scaleSign = intCoeffs.last < BigInt.zero ? -BigInt.one : BigInt.one;
    final normalized = intCoeffs.map((n) => BigRational(scaleSign * (n ~/ numGcd))).toList();
    return Polynomial(normalized, variable: variable);
  }

  /// Euclidean algorithm for polynomial GCD in Q[x]
  static Polynomial gcd(Polynomial p1, Polynomial p2) {
    var a = p1;
    var b = p2;

    if (a.isZero && b.isZero) return Polynomial.zero(variable: a.variable);
    if (a.isZero) return b.toMonic();
    if (b.isZero) return a.toMonic();

    while (!b.isZero) {
      final (_, r) = a.divideWithRemainder(b);
      a = b;
      b = r;
    }

    return a.toMonic();
  }

  /// Polynomial LCM: LCM(A, B) = (A * B) / GCD(A, B) normalized to monic
  static Polynomial lcm(Polynomial p1, Polynomial p2) {
    if (p1.isZero || p2.isZero) return Polynomial.zero(variable: p1.variable);
    final g = gcd(p1, p2);
    final (quotient, _) = (p1 * p2).divideWithRemainder(g);
    return quotient.toMonic();
  }

  BigRational evaluate(BigRational x) {
    var result = BigRational.zero;
    var power = BigRational.one;
    for (final c in coeffs) {
      result = result + (c * power);
      power = power * x;
    }
    return result;
  }

  @override
  String toString() {
    if (isZero) return '0';
    final sb = StringBuffer();
    var first = true;

    for (var i = coeffs.length - 1; i >= 0; i--) {
      final c = coeffs[i];
      if (c.isZero) continue;

      if (first) {
        if (c.isNegative) sb.write('-');
        first = false;
      } else {
        sb.write(c.isNegative ? ' - ' : ' + ');
      }

      final absC = c.abs();

      if (i == 0) {
        sb.write(absC);
      } else {
        if (absC != BigRational.one) {
          sb.write('$absC*');
        }
        sb.write(variable);
        if (i > 1) {
          sb.write('^$i');
        }
      }
    }
    return sb.toString();
  }
}

/// Linear and Quadratic Equation Solvers with exact analytical steps
class EquationSolver {
  /// Solves a*x + b = 0 => x = -b / a
  static Map<String, dynamic> solveLinear(BigRational a, BigRational b) {
    if (a.isZero) {
      if (b.isZero) {
        return {
          'status': 'infinite',
          'explanation': '0 = 0 is an identity. There are infinitely many solutions for any real x.',
        };
      } else {
        return {
          'status': 'none',
          'explanation': '$b = 0 is a contradiction. There are no solutions.',
        };
      }
    }

    final root = -b / a;
    final steps = [
      'Equation in standard form: ${a}x + ($b) = 0',
      'Step 1: Subtract constant term: ${a}x = ${-b}',
      'Step 2: Divide by coefficient of x: x = (${-b}) ÷ ($a)',
      'Step 3: Solution x = $root',
    ];

    return {
      'status': 'single',
      'root': root,
      'rootDouble': root.toDouble(),
      'steps': steps,
    };
  }

  /// Solves a*x^2 + b*x + c = 0 using the quadratic formula with exact discriminant
  static Map<String, dynamic> solveQuadratic(BigRational a, BigRational b, BigRational c) {
    if (a.isZero) {
      return solveLinear(b, c);
    }

    // Discriminant Delta = b^2 - 4*a*c
    final disc = (b * b) - (BigRational.fromInt(4) * a * c);
    final discDouble = disc.toDouble();
    final steps = <String>[
      'Equation: ($a)x² + ($b)x + ($c) = 0',
      'Quadratic Formula: x = [-b ± √(b² - 4ac)] / (2a)',
      'Step 1: Calculate Discriminant Δ = ($b)² - 4($a)($c) = $disc',
    ];

    // Check if discriminant is a perfect square rational (num and den are perfect squares)
    bool isSquare = false;
    BigRational? sqrtDisc;
    if (disc.isPositive || disc.isZero) {
      final (sqNum, rNum) = NumberTheory.isPerfectSquare(disc.num);
      final (sqDen, rDen) = NumberTheory.isPerfectSquare(disc.den);
      if (sqNum && sqDen) {
        isSquare = true;
        sqrtDisc = BigRational(rNum, rDen);
      }
    }

    final twoA = BigRational.fromInt(2) * a;
    final fourA = BigRational.fromInt(4) * a;
    final vertexX = -b / twoA;
    final vertexY = c - ((b * b) / fourA);
    final vertexStr = '($vertexX, $vertexY)';

    if (disc.isZero) {
      final root = -b / twoA;
      steps.add('Step 2: Δ = 0 implies exactly one repeated real root.');
      steps.add('Step 3: x = -b / (2a) = ${-b} / ($twoA) = $root');
      return {
        'status': 'repeated',
        'discriminant': disc,
        'root1': root,
        'root2': root,
        'steps': steps,
        'vertex': vertexStr,
      };
    } else if (disc.isPositive) {
      steps.add('Step 2: Δ > 0 implies two distinct real roots.');
      if (isSquare && sqrtDisc != null) {
        final root1 = (-b + sqrtDisc) / twoA;
        final root2 = (-b - sqrtDisc) / twoA;
        steps.add('Step 3: √Δ = $sqrtDisc (exact rational)');
        steps.add('x₁ = [${-b} + $sqrtDisc] / $twoA = $root1');
        steps.add('x₂ = [${-b} - $sqrtDisc] / $twoA = $root2');
        return {
          'status': 'real_exact',
          'discriminant': disc,
          'root1': root1,
          'root2': root2,
          'root1Double': root1.toDouble(),
          'root2Double': root2.toDouble(),
          'steps': steps,
          'vertex': vertexStr,
        };
      } else {
        final sqrtD = math.sqrt(discDouble);
        final twoADouble = twoA.toDouble();
        final bDouble = b.toDouble();
        final r1 = (-bDouble + sqrtD) / twoADouble;
        final r2 = (-bDouble - sqrtD) / twoADouble;
        steps.add('Step 3: √Δ ≈ ${sqrtD.toStringAsFixed(6)}');
        steps.add('x₁ ≈ ${r1.toStringAsFixed(6)}');
        steps.add('x₂ ≈ ${r2.toStringAsFixed(6)}');
        return {
          'status': 'real_approx',
          'discriminant': disc,
          'root1Double': r1,
          'root2Double': r2,
          'steps': steps,
          'vertex': vertexStr,
        };
      }
    } else {
      // Complex roots
      final twoADouble = twoA.toDouble();
      final realPart = -b.toDouble() / twoADouble;
      final imagPart = math.sqrt(-discDouble) / twoADouble;
      steps.add('Step 2: Δ < 0 implies two complex conjugate roots.');
      steps.add('Real Part: -b / (2a) = ${realPart.toStringAsFixed(4)}');
      steps.add('Imaginary Part: √(|$disc|) / (2a) = ${imagPart.abs().toStringAsFixed(4)}');
      steps.add('x₁ = ${realPart.toStringAsFixed(4)} + ${imagPart.abs().toStringAsFixed(4)}i');
      steps.add('x₂ = ${realPart.toStringAsFixed(4)} - ${imagPart.abs().toStringAsFixed(4)}i');
      return {
        'status': 'complex',
        'discriminant': disc,
        'realPart': realPart,
        'imagPart': imagPart.abs(),
        'steps': steps,
        'vertex': vertexStr,
      };
    }
  }

  /// Factoring simple quadratics: a*x^2 + b*x + c over rationals/integers
  static String factorQuadratic(BigRational a, BigRational b, BigRational c, {String variable = 'x'}) {
    if (a.isZero) {
      if (b.isZero) return c.toString();
      return '($b$variable + $c)';
    }

    // Common factor out 'a'
    final disc = (b * b) - (BigRational.fromInt(4) * a * c);
    if (disc.isNegative) {
      return 'Irreducible over real numbers (Δ = $disc < 0)';
    }

    final (sqNum, rNum) = NumberTheory.isPerfectSquare(disc.num);
    final (sqDen, rDen) = NumberTheory.isPerfectSquare(disc.den);
    if (!sqNum || !sqDen) {
      return 'Irreducible over rationals (Δ = $disc is not a square)';
    }

    final sqrtDisc = BigRational(rNum, rDen);
    final twoA = BigRational.fromInt(2) * a;
    final r1 = (-b + sqrtDisc) / twoA;
    final r2 = (-b - sqrtDisc) / twoA;

    final term1 = r1.isNegative ? '($variable + ${r1.abs()})' : (r1.isZero ? variable : '($variable - $r1)');
    final term2 = r2.isNegative ? '($variable + ${r2.abs()})' : (r2.isZero ? variable : '($variable - $r2)');

    if (a == BigRational.one) {
      return '$term1 * $term2';
    } else if (a == BigRational.minusOne) {
      return '-($term1 * $term2)';
    } else {
      return '$a * $term1 * $term2';
    }
  }
}
