// Qalculyn - UI/UX Theme & Color Customizer Screen
// Real-time interactive customization of accent colors, dark/light/AMOLED modes, and keypad geometries

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/design_system/theme.dart';
import '../../core/providers/settings_provider.dart';

class ThemeCustomizerScreen extends StatelessWidget {
  const ThemeCustomizerScreen({super.key});

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = settings.accentColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme & Color Customizer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(QSpacing.lg),
        children: [
          // Live Calculator Preview Card
          _buildLivePreview(context, settings, isDark, accent),
          const SizedBox(height: QSpacing.xl),

          // Display Mode Section
          _sectionHeader(context, 'Display Theme Mode'),
          Container(
            padding: const EdgeInsets.all(QSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? QColors.darkCard : QColors.lightCard,
              borderRadius: QRadius.borderRadiusLg,
            ),
            child: Column(
              children: [
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (selected) => settings.setThemeMode(selected.first),
                ),
                const SizedBox(height: QSpacing.sm),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('AMOLED Pure Black Mode'),
                  subtitle: const Text('True black (#000000) surfaces for OLED battery saving', style: TextStyle(fontSize: 11)),
                  value: settings.amoledBlack,
                  activeTrackColor: accent,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => settings.setAmoledBlack(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.xl),

          // Accent Color Palette Grid
          _sectionHeader(context, 'Accent Color Palette'),
          Container(
            padding: const EdgeInsets.all(QSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? QColors.darkCard : QColors.lightCard,
              borderRadius: QRadius.borderRadiusLg,
            ),
            child: Wrap(
              spacing: QSpacing.md,
              runSpacing: QSpacing.md,
              children: _palettes.map((p) {
                final isSelected = settings.accentColorValue == p.color.toARGB32();
                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    settings.setAccentColor(p.color);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? p.color.withValues(alpha: 0.18) : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? p.color : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: p.color,
                          child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 8),
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
          ),
          const SizedBox(height: QSpacing.xl),

          // Keypad Button Corner Geometry
          _sectionHeader(context, 'Keypad Button Geometry'),
          Container(
            padding: const EdgeInsets.all(QSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? QColors.darkCard : QColors.lightCard,
              borderRadius: QRadius.borderRadiusLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Corner Radius: ${settings.keypadCornerRadius.toInt()} px'),
                    Row(
                      children: [
                        ActionChip(
                          label: const Text('Square (6px)', style: TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => settings.setKeypadCornerRadius(6),
                        ),
                        const SizedBox(width: 4),
                        ActionChip(
                          label: const Text('Round (16px)', style: TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => settings.setKeypadCornerRadius(16),
                        ),
                        const SizedBox(width: 4),
                        ActionChip(
                          label: const Text('Pill (30px)', style: TextStyle(fontSize: 11)),
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
                  activeColor: accent,
                  onChanged: (val) => settings.setKeypadCornerRadius(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: QSpacing.xl),

          // Restore Defaults Button
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset Theme to Defaults'),
              onPressed: () async {
                await settings.setAccentColor(const Color(0xFF7C3AED));
                await settings.setAmoledBlack(false);
                await settings.setKeypadCornerRadius(16.0);
                await settings.setThemeMode(ThemeMode.system);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme settings restored to default')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: QSpacing.xxl),
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

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: QSpacing.sm, left: QSpacing.xs),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.8,
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
