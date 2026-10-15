// Qalculyn - Shared Tool Widgets
// Reusable UI components for all tool calculators

import 'package:flutter/material.dart';
import '../core/design_system/theme.dart';

/// Scaffold wrapper for tool screens with consistent styling
class ToolScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final String? disclaimer;

  const ToolScaffold({
    super.key,
    required this.title,
    required this.children,
    this.disclaimer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(QSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...children,
            if (disclaimer != null) ...[
              const SizedBox(height: QSpacing.xxl),
              Container(
                padding: const EdgeInsets.all(QSpacing.md),
                decoration: BoxDecoration(
                  color: QColors.info.withValues(alpha: 0.08),
                  borderRadius: QRadius.borderRadiusMd,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: QColors.info),
                    const SizedBox(width: QSpacing.sm),
                    Expanded(
                      child: Text(
                        disclaimer!,
                        style: TextStyle(
                          fontSize: 12,
                          color: QColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Text field with consistent styling for tool inputs
class ToolTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final String? prefix;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final bool? enabled;

  const ToolTextField({
    super.key,
    required this.controller,
    required this.label,
    this.suffix,
    this.prefix,
    this.keyboardType,
    this.onChanged,
    this.readOnly = false,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        filled: true,
        fillColor: isDark ? QColors.darkSurfaceVariant : QColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: QRadius.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: QRadius.borderRadiusMd,
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: QSpacing.lg, vertical: QSpacing.lg),
      ),
      onChanged: onChanged,
    );
  }
}

/// Mode selector chips for tools with multiple calculation modes
class ToolModeSelector extends StatelessWidget {
  final List<String> modes;
  final int selected;
  final ValueChanged<int> onChanged;

  const ToolModeSelector({
    super.key,
    required this.modes,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Wrap(
      spacing: QSpacing.sm,
      runSpacing: QSpacing.sm,
      children: List.generate(modes.length, (i) {
        final isSelected = i == selected;
        return ChoiceChip(
          label: Text(modes[i]),
          selected: isSelected,
          onSelected: (_) => onChanged(i),
          selectedColor: primary.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? primary : Theme.of(context).colorScheme.onSurface,
          ),
          shape: RoundedRectangleBorder(borderRadius: QRadius.borderRadiusSm),
          side: BorderSide(
            color: isSelected ? primary.withValues(alpha: 0.5) : Colors.transparent,
          ),
        );
      }),
    );
  }
}

/// Clean human-readable error messages for everyday users.
/// Completely eliminates parser, compiler, syntax, and exception leakage.
String cleanMathErrorMessage(Object? error, {String fallback = 'Please enter valid numbers'}) {
  if (error == null) return fallback;
  var msg = error.toString().trim();
  msg = msg.replaceAll('FormatException: ', '');
  msg = msg.replaceAll('Exception: ', '');

  if (msg.isEmpty) return fallback;

  if (msg.contains('Invalid radix-10') ||
      msg.contains('Invalid double') ||
      msg.contains('Invalid number') ||
      msg.contains('Empty rational string') ||
      msg.contains('Could not parse') ||
      msg.contains('Invalid fraction format')) {
    return 'Please enter valid numbers';
  }

  if (msg.contains('Division by zero') || msg.contains('Denominator cannot be zero')) {
    return 'Cannot divide by zero';
  }

  if (msg.contains('TokenType') || msg.contains('got ') || msg.contains('Incomplete')) {
    return 'Incomplete calculation';
  }

  if (msg.contains('Unexpected character') || msg.contains('Unknown operator')) {
    return 'Unrecognized symbol in input';
  }

  final atIndex = msg.indexOf(' (at character');
  if (atIndex != -1) {
    msg = msg.substring(0, atIndex).trim();
  }

  return msg.isNotEmpty ? msg : fallback;
}

/// Result display card for tool calculations
class ToolResultCard extends StatelessWidget {
  final Map<String, String> results;
  final String? title;

  const ToolResultCard({
    super.key,
    required this.results,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final hasError = results.containsKey('Error') || results.containsKey('error');

    return Container(
      padding: const EdgeInsets.all(QSpacing.lg),
      decoration: BoxDecoration(
        color: hasError
            ? QColors.error.withValues(alpha: 0.08)
            : (isDark ? QColors.darkCard : QColors.lightElevated),
        borderRadius: QRadius.borderRadiusLg,
        border: Border.all(
          color: hasError
              ? QColors.error.withValues(alpha: 0.3)
              : primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
            const SizedBox(height: QSpacing.md),
          ],
          ...results.entries.map((e) {
            final isMain = e.key == results.keys.first && !hasError;
            var valText = e.value;
            if (hasError || valText.contains('FormatException') || valText.contains('Exception:')) {
              valText = cleanMathErrorMessage(valText, fallback: 'Please check your input values');
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: QSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      e.key,
                      style: TextStyle(
                        fontSize: 14,
                        color: hasError ? QColors.error : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: QSpacing.sm),
                  Expanded(
                    flex: 5,
                    child: Text(
                      valText,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: isMain ? 18 : 15,
                        fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
                        color: hasError ? QColors.error : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Dropdown selector for tool options
class ToolDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;

  const ToolDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? QColors.darkSurfaceVariant : QColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: QRadius.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: QSpacing.lg, vertical: QSpacing.xs),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items.map((item) => DropdownMenuItem<T>(
            value: item,
            child: Text(labelBuilder(item)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
