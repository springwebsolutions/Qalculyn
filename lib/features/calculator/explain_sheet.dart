// Qalculyn - Problem Explanation & Step Breakdown Sheet
// Displays pure mathematical steps without explanation clutter, with user explanation note editor

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/expression_explainer.dart';

class ExplainSheet extends StatefulWidget {
  final String expression;
  final String result;

  const ExplainSheet({
    super.key,
    required this.expression,
    required this.result,
  });

  @override
  State<ExplainSheet> createState() => _ExplainSheetState();
}

class _ExplainSheetState extends State<ExplainSheet> {
  String _userNote = '';
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showAddNoteDialog() {
    _noteController.text = _userNote;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add / Edit Custom Explanation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add your personal study notes, reminders, or step explanation for this problem:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: QSpacing.sm),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g. Remember to evaluate multiplication before addition...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _userNote = '');
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _userNote = _noteController.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final steps = ExpressionExplainer.explain(widget.expression);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.all(QSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? QColors.darkSurface : QColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(QRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: QSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 20, color: primary),
                  const SizedBox(width: QSpacing.sm),
                  Text(
                    'Step-by-Step Explanation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy all steps',
                onPressed: () {
                  final text = steps.join('\n') + (_userNote.isNotEmpty ? '\n\nNote: $_userNote' : '');
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Steps copied to clipboard')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: QSpacing.sm),

          // Problem card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(QSpacing.md),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: QRadius.borderRadiusMd,
              border: Border.all(color: primary.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.expression,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '= ${widget.result}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.md),

          // Steps list (pure mathematical steps without fluff)
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: steps.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final isFinal = idx == steps.length - 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isFinal ? primary : primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isFinal ? Colors.white : primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: QSpacing.sm),
                      Expanded(
                        child: SelectableText(
                          steps[idx],
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: isFinal ? 15 : 13,
                            fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
                            color: isFinal ? primary : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: QSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: QSpacing.sm),

          // User Custom Note Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Explanation / Notes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit_note, size: 16),
                label: Text(_userNote.isEmpty ? 'Add Explanation' : 'Edit Explanation', style: const TextStyle(fontSize: 12)),
                onPressed: _showAddNoteDialog,
              ),
            ],
          ),

          if (_userNote.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(QSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? QColors.darkCard : QColors.lightCard,
                borderRadius: QRadius.borderRadiusSm,
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.sticky_note_2_outlined, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Text('Your Custom Note:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    _userNote,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
