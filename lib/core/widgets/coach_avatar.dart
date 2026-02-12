import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/coach.dart';
import '../theme/app_colors.dart';

// ─── Avatar State ────────────────────────────────────────────────────────────

enum CoachAvatarState { idle, listening, thinking, speaking, empathizing }

enum CoachAvatarSize { small, medium, large }

// ─── Coach Avatar Widget ─────────────────────────────────────────────────────

class CoachAvatar extends StatefulWidget {
  final Coach coach;
  final CoachAvatarState state;
  final CoachAvatarSize size;

  const CoachAvatar({
    super.key,
    required this.coach,
    this.state = CoachAvatarState.idle,
    this.size = CoachAvatarSize.medium,
  });

  @override
  State<CoachAvatar> createState() => _CoachAvatarState();
}

class _CoachAvatarState extends State<CoachAvatar>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _waveController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  double get _dimension {
    switch (widget.size) {
      case CoachAvatarSize.small:
        return 48;
      case CoachAvatarSize.medium:
        return 80;
      case CoachAvatarSize.large:
        return 140;
    }
  }

  double get _emojiFontSize {
    switch (widget.size) {
      case CoachAvatarSize.small:
        return 20;
      case CoachAvatarSize.medium:
        return 34;
      case CoachAvatarSize.large:
        return 56;
    }
  }

  bool get _isAnalytical {
    final p = widget.coach.personality;
    return p == 'analytical' || p == 'direct';
  }

  AnimationController get _activeController {
    switch (widget.state) {
      case CoachAvatarState.idle:
        return _breatheController;
      case CoachAvatarState.listening:
        return _pulseController;
      case CoachAvatarState.thinking:
        return _rotateController;
      case CoachAvatarState.speaking:
        return _waveController;
      case CoachAvatarState.empathizing:
        return _glowController;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.coach.color;
    final dim = _dimension;

    return AnimatedBuilder(
      animation: _activeController,
      controller: _activeController,
      color: color,
      state: widget.state,
      isAnalytical: _isAnalytical,
      dimension: dim,
      child: _buildCore(color, dim),
    );
  }

  Widget _buildCore(Color color, double dim) {
    return SizedBox(
      width: dim,
      height: dim,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glassmorphic background
          Container(
            width: dim * 0.78,
            height: dim * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.35),
                  color.withValues(alpha: 0.12),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: dim * 0.22,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: AppColors.shadowDark,
                  blurRadius: dim * 0.12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          // Photo or Emoji
          if (widget.coach.imagePath != null)
            ClipOval(
              child: Image.asset(
                widget.coach.imagePath!,
                width: dim * 0.72,
                height: dim * 0.72,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Text(
                  widget.coach.emoji,
                  style: TextStyle(fontSize: _emojiFontSize),
                ),
              ),
            )
          else
            Text(
              widget.coach.emoji,
              style: TextStyle(fontSize: _emojiFontSize),
            ),
        ],
      ),
    );
  }
}

// ─── Animated wrapper (single widget, delegated painting) ────────────────────

class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final AnimationController controller;
  final Color color;
  final CoachAvatarState state;
  final bool isAnalytical;
  final double dimension;
  final Widget child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.controller,
    required this.color,
    required this.state,
    required this.isAnalytical,
    required this.dimension,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilderWidget(
      listenable: animation,
      builder: (context, ch) {
        return CustomPaint(
          painter: _AvatarAuraPainter(
            progress: controller.value,
            color: color,
            state: state,
            isAnalytical: isAnalytical,
          ),
          child: ch,
        );
      },
      child: child,
    );
  }
}

/// Thin wrapper to avoid name clash with Flutter's [AnimatedBuilder].
class AnimatedBuilderWidget extends AnimatedWidget {
  final TransitionBuilder builder;
  final Widget? child;

  const AnimatedBuilderWidget({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) => builder(context, child);
}

// ─── Custom painter for aura / ring effects ──────────────────────────────────

class _AvatarAuraPainter extends CustomPainter {
  final double progress;
  final Color color;
  final CoachAvatarState state;
  final bool isAnalytical;

  _AvatarAuraPainter({
    required this.progress,
    required this.color,
    required this.state,
    required this.isAnalytical,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    switch (state) {
      case CoachAvatarState.idle:
        _paintBreathe(canvas, center, radius);
      case CoachAvatarState.listening:
        _paintPulse(canvas, center, radius);
      case CoachAvatarState.thinking:
        _paintThinkingDots(canvas, center, radius);
      case CoachAvatarState.speaking:
        _paintWave(canvas, center, radius);
      case CoachAvatarState.empathizing:
        _paintGlow(canvas, center, radius);
    }

    // Background pattern
    if (isAnalytical) {
      _paintGeometricPattern(canvas, center, radius);
    } else {
      _paintOrganicPattern(canvas, center, radius);
    }
  }

  void _paintBreathe(Canvas canvas, Offset center, double radius) {
    final scale = 0.92 + progress * 0.08;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15 + progress * 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * scale, paint);
  }

  void _paintPulse(Canvas canvas, Offset center, double radius) {
    for (int i = 0; i < 3; i++) {
      final p = (progress + i * 0.33) % 1.0;
      final paint = Paint()
        ..color = color.withValues(alpha: (1 - p) * 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius * (0.85 + p * 0.25), paint);
    }
  }

  void _paintThinkingDots(Canvas canvas, Offset center, double radius) {
    final dotPaint = Paint()..color = color.withValues(alpha: 0.6);
    for (int i = 0; i < 6; i++) {
      final angle = (progress * math.pi * 2) + (i * math.pi / 3);
      final r = radius * 0.95;
      final dx = center.dx + math.cos(angle) * r;
      final dy = center.dy + math.sin(angle) * r;
      canvas.drawCircle(Offset(dx, dy), 2.5, dotPaint);
    }
  }

  void _paintWave(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      final phase = progress * math.pi * 2 + i * 0.8;
      final waveRadius = radius * (0.82 + math.sin(phase) * 0.12);
      canvas.drawCircle(center, waveRadius, paint);
    }
  }

  void _paintGlow(Canvas canvas, Offset center, double radius) {
    final alpha = 0.08 + progress * 0.12;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius * 1.2),
      );
    canvas.drawCircle(center, radius * 1.2, paint);
  }

  void _paintGeometricPattern(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    // Concentric hexagonal hints
    for (int ring = 1; ring <= 3; ring++) {
      final r = radius * 0.3 * ring;
      final path = Path();
      for (int i = 0; i <= 6; i++) {
        final angle = (i * math.pi / 3) - math.pi / 6;
        final p = Offset(
          center.dx + math.cos(angle) * r,
          center.dy + math.sin(angle) * r,
        );
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  void _paintOrganicPattern(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    // Flowing arcs
    for (int i = 0; i < 4; i++) {
      final startAngle = (i * math.pi / 2) + progress * 0.3;
      final rect = Rect.fromCircle(
        center: center,
        radius: radius * (0.5 + i * 0.1),
      );
      canvas.drawArc(rect, startAngle, math.pi * 0.6, false, paint);
    }
  }

  @override
  bool shouldRepaint(_AvatarAuraPainter old) =>
      old.progress != progress || old.state != state;
}
