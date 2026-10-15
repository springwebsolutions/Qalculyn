// Qalculyn - Matrix & Vector Linear Algebra Engine
// Arbitrary dimension matrix operations and 3D vector algebra

import 'dart:math' as math;

class Matrix {
  final int rows;
  final int cols;
  final List<List<double>> data;

  Matrix(this.rows, this.cols, List<List<double>> elements)
      : data = List.generate(
          rows,
          (i) => List.generate(cols, (j) => elements[i][j]),
        );

  factory Matrix.zeros(int rows, int cols) {
    return Matrix(
      rows,
      cols,
      List.generate(rows, (_) => List.filled(cols, 0.0)),
    );
  }

  factory Matrix.identity(int size) {
    return Matrix(
      size,
      size,
      List.generate(
        size,
        (i) => List.generate(size, (j) => (i == j ? 1.0 : 0.0)),
      ),
    );
  }

  /// Parse matrix string format like "[[1, 2], [3, 4]]" or "1 2; 3 4"
  factory Matrix.parse(String text) {
    var str = text.trim();
    if (str.startsWith('[') && str.endsWith(']')) {
      // JSON-like format
      str = str.substring(1, str.length - 1).trim();
      final rowMatches = RegExp(r'\[([^\]]+)\]').allMatches(str);
      if (rowMatches.isNotEmpty) {
        final rowsList = <List<double>>[];
        for (final m in rowMatches) {
          final items = m.group(1)!.split(RegExp(r'[,;\s]+')).where((s) => s.isNotEmpty);
          rowsList.add(items.map(double.parse).toList());
        }
        final r = rowsList.length;
        final c = rowsList[0].length;
        return Matrix(r, c, rowsList);
      }
    }

    // Semicolon row format: "1, 2; 3, 4"
    final rowParts = str.split(';');
    final rowsList = <List<double>>[];
    for (final row in rowParts) {
      final items = row.trim().split(RegExp(r'[,;\s]+')).where((s) => s.isNotEmpty);
      if (items.isNotEmpty) {
        rowsList.add(items.map(double.parse).toList());
      }
    }

    if (rowsList.isEmpty) throw const FormatException('Empty matrix');
    final r = rowsList.length;
    final c = rowsList[0].length;
    return Matrix(r, c, rowsList);
  }

  bool get isSquare => rows == cols;

  double get(int r, int c) => data[r][c];

  Matrix operator +(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw const FormatException('Matrix dimension mismatch in addition');
    }
    return Matrix(
      rows,
      cols,
      List.generate(rows, (i) => List.generate(cols, (j) => data[i][j] + other.data[i][j])),
    );
  }

  Matrix operator -(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw const FormatException('Matrix dimension mismatch in subtraction');
    }
    return Matrix(
      rows,
      cols,
      List.generate(rows, (i) => List.generate(cols, (j) => data[i][j] - other.data[i][j])),
    );
  }

  Matrix operator *(Matrix other) {
    if (cols != other.rows) {
      throw const FormatException('Matrix dimension mismatch in multiplication (A.cols != B.rows)');
    }
    final result = Matrix.zeros(rows, other.cols);
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < other.cols; j++) {
        var sum = 0.0;
        for (var k = 0; k < cols; k++) {
          sum += data[i][k] * other.data[k][j];
        }
        result.data[i][j] = sum;
      }
    }
    return result;
  }

  Matrix scale(double scalar) {
    return Matrix(
      rows,
      cols,
      List.generate(rows, (i) => List.generate(cols, (j) => data[i][j] * scalar)),
    );
  }

  Matrix transpose() {
    return Matrix(
      cols,
      rows,
      List.generate(cols, (j) => List.generate(rows, (i) => data[i][j])),
    );
  }

  double trace() {
    if (!isSquare) throw const FormatException('Trace is only defined for square matrices');
    var tr = 0.0;
    for (var i = 0; i < rows; i++) {
      tr += data[i][i];
    }
    return tr;
  }

  /// Exact Determinant via Gaussian elimination with partial pivoting
  double determinant() {
    if (!isSquare) throw const FormatException('Determinant is only defined for square matrices');
    final n = rows;

    if (n == 1) return data[0][0];
    if (n == 2) return data[0][0] * data[1][1] - data[0][1] * data[1][0];
    if (n == 3) {
      return data[0][0] * (data[1][1] * data[2][2] - data[1][2] * data[2][1]) -
          data[0][1] * (data[1][0] * data[2][2] - data[1][2] * data[2][0]) +
          data[0][2] * (data[1][0] * data[2][1] - data[1][1] * data[2][0]);
    }

    // Clone matrix for elimination
    final m = List.generate(n, (i) => List.generate(n, (j) => data[i][j]));
    var det = 1.0;

    for (var i = 0; i < n; i++) {
      var pivot = i;
      for (var j = i + 1; j < n; j++) {
        if (m[j][i].abs() > m[pivot][i].abs()) {
          pivot = j;
        }
      }

      if (m[pivot][i].abs() < 1e-14) return 0.0;

      if (pivot != i) {
        final temp = m[i];
        m[i] = m[pivot];
        m[pivot] = temp;
        det = -det;
      }

      det *= m[i][i];

      for (var j = i + 1; j < n; j++) {
        final factor = m[j][i] / m[i][i];
        for (var k = i + 1; k < n; k++) {
          m[j][k] -= factor * m[i][k];
        }
      }
    }

    return (det.abs() < 1e-12) ? 0.0 : det;
  }

  /// Inverse matrix via Gauss-Jordan elimination
  Matrix inverse() {
    if (!isSquare) throw const FormatException('Inverse is only defined for square matrices');
    final n = rows;
    final det = determinant();
    if (det.abs() < 1e-12) throw const FormatException('Matrix is singular (determinant = 0), inverse does not exist');

    // Create augmented matrix [A | I]
    final aug = List.generate(
      n,
      (i) => List.generate(2 * n, (j) => (j < n ? data[i][j] : (j - n == i ? 1.0 : 0.0))),
    );

    for (var i = 0; i < n; i++) {
      var pivot = i;
      for (var j = i + 1; j < n; j++) {
        if (aug[j][i].abs() > aug[pivot][i].abs()) {
          pivot = j;
        }
      }

      if (pivot != i) {
        final temp = aug[i];
        aug[i] = aug[pivot];
        aug[pivot] = temp;
      }

      final pivotVal = aug[i][i];
      for (var j = 0; j < 2 * n; j++) {
        aug[i][j] /= pivotVal;
      }

      for (var j = 0; j < n; j++) {
        if (j != i) {
          final factor = aug[j][i];
          for (var k = 0; k < 2 * n; k++) {
            aug[j][k] -= factor * aug[i][k];
          }
        }
      }
    }

    return Matrix(
      n,
      n,
      List.generate(n, (i) => List.generate(n, (j) => aug[i][n + j])),
    );
  }

  static String _fmtNum(double v) {
    if (v.abs() < 1e-11) return '0';
    final fixed = v.toStringAsFixed(4);
    return fixed.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Reduced Row Echelon Form (RREF) with step-by-step row operations
  RrefResult rrefDetailed() {
    final m = List.generate(rows, (i) => List.generate(cols, (j) => data[i][j]));
    final steps = <RrefStep>[];
    steps.add(RrefStep('Initial Matrix', Matrix(rows, cols, m)));

    var lead = 0;
    var rank = 0;

    for (var r = 0; r < rows; r++) {
      if (lead >= cols) break;
      var i = r;
      while (m[i][lead].abs() < 1e-11) {
        i++;
        if (i == rows) {
          i = r;
          lead++;
          if (lead == cols) break;
        }
      }
      if (lead >= cols) break;

      if (i != r) {
        final temp = m[r];
        m[r] = m[i];
        m[i] = temp;
        steps.add(RrefStep('Swap Row ${r + 1} ↔ Row ${i + 1}', Matrix(rows, cols, m)));
      }

      final lv = m[r][lead];
      if ((lv - 1.0).abs() > 1e-11) {
        final factor = lv;
        for (var j = 0; j < cols; j++) {
          m[r][j] /= factor;
          if (m[r][j].abs() < 1e-12) m[r][j] = 0.0;
        }
        steps.add(RrefStep('Scale Row ${r + 1} by 1 / ${_fmtNum(factor)}', Matrix(rows, cols, m)));
      }

      for (var k = 0; k < rows; k++) {
        if (k != r) {
          final factor = m[k][lead];
          if (factor.abs() > 1e-11) {
            for (var j = 0; j < cols; j++) {
              m[k][j] -= factor * m[r][j];
              if (m[k][j].abs() < 1e-12) m[k][j] = 0.0;
            }
            steps.add(RrefStep('Row ${k + 1} ← Row ${k + 1} - (${_fmtNum(factor)}) × Row ${r + 1}', Matrix(rows, cols, m)));
          }
        }
      }

      lead++;
      rank++;
    }

    final finalMatrix = Matrix(rows, cols, m);
    return RrefResult(rref: finalMatrix, rank: rank, steps: steps);
  }

  /// Calculates eigenvalues for 2x2 and 3x3 square matrices with characteristic derivations
  EigenResult eigenvalues() {
    if (!isSquare) {
      throw const FormatException('Eigenvalues are only defined for square matrices.');
    }
    if (rows < 2 || rows > 3) {
      throw const FormatException('Eigenvalue solver supports 2×2 and 3×3 square matrices.');
    }

    if (rows == 2) {
      final a = data[0][0], b = data[0][1];
      final c = data[1][0], d = data[1][1];
      final tr = a + d;
      final det = a * d - b * c;
      final disc = tr * tr - 4 * det;

      final eq = 'λ² - (${_fmtNum(tr)})λ + (${_fmtNum(det)}) = 0';
      final steps = <String>[
        'Matrix A = [[${_fmtNum(a)}, ${_fmtNum(b)}], [${_fmtNum(c)}, ${_fmtNum(d)}]]',
        'Step 1: Compute trace tr(A) = ${_fmtNum(a)} + ${_fmtNum(d)} = ${_fmtNum(tr)}',
        'Step 2: Compute determinant det(A) = (${_fmtNum(a)} × ${_fmtNum(d)}) - (${_fmtNum(b)} × ${_fmtNum(c)}) = ${_fmtNum(det)}',
        'Step 3: Characteristic equation: det(A - λI) = λ² - tr(A)λ + det(A) = 0',
        '  $eq',
        'Step 4: Discriminant Δ = tr² - 4·det = (${_fmtNum(tr)})² - 4·(${_fmtNum(det)}) = ${_fmtNum(disc)}',
      ];

      final values = <String>[];
      if (disc > 1e-12) {
        final sqrtDisc = math.sqrt(disc);
        final l1 = (tr + sqrtDisc) / 2.0;
        final l2 = (tr - sqrtDisc) / 2.0;
        values.add('λ₁ = ${_fmtNum(l1)}');
        values.add('λ₂ = ${_fmtNum(l2)}');
        steps.add('Two distinct real eigenvalues:');
        steps.add('  λ₁ = (${_fmtNum(tr)} + ${_fmtNum(sqrtDisc)}) / 2 = ${_fmtNum(l1)}');
        steps.add('  λ₂ = (${_fmtNum(tr)} - ${_fmtNum(sqrtDisc)}) / 2 = ${_fmtNum(l2)}');
      } else if (disc.abs() <= 1e-12) {
        final l = tr / 2.0;
        values.add('λ = ${_fmtNum(l)} (multiplicity 2)');
        steps.add('One repeated real eigenvalue: λ = ${_fmtNum(tr)} / 2 = ${_fmtNum(l)}');
      } else {
        final realPart = tr / 2.0;
        final imagPart = math.sqrt(-disc) / 2.0;
        values.add('λ₁ = ${_fmtNum(realPart)} + ${_fmtNum(imagPart)}i');
        values.add('λ₂ = ${_fmtNum(realPart)} - ${_fmtNum(imagPart)}i');
        steps.add('Complex conjugate eigenvalues (Δ < 0):');
        steps.add('  λ = ${_fmtNum(realPart)} ± ${_fmtNum(imagPart)}i');
      }

      return EigenResult(values: values, characteristicEquation: eq, steps: steps);
    } else {
      // 3x3 matrix
      final tr = trace();
      final det = determinant();
      final m1 = data[0][0] * data[1][1] - data[0][1] * data[1][0];
      final m2 = data[0][0] * data[2][2] - data[0][2] * data[2][0];
      final m3 = data[1][1] * data[2][2] - data[1][2] * data[2][1];
      final sumMinors = m1 + m2 + m3;

      final eq = 'λ³ - (${_fmtNum(tr)})λ² + (${_fmtNum(sumMinors)})λ - (${_fmtNum(det)}) = 0';
      final steps = <String>[
        'Step 1: Compute trace tr(A) = ${_fmtNum(tr)}',
        'Step 2: Compute sum of principal 2×2 minors = ${_fmtNum(m1)} + ${_fmtNum(m2)} + ${_fmtNum(m3)} = ${_fmtNum(sumMinors)}',
        'Step 3: Compute determinant det(A) = ${_fmtNum(det)}',
        'Step 4: Characteristic equation: det(A - λI) = 0',
        '  $eq',
      ];

      // Solve depressed cubic t^3 + p*t + q = 0 with substitution λ = t + tr/3
      final c2 = tr;
      final c1 = sumMinors;
      final c0 = det;

      final p = c1 - (c2 * c2) / 3.0;
      final q = -c0 + (c1 * c2) / 3.0 - (2.0 * c2 * c2 * c2) / 27.0;
      final disc = (q * q) / 4.0 + (p * p * p) / 27.0;

      final values = <String>[];
      if (disc <= 1e-11) {
        // 3 real roots
        steps.add('Step 5: Depressed cubic discriminant Δ ≤ 0 indicates 3 real eigenvalues.');
        final r = math.sqrt(-p * p * p / 27.0);
        final phi = math.acos((-q / (2.0 * r)).clamp(-1.0, 1.0));
        final m = 2.0 * math.pow(r, 1.0 / 3.0);

        final l1 = m * math.cos(phi / 3.0) + c2 / 3.0;
        final l2 = m * math.cos((phi + 2.0 * math.pi) / 3.0) + c2 / 3.0;
        final l3 = m * math.cos((phi + 4.0 * math.pi) / 3.0) + c2 / 3.0;

        final sorted = [l1, l2, l3]..sort((x, y) => y.compareTo(x));
        values.add('λ₁ = ${_fmtNum(sorted[0])}');
        values.add('λ₂ = ${_fmtNum(sorted[1])}');
        values.add('λ₃ = ${_fmtNum(sorted[2])}');
        steps.add('Calculated real eigenvalues:');
        steps.add('  λ₁ = ${_fmtNum(sorted[0])}');
        steps.add('  λ₂ = ${_fmtNum(sorted[1])}');
        steps.add('  λ₃ = ${_fmtNum(sorted[2])}');
      } else {
        // 1 real root, 2 complex conjugate roots
        steps.add('Step 5: Depressed cubic discriminant Δ > 0 indicates 1 real and 2 complex eigenvalues.');
        final sqrtDisc = math.sqrt(disc);
        final uArg = -q / 2.0 + sqrtDisc;
        final vArg = -q / 2.0 - sqrtDisc;

        double cbrt(double x) => x < 0 ? -math.pow(-x, 1.0 / 3.0).toDouble() : math.pow(x, 1.0 / 3.0).toDouble();
        final u = cbrt(uArg);
        final v = cbrt(vArg);

        final realRoot = u + v + c2 / 3.0;
        final cReal = -(u + v) / 2.0 + c2 / 3.0;
        final cImag = (math.sqrt(3.0) / 2.0) * (u - v).abs();

        values.add('λ₁ = ${_fmtNum(realRoot)}');
        values.add('λ₂,₃ = ${_fmtNum(cReal)} ± ${_fmtNum(cImag)}i');
        steps.add('Calculated eigenvalues:');
        steps.add('  Real eigenvalue: λ₁ = ${_fmtNum(realRoot)}');
        steps.add('  Complex pair: λ₂,₃ = ${_fmtNum(cReal)} ± ${_fmtNum(cImag)}i');
      }

      return EigenResult(values: values, characteristicEquation: eq, steps: steps);
    }
  }

  @override
  String toString() {
    return '[${data.map((row) => '[${row.map((v) => v.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')).join(', ')}]').join(', ')}]';
  }
}

class RrefStep {
  final String description;
  final Matrix matrix;
  const RrefStep(this.description, this.matrix);
}

class RrefResult {
  final Matrix rref;
  final int rank;
  final List<RrefStep> steps;
  const RrefResult({required this.rref, required this.rank, required this.steps});
}

class EigenResult {
  final List<String> values;
  final String characteristicEquation;
  final List<String> steps;
  const EigenResult({required this.values, required this.characteristicEquation, required this.steps});
}

class Vector3D {
  final double x;
  final double y;
  final double z;

  const Vector3D(this.x, this.y, this.z);

  factory Vector3D.parse(String text) {
    var str = text.replaceAll('[', '').replaceAll(']', '').trim();
    final parts = str.split(RegExp(r'[,;\s]+')).where((s) => s.isNotEmpty).toList();
    if (parts.length == 2) {
      return Vector3D(double.parse(parts[0]), double.parse(parts[1]), 0.0);
    }
    if (parts.length >= 3) {
      return Vector3D(double.parse(parts[0]), double.parse(parts[1]), double.parse(parts[2]));
    }
    throw const FormatException('Vector requires 2 or 3 components');
  }

  double get magnitude => math.sqrt(x * x + y * y + z * z);

  Vector3D operator +(Vector3D o) => Vector3D(x + o.x, y + o.y, z + o.z);
  Vector3D operator -(Vector3D o) => Vector3D(x - o.x, y - o.y, z - o.z);
  Vector3D operator *(double s) => Vector3D(x * s, y * s, z * s);

  /// Dot product
  double dot(Vector3D o) => x * o.x + y * o.y + z * o.z;

  /// Cross product
  Vector3D cross(Vector3D o) {
    return Vector3D(
      y * o.z - z * o.y,
      z * o.x - x * o.z,
      x * o.y - y * o.x,
    );
  }

  Vector3D unit() {
    final mag = magnitude;
    if (mag == 0) throw const FormatException('Zero vector has no unit vector');
    return Vector3D(x / mag, y / mag, z / mag);
  }

  double angleToDegrees(Vector3D o) {
    final denom = magnitude * o.magnitude;
    if (denom == 0) return 0.0;
    final cosTheta = (dot(o) / denom).clamp(-1.0, 1.0);
    return math.acos(cosTheta) * 180.0 / math.pi;
  }

  @override
  String toString() => '[${_fmt(x)}, ${_fmt(y)}, ${_fmt(z)}]';

  String _fmt(double v) => v.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}
