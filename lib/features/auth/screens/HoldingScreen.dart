import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leapdriver/core/theme/app_colors.dart';
import 'package:leapdriver/core/theme/app_theme.dart';
import 'package:leapdriver/core/providers/theme_provider.dart';
import 'package:leapdriver/core/providers/locale_provider.dart';

// Colors from AppThemeData — accessed via context.colors

// All UI strings per language — used for live preview as driver taps flags
const _strings = {
  'en': {
    'checkSms':        'Check your SMS',
    'smsInstruction':  'Tap the shipment link sent to your phone to open your trip.',
    'openSmsApp':      'Open your SMS app',
    'smsTapInstruction': 'Tap the link from your dispatcher to get started.',
    'noLoginRequired': 'No login required · Access via SMS link',
    'confirm':         'Confirm Language',
    'saved':           '✓ Language saved',
  },
  'pt': {
    'checkSms':        'Verifique seu SMS',
    'smsInstruction':  'Toque no link de remessa enviado para o seu telefone para abrir sua viagem.',
    'openSmsApp':      'Abra o aplicativo de SMS',
    'smsTapInstruction': 'Toque no link de remessa enviado pelo seu despachante para começar.',
    'noLoginRequired': 'Sem necessidade de login · Acesso fornecido via link SMS',
    'confirm':         'Confirmar Idioma',
    'saved':           '✓ Idioma salvo',
  },
  'pl': {
    'checkSms':        'Sprawdź SMS',
    'smsInstruction':  'Kliknij link przesyłki wysłany na Twój telefon, aby otworzyć trasę.',
    'openSmsApp':      'Otwórz aplikację SMS',
    'smsTapInstruction': 'Kliknij link przesyłki wysłany przez dyspozytora, aby rozpocząć.',
    'noLoginRequired': 'Bez logowania · Dostęp przez link SMS',
    'confirm':         'Potwierdź Język',
    'saved':           '✓ Język zapisany',
  },
  'de': {
    'checkSms':        'SMS prüfen',
    'smsInstruction':  'Tippe auf den Sendungslink auf deinem Telefon, um deine Fahrt zu öffnen.',
    'openSmsApp':      'SMS-App öffnen',
    'smsTapInstruction': 'Tippe auf den Link deines Disponenten, um zu beginnen.',
    'noLoginRequired': 'Kein Login erforderlich · Zugang per SMS-Link',
    'confirm':         'Sprache Bestätigen',
    'saved':           '✓ Sprache gespeichert',
  },
  'hi': {
    'checkSms':        'अपना SMS जांचें',
    'smsInstruction':  'अपनी यात्रा खोलने के लिए फोन पर भेजे गए शिपमेंट लिंक पर टैप करें।',
    'openSmsApp':      'SMS ऐप खोलें',
    'smsTapInstruction': 'शुरू करने के लिए डिस्पैचर द्वारा भेजे गए शिपमेंट लिंक पर टैप करें।',
    'noLoginRequired': 'लॉगिन आवश्यक नहीं · SMS लिंक के माध्यम से पहुंच',
    'confirm':         'भाषा पुष्टि करें',
    'saved':           '✓ भाषा सहेजी गई',
  },
  'es': {
    'checkSms':        'Revisa tu SMS',
    'smsInstruction':  'Toca el enlace del envío enviado a tu teléfono para abrir tu viaje.',
    'openSmsApp':      'Abre la aplicación de SMS',
    'smsTapInstruction': 'Toca el enlace enviado por tu despachador para comenzar.',
    'noLoginRequired': 'Sin inicio de sesión · Acceso por enlace SMS',
    'confirm':         'Confirmar Idioma',
    'saved':           '✓ Idioma guardado',
  },
  'ar': {
    'checkSms':        'تحقق من رسائلك',
    'smsInstruction':  'اضغط على رابط الشحنة المرسل إلى هاتفك لفتح رحلتك.',
    'openSmsApp':      'افتح تطبيق الرسائل',
    'smsTapInstruction': 'اضغط على الرابط المرسل من المرسل لبدء العمل.',
    'noLoginRequired': 'لا يلزم تسجيل الدخول · الوصول عبر رابط SMS',
    'confirm':         'تأكيد اللغة',
    'saved':           '✓ تم حفظ اللغة',
  },
};

String _s(String code, String key) =>
    _strings[code]?[key] ?? _strings['en']![key]!;

class HoldingScreen extends StatefulWidget {
  const HoldingScreen({super.key});

  @override
  State<HoldingScreen> createState() => _HoldingScreenState();
}

class _HoldingScreenState extends State<HoldingScreen> {
  String _selectedCode = 'en';
  bool   _saved        = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = context.read<LocaleProvider>().locale.languageCode;
      setState(() => _selectedCode = current);
    });
  }

  void _selectLanguage(String code) {
    setState(() {
      _selectedCode = code;
      _saved        = false;
    });
  }

  Future<void> _confirmLanguage() async {
    await context.read<LocaleProvider>().setLocale(Locale(_selectedCode));
    if (mounted) setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>(); // rebuild on theme change
    final isRtl = _selectedCode == 'ar';
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface1,
      body: Column(
        children: [

          // ── LEAP brand header ──────────────────────────────────────
          Container(
            width: double.infinity,
            color: c.navColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 22, left: 20, right: 20,
            ),
            child: Column(children: [
              const Text('LEAP',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 36, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: 8, height: 1.0,
                ),
              ),
              const SizedBox(height: 5),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 20, height: 1.5, color: c.accent),
                const SizedBox(width: 8),
                Text('DRIVER',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: c.accent, letterSpacing: 5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 20, height: 1.5, color: c.accent),
              ]),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFF97316))),
                  const SizedBox(width: 6),
                  Text('Powered by Oracle OTM',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans', fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.45),
                      letterSpacing: 0.3,
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 8),
              // Theme picker — bottom-right of header
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    final tp = context.read<ThemeProvider>();
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => ChangeNotifierProvider.value(
                        value: tp,
                        child: const _ThemePickerSheet(),
                      ),
                    );
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Icon(Icons.palette_outlined,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
            ]),
          ),

          // ── Content ────────────────────────────────────────────────
          Expanded(
            child: SafeArea(
              top: false,
              child: Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                const SizedBox(height: 8),

                // ── Main message — live preview in selected language ──
                Text(
                  _s(_selectedCode, 'checkSms'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: c.text, height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _s(_selectedCode, 'smsInstruction'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500,
                    color: c.textMuted, height: 1.6,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Instruction card ──────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: c.surface1,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: c.primary, borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Text('💬', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_s(_selectedCode, 'openSmsApp'), style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800, color: c.text,
                        )),
                        const SizedBox(height: 3),
                        Text(_s(_selectedCode, 'smsTapInstruction'), style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500,
                          color: c.textMuted, height: 1.5,
                        )),
                      ],
                    )),
                  ]),
                ),

                const SizedBox(height: 32),

                // ── Language label ────────────────────────────────────
                Text(
                  'Language · Idioma · Sprache · भाषा · اللغة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10, color: c.textMuted,
                    fontWeight: FontWeight.w600, letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Language picker ───────────────────────────────────
                Wrap(
                  spacing: 8, runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: LocaleProvider.languages.map((lang) {
                    final code     = lang['code']!;
                    final flag     = lang['flag']!;
                    final name     = lang['name']!;
                    final selected = _selectedCode == code;

                    return GestureDetector(
                      onTap: () => _selectLanguage(code),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? c.surface3 : c.surface2,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: selected ? c.primary : c.border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(flag, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(name, style: TextStyle(
                            fontSize: 12,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? c.primary : c.textMuted,
                          )),
                          if (selected) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                color: c.primary, shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ]),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // ── Confirm button — in selected language ─────────────
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _confirmLanguage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _saved ? c.success : c.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _saved
                          ? _s(_selectedCode, 'saved')
                          : _s(_selectedCode, 'confirm'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Footer — in selected language ─────────────────────
                Text(
                  _s(_selectedCode, 'noLoginRequired'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11, color: c.textMuted, fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),            // SafeArea
    ),              // Expanded
        ],          // outer Column children
      ),            // outer Column
    );
  }
}


// ─── Theme picker sheet ───────────────────────────────────────────────────────

class _ThemePickerSheet extends StatelessWidget {
  const _ThemePickerSheet();

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final c  = tp.theme;

    return Container(
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(
          width: 36, height: 4,
          decoration: BoxDecoration(
              color: c.border, borderRadius: BorderRadius.circular(2)),
        )),
        const SizedBox(height: 16),
        Align(alignment: Alignment.centerLeft,
          child: Text('Theme',
            style: TextStyle(fontFamily: 'PlusJakartaSans',
                fontSize: 17, fontWeight: FontWeight.w800, color: c.text))),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10, mainAxisSpacing: 10,
            childAspectRatio: 2.6,
          ),
          itemCount: AppThemes.all.length,
          itemBuilder: (_, i) {
            final theme    = AppThemes.all[i];
            final selected = tp.theme.id == theme.id;
            return GestureDetector(
              onTap: () => tp.setTheme(theme),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? theme.navColor.withValues(alpha: 0.08)
                      : c.surface1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? theme.primary : c.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(children: [
                  Row(mainAxisSize: MainAxisSize.min,
                    children: theme.swatchColors.map((col) => Container(
                      width: 12, height: 12,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                          color: col,
                          borderRadius: BorderRadius.circular(3)),
                    )).toList(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(theme.label,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: selected ? theme.primary : c.text),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(theme.description,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 9, color: c.textMuted),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  )),
                  if (selected)
                    Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                          color: theme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 10),
                    ),
                ]),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
            ),
            child: const Text('Done',
              style: TextStyle(fontFamily: 'PlusJakartaSans',
                  fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}