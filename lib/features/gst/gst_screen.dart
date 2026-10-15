// Qalculyn - GST Calculator
// Indian GST calculations with CGST/SGST and IGST support

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_formatter.dart';
import '../../shared/tool_widgets.dart';

class GstScreen extends StatefulWidget {
  const GstScreen({super.key});

  @override
  State<GstScreen> createState() => _GstScreenState();
}

class _GstScreenState extends State<GstScreen> {
  final _amountCtrl = TextEditingController();
  final _customRateCtrl = TextEditingController();
  final _formatter = const NumberFormatter();
  double _gstRate = 18;
  bool _isInclusive = false;
  bool _isInterState = false;
  bool _useCustomRate = false;

  static const _commonRates = [0.0, 5.0, 12.0, 18.0, 28.0];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _customRateCtrl.dispose();
    super.dispose();
  }

  double get _effectiveRate {
    if (_useCustomRate) return double.tryParse(_customRateCtrl.text) ?? 0;
    return _gstRate;
  }

  Map<String, String> _calculate() {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return {};

    final rate = _effectiveRate;
    if (rate < 0) return {'Error': 'Rate cannot be negative'};

    double baseAmount;
    double gstAmount;
    double totalAmount;

    if (_isInclusive) {
      // Amount includes GST
      baseAmount = amount / (1 + rate / 100);
      gstAmount = amount - baseAmount;
      totalAmount = amount;
    } else {
      // Amount excludes GST
      baseAmount = amount;
      gstAmount = amount * rate / 100;
      totalAmount = amount + gstAmount;
    }

    final results = <String, String>{
      'Base amount': '₹${_formatter.format(baseAmount)}',
    };

    if (_isInterState) {
      results['IGST (${_formatter.format(rate)}%)'] = '₹${_formatter.format(gstAmount)}';
    } else {
      final half = gstAmount / 2;
      results['CGST (${_formatter.format(rate / 2)}%)'] = '₹${_formatter.format(half)}';
      results['SGST (${_formatter.format(rate / 2)}%)'] = '₹${_formatter.format(half)}';
    }

    results['Total GST'] = '₹${_formatter.format(gstAmount)}';
    results['Total amount'] = '₹${_formatter.format(totalAmount)}';

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();
    return ToolScaffold(
      title: 'GST Calculator',
      disclaimer: 'This is a calculation tool for estimation purposes only. It does not constitute tax or legal advice. Consult a qualified tax professional for official calculations.',
      children: [
        // Inclusive/Exclusive toggle
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('GST Exclusive'),
                selected: !_isInclusive,
                onSelected: (_) => setState(() => _isInclusive = false),
                selectedColor: QColors.primaryPurple.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(width: QSpacing.sm),
            Expanded(
              child: ChoiceChip(
                label: const Text('GST Inclusive'),
                selected: _isInclusive,
                onSelected: (_) => setState(() => _isInclusive = true),
                selectedColor: QColors.primaryPurple.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
        const SizedBox(height: QSpacing.lg),

        // Amount
        ToolTextField(
          controller: _amountCtrl,
          label: _isInclusive ? 'Amount (inclusive of GST)' : 'Amount (before GST)',
          prefix: '₹ ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.lg),

        // Rate selection
        Text('GST Rate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: QSpacing.sm),
        Wrap(
          spacing: QSpacing.sm,
          runSpacing: QSpacing.sm,
          children: [
            ..._commonRates.map((rate) => ChoiceChip(
              label: Text('${rate.toInt()}%'),
              selected: !_useCustomRate && _gstRate == rate,
              onSelected: (_) => setState(() {
                _gstRate = rate;
                _useCustomRate = false;
              }),
              selectedColor: QColors.primaryPurple.withValues(alpha: 0.2),
            )),
            ChoiceChip(
              label: const Text('Custom'),
              selected: _useCustomRate,
              onSelected: (_) => setState(() => _useCustomRate = true),
              selectedColor: QColors.primaryPurple.withValues(alpha: 0.2),
            ),
          ],
        ),

        if (_useCustomRate) ...[
          const SizedBox(height: QSpacing.md),
          ToolTextField(
            controller: _customRateCtrl,
            label: 'Custom GST rate',
            suffix: '%',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
        ],

        const SizedBox(height: QSpacing.lg),

        // Intra/Inter state
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Intra-state (CGST+SGST)'),
                selected: !_isInterState,
                onSelected: (_) => setState(() => _isInterState = false),
                selectedColor: QColors.primaryPurple.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(width: QSpacing.sm),
            Expanded(
              child: ChoiceChip(
                label: const Text('Inter-state (IGST)'),
                selected: _isInterState,
                onSelected: (_) => setState(() => _isInterState = true),
                selectedColor: QColors.primaryPurple.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),

        if (results.isNotEmpty) ...[
          const SizedBox(height: QSpacing.xxl),
          ToolResultCard(results: results, title: 'GST Breakdown'),
        ],
      ],
    );
  }
}
