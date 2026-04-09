import 'package:flutter/material.dart';

/// Palette Horizon có light/dark variants.
/// Mục tiêu: giữ style hiện tại ở light, nhưng khi dark mode thì dùng colorScheme
/// để không bị “chói”/khó đọc.
class HorizonColors {
  const HorizonColors._({
    required this.surface,
    required this.card,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primary,
    required this.primaryContainer,
    required this.surfaceContainer,
  });

  final Color surface;
  final Color card;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primary;
  final Color primaryContainer;
  final Color surfaceContainer;

  static HorizonColors of(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (!isDark) {
      return const HorizonColors._(
        surface: Color(0xFFF4F6FF),
        card: Color(0xFFFFFFFF),
        onSurface: Color(0xFF14304F),
        onSurfaceVariant: Color(0xFF445D7F),
        primary: Color(0xFF006286),
        primaryContainer: Color(0xFF2DB7F2),
        surfaceContainer: Color(0xFFDDE9FF),
      );
    }

    return HorizonColors._(
      surface: theme.scaffoldBackgroundColor,
      card: cs.surface,
      onSurface: cs.onSurface,
      onSurfaceVariant: cs.onSurfaceVariant,
      primary: cs.primary,
      primaryContainer: cs.primaryContainer,
      surfaceContainer: cs.surfaceContainerHighest,
    );
  }
}

