import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:leapdriver/core/theme/app_colors.dart';
import 'package:leapdriver/core/theme/app_theme.dart';
import 'package:leapdriver/core/providers/theme_provider.dart';
import 'package:leapdriver/core/widgets/theme_picker.dart';
import 'package:leapdriver/features/driver/constants/driver_constants.dart';
import 'package:leapdriver/core/services/supabase_service.dart';
import 'package:leapdriver/features/driver/models/shipment_models.dart';
import 'package:leapdriver/features/driver/services/live_tracking_service.dart';
import 'package:leapdriver/features/driver/screens/TripCompletionScreen.dart';
import 'package:leapdriver/features/driver/screens/PodUploadScreen.dart';
import 'package:leapdriver/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:leapdriver/core/providers/locale_provider.dart';

// ─── Semantic color helpers ───────────────────────────────────────────────────
// These replace the old hardcoded const Color values at the top of the file.
// Usage inside State methods: final c = context.colors; then c.primary, c.text, etc.
// For places that need a Color before build context is available, fall back to
// AppThemes.navy.xxx — but in practice all color usage is inside build/widgets.

// ─── Stage ────────────────────────────────────────────────────────────────────
enum TripStage {
  pending, accepted, enroutePickup, atPickup,
  inTransit, atDelivery, delivered, completed, declined,
}

class _StageCfg {
  final String label;
  final String btnLabel;
  final Color  btnColor;
  final Color  pillBg;
  final Color  pillFg;
  const _StageCfg(this.label, this.btnLabel, this.btnColor, this.pillBg, this.pillFg);
}

// _stages is now built dynamically via _buildStages(l) inside the widget
// keeping _stageOrder for internal logic only
Map<TripStage, _StageCfg> _buildStages(AppLocalizations l, AppThemeData c) => {
  TripStage.pending:       _StageCfg(l.pendingAcceptance, l.acceptLoad,          c.primary,  const Color(0x26FFB400), const Color(0xFFFFB400)),
  TripStage.accepted:      _StageCfg(l.accepted,          l.startTrip,            c.secondary, const Color(0x33466DE3), const Color(0xFF7EB3FF)),
  TripStage.enroutePickup: _StageCfg(l.enRoutePickup,     l.arrivedAtPickup,     c.warning,  const Color(0x33E8720A), const Color(0xFFFFAA5A)),
  TripStage.atPickup:      _StageCfg(l.atPickup,          l.loaded,              c.success,  const Color(0x3310A868), const Color(0xFF4CDEAA)),
  TripStage.inTransit:     _StageCfg(l.inTransit,         l.arrivedAtDelivery,   c.warning,  const Color(0x33466DE3), const Color(0xFF7EB3FF)),
  TripStage.atDelivery:    _StageCfg(l.atDelivery,        l.deliveredBtn,        c.success,  const Color(0x330891B2), const Color(0xFF67E8F9)),
  TripStage.delivered:     _StageCfg(l.delivered,         l.completeTrip,        c.secondary, const Color(0x3310A868), const Color(0xFF4CDEAA)),
  TripStage.completed:     _StageCfg(l.completed,         '',                    c.secondary, const Color(0x3310A868), const Color(0xFF4CDEAA)),
  TripStage.declined:      _StageCfg(l.declined,          '',                    c.danger,   const Color(0x33E01E35), const Color(0xFFFF6B6B)),
};

// Top-level function required by compute() — must not be a closure or method.
// Runs ShipmentDetail.fromJson in a background isolate to keep the main thread free.
ShipmentDetail _parseShipmentDetail(Map<String, dynamic> raw) =>
    ShipmentDetail.fromJson(raw);

// ─── Screen ───────────────────────────────────────────────────────────────────
class LoadDetailScreen extends StatefulWidget {
  final String shipmentXid;
  const LoadDetailScreen({super.key, required this.shipmentXid});

  @override
  State<LoadDetailScreen> createState() => _LoadDetailScreenState();
}

class _LoadDetailScreenState extends State<LoadDetailScreen> {

  ShipmentDetail? _detail;
  bool      _loading      = true;   // initial load only
  bool      _refreshing   = false;  // background refresh after API actions
  String?   _error;
  bool      _busy         = false;
  bool      _infoExpanded = false;
  TripStage _stage        = TripStage.pending;

  // Tracks which API events have been posted per stop (arrival / departure / pod)
  // Populated from API on load, updated locally after each post.
  final Map<int, Set<String>> _stopActions = {};

  // Uploaded documents
  final Set<String> _uploadedDocs = {};

  // Expanded done-stop tracker
  int? _expandedDoneStop;

  // Stop order — driver can swap stops before trip starts
  List<ShipmentStop> _orderedStops = [];

  // Skipped stops — stopNum → reason code
  final Map<int, String> _skippedStops = {};


  // Decline modal selection
  String? _declineReason;

  // Extra API fields
  double? _distanceKm;
  String? _equipment;
  bool    _isHazardous   = false;
  bool    _isTempControl = false;

  // ─── Live Tracking ─────────────────────────────────────────────────────────
  bool  _liveEnabled         = DriverConstants.liveTrackingDefaultEnabled;
  final int _liveIntervalMinutes = DriverConstants.liveTrackingDefaultIntervalMinutes;

  // Localizations shortcut
  AppLocalizations get _l => AppLocalizations.of(context);
  // Theme shortcut — use c.primary, c.text, c.surface2 etc. anywhere in build
  AppThemeData get _c => context.colors;
  Map<TripStage, _StageCfg> get _stages => _buildStages(_l, _c);

  @override
  void initState() {
    super.initState();
    // Defer all async startup work to after the first frame is rendered.
    // Calling SharedPreferences + network directly in initState blocks the
    // main thread before Flutter can draw anything, causing ANR on slow devices.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadLiveSettings();
        _fetch();
      }
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LIVE TRACKING
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _loadLiveSettings() async {
    final enabled = await LiveTrackingService.loadEnabled();
    setState(() { _liveEnabled = enabled; });
  }

  Future<void> _saveLiveSettings() async {
    await LiveTrackingService.saveSettings(
      enabled:         _liveEnabled,
      intervalMinutes: _liveIntervalMinutes,
    );
    if (_isActiveTrip && _liveEnabled) {
      await LiveTrackingService.instance.updateSettings(
        intervalMinutes: _liveIntervalMinutes,
      );
    }
  }

  bool get _isActiveTrip => [
    TripStage.enroutePickup, TripStage.atPickup,
    TripStage.inTransit, TripStage.atDelivery, TripStage.delivered,
  ].contains(_stage);

  Future<void> _startLiveTracking() async {
    if (!_liveEnabled) return;
    final dom = DriverConstants.getDomainFromShipmentXid(widget.shipmentXid);
    await LiveTrackingService.instance.start(shipmentXid: widget.shipmentXid, domain: dom);
    _snack('📡 Live tracking started · X6 every $_liveIntervalMinutes min', _c.success);
  }

  Future<void> _stopLiveTracking() async {
    await LiveTrackingService.instance.stop();
  }

  void _pauseLiveTracking() {
    LiveTrackingService.instance.pause();
    setState(() {});
    _snack('📡 Live tracking paused', _c.warning);
  }

  Future<void> _resumeLiveTracking() async {
    await LiveTrackingService.instance.resume();
    setState(() {});
    _snack('📡 Live tracking resumed', _c.success);
  }

  void _showLiveSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          decoration: BoxDecoration(
            color: _c.surface2,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: _c.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0))),
                child: const Center(child: Text('📡', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_l.locationSharing, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _c.text)),
                SizedBox(height: 2),
                Text(_l.yourDispatcherSees,
                    style: TextStyle(fontSize: 12, color: _c.textMuted, fontWeight: FontWeight.w500)),
              ])),
            ]),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: _c.surface1, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _c.border)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_l.shareMyLocation,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _c.text)),
                  SizedBox(height: 3),
                  Text(_l.updatesAutomatically,
                      style: TextStyle(fontSize: 12, color: _c.textMuted, fontWeight: FontWeight.w500)),
                ])),
                Switch(
                  value: _liveEnabled,
                  onChanged: (v) { setModal(() {}); setState(() => _liveEnabled = v); },
                  activeThumbColor: _c.success,
                ),
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _saveLiveSettings();
                  _snack(
                    _liveEnabled ? _l.locationSharingOn : _l.locationSharingOff,
                    _liveEnabled ? _c.success : _c.textSecondary,
                  );
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _c.secondary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_l.save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ),
    );
  }


  void _showPauseConfirm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: _c.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            Container(width: 42, height: 42,
              decoration: BoxDecoration(color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFED7AA))),
              child: const Center(child: Text('⏸', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_l.pauseTracking,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _c.text)),
              SizedBox(height: 2),
              Text(_l.pauseTrackingMsg,
                  style: TextStyle(fontSize: 12, color: _c.textMuted, fontWeight: FontWeight.w600)),
            ])),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFED7AA))),
            child:       Row(children: [
              Text('⚠️', style: TextStyle(fontSize: 14)),
              SizedBox(width: 8),
              Expanded(child: Text(
                'The dispatcher will no longer see your live position. Tap the Live badge to resume.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _c.warning, height: 1.5),
              )),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(side: BorderSide(color: _c.border),
                  foregroundColor: _c.textSecondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(0, 48)),
              child: Text(_l.cancel, style: const TextStyle(fontWeight: FontWeight.w700)),
            )),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(
              onPressed: () { Navigator.pop(context); _pauseLiveTracking(); },
              style: ElevatedButton.styleFrom(backgroundColor: _c.warning, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(0, 48)),
              child: Text(_l.pauseTrackingBtn, style: const TextStyle(fontWeight: FontWeight.w800)),
            )),
          ]),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _fetch({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() { _refreshing = true; _error = null; _busy = false; });
    } else {
      setState(() { _loading = true; _error = null; _busy = false; });
    }
    try {
      final data = await SupabaseService.getShipment(widget.shipmentXid);
      if (data['items'] != null && (data['items'] as List).isNotEmpty) {
        final raw = data['items'][0] as Map<String, dynamic>;

        // Parse JSON model in a background isolate — avoids blocking the main
        // thread (and triggering ANR) when the payload is large.
        final detail = await compute(_parseShipmentDetail, raw);

        double? distKm;
        if (raw['loadedDistance'] != null) {
          final v = (raw['loadedDistance']['value'] ?? 0).toDouble();
          final u = (raw['loadedDistance']['unit'] ?? '').toString().toUpperCase();
          distKm  = u == 'MI' ? v * 1.60934 : v;
        }

        String? equip;
        if (raw['firstEquipmentGroupGid'] != null) {
          final s = raw['firstEquipmentGroupGid'].toString();
          equip   = s.contains('.') ? s.split('.').skip(1).join('.') : s;
        }

        if (!mounted) return;
        setState(() {
          _detail        = detail;
          _distanceKm    = distKm;
          _equipment     = equip;
          _isHazardous   = raw['isHazardous'] == true;
          _isTempControl = raw['isTemperatureControl'] == true;
          _loading       = false;
          _refreshing    = false;
          _initStopActions(detail);
          _deriveStage(detail);
          if (_orderedStops.isEmpty) {
            _orderedStops = List.from(detail.stops);
          }
          // Seed uploaded docs from OTM — survives app restarts
          final docKeys = raw['uploadedDocKeys'];
          if (docKeys is List) {
            for (final k in docKeys) {
              if (k is String) _uploadedDocs.add(k);
            }
          }
        });
        // Only start live tracking on initial load — not on pull-to-refresh
        // On refresh, tracking is already running if it was started before
        if (_isActiveTrip && !isRefresh) unawaited(_startLiveTracking());
      } else {
        setState(() { _error = 'Shipment not found'; _loading = false; _refreshing = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; _refreshing = false; });
    }
  }

  // Seed _stopActions from API tracking events
  void _initStopActions(ShipmentDetail d) {
    _stopActions.clear();
    for (final s in d.stops) { _stopActions[s.stopNum] = {}; }
    for (final e in d.trackingEvents) {
      _stopActions[e.shipmentStopNum] ??= {};
      if (e.statusCodeGid == 'X3' || e.statusCodeGid == 'X1') _stopActions[e.shipmentStopNum]!.add('arrival');
      if (e.statusCodeGid == 'AF')                             _stopActions[e.shipmentStopNum]!.add('departure');
      if (e.statusCodeGid == 'CD')                             _stopActions[e.shipmentStopNum]!.add('pod');
    }
  }

  // Derive UI stage from API status + tracking events
  void _deriveStage(ShipmentDetail d) {
    final ts    = d.tripStatus;
    final codes = d.trackingEvents.map((e) => e.statusCodeGid).toSet();
    if (ts == 'COMPLETED')   { _stage = TripStage.completed;    return; }
    if (ts == 'IN_PROGRESS') {
      if (codes.contains('CD')) { _stage = TripStage.delivered;    return; }
      if (codes.contains('X1')) { _stage = TripStage.atDelivery;   return; }
      if (codes.contains('AF')) { _stage = TripStage.inTransit;    return; }
      if (codes.contains('X3')) { _stage = TripStage.atPickup;     return; }
      _stage = TripStage.enroutePickup; return;
    }    if (_stage != TripStage.accepted && _stage != TripStage.declined) {
      _stage = TripStage.pending;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // API CALLS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _postEvent(String code, int stopNum) async {
    setState(() => _busy = true);
    try {
      final now    = DateTime.now();
      final offset = now.timeZoneOffset;
      final sign   = offset.isNegative ? '-' : '+';
      final tz     = '$sign${offset.inHours.abs().toString().padLeft(2, '0')}:'
                     '${offset.inMinutes.remainder(60).abs().toString().padLeft(2, '0')}';
      final evDt   = '${now.toIso8601String().split('.')[0]}$tz';
      await SupabaseService.postEvent(widget.shipmentXid, {
        'statusCodeGid':      code,
        'eventdate':          {'value': evDt},
        'responsiblePartyGid': 'CARRIER',
        'stops':              {'items': [{'stopSequence': stopNum}]},
      });
      setState(() {
        _stopActions[stopNum] ??= {};
        final ak = (code == 'X3' || code == 'X1') ? 'arrival' : code == 'AF' ? 'departure' : 'pod';
        _stopActions[stopNum]!.add(ak);
      });
    } catch (e) {
      _snack('Failed: $e', _c.danger);
      rethrow;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // Fetch fresh trackingEvents from OTM before posting.
  // If the event already exists for this stop, skip the post and
  // just advance the stage — prevents duplicates across sessions.
  Future<bool> _verifyAndPost(String code, int stopNum) async {
    setState(() => _busy = true);
    try {
      // Fresh fetch from OTM
      final data = await SupabaseService.getShipment(widget.shipmentXid);
      if (data['items'] != null && (data['items'] as List).isNotEmpty) {
        final raw    = data['items'][0] as Map<String, dynamic>;
        final detail = await compute(_parseShipmentDetail, raw);
        _initStopActions(detail);   // re-seed stopActions from latest OTM data
      }

      // Check if already posted
      final actionKey = (code == 'X3' || code == 'X1')
          ? 'arrival'
          : code == 'AF'
              ? 'departure'
              : 'pod';

      if (_stopActions[stopNum]?.contains(actionKey) == true) {
        _snack('Already recorded — advancing', _c.info);
        return false;   // caller advances stage, no post needed
      }

      // Not yet posted — go ahead
      await _postEvent(code, stopNum);
      return true;

    } catch (e) {
      _snack('Failed: $e', _c.danger);
      rethrow;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIMARY BUTTON — single entry point for all stage transitions
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _onPrimary() async {
    if (_busy) return;
    final stops = _orderedStops.isNotEmpty ? _orderedStops : (_detail?.stops ?? []);
    final first = stops.isNotEmpty ? stops.first : null;
    // Current active stop = first stop that is not done/skipped
    final curr  = stops.firstWhere((s) => !_stopIsDone(s), orElse: () => stops.last);

    switch (_stage) {
      case TripStage.pending:
        // Accept — local only, no API call needed
        setState(() => _stage = TripStage.accepted);
        break;

      case TripStage.accepted:
        // Start Trip — PATCH trip status to IN_PROGRESS, then advance locally
        setState(() => _busy = true);
        try {
          await SupabaseService.patchStatus(widget.shipmentXid, 'IN_PROGRESS');
          if (mounted) setState(() => _stage = TripStage.enroutePickup);
          unawaited(_startLiveTracking());
        } catch (e) {
          _snack('Failed: $e', _c.danger);
        } finally {
          if (mounted) setState(() => _busy = false);
        }
        break;

      case TripStage.enroutePickup:
        if (first == null) return;
        try {
          await _verifyAndPost('X3', first.stopNum);
          _pauseLiveTracking();           // truck is at pickup — stop pinging
          if (mounted) setState(() => _stage = TripStage.atPickup);
        } catch (e) {
          _snack(_l.couldNotUpdate, _c.danger);
        } finally {
          if (mounted) setState(() => _busy = false);
        }
        break;

      case TripStage.atPickup:
        if (first == null) return;
        try {
          await _verifyAndPost('AF', first.stopNum);
          unawaited(_resumeLiveTracking()); // truck is moving again — resume pinging
          if (mounted) setState(() => _stage = TripStage.inTransit);
        } catch (e) {
          _snack(_l.couldNotUpdate, _c.danger);
        } finally {
          if (mounted) setState(() => _busy = false);
        }
        break;

      case TripStage.inTransit:
        if (stops.isEmpty) return;
        try {
          await _verifyAndPost('X1', curr.stopNum);
          _pauseLiveTracking();           // truck is at delivery — stop pinging
          if (mounted) setState(() => _stage = TripStage.atDelivery);
        } catch (e) {
          _snack(_l.couldNotUpdate, _c.danger);
        } finally {
          if (mounted) setState(() => _busy = false);
        }
        break;

      case TripStage.atDelivery:
        if (stops.isEmpty) return;
        // Require POD for this specific delivery stop before marking as delivered
        final delivStops = stops.where((s) =>
            s.stopType == StopType.drop || s.stopType == StopType.pickAndDrop).toList();
        final currPodKey = delivStops.length == 1 ? 'pod' : 'pod_stop_${curr.stopNum}';
        final isDelivStop = curr.stopType == StopType.drop || curr.stopType == StopType.pickAndDrop;
        if (isDelivStop && !_uploadedDocs.contains(currPodKey)) {
          _snack('Upload POD for this stop before marking as delivered', _c.danger);
          _showDocsSheet();
          return;
        }
        try {
          await _verifyAndPost('CD', curr.stopNum);
          _pauseLiveTracking();           // delivered — no more pinging until complete
          // Check if more stops remain
          final remaining = stops.where((s) => !_stopIsDone(s)).toList();
          if (remaining.isEmpty) {
            if (mounted) setState(() => _stage = TripStage.delivered);
          } else {
            // More stops to deliver — go back to inTransit
            unawaited(_resumeLiveTracking());
            if (mounted) setState(() => _stage = TripStage.inTransit);
          }
        } catch (e) {
          _snack(_l.couldNotUpdate, _c.danger);
        } finally {
          if (mounted) setState(() => _busy = false);
        }
        break;

      case TripStage.delivered:
        // Complete Trip — requires POD for every non-skipped delivery stop
        if (_anyPodMissing()) {
          _snack(_l.uploadPodFirst, _c.danger);
          _showDocsSheet();
          return;
        }
        setState(() => _busy = true);
        try {
          await SupabaseService.patchStatus(widget.shipmentXid, 'COMPLETED');
          await _stopLiveTracking();
          if (mounted) {
            final origin = _detail?.sourceLocation?.city
                ?? _detail?.sourceLocation?.locationName ?? '—';
            final destination = _detail?.destLocation?.city
                ?? _detail?.destLocation?.locationName ?? '—';
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => TripCompletionScreen(
                  shipmentXid: widget.shipmentXid,
                  origin: origin,
                  destination: destination,
                  distanceKm: _distanceKm,
                  stopCount: _detail?.stops.length,
                ),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 500),
              ),
              (route) => false,
            );
          }
        } catch (e) {
          _snack('Failed: $e', _c.danger);
        } finally {
          if (mounted) setState(() => _busy = false);
        }
        break;

      default:
        break;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    // Subscribe to theme changes — rebuilds the whole screen when theme switches
    context.watch<ThemeProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) { if (!didPop) SystemNavigator.pop(); },
      child: Scaffold(
        backgroundColor: _c.surface1,
        body: SafeArea(
          child: _loading
              ? _buildLoading()
              : _error != null
                  ? _buildError()
                  : _detail == null
                      ? Center(child: Text(_l.noData))
                      : _buildApp(),
        ),
      ),
    );
  }

  Widget _buildApp() {
    if (_stage == TripStage.completed) {
      // Navigate to TripCompletionScreen — do it after build via addPostFrameCallback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final origin = _detail?.sourceLocation?.city
            ?? _detail?.sourceLocation?.locationName ?? '—';
        final destination = _detail?.destLocation?.city
            ?? _detail?.destLocation?.locationName ?? '—';
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => TripCompletionScreen(
              shipmentXid: widget.shipmentXid,
              origin: origin,
              destination: destination,
              distanceKm: _distanceKm,
              stopCount: _detail?.stops.length,
            ),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
          (route) => false,
        );
      });
      return const SizedBox.shrink(); // temporary placeholder during transition
    }
    if (_stage == TripStage.declined)  return _buildDeclined();
    return Column(children: [
      // Subtle top progress bar during background refresh — never blocks the UI
      if (_refreshing)
        LinearProgressIndicator(
          backgroundColor: _c.secondary.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation(_c.primary2),
          minHeight: 2,
        ),
      _buildStageNav(),
      _buildHeader(),
      _buildTripBar(),
      _buildQuickActions(),
      Expanded(child: _buildScroll()),
      _buildActionZone(),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOADING / ERROR
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLoading() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    CircularProgressIndicator(color: _c.primary, strokeWidth: 2.5),
    const SizedBox(height: 16),
    Text(_l.loadingShipment, style: _ts(13, _c.textSecondary, FontWeight.w600)),
  ]));

  Widget _buildError() => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(
    mainAxisSize: MainAxisSize.min, children: [
      const Text('⚠️', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text(_l.unableToLoad, style: _ts(18, _c.text, FontWeight.w800)),
      const SizedBox(height: 8),
      Text(_error!, textAlign: TextAlign.center, style: _ts(12, _c.textMuted, FontWeight.w500)),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _fetch,
        style: ElevatedButton.styleFrom(backgroundColor: _c.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: Text(_l.retry),
      ),
    ],
  )));

  // ══════════════════════════════════════════════════════════════════════════
  // STAGE NAV — removed, merged into header
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStageNav() => const SizedBox.shrink();

  // ══════════════════════════════════════════════════════════════════════════
  // HEADER — shipment ID + bold status + stop progress
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    final cfg        = _stages[_stage]!;
    final stops      = _detail?.stops ?? [];
    final doneCount  = stops.where(_stopIsDone).length;
    final totalStops = stops.length;

    final rawId     = _detail?.shipmentXid ?? widget.shipmentXid;
    final displayId = rawId.contains('.') ? rawId.split('.').last : rawId;

    final String progressLine;
    switch (_stage) {
      case TripStage.pending:
      case TripStage.accepted:
        progressLine = totalStops > 0 ? _l.stopsNotStarted(totalStops) : _l.notStarted;
        break;
      case TripStage.enroutePickup:
        progressLine = _l.headingToPickup;
        break;
      case TripStage.inTransit:
        progressLine = _l.inTransit;
        break;
      case TripStage.delivered:
        progressLine = _l.allStopsDone;
        break;
      case TripStage.completed:
        progressLine = _l.tripCompleted;
        break;
      default:
        progressLine = totalStops > 0 ? _l.stopProgress(doneCount + 1, totalStops) : cfg.label;
    }

    return Container(
      color: _c.navColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: icons + status pill ──────────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: () => ThemePicker.show(context),
                child: Container(
                  width: 34, height: 34,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Center(child: _PaletteIcon(swatchColors: _c.swatchColors)),
                ),
              ),
              GestureDetector(
                onTap: _showLanguageSheet,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Center(child: Text('🌐', style: TextStyle(fontSize: 15))),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: cfg.pillBg, borderRadius: BorderRadius.circular(100)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 7, height: 7,
                      decoration: BoxDecoration(color: cfg.pillFg, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(cfg.label, style: _ts(12, cfg.pillFg, FontWeight.w700)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Row 2: shipment ID full width ────────────────────────────
          Text(_l.shipment, style: _ts(9, Colors.white.withValues(alpha: 0.4), FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            '#$displayId',
            style: _ts(28, Colors.white, FontWeight.w800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // ── Row 3: progress bar ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(children: [
              Text(_stageIcon(_stage), style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(child: Text(progressLine, style: _ts(14, Colors.white, FontWeight.w600))),
            ]),
          ),
        ],
      ),
    );
  }

  String _stageIcon(TripStage stage) {
    switch (stage) {
      case TripStage.pending:       return '⏳';
      case TripStage.accepted:      return '✅';
      case TripStage.enroutePickup: return '🚛';
      case TripStage.atPickup:      return '📍';
      case TripStage.inTransit:     return '🚛';
      case TripStage.atDelivery:    return '📍';
      case TripStage.delivered:     return '📦';
      case TripStage.completed:     return '🏁';
      case TripStage.declined:      return '❌';
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TRIP BAR
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTripBar() {
    final stops = _detail!.numStops > 0 ? _detail!.numStops : _detail!.stops.length;
    final dist  = _distanceKm != null ? '${_distanceKm!.toStringAsFixed(0)} km' : '—';
    final equip = _equipment ?? '—';
    return Container(
      decoration:       BoxDecoration(
        gradient: LinearGradient(colors: [_c.tripGrad1, _c.tripGrad2]),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        _tbi('📍', dist),
        _tbSep(),
        _tbi('🛑', '$stops ${_l.stops.toLowerCase()}'),
        _tbSep(),
        _tbi('🚛', equip),
      ]),
    );
  }

  Widget _tbi(String icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(icon, style: const TextStyle(fontSize: 12)),
    const SizedBox(width: 4),
    Text(text, style: _ts(11, const Color(0xD9FFFFFF), FontWeight.w600)),
  ]);

  Widget _tbSep() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 7),
    child: Text('·', style: _ts(14, const Color(0x33FFFFFF), FontWeight.w400)),
  );


  // ══════════════════════════════════════════════════════════════════════════
  // QUICK ACTIONS — 5 buttons: Call Pickup, Call Delivery, Navigate, Docs, Issue
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildQuickActions() {
    final podRequired  = _stage == TripStage.atDelivery || _stage == TripStage.delivered;
    final podMissing   = podRequired && _anyPodMissing();
    final docsLabel    = podMissing ? _l.uploadPod : _l.pod;

    final isRunning = LiveTrackingService.instance.isRunning;
    final isPaused  = LiveTrackingService.instance.isPaused;

    // ── Stage gates — what is allowed at each stage ──────────────────────
    final canNavigate  = _stage != TripStage.pending;
    final canDocs      = _stage == TripStage.atDelivery ||
                         _stage == TripStage.delivered  ||
                         _stage == TripStage.inTransit;   // view-only in transit
    final canEpod      = _stage == TripStage.atDelivery || _stage == TripStage.delivered;
    final canIssue     = _stage != TripStage.pending;

    return Container(
      color: _c.surface2,
      child: Row(children: [
        _qaBtn(Icons.navigation_rounded, _l.navigate,
            canNavigate ? _onNavigate : () => _snack('Accept the load first', _c.warning),
            canNavigate ? _c.primary : _c.textMuted, false),
        _qaBtn(Icons.insert_drive_file_rounded, docsLabel,
            canDocs ? _showDocsSheet : () => _snack('Documents available after trip starts', _c.warning),
            canDocs ? (podMissing ? _c.danger : const Color(0xFF7C3AED)) : _c.textMuted, false,
            badge: canDocs ? _uploadedDocs.length : 0,
            disabled: !canDocs),
        _qaBtn(Icons.draw_rounded, 'e-POD',
            canEpod ? _showEPodSheet : () => _snack('e-POD available at delivery stop', _c.warning),
            canEpod ? const Color(0xFF7C3AED) : _c.textMuted, false,
            disabled: !canEpod),
        _qaBtn(
          Icons.sensors_rounded,
          isRunning ? 'Tracking' : isPaused ? 'Paused' : 'Live Track',
          () {
            if (_isActiveTrip && isRunning)  { _showPauseConfirm(); return; }
            if (_isActiveTrip && isPaused)   { _resumeLiveTracking(); return; }
            if (!_isActiveTrip) { _snack('Live tracking starts when trip begins', _c.warning); return; }
            _showLiveSheet();
          },
          isRunning ? _c.success : isPaused ? _c.warning : _c.info,
          false,
          disabled: !_isActiveTrip && !isRunning && !isPaused,
        ),
        _qaBtn(Icons.warning_amber_rounded, _l.issue,
            canIssue ? _showIssueSheet : () => _snack('Accept the load first', _c.warning),
            canIssue ? _c.danger : _c.textMuted, true,
            disabled: !canIssue),
      ]),
    );
  }

  void _showEPodSheet() {
    _snack('e-POD coming soon', _c.info);
  }

  Widget _qaBtn(IconData icon, String label, VoidCallback onTap, Color iconColor, bool isLast,
      {int badge = 0, bool disabled = false}) {
    final effectiveColor = disabled ? _c.textMuted.withValues(alpha: 0.4) : iconColor;
    return Expanded(child: InkWell(
      onTap: onTap,
      splashColor: effectiveColor.withValues(alpha: 0.1),
      highlightColor: effectiveColor.withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: disabled ? _c.surface1.withValues(alpha: 0.5) : null,
          border: Border(
            right: !isLast ? BorderSide(color: _c.border) : BorderSide.none,
            bottom: BorderSide(color: _c.border),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: effectiveColor.withValues(alpha: disabled ? 0.05 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: effectiveColor),
            ),
            if (badge > 0 && !disabled) Positioned(
              top: -3, right: -3,
              child: Container(
                width: 16, height: 16,
                decoration: BoxDecoration(
                  color: badge == 4 ? _c.success : _c.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: _c.surface2, width: 1.5),
                ),
                child: Center(child: Text('$badge',
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white))),
              ),
            ),
          ]),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center,
              style: _ts(9, disabled ? _c.textMuted.withValues(alpha: 0.4) : _c.textSecondary, FontWeight.w700),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    ));
  }

  void _onNavigate() {
    final stops = _detail?.stops ?? [];
    final target = stops.firstWhere((s) => !_stopIsDone(s), orElse: () => stops.last);
    _snack('${_l.openingMaps} ${target.locationName}', _c.info);
  }

  // Contact sheet — shows name + number before dialing


  // Issue sheet — moved from scroll content, always one tap away
  void _showIssueSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: _c.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerLeft,
              child: Text(_l.reportIssue, style: _ts(17, _c.text, FontWeight.w700))),
          const SizedBox(height: 4),
          Align(alignment: Alignment.centerLeft,
              child: Text(_l.dispatcherNotified,
                  style: _ts(13, _c.textMuted, FontWeight.w500))),
          const SizedBox(height: 16),
          Row(children: [
            _issueBtn('⏰', _l.delay, _c.warning,  Color(0xFFFED7AA), Color(0xFFFFF7ED)),
            const SizedBox(width: 10),
            _issueBtn('🔧', _l.breakdown, _c.danger,    Color(0xFFFECACA), Color(0xFFFFF5F5)),
            const SizedBox(width: 10),
            _issueBtn('📷', _l.damage, _c.danger,    Color(0xFFFECACA), Color(0xFFFFF5F5)),
          ]),
        ]),
      ),
    );
  }

  Widget _issueBtn(String icon, String label, Color fg, Color borderColor, Color bg) {
    return Expanded(child: GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _snack('Dispatcher notified — $label reported', _c.warning);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(label, style: _ts(12, fg, FontWeight.w700)),
        ]),
      ),
    ));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LANGUAGE SHEET — accessible while en-route via 🌐 button in header
  // ══════════════════════════════════════════════════════════════════════════

  void _showLanguageSheet() {
    final localeProvider = context.read<LocaleProvider>();
    String selectedCode  = localeProvider.locale.languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          decoration: BoxDecoration(
            color: _c.surface2,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: _c.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [
              const Text('🌐', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text('Language', style: _ts(17, _c.text, FontWeight.w800)),
            ]),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              alignment: WrapAlignment.start,
              children: LocaleProvider.languages.map((lang) {
                final code     = lang['code']!;
                final flag     = lang['flag']!;
                final name     = lang['name']!;
                final selected = selectedCode == code;
                return GestureDetector(
                  onTap: () {
                    setModal(() => selectedCode = code);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFEEF2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: selected ? _c.primary : _c.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(flag, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(name, style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? _c.primary : _c.textMuted,
                      )),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  await localeProvider.setLocale(Locale(selectedCode));
                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {}); // rebuild with new locale
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _c.secondary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                child: Text(_getConfirmLabel(selectedCode), style: _ts(16, Colors.white, FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SCROLL CONTENT
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildScroll() {
    return RefreshIndicator(
      onRefresh: () => _fetch(isRefresh: true),
      color: _c.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        child: Column(children: [
          _buildInfoCard(),
          const SizedBox(height: 9),
          _buildTimeline(),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INFO CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildInfoCard() {
    final d  = _detail!;
    final wt = d.totalWeight != null
        ? '${d.totalWeight!.value.toStringAsFixed(1)} ${d.totalWeight!.unit}'
        : null;

    return _card(child: Column(children: [
      InkWell(
        onTap: () => setState(() => _infoExpanded = !_infoExpanded),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(children: [
            Text(_l.loadInformation, style: _ts(10, _c.textMuted, FontWeight.w700)),
            const Spacer(),
            AnimatedRotation(
              turns: _infoExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.keyboard_arrow_down_rounded, color: _c.textMuted, size: 18),
            ),
          ]),
        ),
      ),
      if (_infoExpanded) ...[
        Divider(height: 1, color: _c.border),
        // ── Route section ──────────────────────────────────────
        _igSectionHeader(_l.routeSection),
        _igGrid([
          [_l.origin,    d.sourceLocation?.locationName ?? '—'],
          [_l.destination, d.destLocation?.locationName ?? '—'],
          [_l.pickup,    _fmtDT(d.startTime)],
          [_l.delivery,  _fmtDT(d.endTime)],
          [_l.stops,     '${d.numStops > 0 ? d.numStops : d.stops.length}'],
          [_l.distance,  _distanceKm != null ? '${_distanceKm!.toStringAsFixed(0)} km' : '—'],
        ]),
        // ── Load Details section ────────────────────────────────
        _igSectionHeader(_l.loadDetailsSection),
        _igGrid([
          [_l.equipment,    _equipment ?? '—'],
          [_l.weight,       wt ?? '—'],
          [_l.hazardous,    _isHazardous   ? _l.yes : _l.no],
          [_l.tempControl, _isTempControl ? _l.yesTemp : _l.no],
        ]),
      ],
    ]));
  }

  Widget _igGrid(List<List<String>> rows) {
    return Column(children: List.generate((rows.length / 2).ceil(), (ri) {
      final l = rows[ri * 2];
      final r = ri * 2 + 1 < rows.length ? rows[ri * 2 + 1] : null;
      return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: _igCell(l[0], l[1], rightBorder: true)),
        Expanded(child: r != null ? _igCell(r[0], r[1]) : const SizedBox()),
      ]));
    }));
  }

  Widget _igCell(String label, String value, {bool rightBorder = false}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(border: Border(
        right: rightBorder ? BorderSide(color: _c.border) : BorderSide.none,
        top: BorderSide(color: _c.border),
      )),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: _ts(9, _c.textMuted, FontWeight.w700)),
        const SizedBox(height: 3),
        Text(value, style: _ts(13, _c.text, FontWeight.w600)),
      ]),
    );
  }

  Widget _igSectionHeader(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      decoration:       BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: _c.border)),
      ),
      child: Text(text, style: _ts(10, _c.textSecondary, FontWeight.w700)),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STOP TIMELINE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTimeline() {
    final stops     = _orderedStops.isNotEmpty ? _orderedStops : (_detail?.stops ?? []);
    final events    = _detail!.trackingEvents;
    final doneCount = stops.where(_stopIsDone).length;
    final canSwap   = stops.length > 1 &&
                      (_stage == TripStage.pending ||
                       _stage == TripStage.accepted ||
                       _stage == TripStage.inTransit);  // also allow during transit

    String progLabel;
    if (_stage == TripStage.pending || _stage == TripStage.accepted) {
      progLabel = _l.notStarted;
    } else if (_stage == TripStage.inTransit) {
      progLabel = _l.inTransit;
    } else if (doneCount == stops.length) {
      progLabel = _l.allDone;
    } else {
      progLabel = _l.stopProgress(doneCount + 1, stops.length);
    }

    final showPodReminder = _stage == TripStage.atDelivery && _anyPodMissing();

    return _card(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(children: [
          Text(_l.stops, style: _ts(10, _c.textMuted, FontWeight.w700)),
          const Spacer(),
          if (canSwap)
            GestureDetector(
              onTap: _showSwapStopsSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _c.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: _c.primary.withValues(alpha: 0.2)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.swap_vert_rounded, size: 13, color: _c.primary),
                  const SizedBox(width: 4),
                  Text('Reorder', style: _ts(11, _c.primary, FontWeight.w700)),
                ]),
              ),
            )
          else
            Text(progLabel, style: _ts(12, _c.primary, FontWeight.w700)),
        ]),
      ),
      if (showPodReminder) ...[
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: Row(children: [
            const Text('📋', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(child: Text(
              _l.podReminderBanner,
              style: _ts(12, _c.warning, FontWeight.w600),
            )),
          ]),
        ),
      ],
      Divider(height: 1, color: _c.border),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(children: List.generate(stops.length, (idx) {
          final stop   = stops[idx];
          final isLast = idx == stops.length - 1;
          final isDone = _stopIsDone(stop);
          final isCurr = !isDone && (idx == 0 || _stopIsDone(stops[idx - 1]));
          final stEvts = events.where((e) => e.shipmentStopNum == stop.stopNum).toList();
          return _stopItem(stop, isLast: isLast, isDone: isDone, isCurr: isCurr, events: stEvts,
              prevIsDone: idx > 0 && _stopIsDone(stops[idx - 1]));
        })),
      ),
    ]));
  }

  void _showSwapStopsSheet() {
    final isActiveTripReorder = _stage == TripStage.inTransit;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          // During active trip — only show remaining (not done/skipped) stops
          // During pending/accepted — show all stops
          final allStops = List<ShipmentStop>.from(_orderedStops);
          final doneStops = isActiveTripReorder
              ? allStops.where((s) => _stopIsDone(s)).toList()
              : <ShipmentStop>[];
          final reorderableStops = isActiveTripReorder
              ? allStops.where((s) => !_stopIsDone(s)).toList()
              : allStops;

          return Container(
            decoration: BoxDecoration(
              color: _c.surface2,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 36),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: _c.border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(children: [
                Icon(Icons.swap_vert_rounded, size: 18, color: _c.primary),
                const SizedBox(width: 8),
                Text('Reorder Stops', style: _ts(16, _c.text, FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              Text(
                isActiveTripReorder
                    ? 'Drag to reorder remaining stops'
                    : 'Drag to reorder before starting the trip',
                style: _ts(12, _c.textMuted, FontWeight.w500),
              ),
              const SizedBox(height: 16),
              // Show done stops as locked (greyed, no drag handle)
              if (doneStops.isNotEmpty) ...[
                ...doneStops.map((s) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _c.success.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _c.success.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    Icon(Icons.check_circle_rounded, color: _c.success, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s.locationName,
                        style: _ts(13, _c.textMuted, FontWeight.w600))),
                    Text('Done', style: _ts(10, _c.success, FontWeight.w700)),
                  ]),
                )),
                Divider(color: _c.border, height: 16),
              ],
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIdx, newIdx) {
                  if (newIdx > oldIdx) newIdx--;
                  final item = reorderableStops.removeAt(oldIdx);
                  reorderableStops.insert(newIdx, item);
                  setModal(() {});
                  // Rebuild full ordered list: done stops first, then reordered remaining
                  setState(() => _orderedStops = [...doneStops, ...reorderableStops]);
                },
                children: reorderableStops.map((s) {
                  final isPickup  = s.stopType == StopType.pickup;
                  final isSkipped = _stopIsSkipped(s);
                  final pillBg    = isPickup ? const Color(0xFFFEF3C7) : const Color(0xFFDBEAFE);
                  final pillFg    = isPickup ? const Color(0xFF92400E) : const Color(0xFF1E40AF);
                  return Container(
                    key: ValueKey(s.stopNum),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSkipped ? const Color(0xFFFFFBEB) : _c.surface1,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSkipped ? _c.warning : _c.border),
                    ),
                    child: Row(children: [
                      Icon(Icons.drag_handle_rounded, color: _c.textMuted, size: 20),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: pillBg, borderRadius: BorderRadius.circular(100)),
                        child: Text(_typeLabel(s.stopType).toUpperCase(),
                            style: _ts(8, pillFg, FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s.locationName,
                          style: _ts(13, isSkipped ? _c.textMuted : _c.text, FontWeight.w600))),
                      if (isSkipped)
                        Text('Skipped', style: _ts(10, _c.warning, FontWeight.w700))
                      else
                        Icon(Icons.drag_indicator_rounded, color: _c.border, size: 16),
                    ]),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _c.primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Done', style: _ts(15, Colors.white, FontWeight.w700)),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
  bool _stopIsDone(ShipmentStop s) {
    if (_skippedStops.containsKey(s.stopNum)) return true;
    final a = _stopActions[s.stopNum] ?? {};
    return a.contains('arrival') &&
        (s.stopType == StopType.drop ? a.contains('pod') : a.contains('departure'));
  }

  bool _stopIsSkipped(ShipmentStop s) => _skippedStops.containsKey(s.stopNum);

  // ── Centralised POD key helpers — single source of truth ─────────────────
  // Returns the list of POD keys required for non-skipped delivery stops
  List<String> _requiredPodKeys() {
    final deliveryStops = (_orderedStops.isNotEmpty ? _orderedStops : (_detail?.stops ?? []))
        .where((s) => (s.stopType == StopType.drop || s.stopType == StopType.pickAndDrop)
            && !_stopIsSkipped(s))
        .toList();
    if (deliveryStops.isEmpty) return ['pod'];
    if (deliveryStops.length == 1) return ['pod'];
    return deliveryStops.map((s) => 'pod_stop_${s.stopNum}').toList();
  }

  // Returns true if any required POD is missing
  bool _anyPodMissing() => _requiredPodKeys().any((k) => !_uploadedDocs.contains(k));

  // ── Skip stop reason codes — max 5, from PUBLIC OTM list ──────────────────
  static const List<Map<String, String>> _skipReasons = [
    {'code': 'A07', 'label': 'Refused by consignee'},
    {'code': 'A11', 'label': 'Business closed'},
    {'code': 'A03', 'label': 'Incorrect address'},
    {'code': 'A46', 'label': 'Recipient unavailable'},
    {'code': 'A13', 'label': 'Other'},
  ];

  void _showSkipStopSheet(ShipmentStop stop) {
    String? selected;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          decoration: BoxDecoration(
            color: _c.surface2,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: _c.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [
              Icon(Icons.skip_next_rounded, size: 20, color: _c.warning),
              const SizedBox(width: 8),
              Text('Skip Stop ${stop.stopNum}', style: _ts(16, _c.text, FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            Text('Select a reason — this will be recorded in OTM',
                style: _ts(12, _c.textMuted, FontWeight.w500)),
            const SizedBox(height: 16),
            ..._skipReasons.map((r) => GestureDetector(
              onTap: () => setModal(() => selected = r['code']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected == r['code'] ? _c.warning.withValues(alpha: 0.08) : _c.surface1,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected == r['code'] ? _c.warning : _c.border,
                    width: selected == r['code'] ? 1.5 : 0.5,
                  ),
                ),
                child: Row(children: [
                  Icon(
                    selected == r['code'] ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    size: 18,
                    color: selected == r['code'] ? _c.warning : _c.textMuted,
                  ),
                  const SizedBox(width: 10),
                  Text(r['label']!, style: _ts(13, _c.text, FontWeight.w600)),
                ]),
              ),
            )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: selected == null ? null : () {
                  Navigator.pop(ctx);
                  _skipStop(stop, selected!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _c.warning,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _c.border,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Confirm Skip', style: _ts(15, Colors.white, FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _skipStop(ShipmentStop stop, String reasonCode) async {
    setState(() => _busy = true);
    try {
      final now    = DateTime.now();
      final offset = now.timeZoneOffset;
      final sign   = offset.isNegative ? '-' : '+';
      final tz     = '$sign${offset.inHours.abs().toString().padLeft(2, '0')}:'
                     '${offset.inMinutes.remainder(60).abs().toString().padLeft(2, '0')}';
      final evDt   = '${now.toIso8601String().split('.')[0]}$tz';

      await SupabaseService.postEvent(widget.shipmentXid, {
        'statusCodeGid':       'X1',
        'statusReasonCodeGid': reasonCode,
        'eventdate':           {'value': evDt},
        'responsiblePartyGid': 'CARRIER',
        'stops':               {'items': [{'stopSequence': stop.stopNum}]},
      });

      setState(() {
        _skippedStops[stop.stopNum] = reasonCode;
        // Advance stage — find next undone, unskipped stop
        final stops = _orderedStops.isNotEmpty ? _orderedStops : (_detail?.stops ?? []);
        final nextStop = stops.firstWhere(
          (s) => !_stopIsDone(s),
          orElse: () => stops.last,
        );
        if (_stopIsDone(nextStop)) {
          // All stops done/skipped
          _stage = TripStage.delivered;
        } else if (nextStop.stopType == StopType.drop || nextStop.stopType == StopType.pickAndDrop) {
          _stage = TripStage.inTransit;
        } else {
          _stage = TripStage.inTransit;
        }
      });
      _snack('Stop ${stop.stopNum} skipped — recorded in OTM', _c.warning);
    } catch (e) {
      _snack('Failed to skip: $e', _c.danger);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _stopItem(ShipmentStop stop, {
    required bool isLast, required bool isDone, required bool isCurr,
    required List<TrackingEvent> events,
    required bool prevIsDone, // whether the stop above this one is done
  }) {
    // Completed stops collapse to a single summary row — tap to expand
    if (isDone) return _stopItemDone(stop, isLast: isLast, events: events);

    // Node styling for active/upcoming stops
    final nodeColor = isCurr ? _c.activeNode : const Color(0xFFCBD5E1);
    final nodeFg    = isCurr ? Colors.white : const Color(0xFF64748B);

    // Badge for active/upcoming
    String badgeText; Color badgeBg; Color badgeFg;
    if (isCurr) {
      switch (_stage) {
        case TripStage.enroutePickup:
          badgeText = _l.headingHere; badgeBg = const Color(0xFFDBEAFE); badgeFg = _c.primary; break;
        case TripStage.atPickup:
        case TripStage.atDelivery:
          badgeText = _l.youAreHere; badgeBg = const Color(0xFFFEF3C7); badgeFg = _c.warning; break;
        default:
          badgeText = _l.upNext; badgeBg = const Color(0xFFF1F5F9); badgeFg = _c.textSecondary;
      }
    } else {
      badgeText = _l.upcoming; badgeBg = const Color(0xFFF1F5F9); badgeFg = _c.textSecondary;
    }

    final arrT        = _fmtDTShort(stop.plannedArrival);
    final depT        = _fmtTimeOnly(stop.plannedDeparture);
    final arrTimeOnly = _fmtTimeOnly(stop.plannedArrival);
    final showDep     = depT.isNotEmpty && depT != arrTimeOnly;
    final timeStr     = showDep ? '$arrT – $depT' : arrT;

    // Type pill colors
    final isPickup = stop.stopType == StopType.pickup;
    final typePillBg = isPickup ? const Color(0xFFFEF3C7) : const Color(0xFFDBEAFE);
    final typePillFg = isPickup ? const Color(0xFF92400E) : const Color(0xFF1E40AF);

    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // ── Drag handle ──────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.only(top: 6, right: 6),
        child: _dragHandle(),
      ),
      // ── Node + connector ─────────────────────────────────────────────
      SizedBox(width: 32, child: Column(mainAxisSize: MainAxisSize.max, children: [
        // Node circle
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: nodeColor, shape: BoxShape.circle,
            boxShadow: isCurr
                ? [BoxShadow(color: _c.activeNode.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 3)]
                : null,
          ),
          child: Center(child: Text('${stop.stopNum}', style: _ts(13, nodeFg, FontWeight.w800))),
        ),
        // Bottom connector — always Expanded so it fills whatever height content needs
        if (!isLast)
          Expanded(child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 2,
              decoration: BoxDecoration(color: _c.border, borderRadius: BorderRadius.circular(2)),
            ),
          )),
        // Spacer to push connector all the way down when isLast
        if (isLast) const SizedBox(height: 8),
      ])),
      const SizedBox(width: 12),
      // ── Stop content — padding drives row height, connector fills it ──
      Expanded(child: Padding(
        padding: EdgeInsets.only(
          top: 2,
          bottom: isLast ? 8 : 20,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: typePillBg, borderRadius: BorderRadius.circular(100)),
            child: Text(_typeLabel(stop.stopType).toUpperCase(),
                style: _ts(8, typePillFg, FontWeight.w700)),
          ),
          const SizedBox(height: 3),
          Text(stop.locationName, style: _ts(14, _c.text, FontWeight.w800)),
          if (stop.city.isNotEmpty || stop.provinceCode.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text([stop.city, stop.provinceCode].where((s) => s.isNotEmpty).join(' · '),
                  style: _ts(11, _c.textSecondary, FontWeight.w500)),
            ),
          const SizedBox(height: 4),
          Text('📅 $timeStr', style: _ts(11, _c.textMuted, FontWeight.w500)),
          const SizedBox(height: 6),
          _pill(badgeText, badgeBg, badgeFg),
          if (events.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildEventLog(stop, events),
          ],
          // Skip stop button — only shown on current active stop during trip
          if (isCurr && _isActiveTrip) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showSkipStopSheet(stop),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.skip_next_rounded, size: 14, color: _c.textMuted),
                const SizedBox(width: 4),
                Text('Skip this stop', style: _ts(11, _c.textMuted, FontWeight.w600)),
              ]),
            ),
          ],
        ]),
      )),
    ]));
  }

  Widget _stopItemDone(ShipmentStop stop, {
    required bool isLast, required List<TrackingEvent> events,
  }) {
    final isExpanded = _expandedDoneStop == stop.stopNum;
    final isPickup   = stop.stopType == StopType.pickup;
    final isSkipped  = _stopIsSkipped(stop);
    final typePillBg = isPickup ? const Color(0xFFFEF3C7) : const Color(0xFFDBEAFE);
    final typePillFg = isPickup ? const Color(0xFF92400E) : const Color(0xFF1E40AF);

    return Column(children: [
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Drag handle — faded for done stops
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _dragHandle(opacity: 0.1),
          ),
          // Node + connector — same SizedBox(32) structure as active stops
          SizedBox(width: 32, child: Column(mainAxisSize: MainAxisSize.max, children: [
            // Node
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: isSkipped ? _c.warning : _c.success,
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(
                isSkipped ? '✕' : '✓',
                style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w800),
              )),
            ),
            // Bottom connector — stretches to fill row height
            if (!isLast)
              Expanded(child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: isSkipped ? _c.warning : _c.success,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
          ])),
          const SizedBox(width: 12),
          // Content
          Expanded(child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: typePillBg, borderRadius: BorderRadius.circular(100)),
                child: Text(_typeLabel(stop.stopType).toUpperCase(),
                    style: _ts(8, typePillFg, FontWeight.w700)),
              ),
              const SizedBox(height: 3),
              Text(stop.locationName, style: _ts(13, _c.textMuted, FontWeight.w700)),
              Text(
                isSkipped ? '⚠ Skipped' : '✓ Done',
                style: _ts(10, isSkipped ? _c.warning : _c.success, FontWeight.w600),
              ),
            ]),
          )),
          _pill(
            isSkipped ? 'Skipped' : _l.done,
            isSkipped ? const Color(0xFFFFF7ED) : const Color(0xFFDCFCE7),
            isSkipped ? _c.warning : _c.success,
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () => setState(() {
              _expandedDoneStop = isExpanded ? null : stop.stopNum;
            }),
            child: Icon(isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
                color: _c.textMuted, size: 18),
          ),
        ]),
      ),
      // Expanded event log
      if (isExpanded)
        Padding(
          padding: const EdgeInsets.only(left: 50, bottom: 10, top: 6),
          child: _buildEventLog(stop, events),
        ),
    ]);
  }

  Widget _dragHandle({double opacity = 0.3}) {
    return Opacity(
      opacity: opacity,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 14, height: 2, margin: const EdgeInsets.symmetric(vertical: 1.5),
            decoration: BoxDecoration(color: _c.textSecondary, borderRadius: BorderRadius.circular(2))),
        Container(width: 14, height: 2, margin: const EdgeInsets.symmetric(vertical: 1.5),
            decoration: BoxDecoration(color: _c.textSecondary, borderRadius: BorderRadius.circular(2))),
        Container(width: 14, height: 2, margin: const EdgeInsets.symmetric(vertical: 1.5),
            decoration: BoxDecoration(color: _c.textSecondary, borderRadius: BorderRadius.circular(2))),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EVENT LOG — shown only when stop is done
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildEventLog(ShipmentStop stop, List<TrackingEvent> otmEvents) {
    final acts     = _stopActions[stop.stopNum] ?? {};
    final otmCodes = otmEvents.map((e) => e.statusCodeGid).toSet();
    final now      = _fmtTimeOnly(DateTime.now().toIso8601String());

    // Deduplicate — keep only the first occurrence of each statusCodeGid
    // (OTM can sometimes return duplicate events for the same stop)
    final seen = <String>{};
    final deduped = otmEvents.where((e) => seen.add(e.statusCodeGid)).toList();

    final rows = <Widget>[
      ...deduped.map((e) => _evRow(
        icon: _iconForCode(e.statusCodeGid), text: _labelForCode(e.statusCodeGid),
        color: _colorForCode(e.statusCodeGid),
        time: _fmtTimeOnly(e.eventDate),
      )),
      // Locally posted events not yet returned by API
      if (acts.contains('arrival') && !otmCodes.contains('X3') && !otmCodes.contains('X1'))
        _evRow(icon: '📍', text: _l.arrivedAtStop, color: _c.success, time: now),
      if (acts.contains('departure') && !otmCodes.contains('AF'))
        _evRow(icon: '🚀', text: _l.leftStop, color: _c.primary, time: now),
      if (acts.contains('pod') && !otmCodes.contains('CD'))
        _evRow(icon: '✍️', text: _l.podSubmitted, color: _c.warning, time: now),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_l.recordedEvents, style: _ts(10, _c.textMuted, FontWeight.w700)),
      const SizedBox(height: 5),
      ...rows,
    ]);
  }

  Widget _evRow({required String icon, required String text,
      required Color color, required String time}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _c.border)),
      child: Row(children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 5),
        Expanded(child: Text(text, style: _ts(11, _c.text, FontWeight.w700))),
        Text(time, style: TextStyle(fontSize: 11, color: _c.textMuted, fontFamily: 'monospace')),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INCIDENT CARD — only during inTransit
  // ══════════════════════════════════════════════════════════════════════════



  // ══════════════════════════════════════════════════════════════════════════
  // ACTION ZONE — single primary button drives everything
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildActionZone() {
    final cfg        = _stages[_stage]!;
    final allStops   = _orderedStops.isNotEmpty ? _orderedStops : (_detail?.stops ?? []);
    final currStop   = allStops.firstWhere((s) => !_stopIsDone(s), orElse: () => allStops.last);
    final delivStops = allStops.where((s) =>
        s.stopType == StopType.drop || s.stopType == StopType.pickAndDrop).toList();
    final currPodKey = delivStops.length == 1 ? 'pod' : 'pod_stop_${currStop.stopNum}';
    final isCurrDelivStop = currStop.stopType == StopType.drop ||
                            currStop.stopType == StopType.pickAndDrop;

    // Block "Delivered" button if current stop POD is missing
    final isPodBlock = (_stage == TripStage.delivered && _anyPodMissing()) ||
                       (_stage == TripStage.atDelivery && isCurrDelivStop &&
                           !_uploadedDocs.contains(currPodKey));

    // ── Pending stage — swipe to accept / swipe to decline ────────────────
    if (_stage == TripStage.pending) {
      return _buildSwipeActions();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: _c.surface2,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: SizedBox(
        height: 64, width: double.infinity,
        child: ElevatedButton(
          onPressed: (_busy || isPodBlock) ? null : _onPrimaryWithConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPodBlock ? _c.border : cfg.btnColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _c.border,
            disabledForegroundColor: const Color(0xFF94A3B8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            elevation: isPodBlock ? 0 : 4,
            shadowColor: cfg.btnColor.withValues(alpha: 0.3),
          ),
          child: _busy
              ? const SizedBox(width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white)))
              : Text(
                  isPodBlock ? _l.uploadPodToComplete : cfg.btnLabel,
                  style: _ts(isPodBlock ? 14 : 18,
                      isPodBlock ? const Color(0xFF94A3B8) : Colors.white,
                      FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
        ),
      ),
    );
  }

  // ── Real swipe-to-respond widget ──────────────────────────────────────────
  Widget _buildSwipeActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      decoration: BoxDecoration(
        color: _c.surface2,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Swipe to respond to this load',
            style: _ts(11, _c.textMuted, FontWeight.w600)),
        const SizedBox(height: 12),
        _SwipeBar(
          onAccept: () => setState(() => _stage = TripStage.accepted),
          onDecline: _showDeclineModal,
          successColor: _c.success,
          dangerColor:  _c.danger,
          surfaceColor: _c.surface1,
          borderColor:  _c.border,
          textStyle: (size, color, weight) => _ts(size, color, weight),
        ),
      ]),
    );
  }

  // Wraps _onPrimary with confirmation for irreversible stages
  Future<void> _onPrimaryWithConfirm() async {
    const needsConfirm = {
      TripStage.accepted,      // Start Trip
      TripStage.atPickup,      // Loaded
      TripStage.atDelivery,    // Delivered
      TripStage.delivered,     // Complete Trip
    };
    if (needsConfirm.contains(_stage)) {
      final confirmed = await _showConfirmSheet();
      if (!confirmed) return;
    }
    _onPrimary();
  }

  Future<bool> _showConfirmSheet() async {
    final cfg = _stages[_stage]!;
    final result = await showModalBottomSheet<bool>(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: _c.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text(_l.confirmAction, style: _ts(18, _c.text, FontWeight.w800)),
          const SizedBox(height: 6),
          Text('${_l.youAreAboutTo} ${cfg.btnLabel}',
              textAlign: TextAlign.center,
              style: _ts(14, _c.textSecondary, FontWeight.w500)),
          const SizedBox(height: 6),
          Text(_l.cannotBeUndone,
              style: _ts(13, _c.textMuted, FontWeight.w500)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _c.border), foregroundColor: _c.textSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                minimumSize: const Size(0, 52),
              ),
              child: Text(_l.cancel, style: _ts(15, _c.textSecondary, FontWeight.w700)),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: cfg.btnColor, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                minimumSize: const Size(0, 52),
              ),
              child: Text(_l.yesConfirm, style: _ts(15, Colors.white, FontWeight.w800)),
            )),
          ]),
        ]),
      ),
    );
    return result ?? false;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DECLINE MODAL
  // ══════════════════════════════════════════════════════════════════════════

  void _showDeclineModal() {
    _declineReason = null;
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setModal) => Container(
        decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: _c.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 14),
          Text(_l.reasonForDeclining, style: _ts(18, _c.text, FontWeight.w800)),
          const SizedBox(height: 4),
          Text(_l.selectReasonBelow, style: _ts(12, _c.textMuted, FontWeight.w500)),
          const SizedBox(height: 14),
          ...[_l.vehicleIssue, _l.personalEmergency, _l.routeTooLong, _l.lowRate, _l.other]
              .map((r) => GestureDetector(
            onTap: () => setModal(() => _declineReason = r),
            child: Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _declineReason == r ? const Color(0xFFFFF5F5) : Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _declineReason == r ? _c.danger : _c.border, width: 1.5),
              ),
              child: Row(children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _declineReason == r ? _c.danger : _c.border, width: 2),
                    color: _declineReason == r ? _c.danger : Colors.transparent,
                  ),
                  child: _declineReason == r
                      ? const Icon(Icons.circle, size: 8, color: Colors.white) : null,
                ),
                const SizedBox(width: 10),
                Text(r, style: _ts(13, _declineReason == r ? _c.danger : _c.text, FontWeight.w600)),
              ]),
            ),
          )),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _c.border), foregroundColor: _c.textSecondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(0, 48),
              ),
              child: Text(_l.cancel, style: _ts(14, _c.textSecondary, FontWeight.w700)),
            )),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(
              onPressed: () {
                if (_declineReason == null) { _snack(_l.selectReasonFirst, _c.warning); return; }
                Navigator.pop(context);
                setState(() => _stage = TripStage.declined);
              },
              style: ElevatedButton.styleFrom(backgroundColor: _c.danger, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(0, 48)),
              child: Text(_l.confirmDecline, style: _ts(14, Colors.white, FontWeight.w800)),
            )),
          ]),
        ]),
      )),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DOCS SHEET
  // ══════════════════════════════════════════════════════════════════════════

  void _showDocsSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setModal) {
        final l10n = AppLocalizations.of(ctx);

        // Build POD row for each delivery stop dynamically
        final deliveryStops = (_orderedStops.isNotEmpty ? _orderedStops : (_detail?.stops ?? []))
            .where((s) => s.stopType == StopType.drop || s.stopType == StopType.pickAndDrop)
            .toList();

        // Current active delivery stop — the one the driver is at RIGHT NOW
        // Rules:
        //   pending/accepted/enroutePickup/atPickup → all PODs locked (trip not started)
        //   inTransit → all PODs locked (not at a delivery stop yet)
        //   atDelivery → only current stop unlocked, future stops locked
        //   delivered  → all PODs unlocked (catch-up uploads allowed)
        final bool allPodsLocked = _stage == TripStage.pending    ||
                                   _stage == TripStage.accepted   ||
                                   _stage == TripStage.enroutePickup ||
                                   _stage == TripStage.atPickup   ||
                                   _stage == TripStage.inTransit;

        final activeDeliveryStop = _stage == TripStage.atDelivery
            ? deliveryStops.firstWhere((s) => !_stopIsDone(s), orElse: () => deliveryStops.last)
            : null;

        final podDocs = deliveryStops.map((s) {
          final isSkipped     = _stopIsSkipped(s);
          final podKey        = deliveryStops.length == 1 ? 'pod' : 'pod_stop_${s.stopNum}';
          final isDoneAlready = _uploadedDocs.contains(podKey);
          // Locked if: all locked by stage, OR this is a future stop not yet reached
          final isFutureLocked = !isSkipped && !isDoneAlready && (
              allPodsLocked ||
              (activeDeliveryStop != null && s.stopNum != activeDeliveryStop.stopNum)
          );
          return {
            'key':          podKey,
            'icon':         isSkipped ? '⏭️' : isFutureLocked ? '🔒' : '✍️',
            'name':         deliveryStops.length == 1 ? l10n.podSigned : 'POD — Stop ${s.stopNum}',
            'sub':          isSkipped
                ? 'Skipped — no POD required'
                : isFutureLocked
                    ? 'Not yet reached'
                    : s.locationName.isNotEmpty ? s.locationName : l10n.podMandatory,
            'req':          !isSkipped,
            'skip':         isSkipped,
            'futureLocked': isFutureLocked,
          };
        }).toList();

        final otherDocs = [
          {'key': 'eway',    'icon': '📄', 'name': l10n.eWayBill,    'sub': l10n.optional, 'req': false},
          {'key': 'invoice', 'icon': '🧾', 'name': l10n.invoiceCopy, 'sub': l10n.optional, 'req': false},
          {'key': 'damage',  'icon': '📸', 'name': l10n.damagePhoto, 'sub': l10n.optional, 'req': false},
        ];

        final docs = [...podDocs, ...otherDocs];
        return Container(
          decoration: const BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: _c.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Row(children: [
              Text(l10n.documents, style: _ts(16, _c.text, FontWeight.w800)),
              const Spacer(),
              Text(l10n.uploadedCount(_uploadedDocs.length), style: _ts(11, _c.textMuted, FontWeight.w700)),
            ]),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11), border: Border.all(color: _c.border)),
              clipBehavior: Clip.hardEdge,
              child: Column(children: docs.map((doc) {
                final key          = doc['key'] as String;
                final isDone       = _uploadedDocs.contains(key);
                final isReq        = doc['req'] as bool;
                final isSkipped    = (doc['skip'] ?? false) as bool;
                final futureLocked = (doc['futureLocked'] ?? false) as bool;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  decoration: BoxDecoration(
                    color: isSkipped
                        ? const Color(0xFFFFFBEB)
                        : futureLocked
                            ? const Color(0xFFF8FAFC)
                            : null,
                    border: doc != docs.last ? Border(bottom: BorderSide(color: _c.border)) : null,
                  ),
                  child: Row(children: [
                    Text(doc['icon'] as String, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(doc['name'] as String,
                          style: _ts(13, (isSkipped || futureLocked) ? _c.textMuted : _c.text, FontWeight.w700)),
                      Text(doc['sub'] as String,
                          style: _ts(10, isSkipped ? _c.warning : futureLocked ? _c.textMuted : _c.textMuted, FontWeight.w500)),
                    ])),
                    if (!isSkipped && !futureLocked) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDone ? const Color(0xFFDCFCE7) : isReq ? const Color(0xFFFEE2E2) : _c.surface1,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color: isDone ? _c.success : isReq ? const Color(0xFFFCA5A5) : _c.border),
                        ),
                        child: Text(isDone ? _l.uploaded : isReq ? _l.required : _l.optional,
                            style: _ts(10, isDone ? _c.success : isReq ? _c.danger : _c.textMuted, FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: isDone ? null : () async {
                          Navigator.pop(context);
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PodUploadScreen(
                                shipmentXid: widget.shipmentXid,
                                docKey:      key,
                                docLabel:    doc['name'] as String,
                              ),
                            ),
                          );
                          if (result == true && mounted) {
                            setState(() => _uploadedDocs.add(key));
                            if (key == 'pod' || key.startsWith('pod_stop_')) {
                              _snack(_l.podUploadedMsg, _c.success);
                            }
                          }
                        },
                        child: Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: isDone ? _c.success : _c.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: isDone
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : const Icon(Icons.add,   color: Colors.white, size: 18)),
                        ),
                      ),
                    ],
                    if (futureLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _c.surface1,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: _c.border),
                        ),
                        child: Text('Locked', style: _ts(10, _c.textMuted, FontWeight.w700)),
                      ),
                  ]),
                );
              }).toList()),
            ),
          ]),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // COMPLETED / DECLINED
  // ══════════════════════════════════════════════════════════════════════════


  Widget _buildDeclined() => Scaffold(
    backgroundColor: _c.surface1,
    body: SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(
      mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80,
          decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
          child: const Center(child: Text('❌', style: TextStyle(fontSize: 36)))),
        const SizedBox(height: 20),
        Text(_l.loadDeclined, style: _ts(22, _c.text, FontWeight.w800)),
        const SizedBox(height: 8),
        Text(_l.youHaveDeclined,
            textAlign: TextAlign.center, style: _ts(14, _c.textMuted, FontWeight.w500)),
        const SizedBox(height: 4),
        Text(_l.declinedMistake,
            textAlign: TextAlign.center, style: _ts(13, _c.textMuted, FontWeight.w500)),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity, height: 52,
          child: OutlinedButton.icon(
            onPressed: () => _snack(_l.callingDispatcher, _c.primary),
            icon: const Text('📞', style: TextStyle(fontSize: 18)),
            label: Text(_l.callDispatcher, style: _ts(15, _c.text, FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _c.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    )))),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _card({required Widget child}) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border)),
    clipBehavior: Clip.hardEdge, child: child,
  );

  Widget _pill(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
    child: Text(text, style: _ts(11, fg, FontWeight.w600),
        maxLines: 1, overflow: TextOverflow.visible, softWrap: false),
  );

  String _typeLabel(StopType t) =>
      t == StopType.pickup ? _l.pickup : t == StopType.drop ? _l.delivery : '${_l.pickup}+${_l.delivery}';

  String _iconForCode(String c)  => {'X3': '📍', 'X1': '📍', 'AF': '🚀', 'CD': '✍️'}[c] ?? '📋';
  String _labelForCode(String c) => {
    'X3': _l.arrivedAtStop, 'X1': _l.arrivedAtStop,
    'AF': _l.leftStop,         'CD': _l.podSubmitted,
  }[c] ?? c;
  Color _colorForCode(String c)  => {'X3': _c.success, 'X1': _c.success, 'AF': _c.primary, 'CD': _c.warning}[c] ?? _c.textSecondary;

  String _fmtDT(String? v) {
    if (v == null || v.isEmpty) return '—';
    try { return DateFormat('dd MMM · HH:mm').format(DateTime.parse(v)); }
    catch (_) { return v; }
  }

  String _fmtDTShort(String? v) {
    if (v == null || v.isEmpty) return '—';
    try { return DateFormat('dd MMM · HH:mm').format(DateTime.parse(v)); }
    catch (_) { return v; }
  }

  String _fmtTimeOnly(String? v) {
    if (v == null || v.isEmpty) return '';
    try { return DateFormat('HH:mm').format(DateTime.parse(v)); }
    catch (_) { return ''; }
  }

  TextStyle _ts(double size, Color color, FontWeight weight) =>
      TextStyle(fontSize: size, color: color, fontWeight: weight);

  String _getConfirmLabel(String code) {
    const labels = {
      'en': 'Confirm Language',
      'pt': 'Confirmar Idioma',
      'pl': 'Potwierdź Język',
      'de': 'Sprache Bestätigen',
      'hi': 'भाषा पुष्टि करें',
      'es': 'Confirmar Idioma',
      'ar': 'تأكيد اللغة',
    };
    return labels[code] ?? 'Confirm Language';
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13)),
      backgroundColor: color, duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

// ─── Palette icon — 3 colored dots in a circle ───────────────────────────────
class _PaletteIcon extends StatelessWidget {
  final List<Color> swatchColors;
  const _PaletteIcon({required this.swatchColors});

  @override
  Widget build(BuildContext context) {
    final colors = swatchColors.take(3).toList();
    return SizedBox(
      width: 18, height: 18,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(top: 0, left: 0,
            child: _dot(colors.isNotEmpty ? colors[0] : Colors.white)),
          Positioned(top: 0, right: 0,
            child: _dot(colors.length > 1 ? colors[1] : Colors.white)),
          Positioned(bottom: 0, left: 4,
            child: _dot(colors.length > 2 ? colors[2] : Colors.white)),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 8, height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 0.5)),
  );
}

// ─── Pulsing dot for live badge ───────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: 0.3)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(width: 5, height: 5,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
  );
}

// ── SwipeBar — real draggable thumb, left = decline, right = accept ──────────
class _SwipeBar extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final Color successColor;
  final Color dangerColor;
  final Color surfaceColor;
  final Color borderColor;
  final TextStyle Function(double, Color, FontWeight) textStyle;

  const _SwipeBar({
    required this.onAccept,
    required this.onDecline,
    required this.successColor,
    required this.dangerColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.textStyle,
  });

  @override
  State<_SwipeBar> createState() => _SwipeBarState();
}

class _SwipeBarState extends State<_SwipeBar> with SingleTickerProviderStateMixin {
  double _offset = 0;
  late AnimationController _snapCtrl;
  late Animation<double> _snapAnim;
  static const double _thumbSize   = 56.0;
  static const double _triggerFrac = 0.38; // 38% of track = trigger

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() { _snapCtrl.dispose(); super.dispose(); }

  void _snapBack() {
    _snapAnim = Tween<double>(begin: _offset, end: 0.0)
        .animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.elasticOut));
    _snapCtrl.forward(from: 0).then((_) => setState(() => _offset = 0));
    _snapAnim.addListener(() => setState(() => _offset = _snapAnim.value));
  }

  void _onDragStart(DragStartDetails d) {
    _snapCtrl.stop();
  }

  void _onDragUpdate(DragUpdateDetails d, double trackWidth) {
    final maxRight =  trackWidth - _thumbSize;
    final maxLeft  = -(trackWidth - _thumbSize);
    setState(() {
      _offset = (_offset + d.delta.dx).clamp(maxLeft, maxRight);
    });
  }

  void _onDragEnd(DragEndDetails d, double trackWidth) {
    final maxRight = trackWidth - _thumbSize;
    final trigger  = maxRight * _triggerFrac;

    if (_offset > trigger) {
      // Swiped right far enough — accept
      setState(() => _offset = maxRight);
      Future.delayed(const Duration(milliseconds: 150), widget.onAccept);
    } else if (_offset < -trigger) {
      // Swiped left far enough — decline
      setState(() => _offset = -(trackWidth - _thumbSize));
      Future.delayed(const Duration(milliseconds: 150), widget.onDecline);
      Future.delayed(const Duration(milliseconds: 300), _snapBack);
    } else {
      _snapBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final trackWidth = constraints.maxWidth;
      final maxRight   = trackWidth - _thumbSize;
      // Progress: -1 (full left) → 0 (center) → +1 (full right)
      final progress   = _offset / maxRight;
      final isRight    = progress > 0;
      final isLeft     = progress < 0;
      final absP       = progress.abs();

      // Background colour bleeds in as you drag
      final bgColor = isRight
          ? widget.successColor.withValues(alpha: 0.06 + absP * 0.12)
          : isLeft
              ? widget.dangerColor.withValues(alpha: 0.06 + absP * 0.12)
              : Colors.transparent;

      final borderColor = isRight
          ? widget.successColor.withValues(alpha: 0.25 + absP * 0.4)
          : isLeft
              ? widget.dangerColor.withValues(alpha: 0.25 + absP * 0.4)
              : widget.borderColor;

      final thumbColor = isRight
          ? Color.lerp(widget.surfaceColor, widget.successColor, absP * 0.9)!
          : isLeft
              ? Color.lerp(widget.surfaceColor, widget.dangerColor, absP * 0.9)!
              : widget.surfaceColor;

      // Thumb icon
      final thumbIcon = isRight
          ? Icon(Icons.check_rounded, color: Colors.white.withValues(alpha: absP), size: 22)
          : isLeft
              ? Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: absP), size: 22)
              : const Icon(Icons.swap_horiz_rounded, color: Color(0xFF94A3B8), size: 22);

      return GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: (d) => _onDragUpdate(d, trackWidth),
        onHorizontalDragEnd:   (d) => _onDragEnd(d, trackWidth),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: _thumbSize + 4,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular((_thumbSize + 4) / 2),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Stack(children: [
            // ── Decline label (left) ───────────────────────────────────
            Positioned(left: 16, top: 0, bottom: 0,
              child: Opacity(
                opacity: isLeft ? (absP * 2).clamp(0, 1) : (isRight ? 0 : 0.35),
                child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.arrow_back_rounded, color: widget.dangerColor, size: 14),
                  const SizedBox(width: 4),
                  Text('Decline', style: widget.textStyle(13, widget.dangerColor, FontWeight.w700)),
                ])),
              ),
            ),
            // ── Accept label (right) ───────────────────────────────────
            Positioned(right: 16, top: 0, bottom: 0,
              child: Opacity(
                opacity: isRight ? (absP * 2).clamp(0, 1) : (isLeft ? 0 : 0.35),
                child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Accept', style: widget.textStyle(13, widget.successColor, FontWeight.w700)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: widget.successColor, size: 14),
                ])),
              ),
            ),
            // ── Draggable thumb ────────────────────────────────────────
            Positioned(
              left: (trackWidth / 2 - _thumbSize / 2) + _offset,
              top: 2, bottom: 2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                width: _thumbSize,
                decoration: BoxDecoration(
                  color: thumbColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6, offset: const Offset(0, 2),
                  )],
                ),
                child: Center(child: thumbIcon),
              ),
            ),
          ]),
        ),
      );
    });
  }
}