// Qalculyn - Universal Question & Problem Solving Engine
// Inverse formulas, word problems, and questions across Geometry, Finance, Algebra, Statistics, and Physics

import 'dart:math' as math;

class QuestionCategory {
  final String title;
  final List<QuestionItem> questions;

  const QuestionCategory({required this.title, required this.questions});
}

class QuestionItem {
  final String id;
  final String title;
  final String formulaDescription;
  final List<String> inputLabels;
  final Map<String, double> Function(List<double> values) solver;

  const QuestionItem({
    required this.id,
    required this.title,
    required this.formulaDescription,
    required this.inputLabels,
    required this.solver,
  });
}

class UniversalQuestionEngine {
  static List<QuestionCategory> getCategories() {
    return [
      _geometryCategory(),
      _financeEverydayCategory(),
      _algebraNumbersCategory(),
      _statisticsCategory(),
      _physicsEngineeringCategory(),
    ];
  }

  // -------------------------------------------------------------
  // 1. GEOMETRY QUESTIONS
  // -------------------------------------------------------------
  static QuestionCategory _geometryCategory() {
    return QuestionCategory(
      title: 'Geometry & Shapes',
      questions: [
        QuestionItem(
          id: 'geom_pyth_hyp',
          title: 'Pythagorean: Find Hypotenuse (c)',
          formulaDescription: 'c = √(a² + b²)',
          inputLabels: ['Leg a', 'Leg b'],
          solver: (v) {
            final a = v[0], b = v[1];
            if (a <= 0 || b <= 0) throw const FormatException('Legs must be positive');
            final c = math.sqrt(a * a + b * b);
            return {'Hypotenuse (c)': c, 'Area': 0.5 * a * b, 'Perimeter': a + b + c};
          },
        ),
        QuestionItem(
          id: 'geom_pyth_leg',
          title: 'Pythagorean: Find Missing Leg (b)',
          formulaDescription: 'b = √(c² - a²)',
          inputLabels: ['Hypotenuse (c)', 'Known Leg (a)'],
          solver: (v) {
            final c = v[0], a = v[1];
            if (c <= 0 || a <= 0) throw const FormatException('Values must be positive');
            if (c <= a) throw const FormatException('Hypotenuse must exceed leg');
            final b = math.sqrt(c * c - a * a);
            return {'Missing Leg (b)': b, 'Area': 0.5 * a * b, 'Perimeter': a + b + c};
          },
        ),
        QuestionItem(
          id: 'geom_circ_area',
          title: 'Circle: Radius & Circumference from Area',
          formulaDescription: 'r = √(A / π), C = 2πr',
          inputLabels: ['Circle Area (A)'],
          solver: (v) {
            final a = v[0];
            if (a <= 0) throw const FormatException('Area must be positive');
            final r = math.sqrt(a / math.pi);
            return {'Radius (r)': r, 'Diameter (d)': 2 * r, 'Circumference (C)': 2 * math.pi * r};
          },
        ),
        QuestionItem(
          id: 'geom_circ_circ',
          title: 'Circle: Radius & Area from Circumference',
          formulaDescription: 'r = C / (2π), A = πr²',
          inputLabels: ['Circumference (C)'],
          solver: (v) {
            final c = v[0];
            if (c <= 0) throw const FormatException('Circumference must be positive');
            final r = c / (2 * math.pi);
            return {'Radius (r)': r, 'Diameter (d)': 2 * r, 'Area (A)': math.pi * r * r};
          },
        ),
        QuestionItem(
          id: 'geom_tri_3rd_angle',
          title: 'Triangle: 3rd Angle from 2 Angles',
          formulaDescription: 'C = 180° - A - B',
          inputLabels: ['Angle A (deg)', 'Angle B (deg)'],
          solver: (v) {
            final a = v[0], b = v[1];
            if (a <= 0 || b <= 0 || (a + b) >= 180) throw const FormatException('Sum of angles must be < 180°');
            final c = 180.0 - a - b;
            return {'Third Angle C (deg)': c};
          },
        ),
        QuestionItem(
          id: 'geom_rect_dims',
          title: 'Rectangle: Length & Width from Area & Perimeter',
          formulaDescription: 'x² - (P/2)x + A = 0',
          inputLabels: ['Area (A)', 'Perimeter (P)'],
          solver: (v) {
            final a = v[0], p = v[1];
            if (a <= 0 || p <= 0) throw const FormatException('Values must be positive');
            final s = p / 2.0;
            final disc = s * s - 4.0 * a;
            if (disc < 0) throw const FormatException('Impossible: Perimeter too small for this area (P² ≥ 16A)');
            final l = (s + math.sqrt(disc)) / 2.0;
            final w = (s - math.sqrt(disc)) / 2.0;
            return {'Length (l)': math.max(l, w), 'Width (w)': math.min(l, w), 'Diagonal': math.sqrt(l * l + w * w)};
          },
        ),
        QuestionItem(
          id: 'geom_sphere_vol',
          title: 'Sphere: Radius & Surface Area from Volume',
          formulaDescription: 'r = ∛(3V / (4π))',
          inputLabels: ['Volume (V)'],
          solver: (v) {
            final vol = v[0];
            if (vol <= 0) throw const FormatException('Volume must be positive');
            final r = math.pow((3.0 * vol) / (4.0 * math.pi), 1.0 / 3.0).toDouble();
            final sa = 4.0 * math.pi * r * r;
            return {'Radius (r)': r, 'Surface Area (A)': sa, 'Diameter (d)': 2 * r};
          },
        ),
        QuestionItem(
          id: 'geom_cyl_height',
          title: 'Cylinder: Height from Volume & Radius',
          formulaDescription: 'h = V / (πr²)',
          inputLabels: ['Volume (V)', 'Radius (r)'],
          solver: (v) {
            final vol = v[0], r = v[1];
            if (vol <= 0 || r <= 0) throw const FormatException('Values must be positive');
            final h = vol / (math.pi * r * r);
            final totalSa = 2.0 * math.pi * r * (r + h);
            return {'Height (h)': h, 'Total Surface Area': totalSa};
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 2. FINANCE & EVERYDAY QUESTIONS
  // -------------------------------------------------------------
  static QuestionCategory _financeEverydayCategory() {
    return QuestionCategory(
      title: 'Finance & Everyday',
      questions: [
        QuestionItem(
          id: 'fin_rev_discount',
          title: 'Reverse Discount: Find Original Price',
          formulaDescription: 'Original = Discounted / (1 - Discount%/100)',
          inputLabels: ['Discounted Price', 'Discount Percentage (%)'],
          solver: (v) {
            final discPrice = v[0], discPct = v[1];
            if (discPrice <= 0 || discPct <= 0 || discPct >= 100) {
              throw const FormatException('Valid positive price and discount < 100% required');
            }
            final orig = discPrice / (1.0 - discPct / 100.0);
            final saved = orig - discPrice;
            return {'Original Price': orig, 'Amount Saved': saved};
          },
        ),
        QuestionItem(
          id: 'fin_rev_gst',
          title: 'Reverse GST: Find Pre-tax Base Price from MRP',
          formulaDescription: 'Base = MRP / (1 + GST%/100)',
          inputLabels: ['Total MRP (Tax Inclusive)', 'GST Rate (%)'],
          solver: (v) {
            final mrp = v[0], gstRate = v[1];
            if (mrp <= 0 || gstRate <= 0) throw const FormatException('Values must be positive');
            final base = mrp / (1.0 + gstRate / 100.0);
            final tax = mrp - base;
            return {
              'Base Price (Pre-tax)': base,
              'Total GST Amount': tax,
              'CGST (Half)': tax / 2.0,
              'SGST (Half)': tax / 2.0,
            };
          },
        ),
        QuestionItem(
          id: 'fin_doubling_time',
          title: 'Rule of 72 & Exact Doubling Time',
          formulaDescription: 't = ln(2) / ln(1 + r/100) ≈ 72 / r',
          inputLabels: ['Annual Interest Rate (%)'],
          solver: (v) {
            final r = v[0];
            if (r <= 0) throw const FormatException('Rate must be positive');
            final exactYears = math.log(2.0) / math.log(1.0 + r / 100.0);
            final rule72Years = 72.0 / r;
            return {'Exact Doubling Time (Years)': exactYears, 'Rule of 72 Approx (Years)': rule72Years};
          },
        ),
        QuestionItem(
          id: 'fin_rev_emi_loan',
          title: 'Reverse EMI: Affordable Loan Amount',
          formulaDescription: 'P = EMI × ((1+r)^n - 1) / (r(1+r)^n)',
          inputLabels: ['Monthly Affordable EMI', 'Annual Interest Rate (%)', 'Tenure (Years)'],
          solver: (v) {
            final emi = v[0], annualRate = v[1], years = v[2];
            if (emi <= 0 || annualRate <= 0 || years <= 0) throw const FormatException('Values must be positive');
            final r = (annualRate / 12.0) / 100.0;
            final n = (years * 12.0).round();
            final factor = math.pow(1.0 + r, n).toDouble();
            final loanAmount = emi * (factor - 1.0) / (r * factor);
            final totalPay = emi * n;
            final totalInterest = totalPay - loanAmount;
            return {
              'Max Affordable Loan': loanAmount,
              'Total Amount Paid': totalPay,
              'Total Interest Paid': totalInterest,
              'Number of Months': n.toDouble(),
            };
          },
        ),
        QuestionItem(
          id: 'fin_sip_target',
          title: 'Target SIP: Monthly Investment Required',
          formulaDescription: 'P = Target / [ ((1+i)^n - 1)/i × (1+i) ]',
          inputLabels: ['Target Wealth Amount', 'Expected Annual Return (%)', 'Duration (Years)'],
          solver: (v) {
            final target = v[0], annualReturn = v[1], years = v[2];
            if (target <= 0 || annualReturn <= 0 || years <= 0) throw const FormatException('Values must be positive');
            final i = (annualReturn / 12.0) / 100.0;
            final n = (years * 12.0).round();
            final factor = (math.pow(1.0 + i, n) - 1.0) / i * (1.0 + i);
            final monthlySIP = target / factor;
            final totalInvested = monthlySIP * n;
            return {
              'Required Monthly SIP': monthlySIP,
              'Total Invested': totalInvested,
              'Wealth Gain (Returns)': target - totalInvested,
            };
          },
        ),
        QuestionItem(
          id: 'fin_compound_time',
          title: 'Compound Interest: Time to Reach Target Amount',
          formulaDescription: 't = ln(A / P) / ln(1 + r/100)',
          inputLabels: ['Initial Principal (P)', 'Target Amount (A)', 'Annual Interest Rate (%)'],
          solver: (v) {
            final p = v[0], a = v[1], r = v[2];
            if (p <= 0 || a <= p || r <= 0) throw const FormatException('Target must exceed principal');
            final t = math.log(a / p) / math.log(1.0 + r / 100.0);
            return {'Time Required (Years)': t, 'Time in Months': t * 12.0};
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 3. NUMBER THEORY & ALGEBRA QUESTIONS
  // -------------------------------------------------------------
  static QuestionCategory _algebraNumbersCategory() {
    return QuestionCategory(
      title: 'Number Theory & Algebra',
      questions: [
        QuestionItem(
          id: 'alg_missing_lcm_gcd',
          title: 'LCM-GCD Product: Find Other Number',
          formulaDescription: 'B = (LCM × GCD) / A',
          inputLabels: ['LCM', 'GCD', 'Known Number A'],
          solver: (v) {
            final lcm = v[0], gcd = v[1], a = v[2];
            if (lcm <= 0 || gcd <= 0 || a <= 0) throw const FormatException('Values must be positive');
            final b = (lcm * gcd) / a;
            return {'Other Number (B)': b, 'Product (A × B)': lcm * gcd};
          },
        ),
        QuestionItem(
          id: 'alg_linear_solve',
          title: 'Linear Equation: Solve ax + b = c',
          formulaDescription: 'x = (c - b) / a',
          inputLabels: ['Coefficient a', 'Constant b', 'Result c'],
          solver: (v) {
            final a = v[0], b = v[1], c = v[2];
            if (a == 0) throw const FormatException('Coefficient a cannot be zero for linear equation');
            final x = (c - b) / a;
            return {'Solution x': x};
          },
        ),
        QuestionItem(
          id: 'alg_quadratic_vertex',
          title: 'Quadratic Equation: Vertex & Min/Max',
          formulaDescription: 'h = -b/(2a), k = c - b²/(4a)',
          inputLabels: ['Coefficient a', 'Coefficient b', 'Coefficient c'],
          solver: (v) {
            final a = v[0], b = v[1], c = v[2];
            if (a == 0) throw const FormatException('Coefficient a cannot be zero for quadratic');
            final h = -b / (2.0 * a);
            final k = c - (b * b) / (4.0 * a);
            final disc = b * b - 4.0 * a * c;
            return {
              'Vertex X (h)': h,
              'Vertex Y (k)': k,
              'Discriminant (Δ)': disc,
              'Extremum Type': a > 0 ? 1.0 : -1.0, // 1 for Minimum, -1 for Maximum
            };
          },
        ),
        QuestionItem(
          id: 'alg_arith_nth',
          title: 'Arithmetic Sequence: Find n-th Term',
          formulaDescription: 'aₙ = a₁ + (n - 1)d',
          inputLabels: ['First Term (a₁)', 'Common Difference (d)', 'Term Index (n)'],
          solver: (v) {
            final a1 = v[0], d = v[1], n = v[2];
            if (n < 1) throw const FormatException('Term index n must be at least 1');
            final an = a1 + (n - 1) * d;
            final sum = (n / 2.0) * (2 * a1 + (n - 1) * d);
            return {'n-th Term (aₙ)': an, 'Sum of n Terms (Sₙ)': sum};
          },
        ),
        QuestionItem(
          id: 'alg_geom_nth',
          title: 'Geometric Sequence: Find n-th Term',
          formulaDescription: 'aₙ = a₁ × r^(n-1)',
          inputLabels: ['First Term (a₁)', 'Common Ratio (r)', 'Term Index (n)'],
          solver: (v) {
            final a1 = v[0], r = v[1], n = v[2];
            if (n < 1) throw const FormatException('Term index n must be at least 1');
            final an = a1 * math.pow(r, n - 1);
            final sum = r == 1 ? a1 * n : a1 * (1 - math.pow(r, n)) / (1 - r);
            return {'n-th Term (aₙ)': an.toDouble(), 'Sum of n Terms (Sₙ)': sum.toDouble()};
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 4. STATISTICS & PROBABILITY QUESTIONS
  // -------------------------------------------------------------
  static QuestionCategory _statisticsCategory() {
    return QuestionCategory(
      title: 'Statistics & Probability',
      questions: [
        QuestionItem(
          id: 'stat_needed_score',
          title: 'Target Average: Required Exam Score',
          formulaDescription: 'Score = Target × N - CurrentSum',
          inputLabels: ['Desired Target Average', 'Current Score 1', 'Current Score 2', 'Current Score 3'],
          solver: (v) {
            final target = v[0], s1 = v[1], s2 = v[2], s3 = v[3];
            // 4 tests total
            final needed = target * 4.0 - (s1 + s2 + s3);
            return {'Required Score on 4th Exam': needed, 'Current Average': (s1 + s2 + s3) / 3.0};
          },
        ),
        QuestionItem(
          id: 'stat_z_score',
          title: 'Standard Normal: Z-Score',
          formulaDescription: 'Z = (x - μ) / σ',
          inputLabels: ['Observed Value (x)', 'Population Mean (μ)', 'Standard Deviation (σ)'],
          solver: (v) {
            final x = v[0], mu = v[1], sigma = v[2];
            if (sigma <= 0) throw const FormatException('Standard deviation must be strictly positive');
            final z = (x - mu) / sigma;
            return {'Z-Score': z};
          },
        ),
        QuestionItem(
          id: 'stat_at_least_one',
          title: 'Probability: At Least 1 Success in n Trials',
          formulaDescription: 'P(≥1) = 1 - (1 - p)ⁿ',
          inputLabels: ['Single Trial Success Probability (p, 0-1)', 'Number of Trials (n)'],
          solver: (v) {
            final p = v[0], n = v[1];
            if (p < 0 || p > 1 || n < 1) throw const FormatException('p must be between 0 and 1, n ≥ 1');
            final probNone = math.pow(1.0 - p, n).toDouble();
            final probAtLeastOne = 1.0 - probNone;
            return {
              'P(at least 1 success)': probAtLeastOne,
              'P(zero successes)': probNone,
              'Percentage (%)': probAtLeastOne * 100.0,
            };
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 5. PHYSICS & ENGINEERING QUESTIONS
  // -------------------------------------------------------------
  static QuestionCategory _physicsEngineeringCategory() {
    return QuestionCategory(
      title: 'Physics & Engineering',
      questions: [
        QuestionItem(
          id: 'phys_speed_dist_time',
          title: 'Speed, Distance & Time: Find Speed',
          formulaDescription: 'v = d / t',
          inputLabels: ['Distance (d, km or m)', 'Time (t, hours or sec)'],
          solver: (v) {
            final d = v[0], t = v[1];
            if (t <= 0 || d < 0) throw const FormatException('Time must be positive');
            final vVal = d / t;
            return {'Speed (v)': vVal, 'Speed (m/s if km/h)': vVal / 3.6};
          },
        ),
        QuestionItem(
          id: 'phys_ohms_law',
          title: 'Ohm’s Law: Voltage, Current & Resistance',
          formulaDescription: 'V = I × R, P = V × I',
          inputLabels: ['Current (I in Amperes)', 'Resistance (R in Ohms)'],
          solver: (v) {
            final i = v[0], r = v[1];
            if (r < 0) throw const FormatException('Resistance cannot be negative');
            final volt = i * r;
            final power = volt * i;
            return {'Voltage (V)': volt, 'Electric Power (Watts)': power};
          },
        ),
        QuestionItem(
          id: 'phys_density',
          title: 'Density: Mass & Volume',
          formulaDescription: 'ρ = m / V',
          inputLabels: ['Mass (m)', 'Volume (V)'],
          solver: (v) {
            final m = v[0], vol = v[1];
            if (vol <= 0 || m < 0) throw const FormatException('Volume must be positive');
            final rho = m / vol;
            return {'Density (ρ)': rho};
          },
        ),
        QuestionItem(
          id: 'phys_kinetic_energy',
          title: 'Kinetic Energy: KE = ½mv²',
          formulaDescription: 'KE = 0.5 × m × v²',
          inputLabels: ['Mass (kg)', 'Velocity (m/s)'],
          solver: (v) {
            final m = v[0], vel = v[1];
            if (m < 0) throw const FormatException('Mass cannot be negative');
            final ke = 0.5 * m * vel * vel;
            final momentum = m * vel;
            return {'Kinetic Energy (Joules)': ke, 'Momentum (p, kg·m/s)': momentum};
          },
        ),
      ],
    );
  }
}
