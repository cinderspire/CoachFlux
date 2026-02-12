import 'package:flutter/material.dart';
import '../models/coach.dart';

/// Displays coach photo if available, falls back to emoji
class CoachPhoto extends StatelessWidget {
  final Coach coach;
  final double _size;
  final bool showBorder;
  final bool showVerified;

  // ignore: prefer_const_constructors_in_immutables
  CoachPhoto({
    super.key,
    required this.coach,
    double size = 48,
    double? radius,
    this.showBorder = true,
    this.showVerified = false,
  }) : _size = radius != null ? radius * 2 : size;

  @override
  Widget build(BuildContext context) {
    final hasImage = coach.imagePath != null && coach.imagePath!.isNotEmpty;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: showBorder
                ? Border.all(
                    color: coach.color.withValues(alpha: 0.4),
                    width: _size > 80 ? 3 : 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: coach.color.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: hasImage
                ? Image.asset(
                    coach.imagePath!,
                    width: _size,
                    height: _size,
                    fit: BoxFit.cover,
                    errorBuilder: (e1, e2, e3) => _emojiFallback(),
                  )
                : _emojiFallback(),
          ),
        ),
        if (showVerified)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A2E),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified,
                color: coach.color,
                size: _size * 0.3,
              ),
            ),
          ),
      ],
    );
  }

  Widget _emojiFallback() {
    return Container(
      width: _size,
      height: _size,
      color: coach.color.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        coach.emoji,
        style: TextStyle(fontSize: _size * 0.5),
      ),
    );
  }
}
