import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../affirmation/screens/affirmation_screen.dart';

/// Award-winning splash: logo draws itself via stroke animation, fills with gradient,
/// then shows "Finding your perfect coach..." with shimmer.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _strokeCtrl;
  late AnimationController _fillCtrl;
  late AnimationController _textCtrl;
  late AnimationController _subtitleCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _exitCtrl;
  late AnimationController _orbCtrl;

  bool _showSubtext = false;

  @override
  void initState() {
    super.initState();

    _orbCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _strokeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    );

    _fillCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );

    _textCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );

    _subtitleCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );

    _shimmerCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    );

    _exitCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Phase 1: Draw the logo stroke
    await _strokeCtrl.forward().orCancel;
    if (!mounted) return;

    // Phase 2: Fill with gradient
    await _fillCtrl.forward().orCancel;
    if (!mounted) return;

    // Phase 3: Show title
    await _textCtrl.forward().orCancel;
    if (!mounted) return;

    // Phase 4: Show "Finding your perfect coach..." with shimmer
    setState(() => _showSubtext = true);
    _subtitleCtrl.forward();
    _shimmerCtrl.repeat();

    // Wait then exit
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    _shimmerCtrl.stop();
    await _exitCtrl.forward().orCancel;
    if (!mounted) return;

    final onboardingDone = ref.read(onboardingCompleteProvider);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => onboardingDone
            ? AffirmationScreen(nextScreen: const HomeScreen())
            : const OnboardingScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, anim, secondaryAnim, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _strokeCtrl.dispose();
    _fillCtrl.dispose();
    _textCtrl.dispose();
    _subtitleCtrl.dispose();
    _shimmerCtrl.dispose();
    _exitCtrl.dispose();
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: AnimatedBuilder(
        animation: _exitCtrl,
        builder: (context, child) => Opacity(
          opacity: 1.0 - _exitCtrl.value,
          child: child,
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated pulsing orb background
              AnimatedBuilder(
                animation: _orbCtrl,
                builder: (context, _) {
                  final v = _orbCtrl.value;
                  return Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.secondaryLavender.withValues(alpha: 0.08 + 0.06 * v),
                          AppColors.primaryPeach.withValues(alpha: 0.04 + 0.03 * v),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  );
                },
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated logo: stroke → fill
                  Semantics(
                    label: 'AI CoachFlux logo',
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_strokeCtrl, _fillCtrl]),
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _LogoPainter(
                              strokeProgress: _strokeCtrl.value,
                              fillProgress: _fillCtrl.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title: "AI CoachFlux"
                  FadeTransition(
                    opacity: CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic)),
                      child: Text(
                        'AI CoachFlux',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: AppColors.secondaryLavender.withValues(alpha: 0.4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // "Finding your perfect coach..." with shimmer
                  if (_showSubtext)
                    FadeTransition(
                      opacity: CurvedAnimation(parent: _subtitleCtrl, curve: Curves.easeOut),
                      child: AnimatedBuilder(
                        animation: _shimmerCtrl,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              final dx = -1.0 + 3.0 * _shimmerCtrl.value;
                              return LinearGradient(
                                begin: Alignment(dx, 0),
                                end: Alignment(dx + 1.0, 0),
                                colors: [
                                  AppColors.textTertiaryDark,
                                  AppColors.primaryPeach,
                                  AppColors.textTertiaryDark,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ).createShader(bounds);
                            },
                            child: child!,
                          );
                        },
                        child: Text(
                          'Finding your perfect coach...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws the AI CoachFlux logo:
/// A rounded square with a lightning bolt inside.
/// Phase 1: stroke draws itself. Phase 2: fills with gradient.
class _LogoPainter extends CustomPainter {
  final double strokeProgress;
  final double fillProgress;

  _LogoPainter({required this.strokeProgress, required this.fillProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w * 0.24; // corner radius

    // Rounded rectangle path
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, w - 4, h - 4),
      Radius.circular(r),
    );
    final rectPath = Path()..addRRect(rrect);

    // Lightning bolt path (centered)
    final boltPath = Path()
      ..moveTo(w * 0.55, h * 0.18)
      ..lineTo(w * 0.35, h * 0.50)
      ..lineTo(w * 0.48, h * 0.50)
      ..lineTo(w * 0.42, h * 0.82)
      ..lineTo(w * 0.65, h * 0.45)
      ..lineTo(w * 0.52, h * 0.45)
      ..close();

    // Phase 2: Fill
    if (fillProgress > 0) {
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryPeach, AppColors.primaryPeachDark],
        ).createShader(Rect.fromLTWH(0, 0, w, h))
        ..style = PaintingStyle.fill;

      // Clip to progress
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, w, h * fillProgress));
      canvas.drawRRect(rrect, fillPaint);

      // Bolt in dark on fill
      final boltFillPaint = Paint()
        ..color = AppColors.backgroundDark.withValues(alpha: fillProgress)
        ..style = PaintingStyle.fill;
      canvas.drawPath(boltPath, boltFillPaint);
      canvas.restore();
    }

    // Phase 1: Stroke (always on top for the draw-in effect)
    if (strokeProgress > 0) {
      // Rect stroke
      final metric = rectPath.computeMetrics().first;
      final strokeLen = metric.length * strokeProgress;
      final extractedRect = metric.extractPath(0, strokeLen);

      final strokePaint = Paint()
        ..color = AppColors.primaryPeach.withValues(alpha: 0.8 + 0.2 * strokeProgress)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(extractedRect, strokePaint);

      // Bolt stroke
      if (strokeProgress > 0.3) {
        final boltProgress = ((strokeProgress - 0.3) / 0.7).clamp(0.0, 1.0);
        final boltMetric = boltPath.computeMetrics().first;
        final boltLen = boltMetric.length * boltProgress;
        final extractedBolt = boltMetric.extractPath(0, boltLen);

        final boltStrokePaint = Paint()
          ..color = AppColors.primaryPeach
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        if (fillProgress == 0) {
          canvas.drawPath(extractedBolt, boltStrokePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) =>
      old.strokeProgress != strokeProgress || old.fillProgress != fillProgress;
}
