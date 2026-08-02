import 'package:flutter/material.dart';

/// A reusable, theme-aware "pill" label meant to sit on a horizontal reference
/// line (e.g. average-buy price).
///
/// Two-tone text: [label] in the on-surface color + [value] in the accent
/// color (bold). Rounded bordered box with the border in the accent color and
/// a theme-aware background (black in dark, white in light). Every color is
/// overridable; sensible defaults come from `Theme.of(context).brightness`.
class AvgBuyPill extends StatelessWidget {
  const AvgBuyPill({
    Key? key,
    this.label = 'Avg. Buy',
    required this.value,
    this.accentColor = const Color(0xFF00E5FF),
    this.backgroundColor,
    this.labelColor,
    this.borderRadius = 20.0,
    this.borderWidth = 1.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.fontSize = 12.0,
  }) : super(key: key);

  /// Leading text, e.g. `Avg. Buy`.
  final String label;

  /// Trailing value text, rendered in [accentColor] and bold.
  final String value;

  /// Accent color — border + value text. Defaults to cyan.
  final Color accentColor;

  /// Box background. Defaults to black (dark) / white (light).
  final Color? backgroundColor;

  /// [label] text color. Defaults to the theme on-surface color.
  final Color? labelColor;

  final double borderRadius;
  final double borderWidth;
  final EdgeInsets padding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? Colors.black : Colors.white);
    final onSurface =
        labelColor ?? (isDark ? Colors.white : Colors.black87);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: accentColor, width: borderWidth),
      ),
      child: Padding(
        padding: padding,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label ',
                style: TextStyle(
                  color: onSurface,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: value,
                style: TextStyle(
                  color: accentColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
