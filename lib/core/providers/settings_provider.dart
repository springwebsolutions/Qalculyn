// Qalculyn - Settings Provider
// Manages app preferences, theming, color customization, and formatting with persistence

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../math/calculator_engine.dart';
import '../math/number_formatter.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyThemeMode = 'theme_mode';
  static const _keyAngleMode = 'angle_mode';
  static const _keyDecimalPlaces = 'decimal_places';
  static const _keyThousandsSeparator = 'thousands_separator';
  static const _keyHapticFeedback = 'haptic_feedback';
  static const _keyScientificMode = 'scientific_mode';
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyAccentColor = 'accent_color';
  static const _keyAmoledBlack = 'amoled_black';
  static const _keyKeypadCornerRadius = 'keypad_corner_radius';

  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  AngleMode _angleMode = AngleMode.degrees;
  int _decimalPlaces = 10;
  bool _useThousandsSeparator = true;
  bool _hapticFeedback = true;
  bool _scientificMode = false;
  bool _onboardingDone = false;

  // UI / UX Theme and Color Customizer
  int _accentColorValue = 0xFF7C3AED; // Default Qalculyn Purple
  bool _amoledBlack = false;
  double _keypadCornerRadius = 16.0;

  ThemeMode get themeMode => _themeMode;
  AngleMode get angleMode => _angleMode;
  int get decimalPlaces => _decimalPlaces;
  bool get useThousandsSeparator => _useThousandsSeparator;
  bool get hapticFeedback => _hapticFeedback;
  bool get scientificMode => _scientificMode;
  bool get onboardingDone => _onboardingDone;

  Color get accentColor => Color(_accentColorValue);
  int get accentColorValue => _accentColorValue;
  bool get amoledBlack => _amoledBlack;
  double get keypadCornerRadius => _keypadCornerRadius;

  NumberFormatConfig get numberFormatConfig => NumberFormatConfig(
    decimalPlaces: _decimalPlaces,
    useThousandsSeparator: _useThousandsSeparator,
  );

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[_prefs!.getInt(_keyThemeMode) ?? 0];
    _angleMode = AngleMode.values[_prefs!.getInt(_keyAngleMode) ?? 0];
    _decimalPlaces = _prefs!.getInt(_keyDecimalPlaces) ?? 10;
    _useThousandsSeparator = _prefs!.getBool(_keyThousandsSeparator) ?? true;
    _hapticFeedback = _prefs!.getBool(_keyHapticFeedback) ?? true;
    _scientificMode = _prefs!.getBool(_keyScientificMode) ?? false;
    _onboardingDone = _prefs!.getBool(_keyOnboardingDone) ?? false;

    _accentColorValue = _prefs!.getInt(_keyAccentColor) ?? 0xFF7C3AED;
    _amoledBlack = _prefs!.getBool(_keyAmoledBlack) ?? false;
    _keypadCornerRadius = _prefs!.getDouble(_keyKeypadCornerRadius) ?? 16.0;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs?.setInt(_keyThemeMode, mode.index);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColorValue = color.toARGB32();
    await _prefs?.setInt(_keyAccentColor, _accentColorValue);
    notifyListeners();
  }

  Future<void> setAmoledBlack(bool value) async {
    _amoledBlack = value;
    await _prefs?.setBool(_keyAmoledBlack, value);
    notifyListeners();
  }

  Future<void> setKeypadCornerRadius(double radius) async {
    _keypadCornerRadius = radius;
    await _prefs?.setDouble(_keyKeypadCornerRadius, radius);
    notifyListeners();
  }

  Future<void> setAngleMode(AngleMode mode) async {
    _angleMode = mode;
    await _prefs?.setInt(_keyAngleMode, mode.index);
    notifyListeners();
  }

  Future<void> setDecimalPlaces(int places) async {
    _decimalPlaces = places.clamp(0, 15);
    await _prefs?.setInt(_keyDecimalPlaces, _decimalPlaces);
    notifyListeners();
  }

  Future<void> setThousandsSeparator(bool use) async {
    _useThousandsSeparator = use;
    await _prefs?.setBool(_keyThousandsSeparator, use);
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool enabled) async {
    _hapticFeedback = enabled;
    await _prefs?.setBool(_keyHapticFeedback, enabled);
    notifyListeners();
  }

  Future<void> setScientificMode(bool enabled) async {
    _scientificMode = enabled;
    await _prefs?.setBool(_keyScientificMode, enabled);
    notifyListeners();
  }

  Future<void> setOnboardingDone(bool done) async {
    _onboardingDone = done;
    await _prefs?.setBool(_keyOnboardingDone, done);
    notifyListeners();
  }

  Future<void> resetAll() async {
    _themeMode = ThemeMode.system;
    _angleMode = AngleMode.degrees;
    _decimalPlaces = 10;
    _useThousandsSeparator = true;
    _hapticFeedback = true;
    _scientificMode = false;
    _accentColorValue = 0xFF7C3AED;
    _amoledBlack = false;
    _keypadCornerRadius = 16.0;

    await _prefs?.setInt(_keyThemeMode, 0);
    await _prefs?.setInt(_keyAngleMode, 0);
    await _prefs?.setInt(_keyDecimalPlaces, 10);
    await _prefs?.setBool(_keyThousandsSeparator, true);
    await _prefs?.setBool(_keyHapticFeedback, true);
    await _prefs?.setBool(_keyScientificMode, false);
    await _prefs?.setInt(_keyAccentColor, 0xFF7C3AED);
    await _prefs?.setBool(_keyAmoledBlack, false);
    await _prefs?.setDouble(_keyKeypadCornerRadius, 16.0);

    notifyListeners();
  }
}
