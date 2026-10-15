// Qalculyn - Universal Question & Problem Solver Screen
// Interactive multi-category solver for word problems, inverse questions, and real-world mathematics

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/universal_question_engine.dart';
import '../../shared/tool_widgets.dart';

class UniversalQuestionScreen extends StatefulWidget {
  const UniversalQuestionScreen({super.key});

  @override
  State<UniversalQuestionScreen> createState() => _UniversalQuestionScreenState();
}

class _UniversalQuestionScreenState extends State<UniversalQuestionScreen> {
  final List<QuestionCategory> _categories = UniversalQuestionEngine.getCategories();
  int _selectedCategoryIndex = 0;
  int _selectedQuestionIndex = 0;

  final List<TextEditingController> _controllers = [
    TextEditingController(text: '12'),
    TextEditingController(text: '16'),
    TextEditingController(text: '20'),
    TextEditingController(text: '25'),
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _resetInputDefaults() {
    _controllers[0].text = '12';
    _controllers[1].text = '16';
    _controllers[2].text = '20';
    _controllers[3].text = '25';
  }

  QuestionItem get _currentQuestion {
    final cat = _categories[_selectedCategoryIndex];
    if (_selectedQuestionIndex >= cat.questions.length) {
      return cat.questions.first;
    }
    return cat.questions[_selectedQuestionIndex];
  }

  Map<String, String> _calculate() {
    try {
      final q = _currentQuestion;
      final values = _controllers.map((c) => double.tryParse(c.text.trim()) ?? 0.0).toList();
      final res = q.solver(values);
      return res.map((k, v) => MapEntry(k, v.toStringAsFixed(4)));
    } catch (e) {
      return {'Input Note': cleanMathErrorMessage(e, fallback: 'Please enter valid parameters for this problem')};
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final results = _calculate();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ToolScaffold(
      title: 'Question & Problem Solver',
      disclaimer: 'Solve inverse questions, word problems, and missing variables across all scientific & mathematical categories.',
      children: [
        // Category Selector Tabs
        ToolModeSelector(
          modes: _categories.map((c) => c.title.split(' ').first).toList(),
          selected: _selectedCategoryIndex,
          onChanged: (idx) {
            setState(() {
              _selectedCategoryIndex = idx;
              _selectedQuestionIndex = 0;
              _resetInputDefaults();
            });
          },
        ),
        const SizedBox(height: QSpacing.md),

        // Question Dropdown
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
              value: _selectedQuestionIndex.clamp(0, _categories[_selectedCategoryIndex].questions.length - 1),
              items: _categories[_selectedCategoryIndex].questions.asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(
                    entry.value.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedQuestionIndex = val;
                    _resetInputDefaults();
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: QSpacing.md),

        // Formula Header Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(QSpacing.md),
          decoration: BoxDecoration(
            color: QColors.primaryPurple.withValues(alpha: 0.12),
            borderRadius: QRadius.borderRadiusMd,
            border: Border.all(color: QColors.primaryPurple.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Governing Formula / Principle:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: QColors.primaryPurple,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                question.formulaDescription,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: QSpacing.lg),

        // Dynamic Inputs
        for (int i = 0; i < question.inputLabels.length; i++) ...[
          ToolTextField(
            controller: _controllers[i],
            label: question.inputLabels[i],
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            onChanged: (_) => setState(() {}),
          ),
          if (i < question.inputLabels.length - 1) const SizedBox(height: QSpacing.md),
        ],

        const SizedBox(height: QSpacing.xl),
        ToolResultCard(
          title: 'Computed Solution & Metrics',
          results: results,
        ),
        const SizedBox(height: QSpacing.md),

        // Export Study Sheet Button
        OutlinedButton.icon(
          onPressed: _exportStudySheet,
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: const Text('Export Solution as Study Sheet (Markdown)'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(color: QColors.primaryPurple.withValues(alpha: 0.5)),
          ),
        ),
      ],
    );
  }

  void _exportStudySheet() {
    final q = _currentQuestion;
    final results = _calculate();
    final buffer = StringBuffer();
    buffer.writeln('# Qalculyn Study Sheet');
    buffer.writeln('## Problem: ${q.title}\n');
    buffer.writeln('**Governing Principle / Formula:**\n`${q.formulaDescription}`\n');
    buffer.writeln('### Input Parameters:');
    for (int i = 0; i < q.inputLabels.length; i++) {
      buffer.writeln('- **${q.inputLabels[i]}**: ${_controllers[i].text}');
    }
    buffer.writeln('\n### Computed Solution:');
    for (final entry in results.entries) {
      buffer.writeln('- **${entry.key}**: ${entry.value}');
    }
    buffer.writeln('\n---\n*Generated offline by Qalculyn Mathematics Suite*');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Study Sheet copied to clipboard as formatted Markdown!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
