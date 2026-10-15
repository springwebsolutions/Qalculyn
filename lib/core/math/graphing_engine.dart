// Qalculyn - Graphing Engine
// Function sampling, root finding (bisection), extrema detection, and Cartesian analysis

import 'calculus_engine.dart';

class GraphPoint {
  final double x;
  final double y;
  final bool isValid;

  const GraphPoint(this.x, this.y, [this.isValid = true]);
}

class FunctionAnalysis {
  final List<double> roots;
  final double? yIntercept;
  final List<GraphPoint> localMinima;
  final List<GraphPoint> localMaxima;

  const FunctionAnalysis({
    required this.roots,
    this.yIntercept,
    required this.localMinima,
    required this.localMaxima,
  });
}

class GraphingEngine {
  final CalculusEngine _calculus = CalculusEngine();

  /// Sample function f(x) across [xMin, xMax] into [sampleCount] points
  List<GraphPoint> sample(String expression, double xMin, double xMax, {int sampleCount = 300}) {
    if (xMin >= xMax) return [];
    final step = (xMax - xMin) / sampleCount;
    final points = <GraphPoint>[];

    for (int i = 0; i <= sampleCount; i++) {
      final x = xMin + i * step;
      try {
        final y = _calculus.evaluate(expression, x);
        if (y.isNaN || y.isInfinite || y.abs() > 1e6) {
          points.add(GraphPoint(x, 0, false));
        } else {
          points.add(GraphPoint(x, y, true));
        }
      } catch (_) {
        points.add(GraphPoint(x, 0, false));
      }
    }
    return points;
  }

  /// Analyze roots, y-intercept, and local extrema within [xMin, xMax]
  FunctionAnalysis analyze(String expression, double xMin, double xMax) {
    final roots = <double>[];
    final minima = <GraphPoint>[];
    final maxima = <GraphPoint>[];
    double? yIntercept;

    // Y-intercept f(0) if 0 is in range
    if (xMin <= 0 && xMax >= 0) {
      try {
        final y0 = _calculus.evaluate(expression, 0.0);
        if (!y0.isNaN && !y0.isInfinite) {
          yIntercept = y0;
        }
      } catch (_) {}
    }

    // Step-through root and extrema search
    const steps = 100;
    final dx = (xMax - xMin) / steps;
    double? prevY;
    double? prevSlope;

    for (int i = 0; i <= steps; i++) {
      final x = xMin + i * dx;
      try {
        final y = _calculus.evaluate(expression, x);
        if (y.isNaN || y.isInfinite) continue;

        // Check root via sign change or direct zero
        if (prevY != null) {
          if (prevY * y < 0) {
            final root = _refineRoot(expression, x - dx, x);
            if (root != null && !roots.any((r) => (r - root).abs() < 1e-2)) {
              roots.add(root);
            }
          } else if (y.abs() < 1e-7 && !roots.any((r) => (r - x).abs() < 1e-2)) {
            roots.add(x);
          }
        }
        prevY = y;

        // Check slope for extrema
        final diff = _calculus.differentiate(expression, x);
        final slope = diff['firstDerivative']!;
        if (prevSlope != null) {
          if (prevSlope < -1e-4 && slope >= -1e-7) {
            if (!minima.any((m) => (m.x - x).abs() < 2 * dx)) {
              minima.add(GraphPoint(x, y));
            }
          } else if (prevSlope > 1e-4 && slope <= 1e-7) {
            if (!maxima.any((m) => (m.x - x).abs() < 2 * dx)) {
              maxima.add(GraphPoint(x, y));
            }
          }
        }
        prevSlope = slope;
      } catch (_) {}
    }

    return FunctionAnalysis(
      roots: roots,
      yIntercept: yIntercept,
      localMinima: minima,
      localMaxima: maxima,
    );
  }

  /// Bisection root finder
  double? _refineRoot(String expression, double a, double b, {int maxIter = 25}) {
    double low = a;
    double high = b;
    try {
      double fLow = _calculus.evaluate(expression, low);
      double fHigh = _calculus.evaluate(expression, high);
      if (fLow * fHigh > 0) return null;

      for (int i = 0; i < maxIter; i++) {
        final mid = (low + high) / 2.0;
        final fMid = _calculus.evaluate(expression, mid);
        if (fMid.abs() < 1e-7 || (high - low).abs() < 1e-6) {
          return mid;
        }
        if (fLow * fMid < 0) {
          high = mid;
          fHigh = fMid;
        } else {
          low = mid;
          fLow = fMid;
        }
      }
      return (low + high) / 2.0;
    } catch (_) {
      return null;
    }
  }

  /// Find intersection points between two functions f1(x) and f2(x) within [xMin, xMax]
  List<GraphPoint> findIntersections(String expr1, String expr2, double xMin, double xMax, {int steps = 120}) {
    if (expr1.trim().isEmpty || expr2.trim().isEmpty || xMin >= xMax) return [];
    final intersections = <GraphPoint>[];
    final dx = (xMax - xMin) / steps;
    double? prevDiff;

    for (int i = 0; i <= steps; i++) {
      final x = xMin + i * dx;
      try {
        final y1 = _calculus.evaluate(expr1, x);
        final y2 = _calculus.evaluate(expr2, x);
        if (y1.isNaN || y1.isInfinite || y2.isNaN || y2.isInfinite) continue;

        final diff = y1 - y2;
        if (prevDiff != null) {
          if (prevDiff * diff < 0) {
            // Refine intersection using bisection on difference
            var low = x - dx;
            var high = x;
            for (int k = 0; k < 25; k++) {
              final mid = (low + high) / 2.0;
              final dMid = _calculus.evaluate(expr1, mid) - _calculus.evaluate(expr2, mid);
              if (dMid.abs() < 1e-6 || (high - low).abs() < 1e-5) {
                final midY = _calculus.evaluate(expr1, mid);
                if (!intersections.any((p) => (p.x - mid).abs() < 1e-2)) {
                  intersections.add(GraphPoint(mid, midY));
                }
                break;
              }
              final dLow = _calculus.evaluate(expr1, low) - _calculus.evaluate(expr2, low);
              if (dLow * dMid < 0) {
                high = mid;
              } else {
                low = mid;
              }
            }
          } else if (diff.abs() < 1e-6 && !intersections.any((p) => (p.x - x).abs() < 1e-2)) {
            intersections.add(GraphPoint(x, y1));
          }
        }
        prevDiff = diff;
      } catch (_) {}
    }

    return intersections;
  }
}
