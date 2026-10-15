// Qalculyn - Unit Converter
// Comprehensive offline unit conversion across all major categories

import 'package:flutter/material.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/number_formatter.dart';
import '../../shared/tool_widgets.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _inputCtrl = TextEditingController();
  final _formatter = const NumberFormatter();
  int _categoryIndex = 0;
  int _fromUnit = 0;
  int _toUnit = 1;

  static final _categories = <_UnitCategory>[
    _UnitCategory('Length', Icons.straighten, [
      _Unit('Meter', 'm', 1),
      _Unit('Kilometer', 'km', 1000),
      _Unit('Centimeter', 'cm', 0.01),
      _Unit('Millimeter', 'mm', 0.001),
      _Unit('Micrometer', 'μm', 1e-6),
      _Unit('Nanometer', 'nm', 1e-9),
      _Unit('Mile', 'mi', 1609.344),
      _Unit('Yard', 'yd', 0.9144),
      _Unit('Foot', 'ft', 0.3048),
      _Unit('Inch', 'in', 0.0254),
      _Unit('Nautical Mile', 'nmi', 1852),
    ]),
    _UnitCategory('Area', Icons.square_foot, [
      _Unit('Square Meter', 'm²', 1),
      _Unit('Square Kilometer', 'km²', 1e6),
      _Unit('Square Centimeter', 'cm²', 1e-4),
      _Unit('Hectare', 'ha', 10000),
      _Unit('Acre', 'ac', 4046.8564224),
      _Unit('Square Mile', 'mi²', 2589988.110336),
      _Unit('Square Yard', 'yd²', 0.83612736),
      _Unit('Square Foot', 'ft²', 0.09290304),
      _Unit('Square Inch', 'in²', 6.4516e-4),
    ]),
    _UnitCategory('Volume', Icons.water_drop_outlined, [
      _Unit('Liter', 'L', 1),
      _Unit('Milliliter', 'mL', 0.001),
      _Unit('Cubic Meter', 'm³', 1000),
      _Unit('Cubic Centimeter', 'cm³', 0.001),
      _Unit('US Gallon', 'gal', 3.785411784),
      _Unit('US Quart', 'qt', 0.946352946),
      _Unit('US Pint', 'pt', 0.473176473),
      _Unit('US Cup', 'cup', 0.2365882365),
      _Unit('US Fluid Ounce', 'fl oz', 0.0295735295625),
      _Unit('US Tablespoon', 'tbsp', 0.01478676478125),
      _Unit('US Teaspoon', 'tsp', 0.00492892159375),
      _Unit('Imperial Gallon', 'imp gal', 4.54609),
    ]),
    _UnitCategory('Mass', Icons.fitness_center, [
      _Unit('Kilogram', 'kg', 1),
      _Unit('Gram', 'g', 0.001),
      _Unit('Milligram', 'mg', 1e-6),
      _Unit('Metric Ton', 't', 1000),
      _Unit('Pound', 'lb', 0.45359237),
      _Unit('Ounce', 'oz', 0.028349523125),
      _Unit('Stone', 'st', 6.35029318),
      _Unit('US Ton', 'US ton', 907.18474),
      _Unit('Imperial Ton', 'imp ton', 1016.0469088),
    ]),
    _UnitCategory('Temperature', Icons.thermostat, [
      _Unit('Celsius', '°C', 1),
      _Unit('Fahrenheit', '°F', 1),
      _Unit('Kelvin', 'K', 1),
      _Unit('Rankine', '°R', 1),
    ]),
    _UnitCategory('Time', Icons.timer_outlined, [
      _Unit('Second', 's', 1),
      _Unit('Millisecond', 'ms', 0.001),
      _Unit('Microsecond', 'μs', 1e-6),
      _Unit('Minute', 'min', 60),
      _Unit('Hour', 'h', 3600),
      _Unit('Day', 'd', 86400),
      _Unit('Week', 'wk', 604800),
      _Unit('Month (30 days)', 'mo', 2592000),
      _Unit('Year (365 days)', 'yr', 31536000),
    ]),
    _UnitCategory('Speed', Icons.speed, [
      _Unit('Meters/second', 'm/s', 1),
      _Unit('Kilometers/hour', 'km/h', 0.277778),
      _Unit('Miles/hour', 'mph', 0.44704),
      _Unit('Knots', 'kn', 0.514444),
      _Unit('Feet/second', 'ft/s', 0.3048),
      _Unit('Mach', 'Ma', 343),
    ]),
    _UnitCategory('Data', Icons.storage, [
      _Unit('Byte', 'B', 1),
      _Unit('Kilobyte (1000)', 'kB', 1000),
      _Unit('Megabyte (1000)', 'MB', 1e6),
      _Unit('Gigabyte (1000)', 'GB', 1e9),
      _Unit('Terabyte (1000)', 'TB', 1e12),
      _Unit('Petabyte (1000)', 'PB', 1e15),
      _Unit('Kibibyte (1024)', 'KiB', 1024),
      _Unit('Mebibyte (1024)', 'MiB', 1048576),
      _Unit('Gibibyte (1024)', 'GiB', 1073741824),
      _Unit('Tebibyte (1024)', 'TiB', 1099511627776),
      _Unit('Pebibyte (1024)', 'PiB', 1125899906842624),
      _Unit('Bit', 'bit', 0.125),
    ]),
    _UnitCategory('Energy', Icons.bolt, [
      _Unit('Joule', 'J', 1),
      _Unit('Kilojoule', 'kJ', 1000),
      _Unit('Calorie', 'cal', 4.184),
      _Unit('Kilocalorie', 'kcal', 4184),
      _Unit('Watt-hour', 'Wh', 3600),
      _Unit('Kilowatt-hour', 'kWh', 3600000),
      _Unit('Electronvolt', 'eV', 1.602176634e-19),
      _Unit('BTU', 'BTU', 1055.06),
    ]),
    _UnitCategory('Power', Icons.power, [
      _Unit('Watt', 'W', 1),
      _Unit('Kilowatt', 'kW', 1000),
      _Unit('Megawatt', 'MW', 1e6),
      _Unit('Horsepower', 'hp', 745.7),
      _Unit('BTU/hour', 'BTU/h', 0.29307107),
    ]),
    _UnitCategory('Pressure', Icons.compress, [
      _Unit('Pascal', 'Pa', 1),
      _Unit('Kilopascal', 'kPa', 1000),
      _Unit('Megapascal', 'MPa', 1000000),
      _Unit('Bar', 'bar', 100000),
      _Unit('Millibar', 'mbar', 100),
      _Unit('Atmosphere', 'atm', 101325),
      _Unit('PSI', 'psi', 6894.757293168),
      _Unit('mmHg', 'mmHg', 133.3224),
      _Unit('Torr', 'Torr', 133.3224),
    ]),
    _UnitCategory('Angle', Icons.architecture, [
      _Unit('Degree', '°', 1),
      _Unit('Radian', 'rad', 57.29577951308232),
      _Unit('Gradian', 'grad', 0.9),
      _Unit('Arc Minute', '′', 1 / 60),
      _Unit('Arc Second', '″', 1 / 3600),
    ]),
    _UnitCategory('Frequency', Icons.waves, [
      _Unit('Hertz', 'Hz', 1),
      _Unit('Kilohertz', 'kHz', 1000),
      _Unit('Megahertz', 'MHz', 1e6),
      _Unit('Gigahertz', 'GHz', 1e9),
    ]),
    _UnitCategory('Fuel Economy', Icons.local_gas_station, [
      _Unit('km/L', 'km/L', 1),
      _Unit('L/100km', 'L/100km', 1), // Special handling needed
      _Unit('MPG (US)', 'mpg', 0.425144),
      _Unit('MPG (Imperial)', 'imp mpg', 0.354006),
    ]),
  ];

  _UnitCategory get _currentCategory => _categories[_categoryIndex];

  String _convert() {
    final input = double.tryParse(_inputCtrl.text);
    if (input == null) return '';

    final cat = _currentCategory;
    if (_fromUnit >= cat.units.length || _toUnit >= cat.units.length) return '';

    double result;

    if (cat.name == 'Temperature') {
      result = _convertTemperature(input, _fromUnit, _toUnit);
    } else if (cat.name == 'Fuel Economy') {
      result = _convertFuelEconomy(input, _fromUnit, _toUnit, cat);
    } else {
      // Standard: convert to base unit, then to target
      final baseValue = input * cat.units[_fromUnit].factor;
      result = baseValue / cat.units[_toUnit].factor;
    }

    return _formatter.format(result);
  }

  double _convertTemperature(double value, int from, int to) {
    // 0=C, 1=F, 2=K, 3=Rankine (°R)
    double celsius;
    switch (from) {
      case 0: celsius = value;
      case 1: celsius = (value - 32) * 5 / 9;
      case 2: celsius = value - 273.15;
      case 3: celsius = (value - 491.67) * 5 / 9;
      default: celsius = value;
    }
    switch (to) {
      case 0: return celsius;
      case 1: return celsius * 9 / 5 + 32;
      case 2: return celsius + 273.15;
      case 3: return (celsius + 273.15) * 9 / 5;
      default: return celsius;
    }
  }

  double _convertFuelEconomy(double value, int from, int to, _UnitCategory cat) {
    // Convert everything to km/L first
    double kmPerL;
    switch (from) {
      case 0: kmPerL = value; // km/L
      case 1: kmPerL = value == 0 ? 0 : 100 / value; // L/100km -> km/L
      case 2: kmPerL = value * 0.425144; // MPG US -> km/L
      case 3: kmPerL = value * 0.354006; // MPG imp -> km/L
      default: kmPerL = value;
    }

    switch (to) {
      case 0: return kmPerL; // km/L
      case 1: return kmPerL == 0 ? 0 : 100 / kmPerL; // km/L -> L/100km
      case 2: return kmPerL / 0.425144; // km/L -> MPG US
      case 3: return kmPerL / 0.354006; // km/L -> MPG imp
      default: return kmPerL;
    }
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = _convert();
    final cat = _currentCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Category selector
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: QSpacing.md),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final c = _categories[i];
                final selected = i == _categoryIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: QSpacing.sm),
                  child: ChoiceChip(
                    avatar: Icon(c.icon, size: 16, color: selected ? QColors.primaryPurple : null),
                    label: Text(c.name),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _categoryIndex = i;
                      _fromUnit = 0;
                      _toUnit = 1.clamp(0, _categories[i].units.length - 1);
                    }),
                    selectedColor: QColors.primaryPurple.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(QSpacing.lg),
              child: Column(
                children: [
                  // Input
                  ToolTextField(
                    controller: _inputCtrl,
                    label: 'Value',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: QSpacing.lg),

                  // From unit
                  ToolDropdown<int>(
                    label: 'From',
                    value: _fromUnit,
                    items: List.generate(cat.units.length, (i) => i),
                    labelBuilder: (i) => '${cat.units[i].name} (${cat.units[i].symbol})',
                    onChanged: (v) => setState(() => _fromUnit = v ?? 0),
                  ),

                  // Swap button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: QSpacing.sm),
                    child: IconButton(
                      onPressed: _swapUnits,
                      icon: Container(
                        padding: const EdgeInsets.all(QSpacing.sm),
                        decoration: BoxDecoration(
                          color: QColors.primaryPurple.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.swap_vert, color: QColors.primaryPurple),
                      ),
                      tooltip: 'Swap units',
                    ),
                  ),

                  // To unit
                  ToolDropdown<int>(
                    label: 'To',
                    value: _toUnit,
                    items: List.generate(cat.units.length, (i) => i),
                    labelBuilder: (i) => '${cat.units[i].name} (${cat.units[i].symbol})',
                    onChanged: (v) => setState(() => _toUnit = v ?? 0),
                  ),

                  // Result
                  if (result.isNotEmpty) ...[
                    const SizedBox(height: QSpacing.xxl),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(QSpacing.xl),
                      decoration: BoxDecoration(
                        color: isDark ? QColors.darkCard : QColors.lightElevated,
                        borderRadius: QRadius.borderRadiusLg,
                        border: Border.all(color: QColors.primaryPurple.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            result,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: QSpacing.xs),
                          Text(
                            cat.units[_toUnit].symbol,
                            style: TextStyle(
                              fontSize: 16,
                              color: QColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCategory {
  final String name;
  final IconData icon;
  final List<_Unit> units;
  const _UnitCategory(this.name, this.icon, this.units);
}

class _Unit {
  final String name;
  final String symbol;
  final double factor; // Factor to convert to base unit
  const _Unit(this.name, this.symbol, this.factor);
}
