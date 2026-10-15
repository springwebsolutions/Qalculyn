// Qalculyn - Settings Screen
// Comprehensive app preferences, embedded theme & color customizer, and configuration

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/theme.dart';
import '../../core/math/calculator_engine.dart';
import '../../core/providers/calculator_provider.dart';
import '../../core/providers/settings_provider.dart';
import 'theme_customizer_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _palettes = [
    _ColorPalette('Qalculyn Purple', Color(0xFF7C3AED)),
    _ColorPalette('Electric Indigo', Color(0xFF6366F1)),
    _ColorPalette('Cyber Cyan', Color(0xFF06B6D4)),
    _ColorPalette('Emerald Green', Color(0xFF10B981)),
    _ColorPalette('Sunset Amber', Color(0xFFF59E0B)),
    _ColorPalette('Rose Pink', Color(0xFFF43F5E)),
    _ColorPalette('Midnight Blue', Color(0xFF2563EB)),
    _ColorPalette('Crimson Flame', Color(0xFFDC2626)),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final calc = context.read<CalculatorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: QSpacing.lg, vertical: QSpacing.md),
        children: [
          _buildSectionHeader(context, 'Theme & Color Customizer'),
          _buildCard(
            context,
            isDark,
            children: [
              // 1. Live Preview Card
              Padding(
                padding: const EdgeInsets.all(QSpacing.md),
                child: _buildLivePreview(context, settings, isDark, settings.accentColor),
              ),
              const Divider(height: 1),

              // 2. Display Theme Mode
              Padding(
                padding: const EdgeInsets.all(QSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
                    const SizedBox(height: QSpacing.sm),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(value: ThemeMode.system, label: Text('System')),
                        ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                        ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (selected) => settings.setThemeMode(selected.first),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // 3. AMOLED Pure Black Mode
              SwitchListTile(
                secondary: Icon(Icons.dark_mode_outlined, color: primary),
                title: Text(
                  'AMOLED Pure Black Mode',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                ),
                subtitle: Text(
                  'True black (#000000) surfaces for OLED battery saving',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                value: settings.amoledBlack,
                activeTrackColor: settings.accentColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: QSpacing.xs),
                onChanged: (val) => settings.setAmoledBlack(val),
              ),
              const Divider(height: 1),

              // 4. Accent Color Palette Grid
              Padding(
                padding: const EdgeInsets.all(QSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Accent Color Palette', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
                    const SizedBox(height: QSpacing.sm),
                    Wrap(
                      spacing: QSpacing.sm,
                      runSpacing: QSpacing.sm,
                      children: _palettes.map((p) {
                        final isSelected = settings.accentColorValue == p.color.toARGB32();
                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            settings.setAccentColor(p.color);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? p.color.withValues(alpha: 0.18) : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? p.color : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: p.color,
                                  child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? p.color : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // 5. Keypad Button Corner Geometry
              Padding(
                padding: const EdgeInsets.all(QSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Corner Radius: ${settings.keypadCornerRadius.toInt()} px',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
                        Row(
                          children: [
                            ActionChip(
                              label: const Text('Square', style: TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => settings.setKeypadCornerRadius(6),
                            ),
                            const SizedBox(width: 4),
                            ActionChip(
                              label: const Text('Round', style: TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => settings.setKeypadCornerRadius(16),
                            ),
                            const SizedBox(width: 4),
                            ActionChip(
                              label: const Text('Pill', style: TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => settings.setKeypadCornerRadius(30),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Slider(
                      value: settings.keypadCornerRadius,
                      min: 4,
                      max: 32,
                      divisions: 14,
                      activeColor: settings.accentColor,
                      onChanged: (val) => settings.setKeypadCornerRadius(val),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Full Screen Theme Studio Link
              _buildListTile(
                context,
                icon: Icons.fullscreen,
                title: 'Full Screen Theme Studio',
                subtitle: 'Dedicated full-screen visual customizer',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ThemeCustomizerScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: QSpacing.lg),

          _buildSectionHeader(context, 'Calculation & Precision'),
          _buildCard(
            context,
            isDark,
            children: [
              _buildListTile(
                context,
                icon: Icons.functions,
                title: 'Angle Unit',
                subtitle: settings.angleMode == AngleMode.degrees ? 'Degrees (DEG)' : 'Radians (RAD)',
                trailing: SegmentedButton<AngleMode>(
                  segments: const [
                    ButtonSegment(value: AngleMode.degrees, label: Text('DEG')),
                    ButtonSegment(value: AngleMode.radians, label: Text('RAD')),
                  ],
                  selected: {settings.angleMode},
                  onSelectionChanged: (selected) {
                    settings.setAngleMode(selected.first);
                    calc.updateSettings();
                  },
                ),
              ),
              const Divider(height: 1),
              _buildListTile(
                context,
                icon: Icons.pin_outlined,
                title: 'Decimal Precision',
                subtitle: '${settings.decimalPlaces} decimal places',
                trailing: SizedBox(
                  width: 140,
                  child: Slider(
                    value: settings.decimalPlaces.toDouble(),
                    min: 0,
                    max: 15,
                    divisions: 15,
                    label: '${settings.decimalPlaces}',
                    activeColor: QColors.primaryPurple,
                    onChanged: (val) {
                      settings.setDecimalPlaces(val.toInt());
                      calc.updateSettings();
                    },
                  ),
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.format_list_numbered, color: QColors.primaryPurple),
                title: Text(
                  'Thousands Separators',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                ),
                subtitle: Text(
                  'Format numbers with commas (e.g. 1,000,000)',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                value: settings.useThousandsSeparator,
                activeTrackColor: QColors.primaryPurple,
                contentPadding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: QSpacing.xs),
                onChanged: (val) {
                  settings.setThousandsSeparator(val);
                  calc.updateSettings();
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.science_outlined, color: QColors.primaryPurple),
                title: Text(
                  'Default Scientific Panel',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                ),
                subtitle: Text(
                  'Keep scientific keypad expanded by default',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                value: settings.scientificMode,
                activeTrackColor: QColors.primaryPurple,
                contentPadding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: QSpacing.xs),
                onChanged: (val) => settings.setScientificMode(val),
              ),
            ],
          ),
          const SizedBox(height: QSpacing.lg),

          _buildSectionHeader(context, 'Haptics & Feedback'),
          _buildCard(
            context,
            isDark,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.vibration, color: QColors.primaryPurple),
                title: Text(
                  'Vibration Feedback',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                ),
                subtitle: Text(
                  'Light tactile feedback when tapping keys',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                value: settings.hapticFeedback,
                activeTrackColor: QColors.primaryPurple,
                contentPadding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: QSpacing.xs),
                onChanged: (val) => settings.setHapticFeedback(val),
              ),
            ],
          ),
          const SizedBox(height: QSpacing.lg),

          _buildSectionHeader(context, 'History & Storage'),
          _buildCard(
            context,
            isDark,
            children: [
              _buildListTile(
                context,
                icon: Icons.delete_sweep_outlined,
                title: 'Clear Calculation History',
                subtitle: 'Permanently remove all saved calculations',
                trailing: TextButton(
                  onPressed: () => _confirmClearHistory(context, calc),
                  child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
                ),
              ),
              const Divider(height: 1),
              _buildListTile(
                context,
                icon: Icons.restart_alt,
                title: 'Reset All Settings',
                subtitle: 'Restore factory defaults',
                trailing: TextButton(
                  onPressed: () => _confirmResetSettings(context, settings, calc),
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
          const SizedBox(height: QSpacing.lg),

          _buildSectionHeader(context, 'About Qalculyn'),
          _buildCard(
            context,
            isDark,
            children: [
              _buildListTile(
                context,
                icon: Icons.calculate_outlined,
                title: 'Qalculyn',
                subtitle: 'Version 1.0.0 (Release Build 1)\nCalculate without compromise',
              ),
              const Divider(height: 1),
              _buildListTile(
                context,
                icon: Icons.shield_outlined,
                title: 'Privacy & Offline Guarantee',
                subtitle: '100% offline. Zero ads, zero trackers, zero data collection. All calculations & history remain strictly on your device.',
              ),
            ],
          ),
          const SizedBox(height: QSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: QSpacing.sm, left: QSpacing.xs),
      child: Text(
        title,
        style: QTypography.labelLarge(context).copyWith(
          color: QColors.primaryPurple,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? QColors.darkCard : QColors.lightCard,
        borderRadius: QRadius.borderRadiusLg,
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: QColors.primaryPurple),
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: QSpacing.xs),
    );
  }

  void _confirmClearHistory(BuildContext context, CalculatorProvider calc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will delete all saved calculations permanently. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              calc.clearHistory();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmResetSettings(BuildContext context, SettingsProvider settings, CalculatorProvider calc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Settings?'),
        content: const Text('Restore all default preferences for formatting, angle modes, and appearance?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await settings.resetAll();
              calc.updateSettings();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings restored to default')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreview(BuildContext context, SettingsProvider settings, bool isDark, Color accent) {
    final radius = BorderRadius.circular(settings.keypadCornerRadius);

    return Container(
      padding: const EdgeInsets.all(QSpacing.md),
      decoration: BoxDecoration(
        color: settings.amoledBlack && isDark ? Colors.black : (isDark ? QColors.darkSurfaceVariant : QColors.lightSurfaceVariant),
        borderRadius: QRadius.borderRadiusLg,
        border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.remove_red_eye_outlined, size: 16, color: accent),
              const SizedBox(width: QSpacing.xs),
              Text(
                'LIVE THEME PREVIEW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: QSpacing.md),

          // Mini Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: QSpacing.md, vertical: QSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? QColors.darkCard : QColors.lightCard,
              borderRadius: QRadius.borderRadiusMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '25 × 4 + 8',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                Text(
                  '108',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.md),

          // Mini Keypad Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _previewKey('C', Colors.redAccent.withValues(alpha: 0.15), Colors.redAccent, radius),
              _previewKey('( )', accent.withValues(alpha: 0.12), accent, radius),
              _previewKey('%', accent.withValues(alpha: 0.12), accent, radius),
              _previewKey('÷', accent, Colors.white, radius),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _previewKey('7', isDark ? QColors.darkCard : QColors.lightCard, Theme.of(context).colorScheme.onSurface, radius),
              _previewKey('8', isDark ? QColors.darkCard : QColors.lightCard, Theme.of(context).colorScheme.onSurface, radius),
              _previewKey('9', isDark ? QColors.darkCard : QColors.lightCard, Theme.of(context).colorScheme.onSurface, radius),
              _previewKey('×', accent, Colors.white, radius),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _previewKey('4', isDark ? QColors.darkCard : QColors.lightCard, Theme.of(context).colorScheme.onSurface, radius),
              _previewKey('5', isDark ? QColors.darkCard : QColors.lightCard, Theme.of(context).colorScheme.onSurface, radius),
              _previewKey('6', isDark ? QColors.darkCard : QColors.lightCard, Theme.of(context).colorScheme.onSurface, radius),
              _previewKey('−', accent, Colors.white, radius),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewKey(String label, Color bg, Color textCol, BorderRadius radius) {
    return Container(
      width: 65,
      height: 42,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textCol,
          ),
        ),
      ),
    );
  }
}

class _ColorPalette {
  final String name;
  final Color color;
  const _ColorPalette(this.name, this.color);
}
