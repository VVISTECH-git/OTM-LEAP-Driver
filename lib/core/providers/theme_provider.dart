import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leapdriver/core/theme/app_theme.dart';

/// ThemeProvider
///
/// Manages the active theme across the app.
/// Persists the driver's choice to SharedPreferences — survives cold starts.
/// Follows the exact same pattern as LocaleProvider for consistency.
class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_theme';

  AppThemeData _theme = AppThemes.brick;

  AppThemeData get theme => _theme;

  /// Load saved theme on app start.
  /// Called from main() with unawaited() — same pattern as loadSavedLocale().
  Future<void> loadSavedTheme() async {
    final prefs   = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_prefKey);
    if (savedId != null) {
      _theme = AppThemes.byId(savedId);
      notifyListeners();
    }
  }

  /// Set and persist a new theme.
  Future<void> setTheme(AppThemeData theme) async {
    if (_theme.id == theme.id) return;
    _theme = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, theme.id);
  }

  /// Convenience — build the Flutter ThemeData for MaterialApp.theme.
  ThemeData toMaterialTheme() {
    final t = _theme;
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'PlusJakartaSans',
      colorScheme: t.toColorScheme(),
      scaffoldBackgroundColor: t.surface1,

      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'PlusJakartaSans',
            fontSize: 32, fontWeight: FontWeight.w800, color: t.text),
        titleLarge: TextStyle(fontFamily: 'PlusJakartaSans',
            fontSize: 20, fontWeight: FontWeight.w700, color: t.text),
        bodyLarge: TextStyle(fontFamily: 'PlusJakartaSans',
            fontSize: 16, fontWeight: FontWeight.w500, color: t.text),
        bodyMedium: TextStyle(fontFamily: 'PlusJakartaSans',
            fontSize: 14, fontWeight: FontWeight.w500, color: t.textSecondary),
        labelLarge: TextStyle(fontFamily: 'PlusJakartaSans',
            fontSize: 14, fontWeight: FontWeight.w700, color: t.text),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w800, fontSize: 15,
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: t.surface1,
        foregroundColor: t.text,
        titleTextStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 18, fontWeight: FontWeight.w800, color: t.text,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.focusRing, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          color: t.textMuted, fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white,
        ),
      ),
    );
  }
}