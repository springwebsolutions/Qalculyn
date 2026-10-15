// Qalculyn - Number Theory Module
// Overflow-safe arbitrary precision arithmetic for LCM, GCD, prime factorization, and modular tools

import 'big_rational.dart';

class EuclideanStep {
  final BigInt a;
  final BigInt b;
  final BigInt quotient;
  final BigInt remainder;

  const EuclideanStep({
    required this.a,
    required this.b,
    required this.quotient,
    required this.remainder,
  });

  @override
  String toString() => '$a = ($b × $quotient) + $remainder';
}

class GcdResult {
  final BigInt gcd;
  final List<EuclideanStep> steps;
  final String explanation;
  final Map<BigInt, int>? primeFactors;

  const GcdResult({
    required this.gcd,
    required this.steps,
    required this.explanation,
    this.primeFactors,
  });
}

class LcmResult {
  final BigInt lcm;
  final List<String> steps;
  final String explanation;
  final List<BigInt>? smallMultiples;

  const LcmResult({
    required this.lcm,
    required this.steps,
    required this.explanation,
    this.smallMultiples,
  });
}

class NumberTheory {
  /// GCD of two integers using the Euclidean algorithm
  static BigInt gcd(BigInt a, BigInt b) {
    var x = a.abs();
    var y = b.abs();
    while (y != BigInt.zero) {
      final t = y;
      y = x % y;
      x = t;
    }
    return x;
  }

  /// Detailed GCD calculation with step-by-step Euclidean divisions
  static GcdResult gcdDetailed(BigInt a, BigInt b) {
    final origA = a;
    final origB = b;
    var x = a.abs();
    var y = b.abs();

    final steps = <EuclideanStep>[];

    // Handle zero inputs explicitly
    if (x == BigInt.zero && y == BigInt.zero) {
      return GcdResult(
        gcd: BigInt.zero,
        steps: const [],
        explanation: 'GCD(0, 0) = 0 by convention, as every integer divides 0 and there is no greatest positive divisor.',
      );
    }
    if (x == BigInt.zero) {
      return GcdResult(
        gcd: y,
        steps: [],
        explanation: 'GCD(0, $origB) = $y because any integer divides 0 and the greatest divisor of $origB is itself.',
      );
    }
    if (y == BigInt.zero) {
      return GcdResult(
        gcd: x,
        steps: [],
        explanation: 'GCD($origA, 0) = $x because any integer divides 0 and the greatest divisor of $origA is itself.',
      );
    }

    // Ensure x >= y for standard Euclidean division appearance
    if (x < y) {
      final temp = x;
      x = y;
      y = temp;
    }

    while (y != BigInt.zero) {
      final q = x ~/ y;
      final r = x % y;
      steps.add(EuclideanStep(a: x, b: y, quotient: q, remainder: r));
      x = y;
      y = r;
    }

    final resultGcd = x;
    final explanation = 'GCD of |$origA| and |$origB| is $resultGcd (last non-zero remainder in the Euclidean algorithm).';

    return GcdResult(gcd: resultGcd, steps: steps, explanation: explanation);
  }

  /// GCD of multiple integers
  static BigInt gcdMany(List<BigInt> numbers) {
    if (numbers.isEmpty) return BigInt.zero;
    var result = numbers[0].abs();
    for (var i = 1; i < numbers.length; i++) {
      result = gcd(result, numbers[i]);
      if (result == BigInt.one) {
        // Optimization: GCD cannot get smaller than 1
        break;
      }
    }
    return result;
  }

  /// LCM of two integers with overflow-safe division first: (|a| / gcd(a,b)) * |b|
  /// Convention: if either number is 0, LCM is 0.
  static BigInt lcm(BigInt a, BigInt b) {
    if (a == BigInt.zero || b == BigInt.zero) {
      return BigInt.zero;
    }
    final g = gcd(a, b);
    return (a.abs() ~/ g) * b.abs();
  }

  /// Detailed LCM calculation with step-by-step explanation
  static LcmResult lcmDetailed(BigInt a, BigInt b) {
    final origA = a;
    final origB = b;
    final steps = <String>[];

    if (a == BigInt.zero || b == BigInt.zero) {
      steps.add('One or both inputs are 0: a = $a, b = $b.');
      steps.add('By integer definition, the only common multiple of 0 and any integer is 0.');
      return LcmResult(
        lcm: BigInt.zero,
        steps: steps,
        explanation: 'LCM($origA, $origB) = 0 because any multiple of 0 is 0.',
      );
    }

    final absA = a.abs();
    final absB = b.abs();
    final g = gcd(absA, absB);

    steps.add('Step 1: Compute GCD(|$origA|, |$origB|) = $g');
    final quotient = absA ~/ g;
    steps.add('Step 2: Divide $absA by GCD ($g): $absA ÷ $g = $quotient');
    final resultLcm = quotient * absB;
    steps.add('Step 3: Multiply by $absB: $quotient × $absB = $resultLcm');
    steps.add('Formula: LCM(a, b) = (|a| × |b|) / GCD(a, b) = ($absA × $absB) / $g = $resultLcm');

    // Small multiples for visual clarity if numbers are small (<= 100)
    List<BigInt>? multiples;
    if (absA <= BigInt.from(100) && absB <= BigInt.from(100) && resultLcm <= BigInt.from(500)) {
      multiples = [];
      var curr = resultLcm;
      for (var i = 1; i <= 5; i++) {
        multiples.add(curr * BigInt.from(i));
      }
    }

    return LcmResult(
      lcm: resultLcm,
      steps: steps,
      explanation: 'Least Common Multiple of $origA and $origB is $resultLcm.',
      smallMultiples: multiples,
    );
  }

  /// LCM of multiple integers
  static BigInt lcmMany(List<BigInt> numbers) {
    if (numbers.isEmpty) return BigInt.zero;
    var result = numbers[0].abs();
    for (var i = 1; i < numbers.length; i++) {
      result = lcm(result, numbers[i]);
      if (result == BigInt.zero) break;
    }
    return result;
  }

  /// Prime factorization: returns prime -> exponent map
  static Map<BigInt, int> primeFactors(BigInt n) {
    final factors = <BigInt, int>{};
    var num = n.abs();

    if (num <= BigInt.one) return factors;

    // Check factor 2
    var two = BigInt.two;
    while (num % two == BigInt.zero) {
      factors[two] = (factors[two] ?? 0) + 1;
      num ~/= two;
    }

    // Check factor 3
    var three = BigInt.from(3);
    while (num % three == BigInt.zero) {
      factors[three] = (factors[three] ?? 0) + 1;
      num ~/= three;
    }

    // Check 6k ± 1
    var d = BigInt.from(5);
    var step = BigInt.two;
    while (d * d <= num) {
      while (num % d == BigInt.zero) {
        factors[d] = (factors[d] ?? 0) + 1;
        num ~/= d;
      }
      d += step;
      step = (step == BigInt.two) ? BigInt.from(4) : BigInt.two;
    }

    if (num > BigInt.one) {
      factors[num] = (factors[num] ?? 0) + 1;
    }

    return factors;
  }

  /// Format prime factorization as a mathematical string (e.g., 2³ × 3² × 5)
  static String formatPrimeFactors(Map<BigInt, int> factors) {
    if (factors.isEmpty) return 'No prime factors';
    final parts = <String>[];
    for (final entry in factors.entries) {
      if (entry.value == 1) {
        parts.add('${entry.key}');
      } else {
        parts.add('${entry.key}${_toSuperscript(entry.value)}');
      }
    }
    return parts.join(' × ');
  }

  static String _toSuperscript(int n) {
    const digits = {'0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴', '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹'};
    return n.toString().split('').map((ch) => digits[ch] ?? ch).join('');
  }

  /// Prime test: deterministic for small numbers, Miller-Rabin for large numbers
  static bool isPrime(BigInt n) {
    if (n <= BigInt.one) return false;
    if (n == BigInt.two || n == BigInt.from(3)) return true;
    if (n % BigInt.two == BigInt.zero || n % BigInt.from(3) == BigInt.zero) return false;

    // Small trial division
    var d = BigInt.from(5);
    var step = BigInt.two;
    final limit = BigInt.from(1000000); // 10^6
    while (d * d <= n && d <= limit) {
      if (n % d == BigInt.zero) return false;
      d += step;
      step = (step == BigInt.two) ? BigInt.from(4) : BigInt.two;
    }

    if (d * d > n) return true;

    // Miller-Rabin test for larger integers
    return _millerRabin(n);
  }

  static bool _millerRabin(BigInt n) {
    // Write n - 1 as 2^s * d
    var d = n - BigInt.one;
    var s = 0;
    while (d % BigInt.two == BigInt.zero) {
      d ~/= BigInt.two;
      s++;
    }

    // Bases for deterministic test up to 2^64, and high probability beyond
    final bases = [
      BigInt.two,
      BigInt.from(3),
      BigInt.from(5),
      BigInt.from(7),
      BigInt.from(11),
      BigInt.from(13),
      BigInt.from(17),
      BigInt.from(19),
      BigInt.from(23),
      BigInt.from(29),
      BigInt.from(31),
      BigInt.from(37),
    ];

    for (final a in bases) {
      if (a >= n) break;
      var x = a.modPow(d, n);
      if (x == BigInt.one || x == n - BigInt.one) continue;

      var composite = true;
      for (var r = 1; r < s; r++) {
        x = x.modPow(BigInt.two, n);
        if (x == n - BigInt.one) {
          composite = false;
          break;
        }
      }
      if (composite) return false;
    }
    return true;
  }

  /// Find all positive divisors of n
  static List<BigInt> divisors(BigInt n) {
    final num = n.abs();
    if (num == BigInt.zero) return [];
    if (num == BigInt.one) return [BigInt.one];

    final factors = primeFactors(num);
    var result = <BigInt>[BigInt.one];

    for (final entry in factors.entries) {
      final p = entry.key;
      final exp = entry.value;
      final newDivs = <BigInt>[];
      var currentPower = BigInt.one;

      for (var i = 0; i <= exp; i++) {
        for (final d in result) {
          newDivs.add(d * currentPower);
        }
        currentPower *= p;
      }
      result = newDivs;
    }

    result.sort();
    return result;
  }

  /// Perfect square check: returns (isSquare, root)
  static (bool, BigInt) isPerfectSquare(BigInt n) {
    if (n < BigInt.zero) return (false, BigInt.zero);
    if (n == BigInt.zero) return (true, BigInt.zero);
    if (n == BigInt.one) return (true, BigInt.one);

    // Integer square root via Newton's method
    var x0 = n ~/ BigInt.two;
    if (x0 != BigInt.zero) {
      var x1 = (x0 + n ~/ x0) ~/ BigInt.two;
      while (x1 < x0) {
        x0 = x1;
        x1 = (x0 + n ~/ x0) ~/ BigInt.two;
      }
      if (x0 * x0 == n) return (true, x0);
    }
    return (false, BigInt.zero);
  }

  /// Perfect cube check: returns (isCube, root)
  static (bool, BigInt) isPerfectCube(BigInt n) {
    if (n == BigInt.zero) return (true, BigInt.zero);
    final isNeg = n < BigInt.zero;
    final absN = n.abs();

    // Binary search for cube root
    var low = BigInt.one;
    var high = absN;
    while (low <= high) {
      final mid = (low + high) ~/ BigInt.two;
      final cube = mid * mid * mid;
      if (cube == absN) {
        return (true, isNeg ? -mid : mid);
      } else if (cube < absN) {
        low = mid + BigInt.one;
      } else {
        high = mid - BigInt.one;
      }
    }
    return (false, BigInt.zero);
  }

  /// Fraction GCD definition: GCD(a/b, c/d) = GCD(a, c) / LCM(b, d)
  /// Requires fractions in lowest terms with positive denominators
  static BigRational fractionGcd(BigRational f1, BigRational f2) {
    if (f1.isZero) return f2.abs();
    if (f2.isZero) return f1.abs();
    final numGcd = gcd(f1.num, f2.num);
    final denLcm = lcm(f1.den, f2.den);
    return BigRational(numGcd, denLcm);
  }

  /// Fraction LCM definition: LCM(a/b, c/d) = LCM(a, c) / GCD(b, d)
  /// Requires fractions in lowest terms with positive denominators
  static BigRational fractionLcm(BigRational f1, BigRational f2) {
    if (f1.isZero || f2.isZero) return BigRational.zero;
    final numLcm = lcm(f1.num, f2.num);
    final denGcd = gcd(f1.den, f2.den);
    return BigRational(numLcm, denGcd);
  }

  /// Simplify a ratio of integers (e.g. 12 : 18 : 24 -> 2 : 3 : 4)
  static List<BigInt> simplifyRatio(List<BigInt> terms) {
    if (terms.isEmpty) return [];
    final g = gcdMany(terms);
    if (g == BigInt.zero || g == BigInt.one) return terms;
    return terms.map((t) => t ~/ g).toList();
  }

  /// Extended Euclidean Algorithm finding Bézout coefficients x, y such that a*x + b*y = gcd(a, b)
  static ExtendedGcdResult extendedGcd(BigInt a, BigInt b) {
    if (b == BigInt.zero) {
      final signA = a < BigInt.zero ? -BigInt.one : BigInt.one;
      final g = a.abs();
      return ExtendedGcdResult(
        gcd: g,
        x: signA,
        y: BigInt.zero,
        steps: [
          'Direct evaluation with b = 0:',
          'GCD($a, 0) = $g',
          'Identity: $a × ($signA) + 0 × (0) = $g',
        ],
        identity: '$a × ($signA) + $b × (0) = $g',
      );
    }

    final steps = <String>[];
    steps.add('Forward Euclidean division steps:');

    var r0 = a.abs(), r1 = b.abs();
    var s0 = BigInt.one, s1 = BigInt.zero;
    var t0 = BigInt.zero, t1 = BigInt.one;

    var stepNum = 1;
    while (r1 != BigInt.zero) {
      final q = r0 ~/ r1;
      final r2 = r0 - q * r1;
      final s2 = s0 - q * s1;
      final t2 = t0 - q * t1;

      steps.add(
        'Step $stepNum: $r0 = ($q × $r1) + $r2  →  Remainder $r2 = $r0 - ($q × $r1)',
      );

      r0 = r1;
      r1 = r2;
      s0 = s1;
      s1 = s2;
      t0 = t1;
      t1 = t2;
      stepNum++;
    }

    final g = r0;
    // Adjust signs if initial a or b were negative
    var finalX = a < BigInt.zero ? -s0 : s0;
    var finalY = b < BigInt.zero ? -t0 : t0;

    steps.add('');
    steps.add('Backward substitution yields Bézout coefficients:');
    steps.add('GCD($a, $b) = $g');
    steps.add('x = $finalX, y = $finalY');
    final id = '$a × ($finalX) + $b × ($finalY) = $g';
    steps.add('Verification: $id');

    return ExtendedGcdResult(
      gcd: g,
      x: finalX,
      y: finalY,
      steps: steps,
      identity: id,
    );
  }

  /// Modular Exponentiation: (base^exp) mod modulus with step-by-step repeated squaring
  static ModPowResult modPowDetailed(BigInt base, BigInt exp, BigInt mod) {
    final steps = <String>[];
    if (mod <= BigInt.zero) {
      return ModPowResult(
        result: BigInt.zero,
        steps: ['Modulus must be a positive integer greater than 0.'],
      );
    }
    if (exp < BigInt.zero) {
      return ModPowResult(
        result: BigInt.zero,
        steps: ['Negative exponents require finding modular inverse first.'],
      );
    }
    if (mod == BigInt.one) {
      return ModPowResult(
        result: BigInt.zero,
        steps: ['Any integer modulo 1 equals 0.'],
      );
    }

    var result = BigInt.one;
    var currentBase = base % mod;
    var currentExp = exp;

    steps.add('Computing ($base ^ $exp) mod $mod using repeated squaring:');
    steps.add('Initial base mod $mod = $currentBase');

    var step = 1;
    while (currentExp > BigInt.zero) {
      final isOdd = (currentExp % BigInt.two) != BigInt.zero;
      if (isOdd) {
        final prevResult = result;
        result = (result * currentBase) % mod;
        steps.add(
          'Step $step (exp = $currentExp is odd): multiply accumulated result ($prevResult × $currentBase) mod $mod = $result',
        );
      } else {
        steps.add('Step $step (exp = $currentExp is even): square base for next bit');
      }

      currentExp ~/= BigInt.two;
      if (currentExp > BigInt.zero) {
        final prevBase = currentBase;
        currentBase = (currentBase * currentBase) % mod;
        steps.add('  Next square: ($prevBase²) mod $mod = $currentBase');
      }
      step++;
    }

    steps.add('Final Answer: ($base ^ $exp) mod $mod = $result');

    return ModPowResult(result: result, steps: steps);
  }

  /// Modular Multiplicative Inverse: finds x such that (a * x) ≡ 1 (mod m)
  static ModInverseResult modInverseDetailed(BigInt a, BigInt m) {
    final steps = <String>[];
    if (m <= BigInt.one) {
      return ModInverseResult(
        inverse: null,
        exists: false,
        steps: ['Modulus m must be greater than 1.'],
      );
    }

    final positiveA = ((a % m) + m) % m;
    steps.add('Find x such that ($positiveA × x) ≡ 1 (mod $m)');
    steps.add('Condition: Modular inverse exists if and only if GCD($positiveA, $m) = 1.');

    final ext = extendedGcd(positiveA, m);
    if (ext.gcd != BigInt.one) {
      steps.add('GCD($positiveA, $m) = ${ext.gcd} ≠ 1');
      steps.add('Conclusion: No modular inverse exists because $positiveA and $m share a common factor (${ext.gcd}).');
      return ModInverseResult(
        inverse: null,
        exists: false,
        steps: steps,
      );
    }

    // Bézout identity: a*x + m*y = 1 -> a*x ≡ 1 (mod m)
    var inv = ext.x % m;
    if (inv < BigInt.zero) inv += m;

    steps.addAll(ext.steps);
    steps.add('Bézout coefficient x = ${ext.x}');
    steps.add('Normalized modulo $m: $inv');
    steps.add('Verification: ($positiveA × $inv) mod $m = ${(positiveA * inv) % m}');

    return ModInverseResult(
      inverse: inv,
      exists: true,
      steps: steps,
    );
  }

  /// Euler's Totient Function φ(n) with formula derivation
  static TotientResult eulerTotientDetailed(BigInt n) {
    final steps = <String>[];
    if (n <= BigInt.zero) {
      return TotientResult(
        n: n,
        phi: BigInt.zero,
        factors: const {},
        steps: ['Euler\'s Totient function is defined for positive integers n ≥ 1.'],
      );
    }
    if (n == BigInt.one) {
      return TotientResult(
        n: BigInt.one,
        phi: BigInt.one,
        factors: const {},
        steps: ['φ(1) = 1 by definition (1 is relatively prime to itself).'],
      );
    }

    final factors = primeFactors(n);
    steps.add('Step 1: Compute prime factorization of $n:');
    steps.add('$n = ${formatPrimeFactors(factors)}');

    steps.add('Step 2: Apply Euler\'s product formula:');
    steps.add('φ(n) = n × ∏ (1 - 1/p) = n × ∏ ((p - 1) / p)');

    var result = n;
    final factorList = factors.keys.toList();
    for (final p in factorList) {
      result = (result ~/ p) * (p - BigInt.one);
      steps.add('For prime factor $p: multiply by ($p - 1)/$p → intermediate value = $result');
    }

    steps.add('Final Answer: φ($n) = $result');
    steps.add('Interpretation: There are $result integers between 1 and $n that are coprime to $n.');

    return TotientResult(
      n: n,
      phi: result,
      factors: factors,
      steps: steps,
    );
  }
}

class ExtendedGcdResult {
  final BigInt gcd;
  final BigInt x;
  final BigInt y;
  final List<String> steps;
  final String identity;

  const ExtendedGcdResult({
    required this.gcd,
    required this.x,
    required this.y,
    required this.steps,
    required this.identity,
  });
}

class ModPowResult {
  final BigInt result;
  final List<String> steps;

  const ModPowResult({
    required this.result,
    required this.steps,
  });
}

class ModInverseResult {
  final BigInt? inverse;
  final bool exists;
  final List<String> steps;

  const ModInverseResult({
    required this.inverse,
    required this.exists,
    required this.steps,
  });
}

class TotientResult {
  final BigInt n;
  final BigInt phi;
  final Map<BigInt, int> factors;
  final List<String> steps;

  const TotientResult({
    required this.n,
    required this.phi,
    required this.factors,
    required this.steps,
  });
}
