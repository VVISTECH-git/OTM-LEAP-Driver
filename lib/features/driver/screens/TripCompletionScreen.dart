import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:leapdriver/core/theme/app_colors.dart';
import 'package:leapdriver/core/theme/app_theme.dart';
import 'package:leapdriver/core/providers/theme_provider.dart';
import 'package:leapdriver/features/auth/screens/HoldingScreen.dart';
import 'package:leapdriver/l10n/app_localizations.dart';

// Colors are now provided by AppThemeData via context.colors

/// TripCompletionScreen — shown after driver taps "Complete Trip."
///
/// Receives shipment details from LoadDetailScreen to display a summary.
/// After the driver taps "Done", the app returns to the HoldingScreen
/// and their access to this shipment ends.
class TripCompletionScreen extends StatefulWidget {
  final String shipmentXid;
  final String origin;
  final String destination;
  final String? dispatcherPhone; // optional — show call button only if provided
  final double? distanceKm;
  final int?    stopCount;

  const TripCompletionScreen({
    super.key,
    required this.shipmentXid,
    required this.origin,
    required this.destination,
    this.dispatcherPhone,
    this.distanceKm,
    this.stopCount,
  });

  @override
  State<TripCompletionScreen> createState() => _TripCompletionScreenState();
}

class _TripCompletionScreenState extends State<TripCompletionScreen>
    with SingleTickerProviderStateMixin {

  AppLocalizations get _l => AppLocalizations.of(context);
  AppThemeData get _c => context.colors;

  late AnimationController _controller;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _scaleAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDone() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HoldingScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  void _callDispatcher() {
    // Placeholder — wire up url_launcher later
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_l.callingDispatcher),
        backgroundColor: _c.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>(); // rebuild on theme change
    return PopScope(
      canPop: false, // prevent back button — trip is done
      child: Scaffold(
        backgroundColor: _c.surface2,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Success icon ─────────────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildSuccessIcon(),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Heading ──────────────────────────────────────────────
                SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        Text(
                          _l.tripCompletedTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _c.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _l.tripCompletedSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Summary card ─────────────────────────────────────────
                SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildSummaryCard(),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Buttons ──────────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildButtons(),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Big green checkmark circle ─────────────────────────────────────────────
  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF86EFAC), width: 2),
      ),
      child: const Center(
        child: Text('✅', style: TextStyle(fontSize: 48)),
      ),
    );
  }

  // ── Shipment summary card ──────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    // Clean up shipment ID — strip domain prefix if present
    final displayId = widget.shipmentXid.contains('.')
        ? widget.shipmentXid.split('.').last
        : widget.shipmentXid;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _c.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        children: [

          // ── Shipment ID ──────────────────────────────────────────────
          _summaryRow(
            icon: '📦',
            label: _l.shipment,
            value: '#$displayId',
            isCode: true,
          ),

                Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: _c.border),
          ),

          // ── Route ────────────────────────────────────────────────────
          _summaryRow(
            icon: '📍',
            label: _l.origin,
            value: widget.origin,
          ),

          const SizedBox(height: 10),

          _summaryRow(
            icon: '🏁',
            label: _l.destination,
            value: widget.destination,
          ),

                Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: _c.border),
          ),

          // ── POD confirmation ─────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration:       BoxDecoration(
                        color: _c.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                          _l.podSubmittedBadge,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _c.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration:       BoxDecoration(
                        color: _c.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                          _l.tripClosedBadge,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _c.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Trip stats ───────────────────────────────────────────────
          if (widget.distanceKm != null || widget.stopCount != null) ...[
                  Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: _c.border),
            ),
            Row(
              children: [
                if (widget.distanceKm != null) ...[
                  const Text('🚚', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.distanceKm!.toStringAsFixed(0)} km',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _c.text,
                    ),
                  ),
                ],
                if (widget.distanceKm != null && widget.stopCount != null)
                  const SizedBox(width: 20),
                if (widget.stopCount != null) ...[
                  const Text('📍', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.stopCount} stop${widget.stopCount! > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _c.text,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String icon,
    required String label,
    required String value,
    bool isCode = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _c.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: isCode ? 13 : 14,
                fontWeight: FontWeight.w700,
                color: _c.text,
                fontFamily: isCode ? 'monospace' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _buildButtons() {
    return Column(
      children: [
        // Primary: Done — returns to holding screen
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: _c.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
                          _l.done,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

        // Secondary: Call dispatcher — only shown if number is provided
        if (widget.dispatcherPhone != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _callDispatcher,
              icon: const Text('📞', style: TextStyle(fontSize: 16)),
              label: Text(
                          _l.callDispatcher,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _c.textSecondary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _c.border),
                foregroundColor: _c.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}