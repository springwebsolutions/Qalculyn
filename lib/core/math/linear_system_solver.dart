// Qalculyn - Simultaneous Linear Equations Solver
// Solves 2x2 and 3x3 systems of linear equations with Cramer's Rule, Elimination, and step-by-step derivations

import 'big_rational.dart';

enum SystemSolutionStatus {
  unique,
  infiniteSolutions,
  noSolution,
}

class LinearSystemResult {
  final SystemSolutionStatus status;
  final Map<String, double> solution;
  final Map<String, String> exactFractions;
  final String statusDescription;
  final List<String> cramerSteps;
  final List<String> eliminationSteps;

  const LinearSystemResult({
    required this.status,
    required this.solution,
    required this.exactFractions,
    required this.statusDescription,
    required this.cramerSteps,
    required this.eliminationSteps,
  });
}

class LinearSystemSolver {
  /// Solves 2x2 system:
  /// a1*x + b1*y = c1
  /// a2*x + b2*y = c2
  static LinearSystemResult solve2x2(
    double a1, double b1, double c1,
    double a2, double b2, double c2,
  ) {
    final cramer = <String>[];
    final elim = <String>[];

    cramer.add('Given System of Linear Equations:');
    cramer.add('1) ${_formatTerm(a1, 'x')} ${_formatSignedTerm(b1, 'y')} = ${_formatNum(c1)}');
    cramer.add('2) ${_formatTerm(a2, 'x')} ${_formatSignedTerm(b2, 'y')} = ${_formatNum(c2)}');

    elim.add('Given System:');
    elim.add('Eq 1: ${_formatTerm(a1, 'x')} ${_formatSignedTerm(b1, 'y')} = ${_formatNum(c1)}');
    elim.add('Eq 2: ${_formatTerm(a2, 'x')} ${_formatSignedTerm(b2, 'y')} = ${_formatNum(c2)}');

    // Determinants
    final d = a1 * b2 - a2 * b1;
    final dx = c1 * b2 - c2 * b1;
    final dy = a1 * c2 - a2 * c1;

    cramer.add('\nStep 1: Calculate Main Determinant (D):');
    cramer.add('D = | a1  b1 | = (${_formatNum(a1)})(${_formatNum(b2)}) - (${_formatNum(a2)})(${_formatNum(b1)})');
    cramer.add('    | a2  b2 | = ${_formatNum(a1 * b2)} - ${_formatNum(a2 * b1)} = ${_formatNum(d)}');

    if (d.abs() < 1e-12) {
      if (dx.abs() < 1e-12 && dy.abs() < 1e-12) {
        cramer.add('\nSince D = 0 and Dx = Dy = 0:');
        cramer.add('The equations represent identical or coincident lines.');
        return LinearSystemResult(
          status: SystemSolutionStatus.infiniteSolutions,
          solution: {},
          exactFractions: {},
          statusDescription: 'Infinitely many solutions (dependent system)',
          cramerSteps: cramer,
          eliminationSteps: ['System is dependent: both equations represent the same line.'],
        );
      } else {
        cramer.add('\nSince D = 0 but Dx ≠ 0 or Dy ≠ 0:');
        cramer.add('The equations represent parallel lines that never intersect.');
        return LinearSystemResult(
          status: SystemSolutionStatus.noSolution,
          solution: {},
          exactFractions: {},
          statusDescription: 'No solution (inconsistent / parallel lines)',
          cramerSteps: cramer,
          eliminationSteps: ['System is inconsistent: equations represent distinct parallel lines.'],
        );
      }
    }

    final x = dx / d;
    final y = dy / d;

    cramer.add('\nStep 2: Calculate Determinant for x (Dx):');
    cramer.add('Dx = | c1  b1 | = (${_formatNum(c1)})(${_formatNum(b2)}) - (${_formatNum(c2)})(${_formatNum(b1)}) = ${_formatNum(dx)}');

    cramer.add('\nStep 3: Calculate Determinant for y (Dy):');
    cramer.add('Dy = | a1  c1 | = (${_formatNum(a1)})(${_formatNum(c2)}) - (${_formatNum(a2)})(${_formatNum(c1)}) = ${_formatNum(dy)}');

    cramer.add('\nStep 4: Solve for variables via Cramer\'s Rule:');
    cramer.add('x = Dx / D = ${_formatNum(dx)} / ${_formatNum(d)} = ${_formatNum(x)}');
    cramer.add('y = Dy / D = ${_formatNum(dy)} / ${_formatNum(d)} = ${_formatNum(y)}');

    // Elimination method steps
    elim.add('\nStep 1: Eliminate variable y by matching coefficients:');
    elim.add('Multiply Eq 1 by ${_formatNum(b2)} and Eq 2 by ${_formatNum(b1)}:');
    final eq1Scale = '(${_formatNum(a1 * b2)})x + (${_formatNum(b1 * b2)})y = ${_formatNum(c1 * b2)}';
    final eq2Scale = '(${_formatNum(a2 * b1)})x + (${_formatNum(b1 * b2)})y = ${_formatNum(c2 * b1)}';
    elim.add('Scaled Eq 1: $eq1Scale');
    elim.add('Scaled Eq 2: $eq2Scale');

    elim.add('\nStep 2: Subtract the equations:');
    elim.add('(${_formatNum(a1 * b2 - a2 * b1)})x = ${_formatNum(c1 * b2 - c2 * b1)}');
    elim.add('x = ${_formatNum(x)}');

    elim.add('\nStep 3: Substitute x = ${_formatNum(x)} back into Eq 1 to find y:');
    elim.add('y = (${_formatNum(c1)} - (${_formatNum(a1)})(${_formatNum(x)})) / ${_formatNum(b1)}');
    elim.add('y = ${_formatNum(y)}');

    // Exact rational fraction strings
    String xFrac = _toFractionStr(dx, d);
    String yFrac = _toFractionStr(dy, d);

    return LinearSystemResult(
      status: SystemSolutionStatus.unique,
      solution: {'x': x, 'y': y},
      exactFractions: {'x': xFrac, 'y': yFrac},
      statusDescription: 'Unique Solution: x = $xFrac, y = $yFrac',
      cramerSteps: cramer,
      eliminationSteps: elim,
    );
  }

  /// Solves 3x3 system:
  /// a1*x + b1*y + c1*z = d1
  /// a2*x + b2*y + c2*z = d2
  /// a3*x + b3*y + c3*z = d3
  static LinearSystemResult solve3x3(
    double a1, double b1, double c1, double d1,
    double a2, double b2, double c2, double d2,
    double a3, double b3, double c3, double d3,
  ) {
    final steps = <String>[];
    steps.add('Given 3x3 Linear System:');
    steps.add('1) ${_formatTerm(a1, 'x')} ${_formatSignedTerm(b1, 'y')} ${_formatSignedTerm(c1, 'z')} = ${_formatNum(d1)}');
    steps.add('2) ${_formatTerm(a2, 'x')} ${_formatSignedTerm(b2, 'y')} ${_formatSignedTerm(c2, 'z')} = ${_formatNum(d2)}');
    steps.add('3) ${_formatTerm(a3, 'x')} ${_formatSignedTerm(b3, 'y')} ${_formatSignedTerm(c3, 'z')} = ${_formatNum(d3)}');

    // 3x3 determinant helper
    double det3(double m11, double m12, double m13,
                double m21, double m22, double m23,
                double m31, double m32, double m33) {
      return m11 * (m22 * m33 - m23 * m32) -
             m12 * (m21 * m33 - m23 * m31) +
             m13 * (m21 * m32 - m22 * m31);
    }

    final d = det3(a1, b1, c1, a2, b2, c2, a3, b3, c3);
    final dx = det3(d1, b1, c1, d2, b2, c2, d3, b3, c3);
    final dy = det3(a1, d1, c1, a2, d2, c2, a3, d3, c3);
    final dz = det3(a1, b1, d1, a2, b2, d2, a3, b3, d3);

    steps.add('\nStep 1: Compute Main Matrix Determinant (D):');
    steps.add('D = | a1  b1  c1 |');
    steps.add('    | a2  b2  c2 | = ${_formatNum(d)}');
    steps.add('    | a3  b3  c3 |');

    if (d.abs() < 1e-12) {
      if (dx.abs() < 1e-12 && dy.abs() < 1e-12 && dz.abs() < 1e-12) {
        steps.add('\nSince D = 0 and Dx = Dy = Dz = 0:');
        steps.add('The planes intersect in a line or are coincident (infinitely many solutions).');
        return LinearSystemResult(
          status: SystemSolutionStatus.infiniteSolutions,
          solution: {},
          exactFractions: {},
          statusDescription: 'Infinitely many solutions (dependent planes)',
          cramerSteps: steps,
          eliminationSteps: steps,
        );
      } else {
        steps.add('\nSince D = 0 but one or more of Dx, Dy, Dz ≠ 0:');
        steps.add('The planes are parallel or do not share a common intersection point.');
        return LinearSystemResult(
          status: SystemSolutionStatus.noSolution,
          solution: {},
          exactFractions: {},
          statusDescription: 'No solution (inconsistent / no common intersection)',
          cramerSteps: steps,
          eliminationSteps: steps,
        );
      }
    }

    final x = dx / d;
    final y = dy / d;
    final z = dz / d;

    steps.add('\nStep 2: Calculate Coordinate Determinants:');
    steps.add('Dx (replace col 1 with constants) = ${_formatNum(dx)}');
    steps.add('Dy (replace col 2 with constants) = ${_formatNum(dy)}');
    steps.add('Dz (replace col 3 with constants) = ${_formatNum(dz)}');

    steps.add('\nStep 3: Solve for x, y, z via Cramer\'s Rule:');
    steps.add('x = Dx / D = ${_formatNum(dx)} / ${_formatNum(d)} = ${_formatNum(x)}');
    steps.add('y = Dy / D = ${_formatNum(dy)} / ${_formatNum(d)} = ${_formatNum(y)}');
    steps.add('z = Dz / D = ${_formatNum(dz)} / ${_formatNum(d)} = ${_formatNum(z)}');

    final xFrac = _toFractionStr(dx, d);
    final yFrac = _toFractionStr(dy, d);
    final zFrac = _toFractionStr(dz, d);

    return LinearSystemResult(
      status: SystemSolutionStatus.unique,
      solution: {'x': x, 'y': y, 'z': z},
      exactFractions: {'x': xFrac, 'y': yFrac, 'z': zFrac},
      statusDescription: 'Unique Solution: x = $xFrac, y = $yFrac, z = $zFrac',
      cramerSteps: steps,
      eliminationSteps: steps,
    );
  }

  static String _formatTerm(double coeff, String variable) {
    if (coeff == 1.0) return variable;
    if (coeff == -1.0) return '-$variable';
    return '${_formatNum(coeff)}$variable';
  }

  static String _formatSignedTerm(double coeff, String variable) {
    if (coeff >= 0) {
      if (coeff == 1.0) return '+ $variable';
      return '+ ${_formatNum(coeff)}$variable';
    } else {
      if (coeff == -1.0) return '- $variable';
      return '- ${_formatNum(coeff.abs())}$variable';
    }
  }

  static String _formatNum(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  static String _toFractionStr(double num, double den) {
    try {
      final rNum = BigRational.parse(_formatNum(num));
      final rDen = BigRational.parse(_formatNum(den));
      final res = rNum / rDen;
      return res.toString();
    } catch (_) {
      final val = num / den;
      return _formatNum(val);
    }
  }
}
