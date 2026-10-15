# Qalculyn — All-in-One Mathematical Ecosystem

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Privacy: 100% Offline](https://img.shields.io/badge/Privacy-100%25%20Offline-success.svg)](#privacy--security-pledge)
[![Tests: 35/35 Passing](https://img.shields.io/badge/Tests-35%2F35%20Passed-brightgreen.svg)](#test-suite--quality-assurance)

**Qalculyn** is a modern, high-precision, 100% offline mathematics and calculator ecosystem built with Flutter for Android. Engineered for both everyday users and advanced STEM practitioners, Qalculyn blends consumer-grade ergonomics with analytical rigor.

---

## Table of Contents
- [Key Features & Capabilities](#key-features--capabilities)
- [Architecture & Design System](#architecture--design-system)
- [Module Breakdown](#module-breakdown)
  - [1. Core & Scientific Keypad](#1-core--scientific-keypad)
  - [2. Everyday & Financial Calculators](#2-everyday--financial-calculators)
  - [3. Number Theory & Algebra](#3-number-theory--algebra)
  - [4. Advanced Mathematics & Calculus](#4-advanced-mathematics--calculus)
  - [5. Interactive Geometry Studio & Vector Canvas](#5-interactive-geometry-studio--vector-canvas)
  - [6. 2D Function Graphing Studio](#6-2d-function-graphing-studio)
  - [7. Universal Question & Problem Solver](#7-universal-question--problem-solver)
  - [8. Smart Math Assistant & Natural Language Console](#8-smart-math-assistant--natural-language-console)
  - [9. UI/UX Theme & Color Customizer](#9-uiux-theme--color-customizer)
- [Zero Syntax Leakage Guarantee](#zero-syntax-leakage-guarantee)
- [Privacy & Security Pledge](#privacy--security-pledge)
- [Documentation Index](#documentation-index)
- [Building & Running](#building--running)
- [Test Suite & Quality Assurance](#test-suite--quality-assurance)

---

## Key Features & Capabilities

- **100% Offline & Zero Telemetry:** Operates with zero network permissions. No analytics, tracking, advertisements, or background connections.
- **Consumer-Friendly Interface:** Complete elimination of compiler exceptions, raw tokens, and programming jargon. Incomplete calculations present calm, informative guidance notes.
- **Dynamic Theming & AMOLED Pure Black:** 8 curated palettes, OLED-optimized `#000000` surface mode, and real-time adjustable button corner geometry (4px to 32px).
- **Interactive Vector Geometry Canvas:** Live CustomPainter rendering of 16 2D plane figures, 14 3D wireframe solids, and 4 analytic triangle methods that dynamically scale to user inputs.
- **Interactive 2D Function Plotter:** Cartesian grapher with pinch-to-zoom, pan, touch tangent slope tracer, automatic numerical root finder, local extrema detection, and definite integral area shading.
- **Note-Taking & Step Explanations:** Clean, pure mathematical steps by default with an interactive dialog allowing users to add and preserve personal study notes for complex problems.
- **Markdown Study Sheet Export:** Export comprehensive geometry and universal problem-solving study sheets directly to the system clipboard for notes or revision.

---

## Architecture & Design System

```
lib/
├── core/
│   ├── design_system/       # Typography, spacing, corner radii, and dynamic color palettes
│   ├── math/                # Pure mathematical engines (Zero external dependencies)
│   │   ├── calculator_engine.dart       # Safe Pratt expression parser & evaluator
│   │   ├── big_rational.dart            # Arbitrary-precision exact rational arithmetic
│   │   ├── number_theory.dart           # BigInt Euclidean GCD/LCM & factorization
│   │   ├── algebra_engine.dart          # Polynomials, linear & quadratic solvers
│   │   ├── complex_number.dart          # Rectangular & polar complex arithmetic
│   │   ├── matrix_vector.dart           # Linear algebra determinants, inverses & 3D vectors
│   │   ├── calculus_engine.dart         # Finite difference differentiation & Simpson quadrature
│   │   ├── statistics_engine.dart       # Descriptive stats, combinatorics & normal distribution
│   │   ├── sequences_base.dart          # Arbitrary base conversion & series summation
│   │   ├── geometry_engine.dart         # 30+ 2D/3D shapes & analytic triangle solvers
│   │   ├── graphing_engine.dart         # Cartesian curve sampling & calculus feature extraction
│   │   ├── natural_language_parser.dart # Conversational query parser
│   │   ├── smart_math_command.dart      # Command dispatcher & natural language fallback
│   │   └── universal_question_engine.dart # Inverse word problems across 5 disciplines
│   └── providers/           # State management with ChangeNotifier & SharedPreferences
├── features/                # Self-contained domain screens & interactive controllers
│   ├── calculator/          # Main scientific keypad, history sheet & display
│   ├── geometry/            # Interactive vector canvas & shape metrics
│   ├── graphing/            # 2D Cartesian interactive function plotting studio
│   ├── questions/           # Universal question & study sheet generator
│   ├── algebra/             # Quadratic, linear, factoring, and polynomial screens
│   ├── calculus/            # Derivative, integral, and limit calculators
│   ├── complex/             # Complex number arithmetic with user explanation notes
│   ├── linear_algebra/      # Arbitrary dimension matrices & 3D vector geometry
│   ├── number_theory/       # Prime, GCD, LCM, fractions, and base conversion
│   ├── statistics/          # Descriptive statistics, nPr/nCr, and normal distribution
│   ├── settings/            # Settings screen & Theme/Color customizer
│   └── tools/               # Master searchable tool catalogue & Smart Assistant
└── shared/                  # Reusable ToolScaffold, ToolResultCard, and error sanitizers
```

---

## Module Breakdown

### 1. Core & Scientific Keypad
- **Pratt Parser Expression Engine:** Evaluates nested parentheses, implicit multiplication (`2(3)` $\rightarrow$ `6`), exponentiation, factorials, and trigonometry (`sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `sinh`, `cosh`, `tanh`).
- **Interactive Tap-to-Edit Cursor:** Tap anywhere inside an expression to position a cursor and make inline edits, insert missing digits, or replace operators without erasing preceding work.
- **Display Swipe Gesture:** Swipe horizontally across the calculation display to delete digits naturally.
- **Physical Keyboard Support:** Full desktop/tablet number pad and hardware keyboard typing support.
- **Quick Tools Toolbar:** Instant horizontal jump bar above keypad to launch key tools with 1 tap.
- **Airtight Sign Toggle ($\pm$):** Seamlessly toggles negative signs on standalone numbers, compound expressions, and trailing operators without leaving stray brackets on the right.
- **Calculation History & Clean Export:** Persistent local database of past equations with live search filtering and one-tap export to spreadsheet CSV or Markdown study tables.

### 2. Everyday & Financial Calculators
- **Percentage & Discount:** Original price, discount rate, final price, and savings breakdowns.
- **Indian GST:** Pre-tax base calculation, CGST, SGST, IGST, and net reverse MRP tax extraction.
- **Tip & Split:** Bill total, custom tip percentage, and per-person split accounting.
- **Expanded Unit Converter:** High-precision length, mass, temperature (Celsius, Fahrenheit, Kelvin, and Rankine °R), speed, area, volume, pressure (Pa, kPa, MPa, bar, mbar, atm, psi, mmHg), digital data (decimal kB-PB & binary KiB-PiB), energy, and power.
- **Loan EMI & Interest:** Monthly EMI, total interest, principal repayment breakdown, and compound frequency growth.
- **SIP & Savings:** Systematic Investment Plan compounding estimates and future wealth projections.

### 3. Number Theory & Algebra
- **Exact Arbitrary-Precision Rationals:** `BigRational` preserves exact numerators and denominators without floating-point degradation.
- **Simultaneous Equations Solver (2×2 and 3×3):** Solves systems of linear equations with full step-by-step Cramer's Rule determinants and Gaussian Elimination derivations, with clear handling of unique, infinite, and inconsistent cases.
- **Polynomial Long Division & Synthetic Division:** Divides algebraic polynomials step-by-step, showing intermediate monomial quotient terms, subtraction remainders, and Ruffini synthetic division row tables.
- **Extended Euclidean Algorithm & Modular Math:** Solves Bézout's identity ($ax + by = \gcd(a, b)$) with forward and backward Euclidean steps, modular exponentiation via repeated squaring ($a^b \pmod m$), modular multiplicative inverse ($a^{-1} \pmod m$), and Euler's Totient function $\phi(n)$.
- **Monomial & Polynomial GCD/LCM:** Euclidean polynomial division over $\mathbb{Q}[x]$ with normalization to monic form.
- **Linear & Quadratic Analytical Solvers:** Calculates exact real and complex roots ($x = \frac{-b \pm \sqrt{\Delta}}{2a}$) alongside pure mathematical step breakdowns and user note-taking.

### 4. Advanced Mathematics & Calculus
- **Offline Scientific & Physical Constants Catalog:** 40+ fundamental CODATA constants across Universal ($c, G, h, \hbar$), Electromagnetism ($e, \varepsilon_0, \mu_0, k_e, Z_0$), Atomic & Nuclear ($m_e, m_p, m_n, u, \alpha, R_\infty, a_0$), Thermodynamics ($N_A, k_B, R, F, \sigma, b, \text{atm}$), and Astronomy ($g_0, \text{au}, \text{ly}, \text{pc}, M_\odot, M_\oplus, R_\oplus$), with search and 1-tap insert into calculation.
- **Matrix Row Reductions (RREF) & Eigenvalues:** Gauss-Jordan elimination to Reduced Row Echelon Form with every elementary row operation step explained, plus exact 2×2 and 3×3 eigenvalue solvers with characteristic polynomial derivations.
- **Two-Variable Linear Regression:** Computes slope $m$, $y$-intercept $c$, Pearson correlation $r$, and determination $R^2$, paired with an interactive scatter plot canvas and trendline.
- **Complex Numbers ($\mathbb{C}$):** Rectangular ($a + bi$) and Polar ($r \angle \theta$) forms with modulus, argument in degrees and radians, powers ($z^n$), and square roots.
- **Calculus & Limits:** 5-point central stencil numerical differentiation, composite Simpson's 1/3 quadrature ($N = 1000$), and two-sided limit continuity analysis.
- **Statistics & Probability:** Mean, median, sample/population variance, interquartile range (IQR), exact combinatorics ($nPr$, $nCr$), and Gaussian normal distribution CDF/PDF.

### 5. Interactive Geometry Studio & Vector Canvas
- **16 2D Plane Figures:** Circle, Sector, Annulus, Ellipse, Rectangle, Square, Parallelogram, Rhombus, Trapezoid, Triangle, Equilateral Triangle, Regular Pentagon, Hexagon, Octagon, Regular $n$-gon, and Kite.
- **14 3D Solids:** Sphere, Hemisphere, Spherical Cap, Cylinder, Hollow Cylinder, Cone, Frustum, Rectangular Prism, Cube, Square Pyramid, Regular Tetrahedron, Ellipsoid, Torus, and Triangular Prism.
- **Analytic Triangles:** Solves SSS, SAS, ASA, and AAS with circumradius and inradius.
- **24 Inverse Problem Solvers:** Reverse calculations from area, perimeter, volume, or surface area to missing radius, height, or side lengths.
- **Dynamic Vector Canvas:** CustomPainter dynamically renders geometric figures with real-time scaling and wireframes.

### 6. 2D Function Graphing Studio
- **Multi-Curve Plotting:** Plots up to 3 mathematical curves simultaneously ($f_1, f_2, f_3$) with distinct color encoding.
- **Intersection Point Detection:** Automatically calculates and pinpoints exact $(x, y)$ intersection points between curves with glowing visual markers.
- **Real-Time Cartesian Plotter:** Evaluates mathematical expressions over an interactive Cartesian coordinate system.
- **Touch Slope Tracer:** Dragging across the graph calculates and displays the tangent line and derivative slope $f'(x)$ at the touched coordinate.
- **Extrema & Root Detector:** Automatically highlights zero-crossings (roots) and local minima/maxima.
- **Definite Integral Shading:** Shaded polygon visualization of $\int_a^b f_1(x)\,dx$ with numerical area readout.

### 7. Universal Question & Problem Solver
- Spans **Geometry, Finance, Algebra, Statistics, and Physics**.
- Solves inverse word problems (e.g. missing leg from hypotenuse, base price from MRP + GST, missing number from LCM & GCD, resistance from Ohm's Law, kinetic energy from velocity).
- One-tap export of formatted study sheets in Markdown.

### 8. Smart Math Assistant & Natural Language Console
- Accepts both structured commands (e.g. `lcm(12, 18, 24)`, `factor(2x^2 + 5x + 2)`, `solve(2x + 7 = 19)`) and plain English everyday queries (e.g. `"split 1200 between 4 people with 10% tip"`, `"area of circle with radius 7"`, `"speed for 150 km in 2 hours"`).

### 9. UI/UX Theme & Color Customizer
- **Palette Presets:** Qalculyn Purple, Electric Indigo, Cyber Cyan, Emerald Green, Sunset Amber, Rose Pink, Midnight Blue, and Crimson Flame.
- **AMOLED Pure Black:** Replaces dark grey backgrounds with pure `#000000` for OLED battery conservation.
- **Keypad Geometry Customizer:** Custom slider adjusts keypad button corner radii continuously from 4px to 32px with Square (6px), Round (16px), and Pill (30px) presets.

---

## Zero Syntax Leakage Guarantee

Qalculyn is crafted for everyday humans. It guarantees:
1. **No Technical Token Names:** Never displays internal parser terminology like `got TokenType.eof`, `Unexpected token`, or `Regex mismatch`.
2. **No Stack Traces:** All Dart exceptions (`FormatException: Invalid radix-10 number (at character 1)`) are trapped and sanitized by `cleanMathErrorMessage`.
3. **Calm Guidance Notes:** Unfinished expressions display gentle, non-destructive prompts such as `"Please enter valid numbers"`, `"Incomplete calculation"`, or `"Cannot divide by zero"` in place of alarming red error banners.

---

## Privacy & Security Pledge

- **No Internet Permission:** The application manifest does not request `android.permission.INTERNET`.
- **Zero Third-Party SDKs:** Contains zero analytics, crash-reporting SDKs, ad networks, or cloud trackers.
- **Local Persistence Only:** All configuration and history data reside strictly on the user's local device in encrypted/sandboxed private app storage.

---

## Documentation Index

- [Architecture & Technical Design](docs/ARCHITECTURE.md)
- [Comprehensive User Guide](docs/USER_GUIDE.md)
- [Mathematical Specification & Numerical Bounds](docs/MATHEMATICAL_SPECIFICATION.md)

---

## Building & Running

### Prerequisites
- Flutter SDK (3.x or higher)
- Android SDK & Java Development Kit (JDK 17+)

### Commands
```bash
# Clone and enter directory
cd Calculator

# Install dependencies
flutter pub get

# Run static analysis
flutter analyze

# Execute comprehensive test suite
flutter test

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

---

## Test Suite & Quality Assurance

Qalculyn contains an automated regression test suite ([`test/widget_test.dart`](test/widget_test.dart)) with 31 comprehensive tests verifying:
- PEMDAS precedence, scientific trigonometry, and factorial limits
- Pure mathematical step-by-step expression explanation
- Interactive mid-expression cursor placement & backspacing
- Simultaneous linear equations solver (2x2 and 3x3 systems via Cramer's rule & elimination)
- Polynomial long division & synthetic division tableaus
- 40+ offline physical and scientific constants catalog
- Number formatting and comma grouping
- Arbitrary-precision rational arithmetic and polynomial GCD/LCM
- Matrix determinants, inverses, and 3D vector geometry
- Numerical differentiation and Simpson quadrature
- Descriptive statistics and combinatorics
- Triangle solvers and geometric formulas
- Sign toggle ($\pm$) bracket reversibility
- Natural language query interpretation and smart command dispatching
- Cartesian function plotting, root detection, and extrema extraction
- Zero syntax leakage across all calculation screens
