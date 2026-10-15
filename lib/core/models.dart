// Qalculyn - Data Models

/// Represents a calculation history entry
class HistoryEntry {
  final int? id;
  final String expression;
  final String result;
  final double? resultValue;
  final DateTime timestamp;
  final String calculatorType;

  const HistoryEntry({
    this.id,
    required this.expression,
    required this.result,
    this.resultValue,
    required this.timestamp,
    this.calculatorType = 'basic',
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'expression': expression,
    'result': result,
    'result_value': resultValue,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'calculator_type': calculatorType,
  };

  factory HistoryEntry.fromMap(Map<String, dynamic> map) => HistoryEntry(
    id: map['id'] as int?,
    expression: map['expression'] as String,
    result: map['result'] as String,
    resultValue: map['result_value'] as double?,
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    calculatorType: map['calculator_type'] as String? ?? 'basic',
  );

  HistoryEntry copyWith({
    int? id,
    String? expression,
    String? result,
    double? resultValue,
    DateTime? timestamp,
    String? calculatorType,
  }) => HistoryEntry(
    id: id ?? this.id,
    expression: expression ?? this.expression,
    result: result ?? this.result,
    resultValue: resultValue ?? this.resultValue,
    timestamp: timestamp ?? this.timestamp,
    calculatorType: calculatorType ?? this.calculatorType,
  );
}

/// Unit conversion model
class UnitCategory {
  final String name;
  final String icon;
  final List<UnitDef> units;

  const UnitCategory({
    required this.name,
    required this.icon,
    required this.units,
  });
}

class UnitDef {
  final String name;
  final String abbreviation;
  final double toBase; // Multiplier to convert TO base unit
  final double fromBase; // Multiplier to convert FROM base unit
  final double Function(double)? customToBase; // For non-linear (e.g., temperature)
  final double Function(double)? customFromBase;

  const UnitDef({
    required this.name,
    required this.abbreviation,
    this.toBase = 1.0,
    this.fromBase = 1.0,
    this.customToBase,
    this.customFromBase,
  });

  double convertToBase(double value) {
    if (customToBase != null) return customToBase!(value);
    return value * toBase;
  }

  double convertFromBase(double value) {
    if (customFromBase != null) return customFromBase!(value);
    return value * fromBase;
  }
}

/// Tool definition
class ToolDef {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;

  const ToolDef({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
  });
}
