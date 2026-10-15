// Qalculyn - Statistics & Probability Engine
// Descriptive statistics, quartiles, combinatorics (nPr, nCr), and probability distributions

import 'dart:math' as math;

class StatisticsEngine {
  /// Compute comprehensive descriptive statistics for a list of numbers
  static Map<String, dynamic> describe(List<double> raw) {
    if (raw.isEmpty) {
      throw const FormatException('Dataset is empty');
    }

    final data = List.of(raw)..sort();
    final n = data.length;
    final sum = data.reduce((a, b) => a + b);
    final mean = sum / n;

    // Median
    final median = (n % 2 == 1) ? data[n ~/ 2] : (data[n ~/ 2 - 1] + data[n ~/ 2]) / 2.0;

    // Modes
    final freq = <double, int>{};
    for (final x in data) {
      freq[x] = (freq[x] ?? 0) + 1;
    }
    final maxFreq = freq.values.reduce(math.max);
    final modes = maxFreq > 1 ? freq.entries.where((e) => e.value == maxFreq).map((e) => e.key).toList() : <double>[];

    // Variance and Standard Deviation
    var sumSqDiff = 0.0;
    for (final x in data) {
      final diff = x - mean;
      sumSqDiff += diff * diff;
    }
    final popVar = sumSqDiff / n;
    final sampleVar = n > 1 ? sumSqDiff / (n - 1) : 0.0;
    final popStd = math.sqrt(popVar);
    final sampleStd = math.sqrt(sampleVar);

    // Quartiles
    final q1 = _percentile(data, 0.25);
    final q3 = _percentile(data, 0.75);
    final iqr = q3 - q1;

    final min = data.first;
    final max = data.last;
    final range = max - min;

    return {
      'count': n,
      'sum': sum,
      'mean': mean,
      'median': median,
      'modes': modes,
      'min': min,
      'max': max,
      'range': range,
      'popVariance': popVar,
      'sampleVariance': sampleVar,
      'popStdDev': popStd,
      'sampleStdDev': sampleStd,
      'q1': q1,
      'q3': q3,
      'iqr': iqr,
    };
  }

  static double _percentile(List<double> sorted, double p) {
    final n = sorted.length;
    if (n == 1) return sorted[0];
    final index = p * (n - 1);
    final lower = index.floor();
    final upper = index.ceil();
    final weight = index - lower;
    return sorted[lower] * (1.0 - weight) + sorted[upper] * weight;
  }

  /// Factorial n! using BigInt
  static BigInt factorial(int n) {
    if (n < 0) throw const FormatException('Factorial of negative integer is undefined');
    var result = BigInt.one;
    for (var i = 2; i <= n; i++) {
      result *= BigInt.from(i);
    }
    return result;
  }

  /// Permutations nPr = n! / (n - r)!
  static BigInt permutations(int n, int r) {
    if (n < 0 || r < 0 || r > n) {
      throw const FormatException('Invalid n or r for permutations (must have 0 <= r <= n)');
    }
    var result = BigInt.one;
    for (var i = n; i > n - r; i--) {
      result *= BigInt.from(i);
    }
    return result;
  }

  /// Combinations nCr = n! / (r! * (n - r)!)
  static BigInt combinations(int n, int r) {
    if (n < 0 || r < 0 || r > n) {
      throw const FormatException('Invalid n or r for combinations (must have 0 <= r <= n)');
    }
    final k = (r > n - r) ? n - r : r;
    var num = BigInt.one;
    var den = BigInt.one;
    for (var i = 1; i <= k; i++) {
      num *= BigInt.from(n - i + 1);
      den *= BigInt.from(i);
    }
    return num ~/ den;
  }

  /// Binomial distribution P(X = k) = nCk * p^k * (1-p)^(n-k)
  static double binomialPdf(int n, int k, double p) {
    if (k < 0 || k > n || p < 0 || p > 1) return 0.0;
    final coeff = combinations(n, k).toDouble();
    return coeff * math.pow(p, k) * math.pow(1 - p, n - k);
  }

  /// Normal distribution PDF at x with mean mu and std dev sigma
  static double normalPdf(double x, double mu, double sigma) {
    if (sigma <= 0) throw const FormatException('Standard deviation must be positive');
    final z = (x - mu) / sigma;
    return (1.0 / (sigma * math.sqrt(2.0 * math.pi))) * math.exp(-0.5 * z * z);
  }

  /// Normal distribution CDF: P(X <= x) using error function approximation
  static double normalCdf(double x, double mu, double sigma) {
    if (sigma <= 0) throw const FormatException('Standard deviation must be positive');
    final z = (x - mu) / sigma;
    return 0.5 * (1.0 + _erf(z / math.sqrt(2.0)));
  }

  /// Abramowitz and Stegun erf approximation (maximum error < 1.5e-7)
  static double _erf(double x) {
    final isNegative = x < 0;
    final t = 1.0 / (1.0 + 0.3275911 * x.abs());
    final a1 = 0.254829592;
    final a2 = -0.284496736;
    final a3 = 1.421413741;
    final a4 = -1.453152027;
    final a5 = 1.061405429;

    final poly = ((((a5 * t + a4) * t + a3) * t + a2) * t + a1) * t;
    final y = 1.0 - poly * math.exp(-x * x);
    return isNegative ? -y : y;
  }

  /// Two-variable linear regression y = mx + c with Pearson r and R²
  static LinearRegressionResult linearRegression(List<(double, double)> points) {
    final n = points.length;
    if (n < 2) {
      throw const FormatException('Linear regression requires at least 2 distinct data points');
    }

    var sumX = 0.0;
    var sumY = 0.0;
    for (final p in points) {
      sumX += p.$1;
      sumY += p.$2;
    }
    final meanX = sumX / n;
    final meanY = sumY / n;

    var ssXX = 0.0;
    var ssYY = 0.0;
    var ssXY = 0.0;

    for (final p in points) {
      final dx = p.$1 - meanX;
      final dy = p.$2 - meanY;
      ssXX += dx * dx;
      ssYY += dy * dy;
      ssXY += dx * dy;
    }

    if (ssXX.abs() < 1e-12) {
      throw const FormatException('All x-coordinates are identical (vertical line with undefined slope)');
    }

    final slope = ssXY / ssXX;
    final intercept = meanY - slope * meanX;

    final denom = math.sqrt(ssXX * ssYY);
    final r = denom.abs() < 1e-12 ? 0.0 : (ssXY / denom).clamp(-1.0, 1.0);
    final r2 = r * r;

    String rating;
    final absR = r.abs();
    if (absR >= 0.9) {
      rating = r > 0 ? 'Very Strong Positive Correlation' : 'Very Strong Negative Correlation';
    } else if (absR >= 0.7) {
      rating = r > 0 ? 'Strong Positive Correlation' : 'Strong Negative Correlation';
    } else if (absR >= 0.4) {
      rating = r > 0 ? 'Moderate Positive Correlation' : 'Moderate Negative Correlation';
    } else if (absR >= 0.2) {
      rating = 'Weak Correlation';
    } else {
      rating = 'Negligible / No Correlation';
    }

    String fmt(double val) {
      final s = val.toStringAsFixed(4);
      return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }

    final sign = intercept >= 0 ? '+' : '-';
    final eq = 'y = ${fmt(slope)}x $sign ${fmt(intercept.abs())}';

    final steps = <String>[
      'Dataset: $n coordinate pairs (x, y)',
      'Step 1: Compute means: x̄ = ${fmt(meanX)}, ȳ = ${fmt(meanY)}',
      'Step 2: Sum of squares:',
      '  SS_xx = ∑(x - x̄)² = ${fmt(ssXX)}',
      '  SS_yy = ∑(y - ȳ)² = ${fmt(ssYY)}',
      '  SS_xy = ∑(x - x̄)(y - ȳ) = ${fmt(ssXY)}',
      'Step 3: Slope m = SS_xy / SS_xx = ${fmt(ssXY)} / ${fmt(ssXX)} = ${fmt(slope)}',
      'Step 4: Intercept c = ȳ - m·x̄ = ${fmt(meanY)} - (${fmt(slope)} × ${fmt(meanX)}) = ${fmt(intercept)}',
      'Step 5: Trendline equation: $eq',
      'Step 6: Pearson correlation r = SS_xy / √(SS_xx · SS_yy) = ${fmt(r)}',
      'Step 7: Coefficient of determination R² = r² = ${fmt(r2)} (${(r2 * 100).toStringAsFixed(1)}% of variance explained)',
      'Conclusion: $rating',
    ];

    return LinearRegressionResult(
      count: n,
      slope: slope,
      intercept: intercept,
      r: r,
      rSquared: r2,
      equation: eq,
      correlationRating: rating,
      steps: steps,
      points: points,
    );
  }
}

class LinearRegressionResult {
  final int count;
  final double slope;
  final double intercept;
  final double r;
  final double rSquared;
  final String equation;
  final String correlationRating;
  final List<String> steps;
  final List<(double, double)> points;

  const LinearRegressionResult({
    required this.count,
    required this.slope,
    required this.intercept,
    required this.r,
    required this.rSquared,
    required this.equation,
    required this.correlationRating,
    required this.steps,
    required this.points,
  });
}
