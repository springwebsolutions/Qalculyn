// Qalculyn - Number Formatting Utilities
// Handles display formatting, precision, thousands separators, etc.

import 'dart:math' as math;

/// Configuration for number display formatting
class NumberFormatConfig {
  final int decimalPlaces;
  final bool useThousandsSeparator;
  final String thousandsSeparator;
  final String decimalSeparator;
  final bool stripTrailingZeros;
  final bool useScientificNotation;
  final int scientificNotationThreshold;

  const NumberFormatConfig({
    this.decimalPlaces = 10,
    this.useThousandsSeparator = true,
    this.thousandsSeparator = ',',
    this.decimalSeparator = '.',
    this.stripTrailingZeros = true,
    this.useScientificNotation = true,
    this.scientificNotationThreshold = 15,
  });

  NumberFormatConfig copyWith({
    int? decimalPlaces,
    bool? useThousandsSeparator,
    String? thousandsSeparator,
    String? decimalSeparator,
    bool? stripTrailingZeros,
    bool? useScientificNotation,
    int? scientificNotationThreshold,
  }) {
    return NumberFormatConfig(
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      useThousandsSeparator: useThousandsSeparator ?? this.useThousandsSeparator,
      thousandsSeparator: thousandsSeparator ?? this.thousandsSeparator,
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      stripTrailingZeros: stripTrailingZeros ?? this.stripTrailingZeros,
      useScientificNotation: useScientificNotation ?? this.useScientificNotation,
      scientificNotationThreshold: scientificNotationThreshold ?? this.scientificNotationThreshold,
    );
  }
}

/// Formats numbers for display
class NumberFormatter {
  final NumberFormatConfig config;

  const NumberFormatter({this.config = const NumberFormatConfig()});

  /// Format a double value for display
  String format(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    // Check if scientific notation is needed
    if (config.useScientificNotation && _needsScientificNotation(value)) {
      return _formatScientific(value);
    }

    // Check if value is an integer
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      final intStr = value.toInt().toString();
      if (config.useThousandsSeparator) {
        return _addThousandsSeparator(intStr);
      }
      return intStr;
    }

    // Format decimal
    String formatted = value.toStringAsFixed(config.decimalPlaces);

    // Strip trailing zeros if configured
    if (config.stripTrailingZeros && formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }

    // Add thousands separator
    if (config.useThousandsSeparator) {
      final parts = formatted.split('.');
      parts[0] = _addThousandsSeparator(parts[0]);
      formatted = parts.join(config.decimalSeparator);
    } else if (config.decimalSeparator != '.') {
      formatted = formatted.replaceAll('.', config.decimalSeparator);
    }

    return formatted;
  }

  /// Format specifically for the result display (may need fewer digits)
  String formatResult(double value) {
    return format(value);
  }

  /// Format for expressions (no thousands separator, keep it parseable)
  String formatForExpression(double value) {
    if (value.isNaN || value.isInfinite) return format(value);

    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    String formatted = value.toStringAsFixed(config.decimalPlaces);
    if (config.stripTrailingZeros && formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }
    return formatted;
  }

  /// Format a currency value
  String formatCurrency(double value, {String symbol = '₹', int decimals = 2}) {
    final negative = value < 0;
    final abs = value.abs();

    String formatted = abs.toStringAsFixed(decimals);
    final parts = formatted.split('.');
    parts[0] = _addThousandsSeparator(parts[0]);
    formatted = parts.join(config.decimalSeparator);

    return '${negative ? "-" : ""}$symbol$formatted';
  }

  /// Format with Indian numbering system (lakhs, crores)
  String formatIndian(double value) {
    if (value.isNaN || value.isInfinite) return format(value);

    final negative = value < 0;
    final abs = value.abs();

    String intPart;
    String? decPart;

    if (abs == abs.truncateToDouble() && abs < 1e15) {
      intPart = abs.toInt().toString();
    } else {
      final formatted = abs.toStringAsFixed(config.decimalPlaces);
      final parts = formatted.split('.');
      intPart = parts[0];
      decPart = parts.length > 1 ? parts[1] : null;

      if (config.stripTrailingZeros && decPart != null) {
        decPart = decPart.replaceAll(RegExp(r'0+$'), '');
        if (decPart.isEmpty) decPart = null;
      }
    }

    intPart = _addIndianSeparator(intPart);

    var result = negative ? '-$intPart' : intPart;
    if (decPart != null) result += '${config.decimalSeparator}$decPart';
    return result;
  }

  bool _needsScientificNotation(double value) {
    if (value == 0) return false;
    final abs = value.abs();
    return abs >= math.pow(10, config.scientificNotationThreshold) || (abs > 0 && abs < 1e-10);
  }

  String _formatScientific(double value) {
    if (value == 0) return '0';

    final exp = (math.log(value.abs()) / math.ln10).floor();
    final mantissa = value / math.pow(10, exp);

    String mantissaStr = mantissa.toStringAsFixed(config.decimalPlaces.clamp(0, 6));
    if (config.stripTrailingZeros && mantissaStr.contains('.')) {
      mantissaStr = mantissaStr.replaceAll(RegExp(r'0+$'), '');
      mantissaStr = mantissaStr.replaceAll(RegExp(r'\.$'), '');
    }

    return '${mantissaStr}E$exp';
  }

  String _addThousandsSeparator(String intPart) {
    final negative = intPart.startsWith('-');
    var digits = negative ? intPart.substring(1) : intPart;

    if (digits.length <= 3) return intPart;

    final buffer = StringBuffer();
    int count = 0;

    for (int i = digits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(config.thousandsSeparator);
      }
      buffer.write(digits[i]);
      count++;
    }

    final result = buffer.toString().split('').reversed.join();
    return negative ? '-$result' : result;
  }

  String _addIndianSeparator(String intPart) {
    if (intPart.length <= 3) return intPart;

    // Last 3 digits, then groups of 2
    final last3 = intPart.substring(intPart.length - 3);
    var remaining = intPart.substring(0, intPart.length - 3);

    final buffer = StringBuffer();
    int count = 0;

    for (int i = remaining.length - 1; i >= 0; i--) {
      if (count > 0 && count % 2 == 0) {
        buffer.write(config.thousandsSeparator);
      }
      buffer.write(remaining[i]);
      count++;
    }

    final result = buffer.toString().split('').reversed.join();
    return '$result${config.thousandsSeparator}$last3';
  }
}
