// Qalculyn - History Bottom Sheet
// Shows calculation history with search, delete, and reuse functionality

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/theme.dart';
import '../../core/providers/calculator_provider.dart';
import 'package:intl/intl.dart';
import '../calculator/explain_sheet.dart';

class HistorySheet extends StatefulWidget {
  const HistorySheet({super.key});

  @override
  State<HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<HistorySheet> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? QColors.darkSurface : QColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(QRadius.xxl)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: QSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: QRadius.borderRadiusFull,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(QSpacing.lg),
            child: Row(
              children: [
                if (!_isSearching) ...[
                  Text(
                    'History',
                    style: QTypography.headlineMedium(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => setState(() => _isSearching = true),
                    tooltip: 'Search history',
                  ),
                  if (calc.history.isNotEmpty) ...[
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.file_download_outlined),
                      tooltip: 'Export history',
                      onSelected: (val) {
                        if (val == 'csv') {
                          _exportCsv(calc);
                        } else if (val == 'md') {
                          _exportMarkdown(calc);
                        }
                      },
                      itemBuilder: (ctx) => const [
                        PopupMenuItem(
                          value: 'csv',
                          child: Row(
                            children: [
                              Icon(Icons.table_chart_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Export to CSV (Spreadsheet)'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'md',
                          child: Row(
                            children: [
                              Icon(Icons.description_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Export to Markdown Table'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmClearAll(context, calc),
                      tooltip: 'Clear all history',
                    ),
                  ],
                ] else ...[
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search calculations...',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            calc.loadHistory();
                            setState(() => _isSearching = false);
                          },
                        ),
                      ),
                      onChanged: (query) => calc.loadHistory(search: query),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // History list
          Expanded(
            child: calc.history.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: QSpacing.sm),
                    itemCount: calc.history.length,
                    itemBuilder: (context, index) {
                      final entry = calc.history[index];
                      final dateFormat = DateFormat('MMM d, h:mm a');

                      return Dismissible(
                        key: Key('history_${entry.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: QSpacing.xxl),
                          color: QColors.error.withValues(alpha: 0.2),
                          child: const Icon(Icons.delete, color: QColors.error),
                        ),
                        onDismissed: (_) {
                          if (entry.id != null) calc.deleteHistoryEntry(entry.id!);
                        },
                        child: InkWell(
                          onTap: () {
                            calc.reuseExpression(entry.expression);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: QSpacing.xxl,
                              vertical: QSpacing.md,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.expression,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '= ${entry.result}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateFormat.format(entry.timestamp),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.auto_awesome, size: 18, color: Theme.of(context).colorScheme.primary),
                                      tooltip: 'Explain steps',
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (ctx) => ExplainSheet(
                                            expression: entry.expression,
                                            result: entry.result,
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.content_copy, size: 18),
                                      tooltip: 'Copy result',
                                      onPressed: () async {
                                        await Clipboard.setData(ClipboardData(text: entry.result));
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Copied'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.play_arrow, size: 18, color: Theme.of(context).colorScheme.primary),
                                      tooltip: 'Use result',
                                      onPressed: () {
                                        calc.reuseResult(entry.result);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: QSpacing.lg),
          Text(
            _isSearching ? 'No matching calculations' : 'No calculations yet',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: QSpacing.sm),
          Text(
            _isSearching ? 'Try a different search term' : 'Your calculations will appear here',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _exportCsv(CalculatorProvider calc) {
    final buffer = StringBuffer();
    buffer.writeln('Timestamp,Expression,Result');
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    for (final entry in calc.history) {
      final expr = entry.expression.replaceAll('"', '""');
      final res = entry.result.replaceAll('"', '""');
      buffer.writeln('"${dateFormat.format(entry.timestamp)}","$expr","$res"');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculation history exported as CSV (copied to clipboard)')),
    );
  }

  void _exportMarkdown(CalculatorProvider calc) {
    final buffer = StringBuffer();
    buffer.writeln('# Qalculyn Calculation History\n');
    buffer.writeln('| Date & Time | Expression | Result |');
    buffer.writeln('|---|---|---|');
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');
    for (final entry in calc.history) {
      final expr = entry.expression.replaceAll('|', '\\|');
      final res = entry.result.replaceAll('|', '\\|');
      buffer.writeln('| ${dateFormat.format(entry.timestamp)} | `$expr` | **$res** |');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculation history exported as Markdown (copied to clipboard)')),
    );
  }

  void _confirmClearAll(BuildContext context, CalculatorProvider calc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This will permanently delete all calculation history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              calc.clearHistory();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: QColors.error),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }
}
