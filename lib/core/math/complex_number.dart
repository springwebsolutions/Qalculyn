// Qalculyn - Complex Number Engine
// Rectangular (a + bi) and Polar (r * e^(i*theta)) complex arithmetic

import 'dart:math' as math;

class Complex {
  final double real;
  final double imag;

  const Complex(this.real, [this.imag = 0.0]);

  static const Complex zero = Complex(0.0, 0.0);
  static const Complex one = Complex(1.0, 0.0);
  static const Complex i = Complex(0.0, 1.0);

  factory Complex.fromPolar(double r, double thetaRadians) {
    return Complex(r * math.cos(thetaRadians), r * math.sin(thetaRadians));
  }

  /// Parses strings like "3 + 4i", "5 - 2i", "-3i", "4", "2.5 + i"
  factory Complex.parse(String input) {
    var str = input.replaceAll(' ', '').trim();
    if (str.isEmpty) return Complex.zero;

    // Check pure imaginary: e.g. "i", "-i", "4i", "-2.5i"
    if (str == 'i' || str == '+i') return Complex.i;
    if (str == '-i') return const Complex(0.0, -1.0);

    // If ends with i and doesn't have +/- in middle
    final hasI = str.endsWith('i');
    if (hasI) {
      str = str.substring(0, str.length - 1);
      // Look for a second sign
      final lastPlus = str.lastIndexOf('+');
      final lastMinus = str.lastIndexOf('-');
      final signIdx = math.max(lastPlus, lastMinus);

      if (signIdx <= 0) {
        // Pure imaginary
        final val = str.isEmpty ? 1.0 : (str == '-' ? -1.0 : double.parse(str));
        return Complex(0.0, val);
      } else {
        // Real + Imag
        final rStr = str.substring(0, signIdx);
        var iStr = str.substring(signIdx);
        if (iStr == '+') iStr = '1';
        if (iStr == '-') iStr = '-1';
        return Complex(double.parse(rStr), double.parse(iStr));
      }
    } else {
      // Pure real
      return Complex(double.parse(str), 0.0);
    }
  }

  double get modulus => math.sqrt(real * real + imag * imag);
  double get argument => math.atan2(imag, real); // Radians [-pi, pi]
  double get argumentDegrees => argument * 180.0 / math.pi;

  Complex operator +(Complex other) => Complex(real + other.real, imag + other.imag);
  Complex operator -(Complex other) => Complex(real - other.real, imag - other.imag);

  Complex operator *(Complex other) {
    return Complex(
      real * other.real - imag * other.imag,
      real * other.imag + imag * other.real,
    );
  }

  Complex operator /(Complex other) {
    final denom = other.real * other.real + other.imag * other.imag;
    if (denom == 0) throw const FormatException('Division by zero in complex numbers');
    return Complex(
      (real * other.real + imag * other.imag) / denom,
      (imag * other.real - real * other.imag) / denom,
    );
  }

  Complex operator -() => Complex(-real, -imag);

  Complex conjugate() => Complex(real, -imag);

  Complex pow(double exponent) {
    final r = math.pow(modulus, exponent).toDouble();
    final theta = argument * exponent;
    return Complex.fromPolar(r, theta);
  }

  Complex sqrt() {
    final r = math.sqrt(modulus);
    final theta = argument / 2.0;
    return Complex.fromPolar(r, theta);
  }

  String toPolarString({bool inDegrees = true}) {
    final r = modulus.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final ang = inDegrees
        ? '${argumentDegrees.toStringAsFixed(2)}°'
        : '${argument.toStringAsFixed(4)} rad';
    return '$r ∠ $ang';
  }

  @override
  String toString() {
    final rStr = real.abs() < 1e-12 ? '0' : real.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    final iAbs = imag.abs();
    final iStr = iAbs < 1e-12 ? '0' : (iAbs == 1.0 ? '' : iAbs.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), ''));

    if (imag.abs() < 1e-12) return rStr;
    if (real.abs() < 1e-12) return imag < 0 ? '-${iStr}i' : '${iStr}i';

    final sign = imag < 0 ? ' - ' : ' + ';
    return '$rStr$sign${iStr}i';
  }
}
