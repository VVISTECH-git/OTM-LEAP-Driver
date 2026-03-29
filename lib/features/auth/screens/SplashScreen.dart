import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leapdriver/core/providers/theme_provider.dart';
import 'package:leapdriver/features/driver/screens/LoadDetailScreen.dart';
import 'HoldingScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _bgCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _tagCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _bgAnim;
  late Animation<double> _logoFade;
  late Animation<Offset>  _logoSlide;
  late Animation<double> _tagFade;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _bgCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _logoCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _tagCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);

    _bgAnim    = CurvedAnimation(parent: _bgCtrl,   curve: Curves.easeInOut);
    _logoFade  = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic));
    _tagFade   = CurvedAnimation(parent: _tagCtrl,  curve: Curves.easeOut);
    _pulse     = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _bgCtrl.forward().then((_) {
      _logoCtrl.forward().then((_) {
        _tagCtrl.forward();
      });
    });

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) _navigate();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _tagCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    final prefs     = await SharedPreferences.getInstance();
    final pendingId = prefs.getString('pending_shipment_id') ?? '';
    if (!mounted) return;
    if (pendingId.isNotEmpty) {
      await prefs.remove('pending_shipment_id');
      _go(LoadDetailScreen(shipmentXid: pendingId));
    } else {
      _go(const HoldingScreen());
    }
  }

  void _go(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.watch<ThemeProvider>().theme.primary;
    final size    = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(children: [

          // ── Layer 1: Animated route grid background ────────────────────
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _RouteGridPainter(progress: _bgAnim.value, primary: primary),
            ),
          ),

          // ── Layer 2: Radial glow ───────────────────────────────────────
          AnimatedBuilder(
            animation: _logoFade,
            builder: (_, __) => Positioned(
              left: size.width / 2 - 140,
              top: size.height / 2 - 220,
              child: Opacity(
                opacity: _logoFade.value * 0.5,
                child: Container(
                  width: 280, height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      primary.withValues(alpha: 0.35),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),

          // ── Layer 3: Main content ──────────────────────────────────────
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              // Logo ring with pulse
              SlideTransition(
                position: _logoSlide,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => Stack(alignment: Alignment.center, children: [
                      // Outer pulse ring
                      Container(
                        width: 104 + (18 * _pulse.value),
                        height: 104 + (18 * _pulse.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary.withValues(alpha: 0.12 * _pulse.value),
                            width: 1.5,
                          ),
                        ),
                      ),
                      // Static ring
                      Container(
                        width: 88, height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      // Icon
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E1E1E),
                          boxShadow: [BoxShadow(
                            color: primary.withValues(alpha: 0.28),
                            blurRadius: 24, spreadRadius: 2,
                          )],
                        ),
                        child: Center(
                          child: _DriverIcon(color: primary),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Wordmark
              FadeTransition(
                opacity: _logoFade,
                child: SlideTransition(
                  position: _logoSlide,
                  child: Column(children: [
                    const Text('LEAP',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 52, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 10, height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 28, height: 1.5, color: primary),
                      const SizedBox(width: 10),
                      Text('DRIVER',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: primary, letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(width: 28, height: 1.5, color: primary),
                    ]),
                  ]),
                ),
              ),

              const SizedBox(height: 32),

              // Tagline + Oracle badge
              FadeTransition(
                opacity: _tagFade,
                child: Column(children: [
                  Text('Transportation Execution',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans', fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 7, height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFFF97316),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Powered by Oracle OTM',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans', fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.45),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),

          // ── Layer 4: Progress bar ──────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: FadeTransition(
              opacity: _tagFade,
              child: AnimatedBuilder(
                animation: _bgCtrl,
                builder: (_, __) => LinearProgressIndicator(
                  value: _bgCtrl.value,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation(primary),
                  minHeight: 2,
                ),
              ),
            ),
          ),

        ]),
      ),
    );
  }
}


// ── Driver icon — steering wheel with road ────────────────────────────────────
class _DriverIcon extends StatelessWidget {
  const _DriverIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(42, 42),
      painter: _DriverIconPainter(color: color),
    );
  }
}

class _DriverIconPainter extends CustomPainter {
  final Color color;
  const _DriverIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    final cx = w * 0.5;
    final cy = h * 0.42;
    final outerR = w * 0.30;
    final innerR = w * 0.09;

    // Outer steering wheel ring
    canvas.drawCircle(Offset(cx, cy), outerR, paint);

    // Inner hub
    canvas.drawCircle(Offset(cx, cy), innerR, paint);

    // Three spokes — top, bottom-left, bottom-right
    // Top spoke
    canvas.drawLine(
      Offset(cx, cy - innerR),
      Offset(cx, cy - outerR),
      paint,
    );
    // Bottom-left spoke
    canvas.drawLine(
      Offset(cx - innerR * 0.87, cy + innerR * 0.5),
      Offset(cx - outerR * 0.87, cy + outerR * 0.5),
      paint,
    );
    // Bottom-right spoke
    canvas.drawLine(
      Offset(cx + innerR * 0.87, cy + innerR * 0.5),
      Offset(cx + outerR * 0.87, cy + outerR * 0.5),
      paint,
    );

    // Steering column — from hub down
    canvas.drawLine(
      Offset(cx, cy + innerR),
      Offset(cx, h * 0.72),
      paint,
    );

    // Road dashes — perspective lines converging to centre
    final roadPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Left road edge
    canvas.drawLine(
      Offset(w * 0.08, h * 0.98),
      Offset(cx - 2, h * 0.76),
      roadPaint,
    );
    // Right road edge
    canvas.drawLine(
      Offset(w * 0.92, h * 0.98),
      Offset(cx + 2, h * 0.76),
      roadPaint,
    );

    // Centre dashes
    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx, h * 0.96),
      Offset(cx, h * 0.90),
      dashPaint,
    );
    canvas.drawLine(
      Offset(cx, h * 0.86),
      Offset(cx, h * 0.81),
      dashPaint,
    );
  }

  @override
  bool shouldRepaint(_DriverIconPainter old) => old.color != color;
}

// ── Route grid painter ────────────────────────────────────────────────────────
class _RouteGridPainter extends CustomPainter {
  final double progress;
  final Color  primary;
  _RouteGridPainter({required this.progress, required this.primary});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    final linePaint = Paint()..strokeWidth = 1.0..style = PaintingStyle.stroke;

    // Animated L-shaped route lines
    for (int i = 0; i < 20; i++) {
      final sx = rand.nextDouble() * size.width;
      final sy = rand.nextDouble() * size.height;
      final ex = rand.nextDouble() * size.width;
      final ey = rand.nextDouble() * size.height;
      final alpha = (0.025 + rand.nextDouble() * 0.055) * progress;
      linePaint.color = primary.withValues(alpha: alpha);

      final mx = rand.nextBool() ? ex : sx;
      final my = rand.nextBool() ? sy : ey;
      final path = Path()
        ..moveTo(sx, sy)
        ..lineTo(mx, my)
        ..lineTo(ex, ey);

      final metrics = path.computeMetrics().first;
      canvas.drawPath(
        metrics.extractPath(0, metrics.length * progress),
        linePaint,
      );

      if (progress > 0.65) {
        canvas.drawCircle(Offset(ex, ey), 1.8,
            Paint()..color = primary.withValues(alpha: alpha * 2.5));
      }
    }

    // Subtle grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.018 * progress)
      ..strokeWidth = 0.5;
    const step = 42.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_RouteGridPainter old) => old.progress != progress || old.primary != primary;
}