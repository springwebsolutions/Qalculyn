// Qalculyn - Sequences & Number Base Conversion Engine
// Arithmetic, Geometric, and Fibonacci sequences plus arbitrary-base (2-36) conversion

import 'dart:math' as math;

class SequencesEngine {
  /// Arithmetic sequence: a_n = a1 + (n - 1)*d, S_n = n/2 * (2*a1 + (n - 1)*d)
  static Map<String, dynamic> arithmetic({
    required double a1,
    required double d,
    required int n,
  }) {
    if (n <= 0) throw const FormatException('Term count n must be positive');
    final an = a1 + (n - 1) * d;
    final sn = (n / 2.0) * (2.0 * a1 + (n - 1) * d);

    final terms = <double>[];
    final previewCount = math.min(n, 10);
    for (var i = 0; i < previewCount; i++) {
      terms.add(a1 + i * d);
    }

    return {
      'an': an,
      'sn': sn,
      'preview': terms,
      'formula': 'a_n = $a1 + (n - 1) × $d',
      'sumFormula': 'S_n = ($n / 2) × (2($a1) + ($n - 1) × $d) = $sn',
    };
  }

  /// Geometric sequence: a_n = a1 * r^(n - 1), S_n = a1 * (1 - r^n) / (1 - r)
  static Map<String, dynamic> geometric({
    required double a1,
    required double r,
    required int n,
  }) {
    if (n <= 0) throw const FormatException('Term count n must be positive');
    final an = a1 * math.pow(r, n - 1);
    final sn = (r == 1.0) ? a1 * n : a1 * (1.0 - math.pow(r, n)) / (1.0 - r);

    final terms = <double>[];
    final previewCount = math.min(n, 10);
    for (var i = 0; i < previewCount; i++) {
      terms.add(a1 * math.pow(r, i));
    }

    return {
      'an': an,
      'sn': sn,
      'preview': terms,
      'formula': 'a_n = $a1 × ($r)^(n - 1)',
      'sumFormula': 'S_$n = $sn',
    };
  }

  /// Fibonacci: exact BigInt for F_n and sequence generation
  static Map<String, dynamic> fibonacci(int n) {
    if (n < 0) throw const FormatException('Fibonacci index must be non-negative');
    if (n == 0) return {'fn': BigInt.zero, 'sequence': [BigInt.zero]};
    if (n == 1) return {'fn': BigInt.one, 'sequence': [BigInt.zero, BigInt.one]};

    var a = BigInt.zero;
    var b = BigInt.one;
    final seq = <BigInt>[a, b];

    for (var i = 2; i <= n; i++) {
      final c = a + b;
      a = b;
      b = c;
      if (seq.length < 25) seq.add(c);
    }

    return {
      'fn': b,
      'sequence': seq,
    };
  }
}

class BaseConverter {
  static const _digits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// Convert string from base 'fromBase' to 'toBase' (2 <= base <= 36)
  static String convert(String value, int fromBase, int toBase) {
    if (fromBase < 2 || fromBase > 36 || toBase < 2 || toBase > 36) {
      throw const FormatException('Base must be between 2 and 36');
    }

    var str = value.trim().toUpperCase();
    if (str.isEmpty) return '0';

    final isNegative = str.startsWith('-');
    if (isNegative) str = str.substring(1);

    // Parse to BigInt decimal value
    var decimalValue = BigInt.zero;
    final baseBig = BigInt.from(fromBase);

    for (var i = 0; i < str.length; i++) {
      final ch = str[i];
      final digit = _digits.indexOf(ch);
      if (digit == -1 || digit >= fromBase) {
        throw FormatException('Invalid character \'$ch\' for base $fromBase');
      }
      decimalValue = decimalValue * baseBig + BigInt.from(digit);
    }

    if (decimalValue == BigInt.zero) return '0';

    // Convert from BigInt decimal to toBase
    final toBaseBig = BigInt.from(toBase);
    final sb = StringBuffer();

    while (decimalValue > BigInt.zero) {
      final rem = (decimalValue % toBaseBig).toInt();
      sb.write(_digits[rem]);
      decimalValue ~/= toBaseBig;
    }

    final result = sb.toString().split('').reversed.join('');
    return isNegative ? '-$result' : result;
  }
}
