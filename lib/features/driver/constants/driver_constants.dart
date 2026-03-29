import 'package:leapdriver/config/app_config.dart';

/// Driver Module Constants
///
/// OTM credentials have been removed — they live in Supabase.
/// All API calls go through SupabaseService, not directly to OTM.
class DriverConstants {
  DriverConstants._();

  // ─── Domain ────────────────────────────────────────────────────────────────
  static String get defaultDomain => AppConfig.otmDomain;

  // ─── Live Tracking Config ──────────────────────────────────────────────────
  static const String liveTrackingStatusCode             = 'X6';
  static bool   get   liveTrackingDefaultEnabled         => AppConfig.liveTrackingEnabled;
  static const int    liveTrackingDefaultIntervalMinutes = 5;  // ping every 5 min

  // ─── SharedPreferences keys ────────────────────────────────────────────────
  static const String prefLiveEnabled         = 'live_tracking_enabled';
  static const String prefLiveIntervalMinutes = 'live_tracking_interval_minutes';

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static String getDomainFromShipmentXid(String shipmentXid) {
    final parts = shipmentXid.split('.');
    return parts.isNotEmpty ? parts[0] : defaultDomain;
  }

  static String getShipmentIdFromXid(String shipmentXid) {
    final parts = shipmentXid.split('.');
    return parts.length > 1 ? parts[1] : shipmentXid;
  }
}