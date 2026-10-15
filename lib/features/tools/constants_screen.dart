// Qalculyn - Scientific Constants Browser Screen
// Searchable catalog with category filtering, value copy, and one-tap insert into the main calculator

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/constants_catalog.dart';
import '../../core/providers/calculator_provider.dart';

class ConstantsScreen extends StatefulWidget {
  const ConstantsScreen({super.key});

  @override
  State<ConstantsScreen> createState() => _ConstantsScreenState();
}

class _ConstantsScreenState extends State<ConstantsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final filtered = ConstantsCatalog.all.where((c) {
      final matchesCategory = _selectedCategory == 'All' || c.category == _selectedCategory;
      final q = _searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.symbol.toLowerCase().contains(q) ||
          c.unit.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scientific Constants'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(QSpacing.lg, QSpacing.md, QSpacing.lg, QSpacing.sm),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by name, symbol (c, G, h, e) or unit...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? QColors.darkCard : QColors.lightCard,
                border: OutlineInputBorder(
                  borderRadius: QRadius.borderRadiusMd,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: QSpacing.sm),
              ),
            ),
          ),

          // Category Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: QSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: ConstantsCatalog.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: QSpacing.xs),
              itemBuilder: (ctx, idx) {
                final cat = ConstantsCatalog.categories[idx];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  selected: isSelected,
                  selectedColor: primary.withValues(alpha: 0.18),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: QSpacing.xs),

          // Count Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: QSpacing.lg, vertical: QSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} Constants',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Tap to insert or copy',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),

          // Constants List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No constants found',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(QSpacing.lg, QSpacing.xs, QSpacing.lg, QSpacing.xl),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: QSpacing.sm),
                    itemBuilder: (ctx, idx) {
                      final c = filtered[idx];
                      return Container(
                        padding: const EdgeInsets.all(QSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? QColors.darkCard : QColors.lightCard,
                          borderRadius: QRadius.borderRadiusMd,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Symbol badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.12),
                                    borderRadius: QRadius.borderRadiusSm,
                                  ),
                                  child: Text(
                                    c.symbol,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                      fontFamily: 'serif',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: QSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c.category,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: QSpacing.sm),

                            // Value display
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: QSpacing.xs),
                              decoration: BoxDecoration(
                                color: isDark ? QColors.darkSurfaceVariant : QColors.lightSurfaceVariant,
                                borderRadius: QRadius.borderRadiusSm,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      c.formattedValue,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    c.unit,
                                    style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: QSpacing.xs),

                            // Description
                            Text(
                              c.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: QSpacing.sm),

                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.copy_outlined, size: 14),
                                  label: const Text('Copy Value', style: TextStyle(fontSize: 12)),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Clipboard.setData(ClipboardData(text: c.value.toString()));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${c.symbol} value copied to clipboard'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: QSpacing.xs),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.input, size: 14),
                                  label: const Text('Insert in Calc', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    final calc = context.read<CalculatorProvider>();
                                    calc.inputConstant(c.value.toString());
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Inserted ${c.name} (${c.symbol}) into calculation'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
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
  }
}
