// Qalculyn Test Suite
// Unit tests and UI tests for mathematics, formatting, number theory, algebra, calculus, matrices, and smart math input

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalculyn/core/design_system/theme.dart';
import 'package:qalculyn/core/math/calculator_engine.dart';
import 'package:qalculyn/core/math/number_formatter.dart';
import 'package:qalculyn/core/math/big_rational.dart';
import 'package:qalculyn/core/math/number_theory.dart';
import 'package:qalculyn/core/math/algebra_engine.dart';
import 'package:qalculyn/core/math/complex_number.dart';
import 'package:qalculyn/core/math/matrix_vector.dart';
import 'package:qalculyn/core/math/calculus_engine.dart';
import 'package:qalculyn/core/math/statistics_engine.dart';
import 'package:qalculyn/core/math/sequences_base.dart';
import 'package:qalculyn/core/math/geometry_engine.dart';
import 'package:qalculyn/core/math/universal_question_engine.dart';
import 'package:qalculyn/core/math/natural_language_parser.dart';
import 'package:qalculyn/core/math/graphing_engine.dart';
import 'package:qalculyn/core/math/smart_math_command.dart';
import 'package:qalculyn/core/providers/calculator_provider.dart';
import 'package:qalculyn/core/providers/settings_provider.dart';
import 'package:qalculyn/core/math/expression_explainer.dart';
import 'package:qalculyn/core/math/linear_system_solver.dart';
import 'package:qalculyn/core/math/polynomial_division.dart';
import 'package:qalculyn/core/math/constants_catalog.dart';
import 'package:qalculyn/features/calculator/calculator_screen.dart';
import 'package:qalculyn/shared/tool_widgets.dart';
import 'package:provider/provider.dart';

void main() {
  group('Calculator Engine Unit Tests', () {
    test('Basic Arithmetic & PEMDAS Precedence', () {
      final engine = CalculatorEngine();

      expect(engine.evaluate('2 + 3 × 4').value, equals(14.0));
      expect(engine.evaluate('(2 + 3) × 4').value, equals(20.0));
      expect(engine.evaluate('10 - 4 - 2').value, equals(4.0));
      expect(engine.evaluate('10 ÷ 2 × 3').value, equals(15.0));
      expect(engine.evaluate('2 ^ 3 + 1').value, equals(9.0));
    });

    test('Decimal & Negative Calculations', () {
      final engine = CalculatorEngine();

      expect(engine.evaluate('0.1 + 0.2').value, closeTo(0.3, 1e-9));
      expect(engine.evaluate('-5 + 3').value, equals(-2.0));
      expect(engine.evaluate('2 × -3').value, equals(-6.0));
    });

    test('Scientific Functions & Trigonometry', () {
      final engineDeg = CalculatorEngine(angleMode: AngleMode.degrees);
      expect(engineDeg.evaluate('sin(90)').value, closeTo(1.0, 1e-9));
      expect(engineDeg.evaluate('cos(0)').value, closeTo(1.0, 1e-9));
      expect(engineDeg.evaluate('sqrt(16)').value, equals(4.0));
      expect(engineDeg.evaluate('log(100)').value, closeTo(2.0, 1e-9));
      expect(engineDeg.evaluate('log(8, 2)').value, closeTo(3.0, 1e-9));
      expect(engineDeg.evaluate('log2(1024)').value, closeTo(10.0, 1e-9));
      expect(engineDeg.evaluate('log10(1000)').value, closeTo(3.0, 1e-9));
      expect(engineDeg.evaluate('ln(e)').value, closeTo(1.0, 1e-9));
    });

    test('Factorials and Powers', () {
      final engine = CalculatorEngine();
      expect(engine.evaluate('5!').value, equals(120.0));
      expect(engine.evaluate('0!').value, equals(1.0));
      expect(engine.evaluate('2 ^ 10').value, equals(1024.0));
    });

    test('Division by zero returns error CalcResult', () {
      final engine = CalculatorEngine();
      final result = engine.evaluate('5 ÷ 0');
      expect(result.isError, isTrue);
      expect(result.error, contains('Division by zero'));
    });
  });

  group('Number Formatter Tests', () {
    test('Standard Formatting with Commas', () {
      final formatter = NumberFormatter(config: const NumberFormatConfig(useThousandsSeparator: true));
      expect(formatter.format(1000), equals('1,000'));
      expect(formatter.format(1000000), equals('1,000,000'));
      expect(formatter.format(12345.678), equals('12,345.678'));
    });

    test('Clean Trailing Zeros', () {
      final formatter = NumberFormatter();
      expect(formatter.format(12.0), equals('12'));
      expect(formatter.format(12.5000), equals('12.5'));
    });
  });

  group('Number Theory: BigInt GCD, LCM & Factorization', () {
    test('GCD calculations with Euclidean algorithm', () {
      expect(NumberTheory.gcd(BigInt.from(54), BigInt.from(24)), equals(BigInt.from(6)));
      expect(NumberTheory.gcd(BigInt.from(-54), BigInt.from(24)), equals(BigInt.from(6)));
      expect(NumberTheory.gcd(BigInt.from(17), BigInt.from(19)), equals(BigInt.one)); // Co-prime
      expect(NumberTheory.gcd(BigInt.from(54), BigInt.zero), equals(BigInt.from(54)));
      expect(NumberTheory.gcd(BigInt.zero, BigInt.zero), equals(BigInt.zero));

      final detailed = NumberTheory.gcdDetailed(BigInt.from(252), BigInt.from(105));
      expect(detailed.gcd, equals(BigInt.from(21)));
      expect(detailed.steps.isNotEmpty, isTrue);
    });

    test('LCM calculations & identity GCD(a,b)*LCM(a,b) = |a*b|', () {
      final a = BigInt.from(36);
      final b = BigInt.from(48);
      final gcdVal = NumberTheory.gcd(a, b);
      final lcmVal = NumberTheory.lcm(a, b);

      expect(lcmVal, equals(BigInt.from(144)));
      expect(gcdVal * lcmVal, equals(a.abs() * b.abs()));

      expect(NumberTheory.lcm(BigInt.zero, BigInt.from(10)), equals(BigInt.zero));
      expect(NumberTheory.lcm(BigInt.zero, BigInt.zero), equals(BigInt.zero));

      final list = [BigInt.from(12), BigInt.from(18), BigInt.from(24)];
      expect(NumberTheory.lcmMany(list), equals(BigInt.from(72)));
      expect(NumberTheory.gcdMany(list), equals(BigInt.from(6)));
    });

    test('Prime factorization and prime checks', () {
      final factors = NumberTheory.primeFactors(BigInt.from(360));
      expect(factors[BigInt.two], equals(3));
      expect(factors[BigInt.from(3)], equals(2));
      expect(factors[BigInt.from(5)], equals(1));

      expect(NumberTheory.isPrime(BigInt.from(997)), isTrue);
      expect(NumberTheory.isPrime(BigInt.from(999)), isFalse);
      expect(NumberTheory.isPrime(BigInt.one), isFalse);

      final divs = NumberTheory.divisors(BigInt.from(28));
      expect(divs, equals([BigInt.one, BigInt.two, BigInt.from(4), BigInt.from(7), BigInt.from(14), BigInt.from(28)]));
    });

    test('Fraction GCD and LCM', () {
      final f1 = BigRational(BigInt.two, BigInt.from(3));
      final f2 = BigRational(BigInt.from(4), BigInt.from(9));

      final fracGcd = NumberTheory.fractionGcd(f1, f2);
      expect(fracGcd, equals(BigRational(BigInt.two, BigInt.from(9))));

      final fracLcm = NumberTheory.fractionLcm(f1, f2);
      expect(fracLcm, equals(BigRational(BigInt.from(4), BigInt.from(3))));
    });
  });

  group('Algebra Engine: Monomials & Polynomials', () {
    test('Monomial LCM and GCD calculations', () {
      final m1 = Monomial.parse('6*x^2*y');
      final m2 = Monomial.parse('9*x*y^3');

      final gcdMon = Monomial.gcd(m1, m2);
      expect(gcdMon.coefficient, equals(BigInt.from(3)));
      expect(gcdMon.variables['x'], equals(1));
      expect(gcdMon.variables['y'], equals(1));

      final lcmMon = Monomial.lcm(m1, m2);
      expect(lcmMon.coefficient, equals(BigInt.from(18)));
      expect(lcmMon.variables['x'], equals(2));
      expect(lcmMon.variables['y'], equals(3));
    });

    test('Polynomial Euclidean GCD & LCM', () {
      final p1 = Polynomial.parse('x^2 - 1');
      final p2 = Polynomial.parse('x^2 - 2*x + 1');

      final g = Polynomial.gcd(p1, p2);
      expect(g.degree, equals(1));
      expect(g.leadingCoeff, equals(BigRational.one));

      final l = Polynomial.lcm(p1, p2);
      expect(l.degree, equals(3));
    });

    test('Linear and Quadratic Equation Solvers', () {
      final lin = EquationSolver.solveLinear(BigRational.fromInt(2), BigRational.fromInt(6));
      expect(lin['root'], equals(BigRational.fromInt(-3)));

      final quad = EquationSolver.solveQuadratic(
        BigRational.one,
        BigRational.fromInt(-5),
        BigRational.fromInt(6),
      );
      expect(quad['status'], equals('real_exact'));
      expect(quad['root1'], equals(BigRational.fromInt(3)));
      expect(quad['root2'], equals(BigRational.fromInt(2)));
    });
  });

  group('Advanced Mathematics: Complex, Matrix, Calculus, Stats, Geometry & Smart Input', () {
    test('Complex Numbers Arithmetic', () {
      final z1 = Complex.parse('3 + 4i');
      final z2 = Complex.parse('1 - 2i');

      expect(z1.modulus, closeTo(5.0, 1e-9));
      final sum = z1 + z2;
      expect(sum.real, equals(4.0));
      expect(sum.imag, equals(2.0));

      final prod = z1 * z2; // (3+4i)(1-2i) = 3 - 6i + 4i + 8 = 11 - 2i
      expect(prod.real, equals(11.0));
      expect(prod.imag, equals(-2.0));
    });

    test('Matrix & 3D Vector Linear Algebra', () {
      final m = Matrix.parse('[[1, 2], [3, 4]]');
      expect(m.determinant(), equals(-2.0));

      final inv = m.inverse();
      final prod = m * inv;
      expect(prod.get(0, 0), closeTo(1.0, 1e-6));
      expect(prod.get(1, 1), closeTo(1.0, 1e-6));
      expect(prod.get(0, 1).abs(), lessThan(1e-6));

      final u = Vector3D(1, 0, 0);
      final v = Vector3D(0, 1, 0);
      expect(u.dot(v), equals(0.0));
      final cross = u.cross(v);
      expect(cross.z, equals(1.0));
      expect(u.angleToDegrees(v), equals(90.0));
    });

    test('Calculus Differentiation & Integration', () {
      final calc = CalculusEngine();
      // f(x) = x^2, f'(3) = 6
      final d = calc.differentiate('x^2', 3.0);
      expect(d['firstDerivative'], closeTo(6.0, 1e-3));

      // \int_0^3 x^2 dx = [x^3 / 3]_0^3 = 9.0
      final area = calc.integrate('x^2', 0.0, 3.0);
      expect(area, closeTo(9.0, 1e-3));
    });

    test('Statistics Descriptive & Combinatorics', () {
      final data = [10.0, 20.0, 30.0, 40.0, 50.0];
      final res = StatisticsEngine.describe(data);
      expect(res['mean'], equals(30.0));
      expect(res['median'], equals(30.0));

      expect(StatisticsEngine.combinations(5, 2), equals(BigInt.from(10)));
      expect(StatisticsEngine.permutations(5, 2), equals(BigInt.from(20)));
    });

    test('Sequences & Base Converter', () {
      final hex = BaseConverter.convert('255', 10, 16);
      expect(hex, equals('FF'));
      final dec = BaseConverter.convert('FF', 16, 10);
      expect(dec, equals('255'));

      final fib = SequencesEngine.fibonacci(10);
      expect(fib['fn'], equals(BigInt.from(55)));
    });

    test('Geometry Shapes & Triangle Solver', () {
      final circ = GeometryEngine.circle(10.0);
      expect(circ['Area'], closeTo(314.1592, 1e-3));

      // 3-4-5 right triangle
      final tri = GeometryEngine.solveTriangleSSS(3, 4, 5);
      expect(tri['Area'], closeTo(6.0, 1e-6));
      expect(tri['Angle C (deg)'], closeTo(90.0, 1e-6));

      // 2D Shapes tests
      final sector = GeometryEngine.sector(10, 90);
      expect(sector['Arc Length'], closeTo(10 * math.pi / 2, 1e-5));

      final ellipse = GeometryEngine.ellipse(5, 3);
      expect(ellipse['Area'], closeTo(15 * math.pi, 1e-5));

      final poly = GeometryEngine.regularPolygon(6, 4); // Hexagon
      expect(poly['Interior Angle (deg)'], equals(120.0));
      expect(poly['Number of Diagonals'], equals(9.0));

      // 3D Solids tests
      final hemi = GeometryEngine.hemisphere(6);
      expect(hemi['Curved Surface Area'], closeTo(2 * math.pi * 36, 1e-5));
      expect(hemi['Total Surface Area'], closeTo(3 * math.pi * 36, 1e-5));

      final cube = GeometryEngine.cube(4);
      expect(cube['Volume'], equals(64.0));
      expect(cube['Total Surface Area'], equals(96.0));

      final torus = GeometryEngine.torus(10, 2);
      expect(torus['Volume'], closeTo(2 * math.pi * math.pi * 10 * 4, 1e-5));

      // Geometry Questions
      final pyth = GeometryEngine.pythagoreanMissingLeg(13, 5);
      expect(pyth['Missing Leg (b)'], closeTo(12.0, 1e-5));

      final circArea = GeometryEngine.circleFromArea(math.pi * 25);
      expect(circArea['Radius (r)'], closeTo(5.0, 1e-5));

      final rectDims = GeometryEngine.rectangleFromAreaAndPerimeter(24, 20);
      expect(rectDims['Length (l)'], closeTo(6.0, 1e-5));
      expect(rectDims['Width (w)'], closeTo(4.0, 1e-5));
    });

    test('Toggle sign (±) wraps and unwraps without leaving trailing brackets', () {
      final settings = SettingsProvider();
      final calc = CalculatorProvider(settings);

      // Type 5
      calc.inputDigit('5');
      expect(calc.expression, equals('5'));

      // Toggle sign -> (-5)
      calc.toggleSign();
      expect(calc.expression, equals('(-5)'));

      // Toggle sign again -> 5 (reversing must not leave a bracket on the right!)
      calc.toggleSign();
      expect(calc.expression, equals('5'));
      expect(calc.expression.contains(')'), isFalse);
      expect(calc.expression.contains('('), isFalse);

      // Operator test: 2 +
      calc.clear();
      calc.inputDigit('2');
      calc.inputOperator('+');
      expect(calc.expression, equals('2+'));

      // Toggle sign after operator -> 2+(-
      calc.toggleSign();
      expect(calc.expression, equals('2+(-'));

      // Reverse toggle sign after operator -> 2+ (reversing must not leave any bracket!)
      calc.toggleSign();
      expect(calc.expression, equals('2+'));
      expect(calc.expression.endsWith(')'), isFalse);

      // Compound test: 2 + 5 -> 2+(-5) -> 2+5
      calc.inputDigit('5');
      expect(calc.expression, equals('2+5'));
      calc.toggleSign();
      expect(calc.expression, equals('2+(-5)'));
      calc.toggleSign();
      expect(calc.expression, equals('2+5'));
      expect(calc.expression.endsWith(')'), isFalse);
    });

    test('Universal Question Engine solves across categories', () {
      final categories = UniversalQuestionEngine.getCategories();
      expect(categories.length, equals(5));

      // Reverse discount: original of 75 with 25% discount should be 100
      final finCat = categories.firstWhere((c) => c.title.contains('Finance'));
      final revDisc = finCat.questions.firstWhere((q) => q.id == 'fin_rev_discount');
      final resDisc = revDisc.solver([75.0, 25.0]);
      expect(resDisc['Original Price'], closeTo(100.0, 1e-5));

      // Reverse GST: MRP 1180 with 18% GST -> base 1000, tax 180
      final revGst = finCat.questions.firstWhere((q) => q.id == 'fin_rev_gst');
      final resGst = revGst.solver([1180.0, 18.0]);
      expect(resGst['Base Price (Pre-tax)'], closeTo(1000.0, 1e-5));
      expect(resGst['Total GST Amount'], closeTo(180.0, 1e-5));

      // Number Theory: missing number when LCM=60, GCD=4, A=12 -> B=20
      final algCat = categories.firstWhere((c) => c.title.contains('Algebra'));
      final missingNum = algCat.questions.firstWhere((q) => q.id == 'alg_missing_lcm_gcd');
      final resMissing = missingNum.solver([60.0, 4.0, 12.0]);
      expect(resMissing['Other Number (B)'], closeTo(20.0, 1e-5));
    });

    test('Smart Math Command Dispatcher', () {
      final r1 = SmartMathCommand.execute('lcm(12, 18, 24)');
      expect(r1.isSuccess, isTrue);
      expect(r1.result, equals('72'));

      final r2 = SmartMathCommand.execute('gcd(24, 36)');
      expect(r2.isSuccess, isTrue);
      expect(r2.result, equals('12'));

      final r3 = SmartMathCommand.execute('solve(2*x + 5 = 15)');
      expect(r3.isSuccess, isTrue);
      expect(r3.result, contains('x = 5'));

      final r4 = SmartMathCommand.execute('factor(360)');
      expect(r4.isSuccess, isTrue);
      expect(r4.result, contains('2'));

      final r5 = SmartMathCommand.execute('det([[1,2],[3,4]])');
      expect(r5.isSuccess, isTrue);
      expect(r5.result, equals('-2'));

      final r6 = SmartMathCommand.execute('prime(997)');
      expect(r6.isSuccess, isTrue);
      expect(r6.result, contains('YES'));

      // Natural language conversational question execution
      final r7 = SmartMathCommand.execute('area of circle radius 5');
      expect(r7.isSuccess, isTrue);
      expect(r7.result, contains('78.5398'));

      final r8 = SmartMathCommand.execute('hypotenuse 6 and 8');
      expect(r8.isSuccess, isTrue);
      expect(r8.result, contains('10.0000'));

      final r9 = SmartMathCommand.execute('pre tax 1180 gst 18');
      expect(r9.isSuccess, isTrue);
      expect(r9.result, contains('1000.00'));

      final r10 = SmartMathCommand.execute('double money at 8%');
      expect(r10.isSuccess, isTrue);
      expect(r10.result, contains('9.01'));

      final directNl = NaturalLanguageParser.parse('area of circle radius 10');
      expect(directNl.isMatch, isTrue);
      expect(directNl.title, contains('Circle Geometry'));
    });

    test('Graphing Engine Sampling & Cartesian Analysis', () {
      final engine = GraphingEngine();
      final points = engine.sample('x^2 - 4', -5, 5, sampleCount: 100);
      expect(points.length, equals(101));
      expect(points.first.isValid, isTrue);

      final analysis = engine.analyze('x^2 - 4', -5, 5);
      // Roots: -2 and 2
      expect(analysis.roots.length, equals(2));
      expect(analysis.roots.any((r) => (r - (-2.0)).abs() < 0.1), isTrue);
      expect(analysis.roots.any((r) => (r - 2.0).abs() < 0.1), isTrue);

      // y-intercept: (0, -4)
      expect(analysis.yIntercept, closeTo(-4.0, 1e-4));

      // Local minimum at x=0
      expect(analysis.localMinima.isNotEmpty, isTrue);
      expect(analysis.localMinima.first.x, closeTo(0.0, 0.2));
    });

    test('Zero Syntax Leakage & Consumer-Friendly Error Sanitization', () {
      final engine = CalculatorEngine();
      final res = engine.evaluate('5 +');
      expect(res.isError, isTrue);
      expect(res.error, isNot(contains('TokenType')));
      expect(res.error, isNot(contains('got ')));
      expect(res.error, equals('Incomplete calculation'));

      // Test cleanMathErrorMessage sanitizes FormatException
      const rawFormatException = FormatException('Invalid radix-10 number (at character 1)');
      expect(cleanMathErrorMessage(rawFormatException), equals('Please enter valid numbers'));

      const rawDivByZero = FormatException('Division by zero');
      expect(cleanMathErrorMessage(rawDivByZero), equals('Cannot divide by zero'));

      // Test Smart Math Command never leaks FormatException or developer stack
      final cmdRes = SmartMathCommand.execute('gcd(abc, def)');
      expect(cmdRes.isSuccess, isFalse);
      expect(cmdRes.error, isNot(contains('FormatException')));
      expect(cmdRes.error, equals('Please enter valid numbers in the command arguments'));
    });

    test('Expression Explainer generates clean mathematical steps', () {
      final steps = ExpressionExplainer.explain('2 + 3 * 4');
      expect(steps.length, greaterThanOrEqualTo(2));
      expect(steps.last, contains('14'));

      final parenSteps = ExpressionExplainer.explain('(10 - 2) / 4');
      expect(parenSteps.last, contains('2'));
    });

    test('Simultaneous Linear Equations Solver 2x2 and 3x3', () {
      // 2x + 3y = 8, x - y = -1 -> x = 1, y = 2
      final res2 = LinearSystemSolver.solve2x2(2, 3, 8, 1, -1, -1);
      expect(res2.status, equals(SystemSolutionStatus.unique));
      expect(res2.solution['x'], closeTo(1.0, 1e-6));
      expect(res2.solution['y'], closeTo(2.0, 1e-6));
      expect(res2.cramerSteps.length, greaterThanOrEqualTo(5));

      // Parallel lines: 2x + 4y = 6, x + 2y = 8 -> No solution
      final noSol = LinearSystemSolver.solve2x2(2, 4, 6, 1, 2, 8);
      expect(noSol.status, equals(SystemSolutionStatus.noSolution));

      // 3x3: x + y + z = 6, 2y + 5z = -4, 2x + 5y - z = 27
      final res3 = LinearSystemSolver.solve3x3(1, 1, 1, 6, 0, 2, 5, -4, 2, 5, -1, 27);
      expect(res3.status, equals(SystemSolutionStatus.unique));
      expect(res3.solution['x'], closeTo(5.0, 1e-6));
      expect(res3.solution['y'], closeTo(3.0, 1e-6));
      expect(res3.solution['z'], closeTo(-2.0, 1e-6));
    });

    test('Polynomial Long Division and Synthetic Division', () {
      // (x^3 - 8) / (x - 2) = x^2 + 2x + 4, remainder 0
      final divRes = PolynomialDivisionEngine.divide('x^3 - 8', 'x - 2');
      expect(divRes.remainder.isZero, isTrue);
      expect(divRes.isSyntheticApplicable, isTrue);
      expect(divRes.syntheticRoot, equals('2'));
      expect(divRes.textSteps.length, greaterThanOrEqualTo(4));

      // (2x^3 - 3x^2 + 4x - 5) / (x - 2)
      final divRes2 = PolynomialDivisionEngine.divide('2x^3 - 3x^2 + 4x - 5', 'x - 2');
      expect(divRes2.remainder.isZero, isFalse);
      expect(divRes2.remainder.coeffs[0].toDouble(), equals(7.0));
    });

    test('Scientific & Physical Constants Catalog', () {
      expect(ConstantsCatalog.all.length, greaterThanOrEqualTo(30));
      final c = ConstantsCatalog.all.firstWhere((item) => item.symbol == 'c');
      expect(c.value, equals(299792458.0));

      final h = ConstantsCatalog.all.firstWhere((item) => item.symbol == 'h');
      expect(h.value, closeTo(6.626e-34, 1e-36));
    });

    test('Interactive Cursor and Mid-Expression Editing in CalculatorProvider', () {
      final settings = SettingsProvider();
      final calc = CalculatorProvider(settings);

      // Type 123
      calc.inputDigit('1');
      calc.inputDigit('2');
      calc.inputDigit('3');
      expect(calc.expression, equals('123'));
      expect(calc.cursorPosition, equals(3));

      // Move cursor to index 1 (between '1' and '2')
      calc.setCursorPosition(1);
      expect(calc.cursorPosition, equals(1));

      // Insert '9' at cursor -> '1923'
      calc.inputDigit('9');
      expect(calc.expression, equals('1923'));
      expect(calc.cursorPosition, equals(2));

      // Backspace at cursor -> removes '9' -> '123'
      calc.backspace();
      expect(calc.expression, equals('123'));
      expect(calc.cursorPosition, equals(1));
    });

    test('Extended Euclidean, Modular Exponentiation, Inverse & Euler Totient', () {
      // Extended GCD
      final ext = NumberTheory.extendedGcd(BigInt.from(240), BigInt.from(46));
      expect(ext.gcd, equals(BigInt.two));
      // 240 * (-9) + 46 * (47) = -2160 + 2162 = 2
      expect(BigInt.from(240) * ext.x + BigInt.from(46) * ext.y, equals(BigInt.two));

      // Modular Exponentiation: 7^128 mod 13
      // 7^1 = 7, 7^2 = 49 = 10, 7^3 = 70 = 5, 7^4 = 35 = 9, 7^12 = 1 (Fermat's little theorem)
      // 128 = 12 * 10 + 8 -> 7^8 mod 13 = 9^2 = 81 mod 13 = 3
      final powRes = NumberTheory.modPowDetailed(BigInt.from(7), BigInt.from(128), BigInt.from(13));
      expect(powRes.result, equals(BigInt.from(3)));

      // Modular Inverse: 17 * x = 1 (mod 43) -> 17 * 38 = 646 = 43 * 15 + 1
      final invRes = NumberTheory.modInverseDetailed(BigInt.from(17), BigInt.from(43));
      expect(invRes.exists, isTrue);
      expect(invRes.inverse, equals(BigInt.from(38)));

      // Non-coprime modular inverse
      final nonInv = NumberTheory.modInverseDetailed(BigInt.from(6), BigInt.from(9));
      expect(nonInv.exists, isFalse);

      // Euler's Totient phi(360) = 360 * (1 - 1/2) * (1 - 1/3) * (1 - 1/5) = 360 * 1/2 * 2/3 * 4/5 = 96
      final totient = NumberTheory.eulerTotientDetailed(BigInt.from(360));
      expect(totient.phi, equals(BigInt.from(96)));
    });

    test('Matrix RREF & Eigenvalues', () {
      // 2x2 Matrix RREF
      final m2 = Matrix.parse('[[1, 2], [3, 4]]');
      final rref2 = m2.rrefDetailed();
      expect(rref2.rank, equals(2));
      // Invertible 2x2 should reduce to Identity [[1, 0], [0, 1]]
      expect(rref2.rref.data[0][0], closeTo(1.0, 1e-4));
      expect(rref2.rref.data[0][1], closeTo(0.0, 1e-4));
      expect(rref2.rref.data[1][0], closeTo(0.0, 1e-4));
      expect(rref2.rref.data[1][1], closeTo(1.0, 1e-4));

      // 2x2 Eigenvalues: A = [[2, 1], [1, 2]] -> det(A - lambda*I) = (2-L)^2 - 1 = L^2 - 4L + 3 = 0 -> lambda = 3, 1
      final mSym = Matrix.parse('[[2, 1], [1, 2]]');
      final eigenSym = mSym.eigenvalues();
      expect(eigenSym.values.length, equals(2));
      expect(eigenSym.values.any((v) => v.contains('3')), isTrue);
      expect(eigenSym.values.any((v) => v.contains('1')), isTrue);

      // 3x3 Matrix Eigenvalues: diagonal matrix [[2, 0, 0], [0, 5, 0], [0, 0, 7]] -> eigenvalues 7, 5, 2
      final mDiag = Matrix.parse('[[2, 0, 0], [0, 5, 0], [0, 0, 7]]');
      final eigenDiag = mDiag.eigenvalues();
      expect(eigenDiag.values.any((v) => v.contains('7')), isTrue);
      expect(eigenDiag.values.any((v) => v.contains('5')), isTrue);
      expect(eigenDiag.values.any((v) => v.contains('2')), isTrue);
    });

    test('Two-Variable Linear Regression & Correlation', () {
      // Perfectly collinear points: (1, 3), (2, 5), (3, 7), (4, 9) -> y = 2x + 1
      final points = [(1.0, 3.0), (2.0, 5.0), (3.0, 7.0), (4.0, 9.0)];
      final reg = StatisticsEngine.linearRegression(points);
      expect(reg.slope, closeTo(2.0, 1e-4));
      expect(reg.intercept, closeTo(1.0, 1e-4));
      expect(reg.r, closeTo(1.0, 1e-4));
      expect(reg.rSquared, closeTo(1.0, 1e-4));
      expect(reg.correlationRating, contains('Positive'));
    });

    test('Multi-Curve Function Graphing Intersections', () {
      final engine = GraphingEngine();
      // f1(x) = x^2, f2(x) = x + 2 -> x^2 - x - 2 = 0 -> (x-2)(x+1) = 0 -> intersections at x = -1 and x = 2
      final intersections = engine.findIntersections('x^2', 'x + 2', -4.0, 4.0);
      expect(intersections.length, equals(2));
      expect(intersections.any((p) => (p.x - (-1.0)).abs() < 0.05), isTrue);
      expect(intersections.any((p) => (p.x - 2.0).abs() < 0.05), isTrue);
    });
  });

  group('Widget UI Smoke Test', () {
    testWidgets('Renders Calculator Screen and Keypad', (WidgetTester tester) async {
      final settings = SettingsProvider();
      final calc = CalculatorProvider(settings);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: settings),
            ChangeNotifierProvider<CalculatorProvider>.value(value: calc),
          ],
          child: MaterialApp(
            theme: QTheme.light(),
            home: const CalculatorScreen(),
          ),
        ),
      );

      expect(find.text('C'), findsOneWidget);
      expect(find.text('='), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('+'), findsOneWidget);

      await tester.tap(find.text('7'));
      await tester.pump();
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('='));
      await tester.pumpAndSettle();

      expect(find.text('10'), findsWidgets);
    });
  });

  group('Audit Verification & Hardening Tests', () {
    test('CalculusEngine consecutive variables', () {
      final calc = CalculusEngine();
      expect(calc.evaluate('x*x', 3.0), closeTo(9.0, 1e-6));
      expect(calc.evaluate('x+x+x', 2.0), closeTo(6.0, 1e-6));
      expect(calc.evaluate('(x)*(x)', 4.0), closeTo(16.0, 1e-6));
      expect(calc.evaluate('x^2 - 2*x + 1', 5.0), closeTo(16.0, 1e-6));
    });

    test('CalculatorEngine hyperbolic overflow guards', () {
      final engine = CalculatorEngine();
      final resTanh = engine.evaluate('tanh(50)');
      expect(resTanh.isSuccess, isTrue);
      expect(resTanh.value, equals(1.0));

      final resTanhNeg = engine.evaluate('tanh(-50)');
      expect(resTanhNeg.isSuccess, isTrue);
      expect(resTanhNeg.value, equals(-1.0));

      final resSinh = engine.evaluate('sinh(800)');
      expect(resSinh.isError, isTrue);
      expect(resSinh.error, equals('Result is too large'));

      final resCosh = engine.evaluate('cosh(800)');
      expect(resCosh.isError, isTrue);
      expect(resCosh.error, equals('Result is too large'));
    });

    test('CalculatorEngine modulo keyword support', () {
      final engine = CalculatorEngine();
      final res1 = engine.evaluate('10 mod 3');
      expect(res1.isSuccess, isTrue);
      expect(res1.value, equals(1.0));

      final res2 = engine.evaluate('25 mod 7');
      expect(res2.isSuccess, isTrue);
      expect(res2.value, equals(4.0));
    });

    test('CalculatorEngine contextual percentage chaining and precedence', () {
      final engine = CalculatorEngine();
      final res1 = engine.evaluate('100 + 200 + 10%');
      expect(res1.isSuccess, isTrue);
      expect(res1.value, equals(330.0));

      final res2 = engine.evaluate('(200 + 10%) * 2');
      expect(res2.isSuccess, isTrue);
      expect(res2.value, equals(440.0));

      final res3 = engine.evaluate('100 - 10%');
      expect(res3.isSuccess, isTrue);
      expect(res3.value, equals(90.0));
    });

    test('Matrix ragged row validation', () {
      expect(() => Matrix.parse('1 2; 3 4 5'), throwsA(isA<FormatException>()));
      expect(() => Matrix.parse('[[1, 2], [3]]'), throwsA(isA<FormatException>()));

      final m = Matrix.parse('1 2; 3 4');
      expect(m.rows, equals(2));
      expect(m.cols, equals(2));
    });

    test('AlgebraEngine quadratic vertex calculation', () {
      // y = x^2 - 4x + 4 => vertex is (2, 0)
      final res = EquationSolver.solveQuadratic(
        BigRational.one,
        BigRational.fromInt(-4),
        BigRational.fromInt(4),
      );
      expect(res['vertex'], equals('(2, 0)'));
    });

    test('LinearSystemSolver elimination steps with zero coefficient', () {
      // 2x = 4, x + 3y = 7 => b1 = 0
      final res = LinearSystemSolver.solve2x2(2, 0, 4, 1, 3, 7);
      expect(res.status, equals(SystemSolutionStatus.unique));
      expect(res.solution!['x'], closeTo(2.0, 1e-9));
      expect(res.solution!['y'], closeTo(1.6666666, 1e-5));
      expect(res.eliminationSteps.any((s) => s.contains('Directly solve for x')), isTrue);
      expect(res.eliminationSteps.any((s) => s.contains('/ 0')), isFalse);
    });

    test('CalculatorProvider clearEntry and memoryRecall cursor updates', () {
      final settings = SettingsProvider();
      final provider = CalculatorProvider(settings);

      // Type 12 + 34
      provider.inputDigit('1');
      provider.inputDigit('2');
      provider.inputOperator('+');
      provider.inputDigit('3');
      provider.inputDigit('4');
      expect(provider.expression, equals('12+34'));
      expect(provider.cursorPosition, equals(5));

      // clearEntry removes '+34', leaving '12'
      provider.clearEntry();
      expect(provider.expression, equals('12'));
      expect(provider.cursorPosition, equals(2));

      // Test memoryStore and memoryRecall at cursor
      provider.memoryStore(); // stores current display
      provider.inputDigit('5');
      // expression is 12+5, move cursor between 12 and +
      provider.setCursorPosition(2);
      expect(provider.cursorPosition, equals(2));
    });

    test('NumberTheory isPerfectCube bit-length bound', () {
      expect(NumberTheory.isPerfectCube(BigInt.from(1000000)), equals((true, BigInt.from(100))));
      expect(NumberTheory.isPerfectCube(BigInt.from(-27)), equals((true, BigInt.from(-3))));
      expect(NumberTheory.isPerfectCube(BigInt.from(28)), equals((false, BigInt.zero)));
    });
  });
}
