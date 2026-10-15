// Qalculyn - Polynomial Long Division & Synthetic Division
// Generates step-by-step polynomial long division and synthetic division tableaus

import 'algebra_engine.dart';
import 'big_rational.dart';

class PolynomialDivisionStep {
  final int stepNumber;
  final String termChosen;
  final String product;
  final String intermediateRemainder;

  const PolynomialDivisionStep({
    required this.stepNumber,
    required this.termChosen,
    required this.product,
    required this.intermediateRemainder,
  });
}

class PolynomialDivisionResult {
  final Polynomial dividend;
  final Polynomial divisor;
  final Polynomial quotient;
  final Polynomial remainder;
  final List<PolynomialDivisionStep> steps;
  final List<String> textSteps;
  final bool isSyntheticApplicable;
  final String? syntheticRoot;
  final List<List<String>>? syntheticTable;

  const PolynomialDivisionResult({
    required this.dividend,
    required this.divisor,
    required this.quotient,
    required this.remainder,
    required this.steps,
    required this.textSteps,
    required this.isSyntheticApplicable,
    this.syntheticRoot,
    this.syntheticTable,
  });
}

class PolynomialDivisionEngine {
  static PolynomialDivisionResult divide(String dividendStr, String divisorStr) {
    final p = Polynomial.parse(dividendStr);
    final d = Polynomial.parse(divisorStr);

    if (d.isZero) {
      throw const FormatException('Cannot divide by the zero polynomial');
    }

    final (q, r) = p.divideWithRemainder(d);
    final textSteps = <String>[];
    final steps = <PolynomialDivisionStep>[];

    textSteps.add('Given Division: (${p.toString()}) ÷ (${d.toString()})');
    textSteps.add('Dividend degree: ${p.degree}, Divisor degree: ${d.degree}');

    if (p.degree < d.degree) {
      textSteps.add('\nSince the dividend degree (${p.degree}) is strictly less than divisor degree (${d.degree}):');
      textSteps.add('Quotient = 0');
      textSteps.add('Remainder = ${p.toString()}');
      return PolynomialDivisionResult(
        dividend: p,
        divisor: d,
        quotient: q,
        remainder: r,
        steps: const [],
        textSteps: textSteps,
        isSyntheticApplicable: false,
      );
    }

    var currentRemainder = p;
    var stepIndex = 1;

    while (!currentRemainder.isZero && currentRemainder.degree >= d.degree) {
      final degDiff = currentRemainder.degree - d.degree;
      final factor = currentRemainder.leadingCoeff / d.leadingCoeff;

      final termCoeffs = List<BigRational>.filled(degDiff + 1, BigRational.zero);
      termCoeffs[degDiff] = factor;
      final termPoly = Polynomial(termCoeffs, variable: p.variable);

      final product = d * termPoly;
      currentRemainder = currentRemainder - product;

      final stepDesc = 'Step $stepIndex: Divide leading terms (${currentRemainder.leadingCoeff.isZero ? factor.toString() : termPoly.toString()})';
      textSteps.add('\n$stepDesc:');
      textSteps.add('Multiply (${termPoly.toString()}) × (${d.toString()}) = ${product.toString()}');
      textSteps.add('Subtract to get new remainder: ${currentRemainder.isZero ? '0' : currentRemainder.toString()}');

      steps.add(PolynomialDivisionStep(
        stepNumber: stepIndex,
        termChosen: termPoly.toString(),
        product: product.toString(),
        intermediateRemainder: currentRemainder.isZero ? '0' : currentRemainder.toString(),
      ));

      stepIndex++;
    }

    textSteps.add('\nSummary:');
    textSteps.add('Quotient Q(x) = ${q.toString()}');
    textSteps.add('Remainder R(x) = ${r.isZero ? '0' : r.toString()}');
    textSteps.add('\nDivision Algorithm Verification:');
    textSteps.add('P(x) = (${d.toString()}) × (${q.toString()}) + (${r.isZero ? '0' : r.toString()})');

    // Check synthetic division eligibility: divisor is (x - c)
    bool isSynthetic = d.degree == 1 && d.leadingCoeff == BigRational.one;
    String? rootStr;
    List<List<String>>? synTable;

    if (isSynthetic) {
      // d = x + a0 => root c = -a0
      final root = -d.coeffs[0];
      rootStr = root.toString();

      final divCoeffs = p.coeffs.reversed.map((c) => c.toString()).toList();
      final row2 = <String>['—'];
      final row3 = <String>[];

      var running = BigRational.zero;
      final reversedP = p.coeffs.reversed.toList();
      for (var i = 0; i < reversedP.length; i++) {
        if (i == 0) {
          running = reversedP[0];
          row3.add(running.toString());
        } else {
          final mult = running * root;
          row2.add(mult.toString());
          running = reversedP[i] + mult;
          row3.add(running.toString());
        }
      }

      synTable = [divCoeffs, row2, row3];
    }

    return PolynomialDivisionResult(
      dividend: p,
      divisor: d,
      quotient: q,
      remainder: r,
      steps: steps,
      textSteps: textSteps,
      isSyntheticApplicable: isSynthetic,
      syntheticRoot: rootStr,
      syntheticTable: synTable,
    );
  }
}
