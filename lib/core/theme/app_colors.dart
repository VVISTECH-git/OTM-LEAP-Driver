import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leapdriver/core/theme/app_theme.dart';
import 'package:leapdriver/core/providers/theme_provider.dart';

/// AppColors — convenience extension on BuildContext.
///
/// Usage:
///   context.colors.primary          → primary brand color
///   context.colors.surface2         → card background
///   context.colors.textMuted        → muted label text
///   context.appTheme                → full AppThemeData object
///
/// This avoids passing AppThemeData down through constructors.
/// Every widget that needs theme colors just calls context.colors.xxx.

extension AppColorsX on BuildContext {
  AppThemeData get appTheme =>
      read<ThemeProvider>().theme;

  /// Returns the current theme's color set.
  /// Uses read() — safe to call from event handlers, initState, and build().
  /// Rebuilds are driven by the ThemeProvider in the widget tree.
  AppThemeData get colors =>
      read<ThemeProvider>().theme;
}
