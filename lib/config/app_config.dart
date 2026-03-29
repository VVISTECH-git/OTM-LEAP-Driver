library;

/// ╔══════════════════════════════════════════════════════════════════════════╗
/// ║                        APP CONFIG — PER CUSTOMER                        ║
/// ║  This is the ONLY file that changes between customer builds.             ║
/// ╚══════════════════════════════════════════════════════════════════════════╝

class AppConfig {
  AppConfig._();

  // ─── Branding ──────────────────────────────────────────────────────────────
  static const String appName        = 'Leap Driver';
  static const String primaryColorHex = '1847C2';
  static const String navyColorHex    = '0F1F3D';

  // ─── Supabase — LeapPlatform backend ──────────────────────────────────────
  // These are safe to be in the app — anon key has no special privileges
  // All OTM credentials live in Supabase, never in the app
  static const String supabaseUrl        = 'https://hgfezomretctfkdlblpf.supabase.co';
  static const String supabaseAnonKey    = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhnZmV6b21yZXRjdGZrZGxibHBmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1NjAyNjksImV4cCI6MjA4OTEzNjI2OX0.MXu42ddmDxDP-hTvj5Q45JM2e5lKnPpNeO6bWY9qO9w';

  // ─── OTM Domain ────────────────────────────────────────────────────────────
  // Only the domain is needed in the app — used to identify which customer
  // All other OTM config (URL, credentials) lives in Supabase
  static const String otmDomain = 'DEMO';

  // ─── Deep Link ─────────────────────────────────────────────────────────────
  static const String deepLinkHost = 'vvistech.com';
  static const String deepLinkPath = '/shipment';

  // ─── Feature Flags ─────────────────────────────────────────────────────────
  static const bool liveTrackingEnabled  = true;
  static const bool podSignatureEnabled  = true;

  // ─── Color Helpers ─────────────────────────────────────────────────────────
  static int get primaryColor => int.parse('FF$primaryColorHex', radix: 16);
  static int get navyColor    => int.parse('FF$navyColorHex',    radix: 16);
}