// Qalculyn - Comprehensive Geometry & Shapes Screen
// Interactive 2D shapes, 3D solids, Analytic Triangle Solvers, and Geometry Word Problem Solvers

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/geometry_engine.dart';
import '../../shared/tool_widgets.dart';
import 'geometry_canvas_widget.dart';

class GeometryScreen extends StatefulWidget {
  const GeometryScreen({super.key});

  @override
  State<GeometryScreen> createState() => _GeometryScreenState();
}

class _GeometryScreenState extends State<GeometryScreen> {
  int _selectedCategory = 0; // 0: 2D Shapes, 1: 3D Solids, 2: Triangle Solver, 3: Geometry Questions

  // 2D Shapes
  int _selected2D = 0;
  static const _shapes2D = [
    'Circle',
    'Sector & Arc',
    'Annulus (Ring)',
    'Ellipse',
    'Rectangle',
    'Square',
    'Triangle (Heron 3 Sides)',
    'Triangle (Base & Height)',
    'Right Triangle',
    'Equilateral Triangle',
    'Isosceles Triangle',
    'Parallelogram',
    'Rhombus',
    'Trapezoid',
    'Kite',
    'Regular Polygon',
  ];

  // 3D Solids
  int _selected3D = 0;
  static const _shapes3D = [
    'Sphere',
    'Hemisphere',
    'Spherical Cap (Dome)',
    'Cylinder',
    'Hollow Cylinder (Pipe)',
    'Cone',
    'Conical Frustum',
    'Cube',
    'Rectangular Prism (Cuboid)',
    'Square Pyramid',
    'Regular Tetrahedron',
    'Triangular Prism',
    'Torus (Donut)',
    'Ellipsoid',
  ];

  // Triangle Solver
  int _selectedTri = 0;
  static const _triMethods = [
    'SSS (Sides a, b, c)',
    'SAS (Sides a, b, Angle C)',
    'ASA (Angle A, Side c, Angle B)',
    'AAS (Angle A, Angle B, Side a)',
  ];

  // Geometry Questions
  int _selectedQuestion = 0;
  static const _questions = [
    'Pythagorean: Find Hypotenuse (c)',
    'Pythagorean: Find Missing Leg (b)',
    'Circle: Find Radius & Circumference from Area',
    'Circle: Find Radius & Area from Circumference',
    'Circle: Central Angle from Arc Length & Radius',
    'Circle: Chord Length from Radius & Distance to Center',
    'Triangle: Find 3rd Angle from 2 Angles',
    'Triangle: Find Height from Area & Base',
    'Triangle: Find Base from Area & Height',
    'Square: Find Side & Perimeter from Area',
    'Square: Find Side & Area from Perimeter',
    'Square: Find Side & Area from Diagonal',
    'Rectangle: Find Width from Area & Length',
    'Rectangle: Find Dimensions from Area & Perimeter',
    'Polygon: Angles & Diagonals from Number of Sides (n)',
    'Sphere: Find Radius & Area from Volume',
    'Sphere: Find Radius & Volume from Surface Area',
    'Cylinder: Find Height from Volume & Radius',
    'Cylinder: Find Radius from Volume & Height',
    'Cone: Find Height from Volume & Radius',
    'Cube: Find Side from Volume',
    'Cube: Find Side from Surface Area',
    'Cube: Find Side from Space Diagonal',
    'Coordinate 2D: Distance, Midpoint & Slope',
  ];

  // Dimension controllers
  final _v1 = TextEditingController(text: '5');
  final _v2 = TextEditingController(text: '8');
  final _v3 = TextEditingController(text: '10');
  final _v4 = TextEditingController(text: '6');

  @override
  void dispose() {
    _v1.dispose();
    _v2.dispose();
    _v3.dispose();
    _v4.dispose();
    super.dispose();
  }

  void _resetDefaults() {
    _v1.text = '5';
    _v2.text = '8';
    _v3.text = '10';
    _v4.text = '6';
  }

  Map<String, String> _calculate() {
    try {
      final a = double.tryParse(_v1.text.trim()) ?? 0.0;
      final b = double.tryParse(_v2.text.trim()) ?? 0.0;
      final c = double.tryParse(_v3.text.trim()) ?? 0.0;
      final d = double.tryParse(_v4.text.trim()) ?? 0.0;

      Map<String, double> res = {};

      if (_selectedCategory == 0) {
        // 2D Shapes
        switch (_selected2D) {
          case 0: res = GeometryEngine.circle(a); break;
          case 1: res = GeometryEngine.sector(a, b); break;
          case 2: res = GeometryEngine.annulus(a, b); break;
          case 3: res = GeometryEngine.ellipse(a, b); break;
          case 4: res = GeometryEngine.rectangle(a, b); break;
          case 5: res = GeometryEngine.square(a); break;
          case 6: res = GeometryEngine.triangleHeron(a, b, c); break;
          case 7: res = GeometryEngine.triangleBaseHeight(a, b); break;
          case 8: res = GeometryEngine.rightTriangle(a, b); break;
          case 9: res = GeometryEngine.equilateralTriangle(a); break;
          case 10: res = GeometryEngine.isoscelesTriangle(a, b); break;
          case 11: res = GeometryEngine.parallelogram(a, b, c, d); break;
          case 12: res = GeometryEngine.rhombus(a, b); break;
          case 13: res = GeometryEngine.trapezoid(a, b, c); break;
          case 14: res = GeometryEngine.kite(a, b); break;
          case 15: res = GeometryEngine.regularPolygon(a.toInt(), b); break;
        }
      } else if (_selectedCategory == 1) {
        // 3D Solids
        switch (_selected3D) {
          case 0: res = GeometryEngine.sphere(a); break;
          case 1: res = GeometryEngine.hemisphere(a); break;
          case 2: res = GeometryEngine.sphericalCap(a, b); break;
          case 3: res = GeometryEngine.cylinder(a, b); break;
          case 4: res = GeometryEngine.hollowCylinder(a, b, c); break;
          case 5: res = GeometryEngine.cone(a, b); break;
          case 6: res = GeometryEngine.conicalFrustum(a, b, c); break;
          case 7: res = GeometryEngine.cube(a); break;
          case 8: res = GeometryEngine.rectangularPrism(a, b, c); break;
          case 9: res = GeometryEngine.squarePyramid(a, b); break;
          case 10: res = GeometryEngine.tetrahedron(a); break;
          case 11: res = GeometryEngine.triangularPrism(a, b, c); break;
          case 12: res = GeometryEngine.torus(a, b); break;
          case 13: res = GeometryEngine.ellipsoid(a, b, c); break;
        }
      } else if (_selectedCategory == 2) {
        // Triangle Solver
        switch (_selectedTri) {
          case 0: res = GeometryEngine.solveTriangleSSS(a, b, c); break;
          case 1: res = GeometryEngine.solveTriangleSAS(a, b, c); break;
          case 2: res = GeometryEngine.solveTriangleASA(a, b, c); break;
          case 3: res = GeometryEngine.solveTriangleAAS(a, b, c); break;
        }
      } else {
        // Geometry Questions
        switch (_selectedQuestion) {
          case 0: res = GeometryEngine.pythagoreanHypotenuse(a, b); break;
          case 1: res = GeometryEngine.pythagoreanMissingLeg(a, b); break;
          case 2: res = GeometryEngine.circleFromArea(a); break;
          case 3: res = GeometryEngine.circleFromCircumference(a); break;
          case 4: res = GeometryEngine.circleAngleFromArc(a, b); break;
          case 5: res = GeometryEngine.circleChordFromDistance(a, b); break;
          case 6: res = GeometryEngine.triangleThirdAngle(a, b); break;
          case 7: res = GeometryEngine.triangleHeightFromArea(a, b); break;
          case 8: res = GeometryEngine.triangleBaseFromArea(a, b); break;
          case 9: res = GeometryEngine.squareFromArea(a); break;
          case 10: res = GeometryEngine.squareFromPerimeter(a); break;
          case 11: res = GeometryEngine.squareFromDiagonal(a); break;
          case 12: res = GeometryEngine.rectangleMissingWidth(a, b); break;
          case 13: res = GeometryEngine.rectangleFromAreaAndPerimeter(a, b); break;
          case 14: res = GeometryEngine.polygonProperties(a.toInt()); break;
          case 15: res = GeometryEngine.sphereFromVolume(a); break;
          case 16: res = GeometryEngine.sphereFromSurfaceArea(a); break;
          case 17: res = GeometryEngine.cylinderHeightFromVolume(a, b); break;
          case 18: res = GeometryEngine.cylinderRadiusFromVolume(a, b); break;
          case 19: res = GeometryEngine.coneHeightFromVolume(a, b); break;
          case 20: res = GeometryEngine.cubeFromVolume(a); break;
          case 21: res = GeometryEngine.cubeFromSurfaceArea(a); break;
          case 22: res = GeometryEngine.cubeFromSpaceDiagonal(a); break;
          case 23: res = GeometryEngine.coordinate2D(a, b, c, d); break;
        }
      }

      return res.map((k, v) => MapEntry(k, v.toStringAsFixed(4)));
    } catch (e) {
      return {'Calculation Note': cleanMathErrorMessage(e, fallback: 'Please enter valid geometric dimensions')};
    }
  }

  List<String> _getInputLabels() {
    if (_selectedCategory == 0) {
      switch (_selected2D) {
        case 0: return ['Radius (r)'];
        case 1: return ['Radius (r)', 'Central Angle (deg)'];
        case 2: return ['Outer Radius (R)', 'Inner Radius (r)'];
        case 3: return ['Semi-major Axis (a)', 'Semi-minor Axis (b)'];
        case 4: return ['Length (l)', 'Width (w)'];
        case 5: return ['Side Length (s)'];
        case 6: return ['Side a', 'Side b', 'Side c'];
        case 7: return ['Base (b)', 'Height (h)'];
        case 8: return ['Leg a', 'Leg b'];
        case 9: return ['Side Length (a)'];
        case 10: return ['Base (b)', 'Leg (a)'];
        case 11: return ['Base (b)', 'Height (h)', 'Side a (optional)', 'Angle (deg, opt)'];
        case 12: return ['Diagonal 1 (d1)', 'Diagonal 2 (d2)'];
        case 13: return ['Base a', 'Base b', 'Height (h)'];
        case 14: return ['Diagonal 1 (d1)', 'Diagonal 2 (d2)'];
        case 15: return ['Number of Sides (n)', 'Side Length (s)'];
        default: return ['Value 1'];
      }
    } else if (_selectedCategory == 1) {
      switch (_selected3D) {
        case 0: return ['Radius (r)'];
        case 1: return ['Radius (r)'];
        case 2: return ['Sphere Radius (R)', 'Cap Height (h)'];
        case 3: return ['Radius (r)', 'Height (h)'];
        case 4: return ['Outer Radius (R)', 'Inner Radius (r)', 'Height (h)'];
        case 5: return ['Radius (r)', 'Height (h)'];
        case 6: return ['Top Radius (r1)', 'Bottom Radius (r2)', 'Height (h)'];
        case 7: return ['Side Length (s)'];
        case 8: return ['Length (l)', 'Width (w)', 'Height (h)'];
        case 9: return ['Base Side (a)', 'Height (h)'];
        case 10: return ['Edge Length (a)'];
        case 11: return ['Triangle Base (b)', 'Triangle Height (h)', 'Prism Length (L)'];
        case 12: return ['Major Radius (R)', 'Minor Radius (r)'];
        case 13: return ['Semi-axis a', 'Semi-axis b', 'Semi-axis c'];
        default: return ['Value 1'];
      }
    } else if (_selectedCategory == 2) {
      switch (_selectedTri) {
        case 0: return ['Side a', 'Side b', 'Side c'];
        case 1: return ['Side a', 'Side b', 'Angle C (deg)'];
        case 2: return ['Angle A (deg)', 'Side c', 'Angle B (deg)'];
        case 3: return ['Angle A (deg)', 'Angle B (deg)', 'Side a'];
        default: return ['Value 1'];
      }
    } else {
      switch (_selectedQuestion) {
        case 0: return ['Leg a', 'Leg b'];
        case 1: return ['Hypotenuse (c)', 'Known Leg (a)'];
        case 2: return ['Circle Area (A)'];
        case 3: return ['Circle Circumference (C)'];
        case 4: return ['Radius (r)', 'Arc Length (L)'];
        case 5: return ['Radius (r)', 'Distance from Center (d)'];
        case 6: return ['Angle A (deg)', 'Angle B (deg)'];
        case 7: return ['Area (A)', 'Base (b)'];
        case 8: return ['Area (A)', 'Height (h)'];
        case 9: return ['Square Area (A)'];
        case 10: return ['Square Perimeter (P)'];
        case 11: return ['Square Diagonal (d)'];
        case 12: return ['Rectangle Area (A)', 'Length (l)'];
        case 13: return ['Rectangle Area (A)', 'Perimeter (P)'];
        case 14: return ['Number of Sides (n)'];
        case 15: return ['Sphere Volume (V)'];
        case 16: return ['Sphere Surface Area (A)'];
        case 17: return ['Cylinder Volume (V)', 'Radius (r)'];
        case 18: return ['Cylinder Volume (V)', 'Height (h)'];
        case 19: return ['Cone Volume (V)', 'Radius (r)'];
        case 20: return ['Cube Volume (V)'];
        case 21: return ['Cube Surface Area (A)'];
        case 22: return ['Cube Space Diagonal (d)'];
        case 23: return ['Point 1 X (x1)', 'Point 1 Y (y1)', 'Point 2 X (x2)', 'Point 2 Y (y2)'];
        default: return ['Value 1'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();
    final labels = _getInputLabels();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ToolScaffold(
      title: 'Geometry & Shapes',
      disclaimer: 'Calculates all 2D plane and 3D solid geometries, analytic triangle resolutions, and inverse word problem questions.',
      children: [
        // Mode Selector
        ToolModeSelector(
          modes: const ['2D Shapes', '3D Solids', 'Triangle Solver', 'Questions & Solvers'],
          selected: _selectedCategory,
          onChanged: (idx) {
            setState(() {
              _selectedCategory = idx;
              _resetDefaults();
            });
          },
        ),
        const SizedBox(height: QSpacing.md),

        // Shape / Question Dropdown Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? QColors.darkCard : QColors.lightCard,
            borderRadius: QRadius.borderRadiusMd,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              dropdownColor: isDark ? QColors.darkCard : QColors.lightCard,
              value: _selectedCategory == 0
                  ? _selected2D
                  : (_selectedCategory == 1
                      ? _selected3D
                      : (_selectedCategory == 2 ? _selectedTri : _selectedQuestion)),
              items: () {
                final list = _selectedCategory == 0
                    ? _shapes2D
                    : (_selectedCategory == 1
                        ? _shapes3D
                        : (_selectedCategory == 2 ? _triMethods : _questions));
                return list.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList();
              }(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    if (_selectedCategory == 0) {
                      _selected2D = val;
                    } else if (_selectedCategory == 1) {
                      _selected3D = val;
                    } else if (_selectedCategory == 2) {
                      _selectedTri = val;
                    } else {
                      _selectedQuestion = val;
                    }
                    _resetDefaults();
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: QSpacing.md),

        // Live Vector Geometry Canvas
        GeometryCanvasWidget(
          category: _selectedCategory,
          shapeIndex: _selectedCategory == 0
              ? _selected2D
              : (_selectedCategory == 1
                  ? _selected3D
                  : (_selectedCategory == 2 ? _selectedTri : _selectedQuestion)),
          dimensions: [
            double.tryParse(_v1.text.trim()) ?? 5.0,
            double.tryParse(_v2.text.trim()) ?? 5.0,
            double.tryParse(_v3.text.trim()) ?? 5.0,
            double.tryParse(_v4.text.trim()) ?? 5.0,
          ],
        ),
        const SizedBox(height: QSpacing.lg),

        // Dynamic Parameter Inputs with Live +/- Adjusters
        if (labels.isNotEmpty) ...[
          _buildAdjustableField(_v1, labels[0]),
        ],
        if (labels.length > 1) ...[
          const SizedBox(height: QSpacing.md),
          _buildAdjustableField(_v2, labels[1]),
        ],
        if (labels.length > 2) ...[
          const SizedBox(height: QSpacing.md),
          _buildAdjustableField(_v3, labels[2]),
        ],
        if (labels.length > 3) ...[
          const SizedBox(height: QSpacing.md),
          _buildAdjustableField(_v4, labels[3]),
        ],

        const SizedBox(height: QSpacing.xl),
        ToolResultCard(
          title: 'Properties & Solution',
          results: results,
        ),
        const SizedBox(height: QSpacing.md),

        // Export Geometry Study Sheet Button
        OutlinedButton.icon(
          onPressed: _exportStudySheet,
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: const Text('Export Geometry Study Sheet (Markdown)'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(color: QColors.primaryPurple.withValues(alpha: 0.5)),
          ),
        ),
      ],
    );
  }

  void _exportStudySheet() {
    final title = _selectedCategory == 0
        ? _shapes2D[_selected2D]
        : (_selectedCategory == 1
            ? _shapes3D[_selected3D]
            : (_selectedCategory == 2 ? _triMethods[_selectedTri] : _questions[_selectedQuestion]));
    final results = _calculate();
    final labels = _getInputLabels();
    final controllers = [_v1, _v2, _v3, _v4];

    final buffer = StringBuffer();
    buffer.writeln('# Qalculyn Geometry Study Sheet');
    buffer.writeln('## Subject: $title\n');
    buffer.writeln('### Input Parameters:');
    for (int i = 0; i < labels.length && i < controllers.length; i++) {
      buffer.writeln('- **${labels[i]}**: ${controllers[i].text}');
    }
    buffer.writeln('\n### Computed Geometric Properties:');
    for (final entry in results.entries) {
      buffer.writeln('- **${entry.key}**: ${entry.value}');
    }
    buffer.writeln('\n---\n*Generated offline by Qalculyn Geometry Engine*');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Geometry Study Sheet copied to clipboard as formatted Markdown!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAdjustableField(TextEditingController ctrl, String label) {
    return Row(
      children: [
        Expanded(
          child: ToolTextField(
            controller: ctrl,
            label: label,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          icon: const Icon(Icons.remove, size: 18),
          tooltip: 'Decrease dimension',
          onPressed: () {
            final cur = double.tryParse(ctrl.text.trim()) ?? 5.0;
            final updated = math.max(0.5, cur - (cur > 10 ? 5.0 : 1.0));
            setState(() {
              ctrl.text = updated.toString().replaceAll(RegExp(r'\.0$'), '');
            });
          },
        ),
        IconButton.filledTonal(
          icon: const Icon(Icons.add, size: 18),
          tooltip: 'Increase dimension',
          onPressed: () {
            final cur = double.tryParse(ctrl.text.trim()) ?? 5.0;
            final updated = cur + (cur >= 10 ? 5.0 : 1.0);
            setState(() {
              ctrl.text = updated.toString().replaceAll(RegExp(r'\.0$'), '');
            });
          },
        ),
      ],
    );
  }
}
