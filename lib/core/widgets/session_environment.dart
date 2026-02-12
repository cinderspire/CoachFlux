import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ─── Session Environment Widget ──────────────────────────────────────────────

class SessionEnvironment extends StatefulWidget {
  final String coachId;
  final Widget child;

  const SessionEnvironment({
    super.key,
    required this.coachId,
    required this.child,
  });

  @override
  State<SessionEnvironment> createState() => _SessionEnvironmentState();
}

class _SessionEnvironmentState extends State<SessionEnvironment>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Base gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundDark,
                    _envColor.withValues(alpha: 0.08),
                    AppColors.backgroundDark,
                  ],
                ),
              ),
            ),
            // Custom painted environment
            CustomPaint(
              painter: _getEnvironmentPainter(_controller.value),
              size: Size.infinite,
            ),
            // Content
            ?child,
          ],
        );
      },
      child: widget.child,
    );
  }

  Color get _envColor => _EnvironmentColors.forCoach(widget.coachId);

  CustomPainter _getEnvironmentPainter(double t) {
    switch (widget.coachId) {
      case 'flow-master':
        return _FlowStatePainter(t: t);
      case 'zen-mind':
        return _ZenMindPainter(t: t);
      case 'iron-will':
        return _IronWillPainter(t: t);
      case 'career-pilot':
        return _CareerPilotPainter(t: t);
      case 'muse':
        return _MusePainter(t: t);
      case 'money-mind':
        return _MoneyMindPainter(t: t);
      case 'system-builder':
        return _SystemBuilderPainter(t: t);
      case 'stoic-sage':
        return _StoicSagePainter(t: t);
      case 'social-spark':
        return _SocialSparkPainter(t: t);
      case 'sleep-whisperer':
        return _DreamGuardPainter(t: t);
      case 'dr-aura':
        return _DrAuraPainter(t: t);
      default:
        return _FlowStatePainter(t: t);
    }
  }
}

/// Thin wrapper identical to the one in coach_avatar.dart but local to avoid
/// cross-file coupling.  Uses Flutter's [AnimatedWidget] under the hood.
class AnimatedBuilder extends AnimatedWidget {
  final TransitionBuilder builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) => builder(context, child);
}

// ─── Environment Colors ──────────────────────────────────────────────────────

class _EnvironmentColors {
  static Color forCoach(String id) {
    switch (id) {
      case 'flow-master':
        return const Color(0xFF3B82F6);
      case 'zen-mind':
        return AppColors.secondaryLavender;
      case 'iron-will':
        return const Color(0xFFEF4444);
      case 'career-pilot':
        return const Color(0xFFF59E0B);
      case 'muse':
        return const Color(0xFFEC4899);
      case 'money-mind':
        return const Color(0xFF22C55E);
      case 'system-builder':
        return const Color(0xFF06B6D4);
      case 'stoic-sage':
        return const Color(0xFF8B5CF6);
      case 'social-spark':
        return const Color(0xFFF97316);
      case 'sleep-whisperer':
        return const Color(0xFF6366F1);
      case 'dr-aura':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.secondaryLavender;
    }
  }
}

// ─── Individual Environment Painters ─────────────────────────────────────────

/// FlowState – minimalist desk ambiance, soft blue horizontal lines
class _FlowStatePainter extends CustomPainter {
  final double t;
  _FlowStatePainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.06)
      ..strokeWidth = 1;
    // Floating horizontal focus-lines
    for (int i = 0; i < 8; i++) {
      final y = size.height * (0.3 + i * 0.06);
      final xOff = math.sin(t * math.pi * 2 + i) * 30;
      canvas.drawLine(
        Offset(size.width * 0.15 + xOff, y),
        Offset(size.width * 0.85 + xOff, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_FlowStatePainter old) => old.t != t;
}

/// ZenMind – floating petals / particles
class _ZenMindPainter extends CustomPainter {
  final double t;
  _ZenMindPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final rng = math.Random(42);
    for (int i = 0; i < 18; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final drift = math.sin(t * math.pi * 2 + i * 0.7) * 12;
      final alpha = 0.04 + rng.nextDouble() * 0.06;
      paint.color = AppColors.secondaryLavender.withValues(alpha: alpha);
      final r = 2.0 + rng.nextDouble() * 4;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(baseX + drift, baseY - drift * 0.5),
          width: r * 2,
          height: r,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ZenMindPainter old) => old.t != t;
}

/// IronWill – red energy pulse rings
class _IronWillPainter extends CustomPainter {
  final double t;
  _IronWillPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.55);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < 4; i++) {
      final p = (t + i * 0.25) % 1.0;
      paint.color = const Color(0xFFEF4444).withValues(alpha: (1 - p) * 0.12);
      canvas.drawCircle(center, 40 + p * size.width * 0.4, paint);
    }
  }

  @override
  bool shouldRepaint(_IronWillPainter old) => old.t != t;
}

/// CareerPilot – city skyline silhouette
class _CareerPilotPainter extends CustomPainter {
  final double t;
  _CareerPilotPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.06);
    final base = size.height * 0.82;
    final rng = math.Random(7);
    // Simple rectangular buildings
    for (int i = 0; i < 14; i++) {
      final w = 12.0 + rng.nextDouble() * 20;
      final h = 30.0 + rng.nextDouble() * 80;
      final x = i * (size.width / 14) + math.sin(t * math.pi * 2 + i) * 2;
      canvas.drawRect(Rect.fromLTWH(x, base - h, w, h), paint);
    }
  }

  @override
  bool shouldRepaint(_CareerPilotPainter old) => old.t != t;
}

/// Muse – paint splashes
class _MusePainter extends CustomPainter {
  final double t;
  _MusePainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(99);
    final colors = [
      const Color(0xFFEC4899),
      AppColors.quaternarySky,
      AppColors.tertiarySage,
      const Color(0xFFF59E0B),
    ];
    for (int i = 0; i < 12; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 0.05)
        ..style = PaintingStyle.fill;
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final r = 15.0 + rng.nextDouble() * 40;
      final drift = math.sin(t * math.pi * 2 + i * 1.1) * 8;
      canvas.drawCircle(Offset(cx + drift, cy + drift * 0.5), r, paint);
    }
  }

  @override
  bool shouldRepaint(_MusePainter old) => old.t != t;
}

/// MoneyMind – subtle financial chart lines
class _MoneyMindPainter extends CustomPainter {
  final double t;
  _MoneyMindPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E).withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path();
    for (int i = 0; i <= 20; i++) {
      final x = size.width * i / 20;
      final y = size.height * 0.5 +
          math.sin(t * math.pi * 2 + i * 0.5) * 30 +
          math.cos(i * 0.8) * 20;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
    // Second line
    final path2 = Path();
    for (int i = 0; i <= 20; i++) {
      final x = size.width * i / 20;
      final y = size.height * 0.55 +
          math.cos(t * math.pi * 2 + i * 0.4) * 25 +
          math.sin(i * 0.6) * 15;
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    paint.color = const Color(0xFF22C55E).withValues(alpha: 0.04);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(_MoneyMindPainter old) => old.t != t;
}

/// SystemBuilder – circuit board pattern
class _SystemBuilderPainter extends CustomPainter {
  final double t;
  _SystemBuilderPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final dotPaint = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.1);
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
    // Animated trace
    final traceLen = size.width * 0.3;
    final startX = (t * size.width * 1.5) % (size.width + traceLen) - traceLen;
    final traceY = size.height * 0.5;
    paint.color = const Color(0xFF06B6D4).withValues(alpha: 0.12);
    canvas.drawLine(
      Offset(startX, traceY),
      Offset(startX + traceLen, traceY),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SystemBuilderPainter old) => old.t != t;
}

/// StoicSage – marble columns, classical
class _StoicSagePainter extends CustomPainter {
  final double t;
  _StoicSagePainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.05);
    // Columns
    const cols = 5;
    final colWidth = 18.0;
    for (int i = 0; i < cols; i++) {
      final x = size.width * (0.1 + i * 0.2);
      final topY = size.height * 0.15;
      final botY = size.height * 0.85;
      canvas.drawRect(
        Rect.fromLTWH(x - colWidth / 2, topY, colWidth, botY - topY),
        paint,
      );
      // Capital
      canvas.drawRect(
        Rect.fromLTWH(x - colWidth, topY - 6, colWidth * 2, 6),
        paint,
      );
    }
    // Subtle shimmer
    final shimmerPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.03);
    final shimmerY = size.height * (0.2 + t * 0.6);
    canvas.drawRect(
      Rect.fromLTWH(0, shimmerY, size.width, 2),
      shimmerPaint,
    );
  }

  @override
  bool shouldRepaint(_StoicSagePainter old) => old.t != t;
}

/// SocialSpark – warm cafe ambiance (floating warm dots)
class _SocialSparkPainter extends CustomPainter {
  final double t;
  _SocialSparkPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(55);
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 20; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final drift = math.sin(t * math.pi * 2 + i * 0.9) * 6;
      final alpha = 0.03 + rng.nextDouble() * 0.04;
      paint.color = const Color(0xFFF97316).withValues(alpha: alpha);
      canvas.drawCircle(Offset(cx + drift, cy + drift), 3 + rng.nextDouble() * 5, paint);
    }
  }

  @override
  bool shouldRepaint(_SocialSparkPainter old) => old.t != t;
}

/// DreamGuard – night sky with twinkling stars
class _DreamGuardPainter extends CustomPainter {
  final double t;
  _DreamGuardPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(77);
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 40; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final twinkle = (math.sin(t * math.pi * 2 * 3 + i * 1.3) + 1) / 2;
      final alpha = 0.04 + twinkle * 0.1;
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(cx, cy), 1 + rng.nextDouble() * 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(_DreamGuardPainter old) => old.t != t;
}

/// Dr. Aura – soft purple therapy room glow
class _DrAuraPainter extends CustomPainter {
  final double t;
  _DrAuraPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    // Soft radial glow
    final center = Offset(size.width * 0.5, size.height * 0.4);
    final radius = size.width * 0.6;
    final alpha = 0.04 + math.sin(t * math.pi * 2) * 0.02;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7C3AED).withValues(alpha: alpha),
          const Color(0xFF7C3AED).withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);

    // Second softer glow
    final center2 = Offset(size.width * 0.6, size.height * 0.6);
    final alpha2 = 0.03 + math.cos(t * math.pi * 2) * 0.015;
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.secondaryLavender.withValues(alpha: alpha2),
          AppColors.secondaryLavender.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center2, radius: radius * 0.7));
    canvas.drawCircle(center2, radius * 0.7, paint2);
  }

  @override
  bool shouldRepaint(_DrAuraPainter old) => old.t != t;
}
