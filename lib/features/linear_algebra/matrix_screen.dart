// Qalculyn - Linear Algebra Screen
// Matrix determinant, inverse, transpose, RREF row operations, eigenvalues, and 3D vector algebra

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/matrix_vector.dart';
import '../../shared/tool_widgets.dart';

class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});

  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  int _selectedMode = 0; // 0: Matrix Operations, 1: 3D Vector Operations

  // Matrix controllers
  final _matAController = TextEditingController(text: '[[1, 2], [3, 4]]');
  final _matBController = TextEditingController(text: '[[5, 6], [7, 8]]');
  int _matOperation = 0; // 0: Properties, 1: RREF, 2: Eigenvalues, 3: A+B, 4: A-B, 5: A×B

  // Vector controllers
  final _vecUController = TextEditingController(text: '[1, 0, 0]');
  final _vecVController = TextEditingController(text: '[0, 1, 0]');

  @override
  void dispose() {
    _matAController.dispose();
    _matBController.dispose();
    _vecUController.dispose();
    _vecVController.dispose();
    super.dispose();
  }

  void _setMatExample(String a, [String? b]) {
    setState(() {
      _matAController.text = a;
      if (b != null) _matBController.text = b;
    });
  }

  void _setVecExample(String u, String v) {
    setState(() {
      _vecUController.text = u;
      _vecVController.text = v;
    });
  }

  void _showRrefStepsModal(RrefResult rrefRes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? QColors.darkSurface : QColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(QSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gauss-Jordan Row Reductions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: rrefRes.steps.length,
                  itemBuilder: (ctx, i) {
                    final step = rrefRes.steps[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step ${i + 1}: ${step.description}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: QColors.primaryPurple),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? QColors.darkCard : QColors.lightElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              step.matrix.toString(),
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEigenStepsModal(EigenResult eigenRes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? QColors.darkSurface : QColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(QSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Characteristic Derivations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: eigenRes.steps.length,
                  itemBuilder: (ctx, i) {
                    final s = eigenRes.steps[i];
                    final isHeader = s.startsWith('Step');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: isHeader ? 14 : 13,
                          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                          color: isHeader ? QColors.primaryPurple : (isDark ? Colors.white70 : Colors.black87),
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, String> _calculate() {
    if (_selectedMode == 0) {
      // Matrix Operations
      try {
        final a = Matrix.parse(_matAController.text);

        if (_matOperation == 0) {
          // Properties of A
          final results = <String, String>{
            'Dimensions': '${a.rows} × ${a.cols}',
            'Matrix A': a.toString(),
            'Transpose Aᵀ': a.transpose().toString(),
          };

          if (a.isSquare) {
            final det = a.determinant();
            results['Determinant det(A)'] = det.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
            results['Trace tr(A)'] = a.trace().toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
            if (det.abs() > 1e-12) {
              results['Inverse A⁻¹'] = a.inverse().toString();
            } else {
              results['Inverse A⁻¹'] = 'Singular matrix (det = 0, no inverse)';
            }
          } else {
            results['Square Matrix Properties'] = 'Determinant & Trace require a square matrix (rows == cols)';
          }

          final rrefRes = a.rrefDetailed();
          results['Matrix Rank'] = '${rrefRes.rank}';
          return results;
        } else if (_matOperation == 1) {
          // RREF
          final rrefRes = a.rrefDetailed();
          return {
            'Reduced Row Echelon (RREF)': rrefRes.rref.toString(),
            'Matrix Rank': '${rrefRes.rank}',
            'Row Operation Steps': '${rrefRes.steps.length} row transformation steps computed',
          };
        } else if (_matOperation == 2) {
          // Eigenvalues
          if (!a.isSquare || a.rows < 2 || a.rows > 3) {
            return {'Notice': 'Eigenvalue solver supports 2×2 and 3×3 square matrices'};
          }
          final eigenRes = a.eigenvalues();
          return {
            'Eigenvalues': eigenRes.values.join(';  '),
            'Characteristic Equation': eigenRes.characteristicEquation,
          };
        } else {
          final b = Matrix.parse(_matBController.text);
          Matrix res;
          String opName;

          switch (_matOperation) {
            case 3:
              res = a + b;
              opName = 'A + B';
            case 4:
              res = a - b;
              opName = 'A − B';
            case 5:
              res = a * b;
              opName = 'A × B';
            default:
              res = a + b;
              opName = 'A + B';
          }

          return {
            'Result Matrix': res.toString(),
            'Operation': opName,
            'Dimensions': '${res.rows} × ${res.cols}',
          };
        }
      } catch (e) {
        return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter valid matrix rows (comma separated)')};
      }
    } else {
      // 3D Vector Operations
      try {
        final u = Vector3D.parse(_vecUController.text);
        final v = Vector3D.parse(_vecVController.text);

        final dot = u.dot(v);
        final cross = u.cross(v);
        final angle = u.angleToDegrees(v);

        return {
          'Dot Product u · v': dot.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), ''),
          'Cross Product u × v': cross.toString(),
          'Angle Between (deg)': '${angle.toStringAsFixed(2)}°',
          'Angle Between (rad)': '${(angle * 3.141592653589793 / 180.0).toStringAsFixed(4)} rad',
          'Magnitude ||u||': u.magnitude.toStringAsFixed(4),
          'Magnitude ||v||': v.magnitude.toStringAsFixed(4),
          'Unit Vector û': u.unit().toString(),
          'Unit Vector v̂': v.unit().toString(),
        };
      } catch (e) {
        return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter valid 3D vector coordinates [x, y, z]')};
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    RrefResult? currentRref;
    EigenResult? currentEigen;
    if (_selectedMode == 0) {
      try {
        final a = Matrix.parse(_matAController.text);
        if (_matOperation == 1) {
          currentRref = a.rrefDetailed();
        } else if (_matOperation == 2 && a.isSquare && a.rows >= 2 && a.rows <= 3) {
          currentEigen = a.eigenvalues();
        }
      } catch (_) {}
    }

    return ToolScaffold(
      title: 'Matrices & Vectors',
      disclaimer: 'Arbitrary dimension matrices, Gauss-Jordan RREF steps, eigenvalues, and 3D vector geometry.',
      children: [
        ToolModeSelector(
          modes: const ['Matrix Operations', '3D Vector Algebra'],
          selected: _selectedMode,
          onChanged: (idx) => setState(() => _selectedMode = idx),
        ),
        const SizedBox(height: QSpacing.md),

        if (_selectedMode == 0) ...[
          // Matrix presets
          Wrap(
            spacing: QSpacing.sm,
            runSpacing: QSpacing.xs,
            children: [
              ActionChip(
                label: const Text('2×2: [[1, 2], [3, 4]]'),
                onPressed: () => _setMatExample('[[1, 2], [3, 4]]', '[[5, 6], [7, 8]]'),
              ),
              ActionChip(
                label: const Text('3×3: [[1,2,3],[0,1,4],[5,6,0]]'),
                onPressed: () => _setMatExample('[[1, 2, 3], [0, 1, 4], [5, 6, 0]]'),
              ),
              ActionChip(
                label: const Text('RREF Row Demo: [[1,2,3],[4,5,6]]'),
                onPressed: () => _setMatExample('[[1, 2, 3], [4, 5, 6]]'),
              ),
            ],
          ),
          const SizedBox(height: QSpacing.md),

          ToolTextField(
            controller: _matAController,
            label: 'Matrix A format: [[1, 2], [3, 4]] or 1 2; 3 4',
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: QSpacing.md),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Properties & Det'),
                  selected: _matOperation == 0,
                  onSelected: (_) => setState(() => _matOperation = 0),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('RREF Steps'),
                  selected: _matOperation == 1,
                  onSelected: (_) => setState(() => _matOperation = 1),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Eigenvalues'),
                  selected: _matOperation == 2,
                  onSelected: (_) => setState(() => _matOperation = 2),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('A + B'),
                  selected: _matOperation == 3,
                  onSelected: (_) => setState(() => _matOperation = 3),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('A − B'),
                  selected: _matOperation == 4,
                  onSelected: (_) => setState(() => _matOperation = 4),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('A × B'),
                  selected: _matOperation == 5,
                  onSelected: (_) => setState(() => _matOperation = 5),
                ),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.md),

          if (_matOperation >= 3) ...[
            ToolTextField(
              controller: _matBController,
              label: 'Matrix B format: [[5, 6], [7, 8]]',
              keyboardType: TextInputType.text,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: QSpacing.md),
          ],

          if (currentRref != null) ...[
            ElevatedButton.icon(
              onPressed: () => _showRrefStepsModal(currentRref!),
              icon: const Icon(Icons.table_view_outlined),
              label: const Text('View Row Operation Steps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: QColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: QSpacing.md),
          ],

          if (currentEigen != null) ...[
            ElevatedButton.icon(
              onPressed: () => _showEigenStepsModal(currentEigen!),
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('View Characteristic Derivation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: QColors.primaryPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: QSpacing.md),
          ],
        ] else ...[
          // Vector presets
          Wrap(
            spacing: QSpacing.sm,
            runSpacing: QSpacing.xs,
            children: [
              ActionChip(
                label: const Text('Orthogonal: [1,0,0] & [0,1,0]'),
                onPressed: () => _setVecExample('[1, 0, 0]', '[0, 1, 0]'),
              ),
              ActionChip(
                label: const Text('[1, 2, 3] & [4, 5, 6]'),
                onPressed: () => _setVecExample('[1, 2, 3]', '[4, 5, 6]'),
              ),
            ],
          ),
          const SizedBox(height: QSpacing.md),

          ToolTextField(
            controller: _vecUController,
            label: 'Vector u (e.g. [1, 2, 3])',
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: QSpacing.md),
          ToolTextField(
            controller: _vecVController,
            label: 'Vector v (e.g. [4, 5, 6])',
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() {}),
          ),
        ],

        const SizedBox(height: QSpacing.xl),
        ToolResultCard(
          title: _selectedMode == 0 ? 'Matrix Computation Results' : 'Vector Geometry Results',
          results: results,
        ),
      ],
    );
  }
}
