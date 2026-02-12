import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated gradient mesh background — soft moving blobs like Apple iOS wallpapers.
/// Uses 3 animated radial gradient circles drifting across the canvas.
class GradientMeshBackground extends StatefulWidget {
  final Widget child;
  final double intensity;
  const GradientMeshBackground({super.key, required this.child, this.intensity = 1.0});

  @override
  State<GradientMeshBackground> createState() => _GradientMeshBackgroundState();
}

class _GradientMeshBackgroundState extends State<GradientMeshBackground>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl1;
  late final AnimationController _ctrl2;
  late final AnimationController _ctrl3;

  @override
  void initState() {
    super.initState();
    _ctrl1 = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _ctrl2 = AnimationController(vsync: this, duration: const Duration(seconds: 16))
      ..repeat(reverse: true);
    _ctrl3 = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ctrl1, _ctrl2, _ctrl3]),
      builder: (context, _) {
        return CustomPaint(
          painter: _MeshPainter(
            t1: _ctrl1.value,
            t2: _ctrl2.value,
            t3: _ctrl3.value,
            intensity: widget.intensity,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double t1, t2, t3;
  final double intensity;
  _MeshPainter({required this.t1, required this.t2, required this.t3, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    // Base dark background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.backgroundDark,
    );

    final alpha = (0.06 * intensity).clamp(0.0, 0.15);

    // Blob 1: Lavender — top-left drift
    _drawBlob(
      canvas, size,
      cx: size.width * (0.2 + 0.3 * sin(t1 * pi)),
      cy: size.height * (0.15 + 0.2 * cos(t1 * pi * 0.8)),
      radius: size.width * 0.6,
      color: AppColors.secondaryLavender.withValues(alpha: alpha),
    );

    // Blob 2: Peach — center-right drift
    _drawBlob(
      canvas, size,
      cx: size.width * (0.6 + 0.25 * cos(t2 * pi)),
      cy: size.height * (0.4 + 0.3 * sin(t2 * pi * 1.2)),
      radius: size.width * 0.55,
      color: AppColors.primaryPeach.withValues(alpha: alpha),
    );

    // Blob 3: Sage — bottom drift
    _drawBlob(
      canvas, size,
      cx: size.width * (0.4 + 0.3 * sin(t3 * pi * 0.7)),
      cy: size.height * (0.75 + 0.15 * cos(t3 * pi)),
      radius: size.width * 0.5,
      color: AppColors.tertiarySage.withValues(alpha: alpha * 0.7),
    );
  }

  void _drawBlob(Canvas canvas, Size size,
      {required double cx, required double cy, required double radius, required Color color}) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter old) =>
      old.t1 != t1 || old.t2 != t2 || old.t3 != t3;
}
