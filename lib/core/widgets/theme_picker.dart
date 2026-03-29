import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leapdriver/core/theme/app_theme.dart';
import 'package:leapdriver/core/providers/theme_provider.dart';

/// ThemePicker
///
/// A static helper that shows a modal bottom sheet with 9 theme swatch cards.
/// Call ThemePicker.show(context) from anywhere — typically the palette icon
/// button in the LoadDetailScreen header.
///
/// The sheet matches the visual style of the existing language sheet and
/// live tracking sheet (handle, title, scrollable grid, confirm button).
class ThemePicker {
  ThemePicker._();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ThemePickerSheet(),
    );
  }
}

class _ThemePickerSheet extends StatefulWidget {
  @override
  State<_ThemePickerSheet> createState() => _ThemePickerSheetState();
}

class _ThemePickerSheetState extends State<_ThemePickerSheet> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = context.read<ThemeProvider>().theme.id;
  }

  @override
  Widget build(BuildContext context) {
    final provider   = context.read<ThemeProvider>();
    final sheetBg    = provider.theme.id == 'dark'
        ? const Color(0xFF1E293B)
        : Colors.white;
    final titleColor = provider.theme.id == 'dark'
        ? const Color(0xFFF1F5F9)
        : const Color(0xFF0F1F3D);
    final subColor   = provider.theme.id == 'dark'
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF8892A4);
    final borderCol  = provider.theme.id == 'dark'
        ? const Color(0xFF2D3748)
        : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        16, 16, 16,
        MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: borderCol,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Title row
          Row(children: [
            Text('Choose Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: titleColor)),
            const Spacer(),
            Text('${AppThemes.all.length} themes',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subColor)),
          ]),
          const SizedBox(height: 4),
          Text('Changes apply instantly across the whole app',
              style: TextStyle(fontSize: 12, color: subColor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),

          // Grid — 2 columns
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:   2,
              crossAxisSpacing: 10,
              mainAxisSpacing:  10,
              childAspectRatio: 2.6,
            ),
            itemCount: AppThemes.all.length,
            itemBuilder: (_, i) {
              final t        = AppThemes.all[i];
              final selected = _selectedId == t.id;
              return _SwatchCard(
                theme:    t,
                selected: selected,
                onTap: () async {
                  setState(() => _selectedId = t.id);
                  await provider.setTheme(t);
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Done button — uses the currently active theme's primary color
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
                elevation: 0,
              ),
              child: const Text('Done',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwatchCard extends StatelessWidget {
  final AppThemeData theme;
  final bool         selected;
  final VoidCallback onTap;

  const _SwatchCard({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.read<ThemeProvider>().theme;
    final cardBg   = currentTheme.id == 'dark'
        ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final labelCol = currentTheme.id == 'dark'
        ? const Color(0xFFF1F5F9) : const Color(0xFF0F1F3D);
    final descCol  = currentTheme.id == 'dark'
        ? const Color(0xFF9CA3AF) : const Color(0xFF8892A4);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.navColor.withValues(alpha: 0.08) : cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.primary : (currentTheme.id == 'dark'
                ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0)),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          // 4 color swatches
          Row(
            mainAxisSize: MainAxisSize.min,
            children: theme.swatchColors.map((c) => Container(
              width: 13, height: 13,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
            )).toList(),
          ),
          const SizedBox(width: 8),
          // Name + description
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(theme.label,
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: selected ? theme.primary : labelCol,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(theme.description,
                  style: TextStyle(fontSize: 9, color: descCol, fontWeight: FontWeight.w500),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          )),
          // Selected checkmark
          if (selected)
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(color: theme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
        ]),
      ),
    );
  }
}