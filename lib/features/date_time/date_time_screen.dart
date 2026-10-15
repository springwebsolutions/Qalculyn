// Qalculyn - Date & Time Calculator

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../shared/tool_widgets.dart';
import 'package:intl/intl.dart';

class DateTimeScreen extends StatefulWidget {
  const DateTimeScreen({super.key});

  @override
  State<DateTimeScreen> createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  int _mode = 0;
  DateTime _date1 = DateTime.now();
  DateTime _date2 = DateTime.now().add(const Duration(days: 30));
  final _daysCtrl = TextEditingController();
  final _weeksCtrl = TextEditingController();
  final _monthsCtrl = TextEditingController();

  static const _modes = ['Date Difference', 'Add/Subtract Days', 'Add Weeks/Months'];
  final _dateFormat = DateFormat('MMM d, yyyy');

  @override
  void dispose() {
    _daysCtrl.dispose();
    _weeksCtrl.dispose();
    _monthsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, DateTime current, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  Map<String, String> _calculate() {
    switch (_mode) {
      case 0: // Date difference
        final diff = _date2.difference(_date1);
        final days = diff.inDays.abs();
        final weeks = days ~/ 7;
        final remainingDays = days % 7;

        // Calculate months and years
        int years = 0;
        int months = 0;
        DateTime start = _date1.isBefore(_date2) ? _date1 : _date2;
        DateTime end = _date1.isBefore(_date2) ? _date2 : _date1;

        years = end.year - start.year;
        months = end.month - start.month;
        int daysRem = end.day - start.day;

        if (daysRem < 0) {
          months--;
          final prevMonth = DateTime(end.year, end.month, 0);
          daysRem += prevMonth.day;
        }
        if (months < 0) {
          years--;
          months += 12;
        }

        return {
          'Total days': '$days days',
          'Weeks & days': '$weeks weeks, $remainingDays days',
          'Breakdown': '$years years, $months months, $daysRem days',
          'Hours': '${diff.inHours.abs()} hours',
        };

      case 1: // Add/subtract days
        final days = int.tryParse(_daysCtrl.text) ?? 0;
        final resultDate = _date1.add(Duration(days: days));
        return {
          'Start date': _dateFormat.format(_date1),
          'Days': '$days',
          'Result date': _dateFormat.format(resultDate),
          'Day of week': DateFormat('EEEE').format(resultDate),
        };

      case 2: // Add weeks/months
        final weeks = int.tryParse(_weeksCtrl.text) ?? 0;
        final months = int.tryParse(_monthsCtrl.text) ?? 0;
        var result = _date1.add(Duration(days: weeks * 7));
        // Add months properly
        var newMonth = result.month + months;
        var newYear = result.year;
        while (newMonth > 12) {
          newMonth -= 12;
          newYear++;
        }
        while (newMonth < 1) {
          newMonth += 12;
          newYear--;
        }
        // Clamp day to valid range for the target month
        final maxDay = DateTime(newYear, newMonth + 1, 0).day;
        final clampedDay = result.day > maxDay ? maxDay : result.day;
        result = DateTime(newYear, newMonth, clampedDay);

        return {
          'Start date': _dateFormat.format(_date1),
          'Added': '$weeks weeks, $months months',
          'Result date': _dateFormat.format(result),
          'Day of week': DateFormat('EEEE').format(result),
        };

      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    return ToolScaffold(
      title: 'Date & Time Calculator',
      children: [
        ToolModeSelector(
          modes: _modes,
          selected: _mode,
          onChanged: (i) => setState(() => _mode = i),
        ),
        const SizedBox(height: QSpacing.xl),

        // Date 1 selector
        _DateSelector(
          label: _mode == 0 ? 'From date' : 'Start date',
          date: _date1,
          onTap: () => _pickDate(context, _date1, (d) => _date1 = d),
          dateFormat: _dateFormat,
        ),
        const SizedBox(height: QSpacing.md),

        if (_mode == 0) ...[
          _DateSelector(
            label: 'To date',
            date: _date2,
            onTap: () => _pickDate(context, _date2, (d) => _date2 = d),
            dateFormat: _dateFormat,
          ),
        ] else if (_mode == 1) ...[
          ToolTextField(
            controller: _daysCtrl,
            label: 'Days (negative to subtract)',
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            onChanged: (_) => setState(() {}),
          ),
        ] else ...[
          ToolTextField(
            controller: _weeksCtrl,
            label: 'Weeks',
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: QSpacing.md),
          ToolTextField(
            controller: _monthsCtrl,
            label: 'Months',
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            onChanged: (_) => setState(() {}),
          ),
        ],

        if (results.isNotEmpty) ...[
          const SizedBox(height: QSpacing.xxl),
          ToolResultCard(results: results, title: 'Result'),
        ],
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  final DateFormat dateFormat;

  const _DateSelector({
    required this.label,
    required this.date,
    required this.onTap,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: QRadius.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.all(QSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? QColors.darkSurfaceVariant : QColors.lightSurfaceVariant,
          borderRadius: QRadius.borderRadiusMd,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: QColors.primaryPurple),
            const SizedBox(width: QSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  dateFormat.format(date),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
