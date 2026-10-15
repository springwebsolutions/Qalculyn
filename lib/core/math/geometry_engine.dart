// Qalculyn - Comprehensive Geometry & Trigonometry Engine
// All 2D Euclidean shapes, 3D solids, analytic Triangle Solvers, and inverse question solvers.

import 'dart:math' as math;

class GeometryEngine {
  // ==========================================
  // 1. 2D SHAPES
  // ==========================================

  static Map<String, double> circle(double radius) {
    if (radius <= 0) throw const FormatException('Radius must be positive');
    final area = math.pi * radius * radius;
    final circumference = 2.0 * math.pi * radius;
    final diameter = 2.0 * radius;
    return {
      'Area': area,
      'Circumference': circumference,
      'Diameter': diameter,
      'Radius': radius,
    };
  }

  static Map<String, double> sector(double radius, double angleDeg) {
    if (radius <= 0) throw const FormatException('Radius must be positive');
    if (angleDeg <= 0 || angleDeg > 360) throw const FormatException('Angle must be between 0° and 360°');
    final angleRad = angleDeg * math.pi / 180.0;
    final arcLength = radius * angleRad;
    final sectorArea = 0.5 * radius * radius * angleRad;
    final chordLength = 2.0 * radius * math.sin(angleRad / 2.0);
    final perimeter = arcLength + 2.0 * radius;
    return {
      'Arc Length': arcLength,
      'Sector Area': sectorArea,
      'Chord Length': chordLength,
      'Perimeter': perimeter,
      'Central Angle (rad)': angleRad,
    };
  }

  static Map<String, double> annulus(double outerR, double innerR) {
    if (outerR <= 0 || innerR <= 0) throw const FormatException('Radii must be positive');
    if (outerR <= innerR) throw const FormatException('Outer radius must exceed inner radius');
    final area = math.pi * (outerR * outerR - innerR * innerR);
    final ringWidth = outerR - innerR;
    final outerCircumference = 2.0 * math.pi * outerR;
    final innerCircumference = 2.0 * math.pi * innerR;
    return {
      'Area': area,
      'Ring Width': ringWidth,
      'Outer Circumference': outerCircumference,
      'Inner Circumference': innerCircumference,
      'Average Radius': (outerR + innerR) / 2.0,
    };
  }

  static Map<String, double> ellipse(double a, double b) {
    if (a <= 0 || b <= 0) throw const FormatException('Semi-axes must be positive');
    final major = math.max(a, b);
    final minor = math.min(a, b);
    final area = math.pi * major * minor;
    // Ramanujan 1st approximation for perimeter
    final h = math.pow((major - minor) / (major + minor), 2).toDouble();
    final perimeter = math.pi * (major + minor) * (1.0 + (3.0 * h) / (10.0 + math.sqrt(4.0 - 3.0 * h)));
    final c = math.sqrt(major * major - minor * minor); // focal distance
    final eccentricity = c / major;
    return {
      'Area': area,
      'Perimeter (approx)': perimeter,
      'Focal Distance (c)': c,
      'Eccentricity (e)': eccentricity,
      'Semi-major Axis (a)': major,
      'Semi-minor Axis (b)': minor,
    };
  }

  static Map<String, double> rectangle(double length, double width) {
    if (length <= 0 || width <= 0) throw const FormatException('Dimensions must be positive');
    final area = length * width;
    final perimeter = 2.0 * (length + width);
    final diagonal = math.sqrt(length * length + width * width);
    return {
      'Area': area,
      'Perimeter': perimeter,
      'Diagonal': diagonal,
      'Length': length,
      'Width': width,
    };
  }

  static Map<String, double> square(double side) {
    if (side <= 0) throw const FormatException('Side must be positive');
    final area = side * side;
    final perimeter = 4.0 * side;
    final diagonal = side * math.sqrt(2.0);
    final inradius = side / 2.0;
    final circumradius = diagonal / 2.0;
    return {
      'Area': area,
      'Perimeter': perimeter,
      'Diagonal': diagonal,
      'Inradius': inradius,
      'Circumradius': circumradius,
    };
  }

  static Map<String, double> triangleHeron(double a, double b, double c) {
    if (a <= 0 || b <= 0 || c <= 0) throw const FormatException('Side lengths must be positive');
    if (a + b <= c || a + c <= b || b + c <= a) {
      throw const FormatException('Triangle inequality violated (sum of two sides must exceed third)');
    }
    final s = (a + b + c) / 2.0;
    final area = math.sqrt(s * (s - a) * (s - b) * (s - c));
    final perimeter = a + b + c;
    final inradius = area / s;
    final circumradius = (a * b * c) / (4.0 * area);
    final heightA = 2.0 * area / a;
    final heightB = 2.0 * area / b;
    final heightC = 2.0 * area / c;
    return {
      'Area': area,
      'Perimeter': perimeter,
      'Semi-Perimeter': s,
      'Inradius': inradius,
      'Circumradius': circumradius,
      'Height on a': heightA,
      'Height on b': heightB,
      'Height on c': heightC,
    };
  }

  static Map<String, double> triangleBaseHeight(double base, double height) {
    if (base <= 0 || height <= 0) throw const FormatException('Base and height must be positive');
    final area = 0.5 * base * height;
    return {
      'Area': area,
      'Base': base,
      'Height': height,
    };
  }

  static Map<String, double> rightTriangle(double legA, double legB) {
    if (legA <= 0 || legB <= 0) throw const FormatException('Legs must be positive');
    final hypotenuse = math.sqrt(legA * legA + legB * legB);
    final area = 0.5 * legA * legB;
    final perimeter = legA + legB + hypotenuse;
    final angleADeg = math.atan(legA / legB) * 180.0 / math.pi;
    final angleBDeg = 90.0 - angleADeg;
    final altitude = (legA * legB) / hypotenuse;
    return {
      'Hypotenuse (c)': hypotenuse,
      'Area': area,
      'Perimeter': perimeter,
      'Angle A (deg)': angleADeg,
      'Angle B (deg)': angleBDeg,
      'Altitude to Hypotenuse': altitude,
    };
  }

  static Map<String, double> equilateralTriangle(double side) {
    if (side <= 0) throw const FormatException('Side must be positive');
    final area = (math.sqrt(3.0) / 4.0) * side * side;
    final perimeter = 3.0 * side;
    final height = (math.sqrt(3.0) / 2.0) * side;
    final inradius = height / 3.0;
    final circumradius = (2.0 * height) / 3.0;
    return {
      'Area': area,
      'Perimeter': perimeter,
      'Height': height,
      'Inradius': inradius,
      'Circumradius': circumradius,
    };
  }

  static Map<String, double> isoscelesTriangle(double base, double leg) {
    if (base <= 0 || leg <= 0) throw const FormatException('Base and leg must be positive');
    if (2.0 * leg <= base) throw const FormatException('Two legs sum must exceed base (2 * leg > base)');
    final height = math.sqrt(leg * leg - (base * base / 4.0));
    final area = 0.5 * base * height;
    final perimeter = base + 2.0 * leg;
    final baseAngle = math.acos((base / 2.0) / leg) * 180.0 / math.pi;
    final apexAngle = 180.0 - 2.0 * baseAngle;
    return {
      'Area': area,
      'Perimeter': perimeter,
      'Height': height,
      'Base Angle (deg)': baseAngle,
      'Apex Angle (deg)': apexAngle,
    };
  }

  static Map<String, double> parallelogram(double base, double height, double sideA, double angleDeg) {
    if (base <= 0) throw const FormatException('Base must be positive');
    double calcArea = 0;
    double perimeter = 0;
    double d1 = 0;
    double d2 = 0;

    if (height > 0) {
      calcArea = base * height;
      if (sideA > 0) {
        perimeter = 2.0 * (base + sideA);
      }
    } else if (sideA > 0 && angleDeg > 0 && angleDeg < 180) {
      final rad = angleDeg * math.pi / 180.0;
      calcArea = base * sideA * math.sin(rad);
      perimeter = 2.0 * (base + sideA);
      // Diagonals via Law of Cosines
      d1 = math.sqrt(base * base + sideA * sideA - 2.0 * base * sideA * math.cos(rad));
      final radSupp = (180.0 - angleDeg) * math.pi / 180.0;
      d2 = math.sqrt(base * base + sideA * sideA - 2.0 * base * sideA * math.cos(radSupp));
    } else {
      throw const FormatException('Provide either (Base & Height) or (Base, Side A & Angle)');
    }

    final res = {'Area': calcArea};
    if (perimeter > 0) res['Perimeter'] = perimeter;
    if (d1 > 0) res['Diagonal 1'] = d1;
    if (d2 > 0) res['Diagonal 2'] = d2;
    return res;
  }

  static Map<String, double> rhombus(double d1, double d2) {
    if (d1 <= 0 || d2 <= 0) throw const FormatException('Diagonals must be positive');
    final area = 0.5 * d1 * d2;
    final side = math.sqrt((d1 / 2.0) * (d1 / 2.0) + (d2 / 2.0) * (d2 / 2.0));
    final perimeter = 4.0 * side;
    final inradius = area / perimeter * 2.0;
    return {
      'Area': area,
      'Side Length': side,
      'Perimeter': perimeter,
      'Inradius': inradius,
    };
  }

  static Map<String, double> trapezoid(double a, double b, double h) {
    if (a <= 0 || b <= 0 || h <= 0) throw const FormatException('Dimensions must be positive');
    final area = ((a + b) / 2.0) * h;
    final median = (a + b) / 2.0;
    return {
      'Area': area,
      'Median (Midsegment)': median,
      'Base a': a,
      'Base b': b,
      'Height': h,
    };
  }

  static Map<String, double> kite(double d1, double d2) {
    if (d1 <= 0 || d2 <= 0) throw const FormatException('Diagonals must be positive');
    final area = 0.5 * d1 * d2;
    return {'Area': area, 'Diagonal 1': d1, 'Diagonal 2': d2};
  }

  static Map<String, double> regularPolygon(int n, double side) {
    if (n < 3) throw const FormatException('Number of sides must be at least 3');
    if (side <= 0) throw const FormatException('Side length must be positive');
    final perimeter = n * side;
    final apothem = side / (2.0 * math.tan(math.pi / n));
    final area = 0.5 * perimeter * apothem;
    final circumradius = side / (2.0 * math.sin(math.pi / n));
    final interiorAngle = ((n - 2) * 180.0) / n;
    final exteriorAngle = 360.0 / n;
    final numDiagonals = (n * (n - 3)) / 2.0;
    return {
      'Area': area,
      'Perimeter': perimeter,
      'Apothem (Inradius)': apothem,
      'Circumradius': circumradius,
      'Interior Angle (deg)': interiorAngle,
      'Exterior Angle (deg)': exteriorAngle,
      'Number of Diagonals': numDiagonals,
    };
  }

  // ==========================================
  // 2. 3D SOLIDS
  // ==========================================

  static Map<String, double> sphere(double radius) {
    if (radius <= 0) throw const FormatException('Radius must be positive');
    final volume = (4.0 / 3.0) * math.pi * math.pow(radius, 3);
    final surfaceArea = 4.0 * math.pi * radius * radius;
    final circumference = 2.0 * math.pi * radius;
    return {
      'Volume': volume,
      'Surface Area': surfaceArea,
      'Great Circle Circumference': circumference,
      'Radius': radius,
    };
  }

  static Map<String, double> hemisphere(double radius) {
    if (radius <= 0) throw const FormatException('Radius must be positive');
    final volume = (2.0 / 3.0) * math.pi * math.pow(radius, 3);
    final curvedArea = 2.0 * math.pi * radius * radius;
    final totalArea = 3.0 * math.pi * radius * radius;
    return {
      'Volume': volume,
      'Curved Surface Area': curvedArea,
      'Total Surface Area': totalArea,
      'Base Circular Area': math.pi * radius * radius,
    };
  }

  static Map<String, double> sphericalCap(double sphereRadius, double capHeight) {
    if (sphereRadius <= 0 || capHeight <= 0) throw const FormatException('Dimensions must be positive');
    if (capHeight > 2.0 * sphereRadius) throw const FormatException('Cap height cannot exceed sphere diameter');
    final volume = (math.pi * capHeight * capHeight / 3.0) * (3.0 * sphereRadius - capHeight);
    final curvedArea = 2.0 * math.pi * sphereRadius * capHeight;
    final baseRadius = math.sqrt(capHeight * (2.0 * sphereRadius - capHeight));
    final totalArea = curvedArea + math.pi * baseRadius * baseRadius;
    return {
      'Volume': volume,
      'Curved Surface Area': curvedArea,
      'Total Surface Area': totalArea,
      'Base Radius': baseRadius,
    };
  }

  static Map<String, double> cylinder(double radius, double height) {
    if (radius <= 0 || height <= 0) throw const FormatException('Dimensions must be positive');
    final baseArea = math.pi * radius * radius;
    final volume = baseArea * height;
    final lateralArea = 2.0 * math.pi * radius * height;
    final totalArea = 2.0 * baseArea + lateralArea;
    return {
      'Volume': volume,
      'Lateral Surface Area': lateralArea,
      'Total Surface Area': totalArea,
      'Base Area': baseArea,
    };
  }

  static Map<String, double> hollowCylinder(double outerR, double innerR, double height) {
    if (outerR <= 0 || innerR <= 0 || height <= 0) throw const FormatException('Dimensions must be positive');
    if (outerR <= innerR) throw const FormatException('Outer radius must exceed inner radius');
    final materialVolume = math.pi * (outerR * outerR - innerR * innerR) * height;
    final innerLateral = 2.0 * math.pi * innerR * height;
    final outerLateral = 2.0 * math.pi * outerR * height;
    final baseRingArea = math.pi * (outerR * outerR - innerR * innerR);
    final totalArea = innerLateral + outerLateral + 2.0 * baseRingArea;
    return {
      'Material Volume': materialVolume,
      'Total Surface Area': totalArea,
      'Outer Lateral Area': outerLateral,
      'Inner Lateral Area': innerLateral,
      'Base Ring Area': baseRingArea,
    };
  }

  static Map<String, double> cone(double radius, double height) {
    if (radius <= 0 || height <= 0) throw const FormatException('Dimensions must be positive');
    final slantHeight = math.sqrt(radius * radius + height * height);
    final volume = (1.0 / 3.0) * math.pi * radius * radius * height;
    final lateralArea = math.pi * radius * slantHeight;
    final baseArea = math.pi * radius * radius;
    final totalArea = baseArea + lateralArea;
    return {
      'Volume': volume,
      'Slant Height (l)': slantHeight,
      'Lateral Surface Area': lateralArea,
      'Total Surface Area': totalArea,
      'Base Area': baseArea,
    };
  }

  static Map<String, double> conicalFrustum(double r1, double r2, double height) {
    if (r1 <= 0 || r2 <= 0 || height <= 0) throw const FormatException('Dimensions must be positive');
    final slantHeight = math.sqrt(height * height + math.pow(r1 - r2, 2));
    final volume = (1.0 / 3.0) * math.pi * height * (r1 * r1 + r2 * r2 + r1 * r2);
    final lateralArea = math.pi * (r1 + r2) * slantHeight;
    final totalArea = lateralArea + math.pi * (r1 * r1 + r2 * r2);
    return {
      'Volume': volume,
      'Slant Height': slantHeight,
      'Lateral Surface Area': lateralArea,
      'Total Surface Area': totalArea,
    };
  }

  static Map<String, double> cube(double side) {
    if (side <= 0) throw const FormatException('Side must be positive');
    final volume = math.pow(side, 3).toDouble();
    final surfaceArea = 6.0 * side * side;
    final faceDiagonal = side * math.sqrt(2.0);
    final spaceDiagonal = side * math.sqrt(3.0);
    final inscribedRadius = side / 2.0;
    final circumscribedRadius = spaceDiagonal / 2.0;
    return {
      'Volume': volume,
      'Total Surface Area': surfaceArea,
      'Face Diagonal': faceDiagonal,
      'Space Diagonal': spaceDiagonal,
      'Inscribed Sphere Radius': inscribedRadius,
      'Circumscribed Sphere Radius': circumscribedRadius,
    };
  }

  static Map<String, double> rectangularPrism(double l, double w, double h) {
    if (l <= 0 || w <= 0 || h <= 0) throw const FormatException('Dimensions must be positive');
    final volume = l * w * h;
    final surfaceArea = 2.0 * (l * w + l * h + w * h);
    final lateralArea = 2.0 * h * (l + w);
    final spaceDiagonal = math.sqrt(l * l + w * w + h * h);
    return {
      'Volume': volume,
      'Total Surface Area': surfaceArea,
      'Lateral Area': lateralArea,
      'Space Diagonal': spaceDiagonal,
    };
  }

  static Map<String, double> squarePyramid(double baseSide, double height) {
    if (baseSide <= 0 || height <= 0) throw const FormatException('Dimensions must be positive');
    final slantHeight = math.sqrt(height * height + (baseSide / 2.0) * (baseSide / 2.0));
    final volume = (1.0 / 3.0) * baseSide * baseSide * height;
    final lateralArea = 2.0 * baseSide * slantHeight;
    final totalArea = baseSide * baseSide + lateralArea;
    return {
      'Volume': volume,
      'Slant Height': slantHeight,
      'Lateral Surface Area': lateralArea,
      'Total Surface Area': totalArea,
      'Base Area': baseSide * baseSide,
    };
  }

  static Map<String, double> tetrahedron(double edge) {
    if (edge <= 0) throw const FormatException('Edge must be positive');
    final volume = math.pow(edge, 3) / (6.0 * math.sqrt(2.0));
    final surfaceArea = math.sqrt(3.0) * edge * edge;
    final height = math.sqrt(6.0) / 3.0 * edge;
    return {
      'Volume': volume,
      'Total Surface Area': surfaceArea,
      'Height': height,
    };
  }

  static Map<String, double> triangularPrism(double base, double triangleHeight, double length) {
    if (base <= 0 || triangleHeight <= 0 || length <= 0) throw const FormatException('Dimensions must be positive');
    final baseArea = 0.5 * base * triangleHeight;
    final volume = baseArea * length;
    return {
      'Volume': volume,
      'Triangle Base Area': baseArea,
      'Length': length,
    };
  }

  static Map<String, double> torus(double majorR, double minorR) {
    if (majorR <= 0 || minorR <= 0) throw const FormatException('Radii must be positive');
    if (minorR >= majorR) throw const FormatException('Major radius must exceed minor radius (R > r)');
    final volume = 2.0 * math.pi * math.pi * majorR * minorR * minorR;
    final surfaceArea = 4.0 * math.pi * math.pi * majorR * minorR;
    return {
      'Volume': volume,
      'Surface Area': surfaceArea,
      'Major Radius (R)': majorR,
      'Minor Radius (r)': minorR,
    };
  }

  static Map<String, double> ellipsoid(double a, double b, double c) {
    if (a <= 0 || b <= 0 || c <= 0) throw const FormatException('Semi-axes must be positive');
    final volume = (4.0 / 3.0) * math.pi * a * b * c;
    // Knud Thomsen's surface area formula (p ≈ 1.6075)
    const p = 1.6075;
    final ap = math.pow(a, p);
    final bp = math.pow(b, p);
    final cp = math.pow(c, p);
    final surfaceArea = 4.0 * math.pi * math.pow((ap * bp + ap * cp + bp * cp) / 3.0, 1.0 / p);
    return {
      'Volume': volume,
      'Surface Area (approx)': surfaceArea,
      'Semi-axis a': a,
      'Semi-axis b': b,
      'Semi-axis c': c,
    };
  }

  // ==========================================
  // 3. ANALYTIC TRIANGLE SOLVERS
  // ==========================================

  /// SSS (3 sides)
  static Map<String, double> solveTriangleSSS(double a, double b, double c) {
    if (a <= 0 || b <= 0 || c <= 0) throw const FormatException('Sides must be positive');
    if (a + b <= c || a + c <= b || b + c <= a) {
      throw const FormatException('Triangle inequality violated (sum of two sides must exceed third)');
    }
    final cosA = ((b * b + c * c - a * a) / (2.0 * b * c)).clamp(-1.0, 1.0);
    final cosB = ((a * a + c * c - b * b) / (2.0 * a * c)).clamp(-1.0, 1.0);
    final radA = math.acos(cosA);
    final radB = math.acos(cosB);
    final radC = math.pi - radA - radB;

    final degA = radA * 180.0 / math.pi;
    final degB = radB * 180.0 / math.pi;
    final degC = radC * 180.0 / math.pi;

    final area = 0.5 * b * c * math.sin(radA);
    final perimeter = a + b + c;

    return {
      'Side a': a,
      'Side b': b,
      'Side c': c,
      'Angle A (deg)': degA,
      'Angle B (deg)': degB,
      'Angle C (deg)': degC,
      'Area': area,
      'Perimeter': perimeter,
    };
  }

  /// SAS (Side a, Side b, and included Angle C in degrees)
  static Map<String, double> solveTriangleSAS(double a, double b, double degC) {
    if (a <= 0 || b <= 0) throw const FormatException('Sides must be positive');
    if (degC <= 0 || degC >= 180) throw const FormatException('Angle must be between 0° and 180°');
    final radC = degC * math.pi / 180.0;
    final c = math.sqrt(a * a + b * b - 2.0 * a * b * math.cos(radC));
    return solveTriangleSSS(a, b, c);
  }

  /// ASA (Angle A, Side c, Angle B)
  static Map<String, double> solveTriangleASA(double degA, double c, double degB) {
    if (c <= 0) throw const FormatException('Side must be positive');
    if (degA <= 0 || degB <= 0 || (degA + degB) >= 180) {
      throw const FormatException('Sum of angles must be strictly less than 180°');
    }
    final degC = 180.0 - degA - degB;
    final radA = degA * math.pi / 180.0;
    final radB = degB * math.pi / 180.0;
    final radC = degC * math.pi / 180.0;

    // Law of Sines: a = c * sin(A) / sin(C), b = c * sin(B) / sin(C)
    final a = c * math.sin(radA) / math.sin(radC);
    final b = c * math.sin(radB) / math.sin(radC);
    return solveTriangleSSS(a, b, c);
  }

  /// AAS (Angle A, Angle B, Side a)
  static Map<String, double> solveTriangleAAS(double degA, double degB, double a) {
    if (a <= 0) throw const FormatException('Side must be positive');
    if (degA <= 0 || degB <= 0 || (degA + degB) >= 180) {
      throw const FormatException('Sum of angles must be strictly less than 180°');
    }
    final degC = 180.0 - degA - degB;
    final radA = degA * math.pi / 180.0;
    final radB = degB * math.pi / 180.0;
    final radC = degC * math.pi / 180.0;

    final b = a * math.sin(radB) / math.sin(radA);
    final c = a * math.sin(radC) / math.sin(radA);
    return solveTriangleSSS(a, b, c);
  }

  // ==========================================
  // 4. GEOMETRY QUESTIONS & INVERSE SOLVERS
  // ==========================================

  static Map<String, double> pythagoreanHypotenuse(double a, double b) {
    if (a <= 0 || b <= 0) throw const FormatException('Legs must be positive');
    final c = math.sqrt(a * a + b * b);
    return {'Hypotenuse (c)': c, 'Leg a': a, 'Leg b': b};
  }

  static Map<String, double> pythagoreanMissingLeg(double c, double a) {
    if (c <= 0 || a <= 0) throw const FormatException('Lengths must be positive');
    if (c <= a) throw const FormatException('Hypotenuse must be greater than leg');
    final b = math.sqrt(c * c - a * a);
    return {'Missing Leg (b)': b, 'Hypotenuse (c)': c, 'Known Leg (a)': a};
  }

  static Map<String, double> circleFromArea(double area) {
    if (area <= 0) throw const FormatException('Area must be positive');
    final radius = math.sqrt(area / math.pi);
    final circumference = 2.0 * math.pi * radius;
    return {'Radius (r)': radius, 'Diameter (d)': 2.0 * radius, 'Circumference (C)': circumference};
  }

  static Map<String, double> circleFromCircumference(double circumference) {
    if (circumference <= 0) throw const FormatException('Circumference must be positive');
    final radius = circumference / (2.0 * math.pi);
    final area = math.pi * radius * radius;
    return {'Radius (r)': radius, 'Diameter (d)': 2.0 * radius, 'Area (A)': area};
  }

  static Map<String, double> circleAngleFromArc(double radius, double arcLength) {
    if (radius <= 0 || arcLength <= 0) throw const FormatException('Values must be positive');
    final rad = arcLength / radius;
    final deg = rad * 180.0 / math.pi;
    return {'Central Angle (deg)': deg, 'Central Angle (rad)': rad};
  }

  static Map<String, double> circleChordFromDistance(double radius, double distance) {
    if (radius <= 0 || distance < 0) throw const FormatException('Values must be valid');
    if (distance >= radius) throw const FormatException('Distance must be strictly less than radius');
    final chord = 2.0 * math.sqrt(radius * radius - distance * distance);
    return {'Chord Length': chord, 'Radius': radius, 'Distance from Center': distance};
  }

  static Map<String, double> triangleThirdAngle(double angleA, double angleB) {
    if (angleA <= 0 || angleB <= 0 || (angleA + angleB) >= 180) {
      throw const FormatException('Sum of two angles must be between 0° and 180°');
    }
    final angleC = 180.0 - angleA - angleB;
    return {'Third Angle C (deg)': angleC, 'Angle A (deg)': angleA, 'Angle B (deg)': angleB};
  }

  static Map<String, double> triangleHeightFromArea(double area, double base) {
    if (area <= 0 || base <= 0) throw const FormatException('Area and base must be positive');
    final height = 2.0 * area / base;
    return {'Height (h)': height, 'Base (b)': base, 'Area (A)': area};
  }

  static Map<String, double> triangleBaseFromArea(double area, double height) {
    if (area <= 0 || height <= 0) throw const FormatException('Area and height must be positive');
    final base = 2.0 * area / height;
    return {'Base (b)': base, 'Height (h)': height, 'Area (A)': area};
  }

  static Map<String, double> squareFromArea(double area) {
    if (area <= 0) throw const FormatException('Area must be positive');
    final side = math.sqrt(area);
    final perimeter = 4.0 * side;
    final diagonal = side * math.sqrt(2.0);
    return {'Side (s)': side, 'Perimeter (P)': perimeter, 'Diagonal (d)': diagonal};
  }

  static Map<String, double> squareFromPerimeter(double perimeter) {
    if (perimeter <= 0) throw const FormatException('Perimeter must be positive');
    final side = perimeter / 4.0;
    final area = side * side;
    final diagonal = side * math.sqrt(2.0);
    return {'Side (s)': side, 'Area (A)': area, 'Diagonal (d)': diagonal};
  }

  static Map<String, double> squareFromDiagonal(double diagonal) {
    if (diagonal <= 0) throw const FormatException('Diagonal must be positive');
    final side = diagonal / math.sqrt(2.0);
    final area = side * side;
    final perimeter = 4.0 * side;
    return {'Side (s)': side, 'Area (A)': area, 'Perimeter (P)': perimeter};
  }

  static Map<String, double> rectangleMissingWidth(double area, double length) {
    if (area <= 0 || length <= 0) throw const FormatException('Values must be positive');
    final width = area / length;
    final perimeter = 2.0 * (length + width);
    final diagonal = math.sqrt(length * length + width * width);
    return {'Width (w)': width, 'Perimeter (P)': perimeter, 'Diagonal (d)': diagonal};
  }

  static Map<String, double> rectangleFromAreaAndPerimeter(double area, double perimeter) {
    if (area <= 0 || perimeter <= 0) throw const FormatException('Values must be positive');
    // x^2 - (P/2)x + A = 0
    final s = perimeter / 2.0;
    final disc = s * s - 4.0 * area;
    if (disc < 0) {
      throw const FormatException('Impossible geometry: perimeter is too small for this area (P² ≥ 16A)');
    }
    final l = (s + math.sqrt(disc)) / 2.0;
    final w = (s - math.sqrt(disc)) / 2.0;
    return {
      'Length (l)': math.max(l, w),
      'Width (w)': math.min(l, w),
      'Diagonal': math.sqrt(l * l + w * w),
    };
  }

  static Map<String, double> polygonProperties(int n) {
    if (n < 3) throw const FormatException('Polygon must have at least 3 sides');
    final sumAngles = (n - 2) * 180.0;
    final interior = sumAngles / n;
    final exterior = 360.0 / n;
    final diagonals = (n * (n - 3)) / 2.0;
    return {
      'Sum of Interior Angles (deg)': sumAngles,
      'Interior Angle (deg)': interior,
      'Exterior Angle (deg)': exterior,
      'Total Diagonals': diagonals,
      'Number of Sides': n.toDouble(),
    };
  }

  static Map<String, double> sphereFromVolume(double volume) {
    if (volume <= 0) throw const FormatException('Volume must be positive');
    final radius = math.pow((3.0 * volume) / (4.0 * math.pi), 1.0 / 3.0).toDouble();
    final surfaceArea = 4.0 * math.pi * radius * radius;
    return {'Radius (r)': radius, 'Surface Area (A)': surfaceArea, 'Diameter': 2.0 * radius};
  }

  static Map<String, double> sphereFromSurfaceArea(double surfaceArea) {
    if (surfaceArea <= 0) throw const FormatException('Surface area must be positive');
    final radius = math.sqrt(surfaceArea / (4.0 * math.pi));
    final volume = (4.0 / 3.0) * math.pi * math.pow(radius, 3);
    return {'Radius (r)': radius, 'Volume (V)': volume, 'Diameter': 2.0 * radius};
  }

  static Map<String, double> cylinderHeightFromVolume(double volume, double radius) {
    if (volume <= 0 || radius <= 0) throw const FormatException('Values must be positive');
    final height = volume / (math.pi * radius * radius);
    final totalArea = 2.0 * math.pi * radius * (radius + height);
    return {'Height (h)': height, 'Total Surface Area': totalArea};
  }

  static Map<String, double> cylinderRadiusFromVolume(double volume, double height) {
    if (volume <= 0 || height <= 0) throw const FormatException('Values must be positive');
    final radius = math.sqrt(volume / (math.pi * height));
    final totalArea = 2.0 * math.pi * radius * (radius + height);
    return {'Radius (r)': radius, 'Total Surface Area': totalArea};
  }

  static Map<String, double> coneHeightFromVolume(double volume, double radius) {
    if (volume <= 0 || radius <= 0) throw const FormatException('Values must be positive');
    final height = (3.0 * volume) / (math.pi * radius * radius);
    final slant = math.sqrt(radius * radius + height * height);
    return {'Height (h)': height, 'Slant Height (l)': slant};
  }

  static Map<String, double> cubeFromVolume(double volume) {
    if (volume <= 0) throw const FormatException('Volume must be positive');
    final side = math.pow(volume, 1.0 / 3.0).toDouble();
    final area = 6.0 * side * side;
    final spaceDiag = side * math.sqrt(3.0);
    return {'Side Length (s)': side, 'Surface Area (A)': area, 'Space Diagonal': spaceDiag};
  }

  static Map<String, double> cubeFromSurfaceArea(double surfaceArea) {
    if (surfaceArea <= 0) throw const FormatException('Surface area must be positive');
    final side = math.sqrt(surfaceArea / 6.0);
    final volume = math.pow(side, 3).toDouble();
    final spaceDiag = side * math.sqrt(3.0);
    return {'Side Length (s)': side, 'Volume (V)': volume, 'Space Diagonal': spaceDiag};
  }

  static Map<String, double> cubeFromSpaceDiagonal(double spaceDiagonal) {
    if (spaceDiagonal <= 0) throw const FormatException('Diagonal must be positive');
    final side = spaceDiagonal / math.sqrt(3.0);
    final volume = math.pow(side, 3).toDouble();
    final area = 6.0 * side * side;
    return {'Side Length (s)': side, 'Volume (V)': volume, 'Surface Area': area};
  }

  static Map<String, double> coordinate2D(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final distance = math.sqrt(dx * dx + dy * dy);
    final midX = (x1 + x2) / 2.0;
    final midY = (y1 + y2) / 2.0;

    final res = {
      'Distance': distance,
      'Midpoint X': midX,
      'Midpoint Y': midY,
    };
    if (dx.abs() > 1e-12) {
      final slope = dy / dx;
      final yIntercept = y1 - slope * x1;
      res['Slope (m)'] = slope;
      res['y-intercept (b)'] = yIntercept;
    }
    return res;
  }
}
