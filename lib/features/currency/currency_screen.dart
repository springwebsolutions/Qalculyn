// Qalculyn - Offline Currency Converter
// 100% offline currency calculator with customizable exchange rates

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_formatter.dart';
import '../../shared/tool_widgets.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final _amountController = TextEditingController(text: '100');
  final _rateController = TextEditingController(text: '83.50');

  String _fromCurrency = 'USD';
  String _toCurrency = 'INR';

  final _formatter = NumberFormatter();

  static const _popularCurrencies = [
    'USD - US Dollar',
    'INR - Indian Rupee',
    'EUR - Euro',
    'GBP - British Pound',
    'JPY - Japanese Yen',
    'CAD - Canadian Dollar',
    'AUD - Australian Dollar',
    'CHF - Swiss Franc',
    'CNY - Chinese Yuan',
    'SGD - Singapore Dollar',
    'AED - UAE Dirham',
  ];

  static final Map<String, double> _approxRatesToUsd = {
    'USD': 1.0,
    'INR': 83.50,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 155.0,
    'CAD': 1.36,
    'AUD': 1.52,
    'CHF': 0.91,
    'CNY': 7.23,
    'SGD': 1.35,
    'AED': 3.67,
  };

  @override
  void initState() {
    super.initState();
    _updateRateFromDefaults();
  }

  void _updateRateFromDefaults() {
    final fromUsd = _approxRatesToUsd[_fromCurrency] ?? 1.0;
    final toUsd = _approxRatesToUsd[_toCurrency] ?? 1.0;
    final rate = toUsd / fromUsd;
    _rateController.text = rate < 0.01 ? rate.toStringAsFixed(6) : rate.toStringAsFixed(4);
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _updateRateFromDefaults();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Map<String, String> _calculate() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    final rate = double.tryParse(_rateController.text);

    if (amount == null || rate == null) {
      return {'Converted': '—', 'Rate': '—'};
    }

    final converted = amount * rate;
    return {
      'Converted Amount': '${_formatter.format(converted)} $_toCurrency',
      'Original Amount': '${_formatter.format(amount)} $_fromCurrency',
      'Exchange Rate': '1 $_fromCurrency = $rate $_toCurrency',
    };
  }

  @override
  Widget build(BuildContext context) {
    final results = _calculate();

    return ToolScaffold(
      title: 'Currency Converter',
      disclaimer: '100% Offline: Reference rates are approximate guidelines. You can edit the exchange rate directly for precise calculations.',
      children: [
        // Currency selector row
        Row(
          children: [
            Expanded(
              child: _buildCurrencyPicker('From', _fromCurrency, (val) {
                setState(() {
                  _fromCurrency = val;
                  _updateRateFromDefaults();
                });
              }),
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: QColors.primaryPurple),
              onPressed: _swapCurrencies,
              tooltip: 'Swap currencies',
            ),
            Expanded(
              child: _buildCurrencyPicker('To', _toCurrency, (val) {
                setState(() {
                  _toCurrency = val;
                  _updateRateFromDefaults();
                });
              }),
            ),
          ],
        ),
        const SizedBox(height: QSpacing.lg),
        ToolTextField(
          controller: _amountController,
          label: 'Amount ($_fromCurrency)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.md),
        ToolTextField(
          controller: _rateController,
          label: 'Custom Exchange Rate (1 $_fromCurrency = ? $_toCurrency)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: QSpacing.xl),
        ToolResultCard(
          title: 'Conversion Summary',
          results: results,
        ),
      ],
    );
  }

  Widget _buildCurrencyPicker(String label, String value, ValueChanged<String> onChanged) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: QSpacing.xs),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: _popularCurrencies.map((c) {
            final code = c.split(' - ').first;
            return DropdownMenuItem<String>(
              value: code,
              child: Text(code, style: const TextStyle(fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}
