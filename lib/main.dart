// Qalculyn — Complete Production-Ready Android Calculator Ecosystem
// Application entry point

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/design_system/theme.dart';
import 'core/providers/calculator_provider.dart';
import 'core/providers/settings_provider.dart';
import 'features/calculator/calculator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize persistent settings
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<CalculatorProvider>(
          create: (_) => CalculatorProvider(settingsProvider),
        ),
      ],
      child: const QalculynApp(),
    ),
  );
}

class QalculynApp extends StatelessWidget {
  const QalculynApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Qalculyn',
      debugShowCheckedModeBanner: false,
      theme: QTheme.light(accentColor: settings.accentColor),
      darkTheme: QTheme.dark(
        accentColor: settings.accentColor,
        amoledBlack: settings.amoledBlack,
      ),
      themeMode: settings.themeMode,
      home: const CalculatorScreen(),
    );
  }
}
