import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leapdriver/core/services/deep_link_service.dart';
import 'package:leapdriver/core/providers/locale_provider.dart';
import 'package:leapdriver/core/providers/theme_provider.dart';
import 'package:leapdriver/features/auth/screens/SplashScreen.dart';
import 'package:leapdriver/features/driver/screens/LoadDetailScreen.dart';
import 'package:leapdriver/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeProvider = LocaleProvider();
  final themeProvider  = ThemeProvider();

  // Load saved preferences in the background — same pattern for both providers.
  // Neither call is awaited so the UI renders immediately on first frame.
  unawaited(localeProvider.loadSavedLocale());
  unawaited(themeProvider.loadSavedTheme());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider  = context.watch<ThemeProvider>();

    return DeepLinkHandler(
      onShipmentDeepLink: (String shipmentId) {
        _handleShipmentDeepLink(shipmentId);
      },
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Leap Driver',

        // ── Localizations ──────────────────────────────────────────────
        locale: localeProvider.locale,
        supportedLocales: LocaleProvider.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // ── Theme — driven by ThemeProvider ───────────────────────────
        theme: themeProvider.toMaterialTheme(),

        home: const SplashScreen(),
      ),
    );
  }

  static void _handleShipmentDeepLink(String shipmentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_shipment_id', shipmentId);

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoadDetailScreen(shipmentXid: shipmentId),
        ),
        (route) => false,
      );
    });
  }
}