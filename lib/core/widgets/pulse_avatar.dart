import 'package:flutter/material.dart';

/// Emoji avatar with animated pulsing glow ring.
class PulseAvatar extends StatefulWidget {
  final String emoji;
  final Color glowColor;
  final double size;
  final bool showPulse;
  final String? imagePath;

  const PulseAvatar({
    super.key,
    required this.emoji,
    required this.glowColor,
    this.size = 48,
    this.showPulse = true,
    this.imagePath,
  });

  @override
  State<PulseAvatar> createState() => _PulseAvatarState();
}

class _PulseAvatarState extends State<PulseAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final pulseValue = widget.showPulse ? _ctrl.value : 0.0;
        return Container(
          width: widget.size + 8,
          height: widget.size + 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.glowColor.withValues(alpha: 0.3 + 0.4 * pulseValue),
              width: 2 + pulseValue,
            ),
            boxShadow: widget.showPulse
                ? [
                    BoxShadow(
                      color: widget.glowColor.withValues(alpha: 0.15 + 0.15 * pulseValue),
                      blurRadius: 12 + 8 * pulseValue,
                      spreadRadius: 1 + 2 * pulseValue,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.imagePath != null
                ? ClipOval(
                    child: Image.asset(
                      widget.imagePath!,
                      width: widget.size * 0.85,
                      height: widget.size * 0.85,
                      fit: BoxFit.cover,
                      errorBuilder: (e1, e2, e3) => Text(
                        widget.emoji,
                        style: TextStyle(fontSize: widget.size * 0.55),
                      ),
                    ),
                  )
                : Text(
                    widget.emoji,
                    style: TextStyle(fontSize: widget.size * 0.55),
                  ),
          ),
        );
      },
    );
  }
}
