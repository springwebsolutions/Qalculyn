// Qalculyn - Exact BigRational Arithmetic
// Arbitrary-precision exact rational numbers for algebra and number theory

class BigRational implements Comparable<BigRational> {
  final BigInt num;
  final BigInt den;

  static final BigRational zero = BigRational(BigInt.zero);
  static final BigRational one = BigRational(BigInt.one);
  static final BigRational minusOne = BigRational(-BigInt.one);

  factory BigRational(BigInt numerator, [BigInt? denominator]) {
    var n = numerator;
    var d = denominator ?? BigInt.one;

    if (d == BigInt.zero) {
      throw const FormatException('Denominator cannot be zero in rational number');
    }

    if (d < BigInt.zero) {
      n = -n;
      d = -d;
    }

    if (n == BigInt.zero) {
      return BigRational._internal(BigInt.zero, BigInt.one);
    }

    final gcdVal = _gcd(n.abs(), d);
    return BigRational._internal(n ~/ gcdVal, d ~/ gcdVal);
  }

  const BigRational._internal(this.num, this.den);

  factory BigRational.fromInt(int numerator, [int denominator = 1]) =>
      BigRational(BigInt.from(numerator), BigInt.from(denominator));

  factory BigRational.parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw const FormatException('Empty rational string');

    if (trimmed.contains('/')) {
      final parts = trimmed.split('/');
      if (parts.length != 2) throw FormatException('Invalid fraction format: $text');
      final n = BigInt.parse(parts[0].trim());
      final d = BigInt.parse(parts[1].trim());
      return BigRational(n, d);
    } else if (trimmed.contains('.')) {
      final parts = trimmed.split('.');
      if (parts.length != 2) throw FormatException('Invalid decimal format: $text');
      final isNegative = parts[0].startsWith('-');
      final wholeStr = isNegative ? parts[0].substring(1) : parts[0];
      final fracStr = parts[1];
      final denom = BigInt.from(10).pow(fracStr.length);
      final whole = wholeStr.isEmpty ? BigInt.zero : BigInt.parse(wholeStr);
      final frac = fracStr.isEmpty ? BigInt.zero : BigInt.parse(fracStr);
      final totalNum = whole * denom + frac;
      return BigRational(isNegative ? -totalNum : totalNum, denom);
    } else {
      return BigRational(BigInt.parse(trimmed), BigInt.one);
    }
  }

  static BigInt _gcd(BigInt a, BigInt b) {
    while (b != BigInt.zero) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  bool get isZero => num == BigInt.zero;
  bool get isOne => num == den;
  bool get isNegative => num < BigInt.zero;
  bool get isPositive => num > BigInt.zero;
  bool get isInteger => den == BigInt.one;

  BigRational operator +(BigRational other) {
    final n = num * other.den + other.num * den;
    final d = den * other.den;
    return BigRational(n, d);
  }

  BigRational operator -(BigRational other) {
    final n = num * other.den - other.num * den;
    final d = den * other.den;
    return BigRational(n, d);
  }

  BigRational operator *(BigRational other) {
    return BigRational(num * other.num, den * other.den);
  }

  BigRational operator /(BigRational other) {
    if (other.isZero) {
      throw const FormatException('Division by zero in rational arithmetic');
    }
    return BigRational(num * other.den, den * other.num);
  }

  BigRational operator -() => BigRational._internal(-num, den);

  BigRational abs() => BigRational._internal(num.abs(), den);

  BigRational inverse() {
    if (isZero) throw const FormatException('Cannot invert zero rational');
    return BigRational(den, num);
  }

  BigRational pow(int exponent) {
    if (exponent == 0) return BigRational.one;
    if (isZero) return BigRational.zero;
    if (exponent > 0) {
      return BigRational(num.pow(exponent), den.pow(exponent));
    } else {
      final pos = -exponent;
      return BigRational(den.pow(pos), num.pow(pos));
    }
  }

  double toDouble() => num.toDouble() / den.toDouble();

  @override
  int compareTo(BigRational other) {
    final diff = (num * other.den) - (other.num * den);
    if (diff < BigInt.zero) return -1;
    if (diff > BigInt.zero) return 1;
    return 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BigRational && num == other.num && den == other.den;
  }

  @override
  int get hashCode => Object.hash(num, den);

  @override
  String toString() {
    if (den == BigInt.one) return num.toString();
    return '$num/$den';
  }

  String toMixedFraction() {
    if (den == BigInt.one) return num.toString();
    final whole = num ~/ den;
    final rem = (num % den).abs();
    if (whole == BigInt.zero) return '$num/$den';
    return '$whole $rem/$den';
  }
}
