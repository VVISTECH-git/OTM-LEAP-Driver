import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppThemeData
//
// One object per theme. Every screen reads colors from here — no more
// hardcoded hex constants scattered across files.
//
// Semantic token naming (purpose-based, not color-based):
//   navColor / navColor2   — app header background (gradient stops)
//   tripGrad1 / tripGrad2  — trip bar gradient stops
//   primary / primary2     — main brand color (buttons, links, active states)
//   accent                 — highlights, active nodes, focus rings
//   success / warning / danger / info  — status semantics
//   surface1 / surface2 / surface3     — layered backgrounds
//   text / textMuted / textSecondary   — text hierarchy
//   border                 — card / divider strokes
//   ctaGradient            — if non-null, primary button uses a gradient
// ─────────────────────────────────────────────────────────────────────────────

class AppThemeData {
  final String id;
  final String label;
  final String description;

  // Header / nav
  final Color navColor;
  final Color navColor2;

  // Trip bar gradient
  final Color tripGrad1;
  final Color tripGrad2;

  // Brand / action
  final Color primary;
  final Color primary2;
  final Color accent;

  // CTA button — if set, button uses LinearGradient instead of flat primary
  final List<Color>? ctaGradient;

  // Semantic status
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  // Surfaces (3-level hierarchy)
  final Color surface1;   // page / scaffold background
  final Color surface2;   // cards, sheets, white areas
  final Color surface3;   // hover states, section rows, input fills

  // Text
  final Color text;
  final Color textMuted;
  final Color textSecondary;

  // Borders
  final Color border;

  // Focus ring
  final Color focusRing;

  // Secondary color (nav/dark color — used for Done buttons, confirmed actions)
  final Color secondary;

  // Active stop node on timeline
  final Color activeNode;
  final Color activeNodeGlow;

  // Swatch colors shown in picker (4 dots)
  final List<Color> swatchColors;

  const AppThemeData({
    required this.id,
    required this.label,
    required this.description,
    required this.navColor,
    required this.navColor2,
    required this.tripGrad1,
    required this.tripGrad2,
    required this.primary,
    required this.primary2,
    required this.accent,
    this.ctaGradient,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.text,
    required this.textMuted,
    required this.textSecondary,
    required this.border,
    required this.focusRing,
    required this.secondary,
    required this.activeNode,
    required this.activeNodeGlow,
    required this.swatchColors,
  });

  // Convenience: build a Flutter ColorScheme from this theme
  ColorScheme toColorScheme() => ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
    primary: primary,
    secondary: accent,
    surface: surface1,
    error: danger,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// All 9 themes
// ─────────────────────────────────────────────────────────────────────────────

class AppThemes {
  AppThemes._();

  static const navy = AppThemeData(
    id: 'navy', label: 'Navy Blue', description: 'Enterprise · Professional',
    navColor:        Color(0xFF0F1F3D),
    navColor2:       Color(0xFF162952),
    tripGrad1:       Color(0xFF162952),
    tripGrad2:       Color(0xFF1847C2),
    primary:         Color(0xFF1847C2),
    primary2:        Color(0xFF2D5BE3),
    accent:          Color(0xFFE8720A),
    success:         Color(0xFF10A868),
    warning:         Color(0xFFE8720A),
    danger:          Color(0xFFE01E35),
    info:            Color(0xFF0EA5E9),
    surface1:        Color(0xFFF4F6FB),
    surface2:        Color(0xFFFFFFFF),
    surface3:        Color(0xFFEDF1F7),
    text:            Color(0xFF0F1F3D),
    textMuted:       Color(0xFF7A8499),
    textSecondary:   Color(0xFF4B5675),
    border:          Color(0xFFD4DCE9),
    focusRing:       Color(0xFF2D5BE3),
    secondary:   Color(0xFF0F1F3D),
    activeNode:      Color(0xFF1847C2),
    activeNodeGlow:  Color(0x331847C2),
    swatchColors: [Color(0xFF0F1F3D), Color(0xFF1847C2), Color(0xFFE8720A), Color(0xFF10A868)],
  );

  static const brick = AppThemeData(
    id: 'brick', label: 'Brick Red', description: 'Logistics · High energy',
    navColor:        Color(0xFF7D1C0E),
    navColor2:       Color(0xFF4E0F07),
    tripGrad1:       Color(0xFF5C1308),
    tripGrad2:       Color(0xFF7A1D12),
    primary:         Color(0xFFC53B2C),
    primary2:        Color(0xFFE24A39),
    accent:          Color(0xFFF97316),
    ctaGradient:     [Color(0xFFC92A1B), Color(0xFFE24A39)],
    success:         Color(0xFF10A868),
    warning:         Color(0xFFF97316),
    danger:          Color(0xFFE01E35),
    info:            Color(0xFF0EA5E9),
    surface1:        Color(0xFFFAEAE7),
    surface2:        Color(0xFFFFFFFF),
    surface3:        Color(0xFFF5DDD8),
    text:            Color(0xFF3D0D06),
    textMuted:       Color(0xFF7A4B43),
    textSecondary:   Color(0xFF5C3028),
    border:          Color(0xFFE2C2BC),
    focusRing:       Color(0xFFE24A39),
    secondary:   Color(0xFF7D1C0E),
    activeNode:      Color(0xFFF97316),
    activeNodeGlow:  Color(0x47F97316),
    swatchColors: [Color(0xFF7D1C0E), Color(0xFFC53B2C), Color(0xFFF97316), Color(0xFF10A868)],
  );

  static const forest = AppThemeData(
    id: 'forest', label: 'Forest Green', description: 'Operations · Calm',
    navColor:        Color(0xFF0D4F3C),
    navColor2:       Color(0xFF0A3D2E),
    tripGrad1:       Color(0xFF0A3D2E),
    tripGrad2:       Color(0xFF0D4F3C),
    primary:         Color(0xFF0D7A4E),
    primary2:        Color(0xFF10A868),
    accent:          Color(0xFF2563EB),   // blue accent breaks green monotony
    success:         Color(0xFF10A868),
    warning:         Color(0xFFD97706),
    danger:          Color(0xFFE01E35),
    info:            Color(0xFF2563EB),
    surface1:        Color(0xFFF0FDF4),
    surface2:        Color(0xFFFFFFFF),
    surface3:        Color(0xFFDCFCE7),
    text:            Color(0xFF052E1A),
    textMuted:       Color(0xFF4D8C6F),
    textSecondary:   Color(0xFF1E5C41),
    border:          Color(0xFFBBE8D4),
    focusRing:       Color(0xFF2563EB),
    secondary:   Color(0xFF0D4F3C),
    activeNode:      Color(0xFF2563EB),   // blue node stands out from green header
    activeNodeGlow:  Color(0x332563EB),
    swatchColors: [Color(0xFF0D4F3C), Color(0xFF0D7A4E), Color(0xFFD97706), Color(0xFF2563EB)],
  );

  static const midnight = AppThemeData(
    id: 'midnight', label: 'Midnight Indigo', description: 'Tech · Premium',
    navColor:        Color(0xFF1E1B4B),
    navColor2:       Color(0xFF16134A),
    tripGrad1:       Color(0xFF16134A),
    tripGrad2:       Color(0xFF3730A3),
    primary:         Color(0xFF4338CA),
    primary2:        Color(0xFF6366F1),
    accent:          Color(0xFFF59E0B),
    success:         Color(0xFF10B981),
    warning:         Color(0xFFF59E0B),
    danger:          Color(0xFFEF4444),
    info:            Color(0xFF6366F1),
    surface1:        Color(0xFFEEF2FF),
    surface2:        Color(0xFFFFFFFF),
    surface3:        Color(0xFFE0E7FF),
    text:            Color(0xFF1E1B4B),
    textMuted:       Color(0xFF6D68D8),
    textSecondary:   Color(0xFF3730A3),
    border:          Color(0xFFC7D2FE),
    focusRing:       Color(0xFF6366F1),
    secondary:   Color(0xFF1E1B4B),
    activeNode:      Color(0xFFF59E0B),
    activeNodeGlow:  Color(0x40F59E0B),
    swatchColors: [Color(0xFF1E1B4B), Color(0xFF4338CA), Color(0xFFF59E0B), Color(0xFF10B981)],
  );

  static const slate = AppThemeData(
    id: 'slate', label: 'Slate & Steel', description: 'Corporate · Minimal',
    navColor:        Color(0xFF1E293B),
    navColor2:       Color(0xFF0F172A),
    tripGrad1:       Color(0xFF0F172A),
    tripGrad2:       Color(0xFF1E3A5F),
    primary:         Color(0xFF2563EB),
    primary2:        Color(0xFF3B82F6),
    accent:          Color(0xFFF59E0B),
    success:         Color(0xFF22C55E),
    warning:         Color(0xFFF59E0B),
    danger:          Color(0xFFEF4444),
    info:            Color(0xFF0EA5E9),
    surface1:        Color(0xFFF8FAFC),
    surface2:        Color(0xFFFFFFFF),
    surface3:        Color(0xFFF1F5F9),
    text:            Color(0xFF0F172A),
    textMuted:       Color(0xFF7A8DA3),
    textSecondary:   Color(0xFF475569),
    border:          Color(0xFFCBD5E1),
    focusRing:       Color(0xFF3B82F6),
    secondary:   Color(0xFF1E293B),
    activeNode:      Color(0xFF2563EB),
    activeNodeGlow:  Color(0x332563EB),
    swatchColors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF3B82F6), Color(0xFF22C55E)],
  );

  static const teal = AppThemeData(
    id: 'teal', label: 'Teal Aqua', description: 'SaaS · Modern',
    navColor:        Color(0xFF0F4C5C),
    navColor2:       Color(0xFF093848),
    tripGrad1:       Color(0xFF093848),
    tripGrad2:       Color(0xFF0D6B7A),
    primary:         Color(0xFF0D9488),
    primary2:        Color(0xFF14B8A6),
    accent:          Color(0xFFF59E0B),   // warm amber accent breaks teal monotony
    success:         Color(0xFF10A868),
    warning:         Color(0xFFF59E0B),
    danger:          Color(0xFFEF4444),
    info:            Color(0xFF0EA5E9),
    surface1:        Color(0xFFF0FDFA),
    surface2:        Color(0xFFFFFFFF),
    surface3:        Color(0xFFCCFBF1),
    text:            Color(0xFF042F2E),
    textMuted:       Color(0xFF3D9E95),
    textSecondary:   Color(0xFF0F766E),
    border:          Color(0xFF9DE0D8),
    focusRing:       Color(0xFF14B8A6),
    secondary:   Color(0xFF0F4C5C),
    activeNode:      Color(0xFFF59E0B),   // amber node pops off teal header
    activeNodeGlow:  Color(0x47F59E0B),
    swatchColors: [Color(0xFF0F4C5C), Color(0xFF14B8A6), Color(0xFF0EA5E9), Color(0xFF10A868)],
  );

  static const indigo = AppThemeData(
    id: 'indigo', label: 'Indigo Purple', description: 'Product · Design',
    navColor:        Color(0xFF312E81),
    navColor2:       Color(0xFF231E6B),
    tripGrad1:       Color(0xFF231E6B),
    tripGrad2:       Color(0xFF3730A3),
    primary:         Color(0xFF4F46E5),
    primary2:        Color(0xFF6366F1),
    accent:          Color(0xFF8B5CF6),
    success:         Color(0xFF10B981),
    warning:         Color(0xFFF59E0B),
    danger:          Color(0xFFEF4444),
    info:            Color(0xFF6366F1),
    surface1:        Color(0xFFEEF2FF),
    surface2:        Color(0xFFFFFFFF),
    surface3:        Color(0xFFE0E7FF),
    text:            Color(0xFF1E1B4B),
    textMuted:       Color(0xFF6D7AC7),
    textSecondary:   Color(0xFF3730A3),
    border:          Color(0xFFC7D2FE),
    focusRing:       Color(0xFF6366F1),
    secondary:   Color(0xFF312E81),
    activeNode:      Color(0xFF8B5CF6),
    activeNodeGlow:  Color(0x408B5CF6),
    swatchColors: [Color(0xFF312E81), Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF10B981)],
  );

  static const amber = AppThemeData(
    id: 'amber', label: 'Amber Gold', description: 'Outdoor · High visibility',
    navColor:        Color(0xFF78350F),
    navColor2:       Color(0xFF5C2809),
    tripGrad1:       Color(0xFF5C2809),
    tripGrad2:       Color(0xFF92400E),
    primary:         Color(0xFF1D4ED8),  // blue primary — legible on amber surface
    primary2:        Color(0xFF2563EB),
    accent:          Color(0xFFF59E0B),
    success:         Color(0xFF10A868),
    warning:         Color(0xFFD97706),
    danger:          Color(0xFFEF4444),
    info:            Color(0xFF2563EB),
    surface1:        Color(0xFFFFFBEB),
    surface2:        Color(0xFFFFFFFF),
    surface3:        Color(0xFFFEF3C7),
    text:            Color(0xFF3C1A05),
    textMuted:       Color(0xFF92540C),
    textSecondary:   Color(0xFF78350F),
    border:          Color(0xFFFCD99A),
    focusRing:       Color(0xFF2563EB),
    secondary:   Color(0xFF78350F),
    activeNode:      Color(0xFFF59E0B),
    activeNodeGlow:  Color(0x4CF59E0B),
    swatchColors: [Color(0xFF78350F), Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFF10A868)],
  );

  static const dark = AppThemeData(
    id: 'dark', label: 'Dark Mode', description: 'Night · Battery saver',
    navColor:        Color(0xFF0F172A),
    navColor2:       Color(0xFF020617),
    tripGrad1:       Color(0xFF020617),
    tripGrad2:       Color(0xFF1E293B),
    primary:         Color(0xFF3B82F6),
    primary2:        Color(0xFF60A5FA),
    accent:          Color(0xFFF59E0B),
    success:         Color(0xFF10B981),
    warning:         Color(0xFFF59E0B),
    danger:          Color(0xFFEF4444),
    info:            Color(0xFF60A5FA),
    surface1:        Color(0xFF0F172A),
    surface2:        Color(0xFF1E293B),
    surface3:        Color(0xFF2D3748),
    text:            Color(0xFFF1F5F9),
    textMuted:       Color(0xFF9CA3AF),
    textSecondary:   Color(0xFFCBD5E1),
    border:          Color(0xFF2D3748),
    focusRing:       Color(0xFF60A5FA),
    secondary:   Color(0xFF0F172A),
    activeNode:      Color(0xFF60A5FA),
    activeNodeGlow:  Color(0x4C60A5FA),
    swatchColors: [Color(0xFF0F172A), Color(0xFF1F2937), Color(0xFF3B82F6), Color(0xFF10B981)],
  );

  // All themes in display order
  static const List<AppThemeData> all = [
    navy, brick, forest, midnight, slate, teal, indigo, amber, dark,
  ];

  // Look up by id
  static AppThemeData byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => navy);
}
