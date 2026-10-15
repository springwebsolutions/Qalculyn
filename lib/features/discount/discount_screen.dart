// Qalculyn - Discount & Shopping Savings Calculator
// Standard discount, stacked / double discounts, sales tax, and effective discount rate

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_formatter.dart';
import '../../shared/tool_widgets.dart';

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({super.key});

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  int _selectedMode = 0; // 0: Standard, 1: Stacked / Double Discount
  String _currencySymbol = '₹';

  final _priceCtrl = TextEditingController(text: '2500');
  final _discount1Ctrl = TextEditingController(text: '40');
  final _discount2Ctrl = TextEditingController(text: '15');
  final _taxCtrl = TextEditingController(text: '5');
  bool _taxAfterDiscount = true;
  final _formatter = const NumberFormatter();

  @override
  void dispose() {
    _priceCtrl.dispose();
    _discount1Ctrl.dispose();
    _discount2Ctrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  Map<String, String> _calculate() {
    final price = double.tryParse(_priceCtrl.text.replaceAll(',', ''));
    final d1 = double.tryParse(_discount1Ctrl.text);

    if (price == null || d1 == null) return {};
    if (price < 0) return {'Error': 'Price cannot be negative'};
    if (d1 < 0 || d1 > 100) return {'Error': 'Discount 1 must be between 0% and 100%'};

    final sym = _currencySymbol;

    if (_selectedMode == 0) {
      // Standard single discount
      final discountAmt = price * d1 / 100.0;
      final afterDiscount = price - discountAmt;
      final tax = double.tryParse(_taxCtrl.text) ?? 0.0;

      double finalPrice;
      double taxAmount;

      if (tax > 0) {
        if (_taxAfterDiscount) {
          taxAmount = afterDiscount * tax / 100.0;
          finalPrice = afterDiscount + taxAmount;
        } else {
          taxAmount = price * tax / 100.0;
          finalPrice = (price + taxAmount) - discountAmt;
        }
      } else {
        taxAmount = 0.0;
        finalPrice = afterDiscount;
      }

      final savings = price - afterDiscount;

      final results = <String, String>{
        'Final Price to Pay': '$sym${_formatter.format(finalPrice)}',
        'Total Money Saved': '$sym${_formatter.format(savings)}',
        'Original Price': '$sym${_formatter.format(price)}',
        'Discount Applied': '-$sym${_formatter.format(discountAmt)} (${_formatter.format(d1)}%)',
        'Price After Discount': '$sym${_formatter.format(afterDiscount)}',
      };

      if (tax > 0) {
        results['Sales Tax (${_formatter.format(tax)}%)'] = '+$sym${_formatter.format(taxAmount)}';
        results['Tax Order'] = _taxAfterDiscount ? 'Calculated after discount' : 'Calculated before discount';
      }

      return results;
    } else {
      // Stacked / Double discount
      final d2 = double.tryParse(_discount2Ctrl.text) ?? 0.0;
      if (d2 < 0 || d2 > 100) return {'Error': 'Additional coupon must be between 0% and 100%'};

      // First discount
      final discount1Amt = price * d1 / 100.0;
      final priceAfter1 = price - discount1Amt;

      // Second stacked discount on the remaining price
      final discount2Amt = priceAfter1 * d2 / 100.0;
      final finalDiscountedPrice = priceAfter1 - discount2Amt;

      // Total effective discount rate
      final totalSaved = discount1Amt + discount2Amt;
      final effectiveRate = (totalSaved / price) * 100.0;

      // Tax calculation
      final tax = double.tryParse(_taxCtrl.text) ?? 0.0;
      final taxAmt = tax > 0 ? (finalDiscountedPrice * tax / 100.0) : 0.0;
      final finalPayable = finalDiscountedPrice + taxAmt;

      final results = <String, String>{
        'Final Price to Pay': '$sym${_formatter.format(finalPayable)}',
        'Total Money Saved': '$sym${_formatter.format(totalSaved)}',
        'Effective Overall Discount': '${effectiveRate.toStringAsFixed(1)}% (Not ${(d1 + d2).toStringAsFixed(0)}%)',
        'Original Price': '$sym${_formatter.format(price)}',
        'Primary Discount (${_formatter.format(d1)}%)': '-$sym${_formatter.format(discount1Amt)}',
        'Price After 1st Discount': '$sym${_formatter.format(priceAfter1)}',
        'Stacked Coupon (${_formatter.format(d2)}%)': '-$sym${_formatter.format(discount2Amt)}',
      };

      if (tax > 0) {
        results['Sales Tax (${_formatter.format(tax)}%)'] = '+$sym${_formatter.format(taxAmt)}';
      }

      return results;
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    return ToolScaffold(
      title: 'Discount & Shopping Savings',
      disclaimer: 'Calculates single and stacked retail discounts. Stacked discounts apply sequentially to the reduced balance.',
      children: [
        ToolModeSelector(
          modes: const ['Single Discount', 'Stacked Double Discount'],
          selected: _selectedMode,
          onChanged: (idx) => setState(() => _selectedMode = idx),
        ),
        const SizedBox(height: QSpacing.md),

        // Currency selection row
        Row(
          children: [
            const Text('Currency:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Wrap(
              spacing: 6,
              children: ['₹', '\$', '€', '£'].map((sym) {
                final isSelected = _currencySymbol == sym;
                return ChoiceChip(
                  label: Text(sym),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _currencySymbol = sym),
                  selectedColor: QColors.primaryPurple.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: QSpacing.md),

        ToolTextField(
          controller: _priceCtrl,
          label: 'Original Item Price',
          prefix: '$_currencySymbol ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),

        ToolTextField(
          controller: _discount1Ctrl,
          label: _selectedMode == 0 ? 'Discount Rate' : 'Primary Store Discount',
          suffix: '%',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),

        if (_selectedMode == 1) ...[
          ToolTextField(
            controller: _discount2Ctrl,
            label: 'Additional Stacked Coupon (VIP / Promo)',
            suffix: '%',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: QSpacing.md),
        ],

        ToolTextField(
          controller: _taxCtrl,
          label: 'Sales Tax / VAT (Optional)',
          suffix: '%',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),

        if (_selectedMode == 0 && _taxCtrl.text.isNotEmpty && (double.tryParse(_taxCtrl.text) ?? 0) > 0)
          Padding(
            padding: const EdgeInsets.only(top: QSpacing.sm),
            child: Row(
              children: [
                Text('Apply tax:', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(width: QSpacing.sm),
                ChoiceChip(
                  label: const Text('After discount'),
                  selected: _taxAfterDiscount,
                  onSelected: (_) => setState(() => _taxAfterDiscount = true),
                  selectedColor: QColors.primaryPurple.withValues(alpha: 0.2),
                ),
                const SizedBox(width: QSpacing.sm),
                ChoiceChip(
                  label: const Text('Before discount'),
                  selected: !_taxAfterDiscount,
                  onSelected: (_) => setState(() => _taxAfterDiscount = false),
                  selectedColor: QColors.primaryPurple.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),

        if (results.isNotEmpty) ...[
          const SizedBox(height: QSpacing.xxl),
          ToolResultCard(
            results: results,
            title: _selectedMode == 0 ? 'Discount Breakdown' : 'Stacked Savings Breakdown',
          ),
        ],
      ],
    );
  }
}
