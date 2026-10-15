// Qalculyn - Natural Language Math Question & Word Problem Parser
// Offline conversational query interpreter mapping natural language expressions to exact mathematical solvers

import 'dart:math' as math;
import 'geometry_engine.dart';

class NaturalLanguageResult {
  final bool isMatch;
  final String query;
  final String? title;
  final String? formula;
  final Map<String, String> results;
  final String? explanation;

  const NaturalLanguageResult({
    required this.isMatch,
    required this.query,
    this.title,
    this.formula,
    this.results = const {},
    this.explanation,
  });

  const NaturalLanguageResult.noMatch(this.query)
      : isMatch = false,
        title = null,
        formula = null,
        results = const {},
        explanation = null;
}

class NaturalLanguageParser {
  static NaturalLanguageResult parse(String input) {
    final clean = input.trim().toLowerCase();
    if (clean.isEmpty) return const NaturalLanguageResult.noMatch('');

    // Extract numbers from the query
    final numberRegex = RegExp(r'[-+]?\d*\.?\d+');
    final matches = numberRegex.allMatches(clean);
    final numbers = matches.map((m) => double.tryParse(m.group(0)!) ?? 0.0).toList();

    // 1. Circle queries: "area of circle radius 5" or "circumference of circle r 10"
    if (clean.contains('circle') && clean.contains('radius') && numbers.isNotEmpty) {
      final r = numbers.first;
      final res = GeometryEngine.circle(r);
      return NaturalLanguageResult(
        isMatch: true,
        query: input,
        title: 'Circle Geometry (Radius: $r)',
        formula: 'A = πr², C = 2πr',
        results: res.map((k, v) => MapEntry(k, v.toStringAsFixed(4))),
        explanation: 'Area is calculated using πr² and circumference using 2πr.',
      );
    }

    // 2. Circle from area: "radius of circle with area 50"
    if (clean.contains('circle') && clean.contains('area') && numbers.isNotEmpty) {
      final a = numbers.first;
      final res = GeometryEngine.circleFromArea(a);
      return NaturalLanguageResult(
        isMatch: true,
        query: input,
        title: 'Circle from Area ($a)',
        formula: 'r = √(A / π)',
        results: res.map((k, v) => MapEntry(k, v.toStringAsFixed(4))),
        explanation: 'Inverting circle area yields radius r = √(A / π).',
      );
    }

    // 3. Pythagorean hypotenuse: "hypotenuse 6 and 8" or "pythagorean 3 4"
    if ((clean.contains('hypotenuse') || clean.contains('pythagor')) && numbers.length >= 2) {
      final a = numbers[0], b = numbers[1];
      final res = GeometryEngine.pythagoreanHypotenuse(a, b);
      return NaturalLanguageResult(
        isMatch: true,
        query: input,
        title: 'Pythagorean Hypotenuse ($a, $b)',
        formula: 'c = √(a² + b²)',
        results: res.map((k, v) => MapEntry(k, v.toStringAsFixed(4))),
        explanation: 'The hypotenuse c is the square root of the sum of the squares of the legs.',
      );
    }

    // 4. Pythagorean missing leg: "missing leg hypotenuse 13 leg 5"
    if (clean.contains('leg') && (clean.contains('hypotenuse') || clean.contains('hyp')) && numbers.length >= 2) {
      final c = math.max(numbers[0], numbers[1]);
      final a = math.min(numbers[0], numbers[1]);
      final res = GeometryEngine.pythagoreanMissingLeg(c, a);
      return NaturalLanguageResult(
        isMatch: true,
        query: input,
        title: 'Missing Triangle Leg (c: $c, a: $a)',
        formula: 'b = √(c² - a²)',
        results: res.map((k, v) => MapEntry(k, v.toStringAsFixed(4))),
      );
    }

    // 5. Reverse GST / Pre-tax: "pre tax 1180 gst 18" or "mrp 1180 18% gst"
    if ((clean.contains('gst') || clean.contains('tax')) && (clean.contains('pre') || clean.contains('mrp') || clean.contains('reverse')) && numbers.length >= 2) {
      double mrp;
      double gst;
      final explicitGst = RegExp(r'gst\s*[:=]?\s*(\d+(?:\.\d+)?)|(\d+(?:\.\d+)?)\s*%\s*(?:gst|tax)?').firstMatch(clean);
      if (explicitGst != null) {
        final parsed = double.tryParse(explicitGst.group(1) ?? explicitGst.group(2) ?? '');
        if (parsed != null && (numbers[0] == parsed || numbers[1] == parsed)) {
          gst = parsed;
          mrp = (numbers[0] == parsed) ? numbers[1] : numbers[0];
        } else {
          mrp = math.max(numbers[0], numbers[1]);
          gst = math.min(numbers[0], numbers[1]);
        }
      } else {
        mrp = math.max(numbers[0], numbers[1]);
        gst = math.min(numbers[0], numbers[1]);
      }
      final base = mrp / (1.0 + gst / 100.0);
      final tax = mrp - base;
      return NaturalLanguageResult(
        isMatch: true,
        query: input,
        title: 'Reverse GST Pre-tax Calculation (MRP: $mrp, GST: $gst%)',
        formula: 'Base = MRP / (1 + GST/100)',
        results: {
          'Base Price (Pre-tax)': base.toStringAsFixed(2),
          'Total GST Tax': tax.toStringAsFixed(2),
          'CGST (Half)': (tax / 2.0).toStringAsFixed(2),
          'SGST (Half)': (tax / 2.0).toStringAsFixed(2),
        },
      );
    }

    // 6. Reverse Discount: "original price of 75 discount 25%" or "discounted 75 discount 25"
    if (clean.contains('discount') && (clean.contains('original') || clean.contains('pre') || clean.contains('before')) && numbers.length >= 2) {
      final discPrice = numbers[0];
      final discPct = numbers[1];
      if (discPct < 100) {
        final orig = discPrice / (1.0 - discPct / 100.0);
        return NaturalLanguageResult(
          isMatch: true,
          query: input,
          title: 'Original Price Before Discount',
          formula: 'Original = Price / (1 - Discount/100)',
          results: {
            'Original Price': orig.toStringAsFixed(2),
            'Discounted Price': discPrice.toStringAsFixed(2),
            'Amount Saved': (orig - discPrice).toStringAsFixed(2),
          },
        );
      }
    }

    // 7. Doubling Time / Rule of 72: "double money at 8%" or "doubling time rate 7"
    if ((clean.contains('double') || clean.contains('doubling')) && numbers.isNotEmpty) {
      final r = numbers.first;
      if (r > 0) {
        final exactYears = math.log(2.0) / math.log(1.0 + r / 100.0);
        final rule72 = 72.0 / r;
        return NaturalLanguageResult(
          isMatch: true,
          query: input,
          title: 'Investment Doubling Time ($r% p.a.)',
          formula: 't = ln(2) / ln(1 + r/100)',
          results: {
            'Exact Doubling Years': exactYears.toStringAsFixed(2),
            'Rule of 72 (approx)': rule72.toStringAsFixed(2),
            'Months': (exactYears * 12.0).toStringAsFixed(1),
          },
        );
      }
    }

    // 8. Reverse SIP: "sip for 1000000 at 12% in 10 years"
    if (clean.contains('sip') && numbers.length >= 3) {
      final target = numbers[0];
      final rate = numbers[1];
      final years = numbers[2];
      final i = (rate / 12.0) / 100.0;
      final n = (years * 12.0).round();
      final factor = (math.pow(1.0 + i, n) - 1.0) / i * (1.0 + i);
      final monthly = target / factor;
      final totalInvested = monthly * n;
      return NaturalLanguageResult(
        isMatch: true,
        query: input,
        title: 'Required Monthly SIP for Target Goal',
        formula: 'P = Target / [ ((1+i)ⁿ - 1)/i × (1+i) ]',
        results: {
          'Required Monthly SIP': monthly.toStringAsFixed(2),
          'Total Invested': totalInvested.toStringAsFixed(2),
          'Estimated Wealth Gain': (target - totalInvested).toStringAsFixed(2),
        },
      );
    }

    // 9. Sphere volume / surface area: "volume of sphere radius 5"
    if (clean.contains('sphere') && clean.contains('radius') && numbers.isNotEmpty) {
      final r = numbers.first;
      final res = GeometryEngine.sphere(r);
      return NaturalLanguageResult(
        isMatch: true,
        query: input,
        title: 'Sphere Geometry (Radius: $r)',
        formula: 'V = (4/3)πr³, A = 4πr²',
        results: res.map((k, v) => MapEntry(k, v.toStringAsFixed(4))),
      );
    }

    // 10. Cylinder volume: "volume of cylinder radius 3 height 7"
    if (clean.contains('cylinder') && numbers.length >= 2) {
      final r = numbers[0];
      final h = numbers[1];
      final res = GeometryEngine.cylinder(r, h);
      return NaturalLanguageResult(
        isMatch: true,
        query: input,
        title: 'Cylinder Geometry (r: $r, h: $h)',
        formula: 'V = πr²h, A = 2πr(r + h)',
        results: res.map((k, v) => MapEntry(k, v.toStringAsFixed(4))),
      );
    }

    // 11. Physics: Speed, Distance, Time: "speed distance 150 time 2"
    if (clean.contains('speed') && clean.contains('distance') && numbers.length >= 2) {
      final d = numbers[0];
      final t = numbers[1];
      if (t > 0) {
        final v = d / t;
        return NaturalLanguageResult(
          isMatch: true,
          query: input,
          title: 'Speed Calculation (d: $d, t: $t)',
          formula: 'v = d / t',
          results: {
            'Speed (units/time)': v.toStringAsFixed(2),
            'Speed (m/s if km/h)': (v / 3.6).toStringAsFixed(2),
          },
        );
      }
    }

    // 12. Ohm's law: "voltage current 3 resistance 4"
    if ((clean.contains('ohm') || clean.contains('voltage')) && numbers.length >= 2) {
      final i = numbers[0];
      final r = numbers[1];
      final v = i * r;
      return NaturalLanguageResult(
        isMatch: true,
        query: input,
        title: 'Ohm’s Law Voltage & Power (I: $i A, R: $r Ω)',
        formula: 'V = I × R, P = V × I',
        results: {
          'Voltage (V)': v.toStringAsFixed(2),
          'Power (Watts)': (v * i).toStringAsFixed(2),
        },
      );
    }

    return const NaturalLanguageResult.noMatch('');
  }
}
