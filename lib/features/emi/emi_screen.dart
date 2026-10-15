// Qalculyn - EMI (Loan) Calculator
// Calculates monthly EMI, total interest, total payable amount, amortization schedule, and prepayment savings

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_formatter.dart';
import '../../shared/tool_widgets.dart';

class EmiScreen extends StatefulWidget {
  const EmiScreen({super.key});

  @override
  State<EmiScreen> createState() => _EmiScreenState();
}

class _EmiScreenState extends State<EmiScreen> {
  int _selectedMode = 0; // 0: Standard EMI, 1: Prepayment Simulator

  final _amountController = TextEditingController(text: '1000000');
  final _rateController = TextEditingController(text: '8.5');
  final _tenureController = TextEditingController(text: '20');

  // Prepayment inputs
  final _extraMonthlyController = TextEditingController(text: '5000');
  final _oneTimePrepayController = TextEditingController(text: '100000');
  final _oneTimeMonthController = TextEditingController(text: '12');

  bool _isTenureInYears = true;
  final _formatter = const NumberFormatter();

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    _extraMonthlyController.dispose();
    _oneTimePrepayController.dispose();
    _oneTimeMonthController.dispose();
    super.dispose();
  }

  void _showAmortizationSheet(double p, double rAnnual, int n, double emi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final r = rAnnual / (12 * 100);

        // Compute yearly schedule
        final yearlySchedule = <_YearlyAmortization>[];
        var currentBalance = p;
        var totalInterestAccum = 0.0;

        var year = 1;
        var yearPrincipal = 0.0;
        var yearInterest = 0.0;

        for (var m = 1; m <= n && currentBalance > 0.01; m++) {
          final interestMonth = currentBalance * r;
          final principalMonth = min(emi - interestMonth, currentBalance);
          currentBalance = max(0.0, currentBalance - principalMonth);

          yearPrincipal += principalMonth;
          yearInterest += interestMonth;
          totalInterestAccum += interestMonth;

          if (m % 12 == 0 || m == n || currentBalance <= 0.01) {
            yearlySchedule.add(_YearlyAmortization(
              year: year,
              principalPaid: yearPrincipal,
              interestPaid: yearInterest,
              endingBalance: currentBalance,
            ));
            year++;
            yearPrincipal = 0.0;
            yearInterest = 0.0;
          }
        }

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.82,
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
                    'Annual Amortization Schedule',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              // Summary row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Principal: ${_formatter.format(p)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Total Interest: ${_formatter.format(totalInterestAccum)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Schedule List
              Expanded(
                child: ListView.separated(
                  itemCount: yearlySchedule.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = yearlySchedule[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: QColors.primaryPurple.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Year ${item.year}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: QColors.primaryPurple),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Principal: ${_formatter.format(item.principalPaid)}', style: const TextStyle(fontSize: 13)),
                                    Text('Interest: ${_formatter.format(item.interestPaid)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ending Balance: ${_formatter.format(item.endingBalance)}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Copy to clipboard
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final buf = StringBuffer();
                    buf.writeln('Year,Principal Paid,Interest Paid,Ending Balance');
                    for (final item in yearlySchedule) {
                      buf.writeln('${item.year},${item.principalPaid.toStringAsFixed(2)},${item.interestPaid.toStringAsFixed(2)},${item.endingBalance.toStringAsFixed(2)}');
                    }
                    Clipboard.setData(ClipboardData(text: buf.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amortization schedule copied as CSV')));
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy Schedule as CSV'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, String> _calculate() {
    final p = double.tryParse(_amountController.text.replaceAll(',', ''));
    final rAnnual = double.tryParse(_rateController.text);
    final tenure = double.tryParse(_tenureController.text);

    if (p == null || rAnnual == null || tenure == null || p <= 0 || rAnnual < 0 || tenure <= 0) {
      return {'Monthly EMI': '—', 'Total Interest': '—', 'Total Payment': '—'};
    }

    final n = _isTenureInYears ? (tenure * 12).round() : tenure.round();
    if (n <= 0) {
      return {'Error': 'Tenure must be greater than 0'};
    }

    if (rAnnual == 0) {
      final emi = p / n;
      return {
        'Monthly EMI': _formatter.format(emi),
        'Total Interest': _formatter.format(0),
        'Total Payment': _formatter.format(p),
      };
    }

    final r = rAnnual / (12 * 100);
    final powTerm = pow(1 + r, n);
    final emi = (p * r * powTerm) / (powTerm - 1);
    final totalPayment = emi * n;
    final totalInterest = totalPayment - p;

    if (_selectedMode == 0) {
      return {
        'Monthly EMI': _formatter.format(emi),
        'Principal Amount': _formatter.format(p),
        'Total Interest': _formatter.format(totalInterest),
        'Total Payment': _formatter.format(totalPayment),
        'Total Months': '$n months (${(n / 12).toStringAsFixed(1)} years)',
      };
    } else {
      // Prepayment Simulation
      final extraMonthly = double.tryParse(_extraMonthlyController.text.replaceAll(',', '')) ?? 0.0;
      final lumpSum = double.tryParse(_oneTimePrepayController.text.replaceAll(',', '')) ?? 0.0;
      final lumpMonth = int.tryParse(_oneTimeMonthController.text) ?? 12;

      var balance = p;
      var monthsWithPrepay = 0;
      var interestWithPrepay = 0.0;

      while (balance > 0.01 && monthsWithPrepay < n * 2) {
        monthsWithPrepay++;
        final interestMonth = balance * r;
        interestWithPrepay += interestMonth;

        var payThisMonth = emi + extraMonthly;
        if (monthsWithPrepay == lumpMonth) {
          payThisMonth += lumpSum;
        }

        final principalMonth = min(payThisMonth - interestMonth, balance);
        balance = max(0.0, balance - principalMonth);
      }

      final monthsSaved = max(0, n - monthsWithPrepay);
      final interestSaved = max(0.0, totalInterest - interestWithPrepay);

      return {
        'New Loan Duration': '$monthsWithPrepay months (${(monthsWithPrepay / 12).toStringAsFixed(1)} years)',
        'Time Saved': '$monthsSaved months (${(monthsSaved / 12).toStringAsFixed(1)} years early)',
        'Total Interest Saved': _formatter.format(interestSaved),
        'New Total Interest': _formatter.format(interestWithPrepay),
        'Standard Total Interest': _formatter.format(totalInterest),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    final p = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    final rAnnual = double.tryParse(_rateController.text) ?? 0.0;
    final tenure = double.tryParse(_tenureController.text) ?? 0.0;
    final n = _isTenureInYears ? (tenure * 12).round() : tenure.round();

    double emi = 0.0;
    double totalInterest = 0.0;
    if (p > 0 && rAnnual > 0 && n > 0) {
      final r = rAnnual / (12 * 100);
      final powTerm = pow(1 + r, n);
      emi = (p * r * powTerm) / (powTerm - 1);
      totalInterest = (emi * n) - p;
    }

    return ToolScaffold(
      title: 'EMI & Loan Calculator',
      disclaimer: 'Calculations are estimates based on fixed interest rates. Bank fees and processing charges may vary.',
      children: [
        ToolModeSelector(
          modes: const ['Standard Loan', 'Prepayment Impact'],
          selected: _selectedMode,
          onChanged: (idx) => setState(() => _selectedMode = idx),
        ),
        const SizedBox(height: QSpacing.md),

        ToolTextField(
          controller: _amountController,
          label: 'Loan Amount (Principal)',
          prefix: '₹ / \$ ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _rateController,
          label: 'Annual Interest Rate',
          suffix: '% p.a.',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: ToolTextField(
                controller: _tenureController,
                label: 'Loan Tenure',
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: QSpacing.md),
            Expanded(
              flex: 2,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Years')),
                  ButtonSegment(value: false, label: Text('Mos')),
                ],
                selected: {_isTenureInYears},
                onSelectionChanged: (selected) {
                  setState(() => _isTenureInYears = selected.first);
                },
              ),
            ),
          ],
        ),

        if (_selectedMode == 1) ...[
          const SizedBox(height: QSpacing.lg),
          const Text('Prepayment Strategy', style: TextStyle(fontWeight: FontWeight.bold, color: QColors.primaryPurple)),
          const SizedBox(height: QSpacing.sm),
          ToolTextField(
            controller: _extraMonthlyController,
            label: 'Extra Monthly Prepayment',
            prefix: '₹ / \$ ',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: QSpacing.md),
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                  controller: _oneTimePrepayController,
                  label: 'One-Time Lump Sum',
                  prefix: '₹ / \$ ',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: QSpacing.md),
              Expanded(
                child: ToolTextField(
                  controller: _oneTimeMonthController,
                  label: 'In Month #',
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: QSpacing.lg),

        // Visual Proportion Bar: Principal vs Interest
        if (p > 0 && totalInterest > 0) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: (p / (p + totalInterest) * 100).round(),
                    child: Container(color: QColors.primaryPurple),
                  ),
                  Expanded(
                    flex: (totalInterest / (p + totalInterest) * 100).round(),
                    child: Container(color: Colors.amber),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: QColors.primaryPurple, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Principal: ${(p / (p + totalInterest) * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11)),
                ],
              ),
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Interest: ${(totalInterest / (p + totalInterest) * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: QSpacing.md),
        ],

        // Action to view full amortization schedule
        if (emi > 0) ...[
          ElevatedButton.icon(
            onPressed: () => _showAmortizationSheet(p, rAnnual, n, emi),
            icon: const Icon(Icons.table_chart_outlined),
            label: const Text('View Annual Amortization Table'),
            style: ElevatedButton.styleFrom(
              backgroundColor: QColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: QSpacing.md),
        ],

        ToolResultCard(
          title: _selectedMode == 0 ? 'Repayment Summary' : 'Prepayment Savings Summary',
          results: results,
        ),
      ],
    );
  }
}

class _YearlyAmortization {
  final int year;
  final double principalPaid;
  final double interestPaid;
  final double endingBalance;

  const _YearlyAmortization({
    required this.year,
    required this.principalPaid,
    required this.interestPaid,
    required this.endingBalance,
  });
}
