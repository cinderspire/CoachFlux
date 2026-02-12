import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Collectible wisdom card — unlocked after sessions.
/// Beautiful gradient card design with coach's color.
class WisdomCard extends StatefulWidget {
  final String wisdom;
  final String coachName;
  final String coachEmoji;
  final Color coachColor;
  final int cardNumber;

  const WisdomCard({
    super.key,
    required this.wisdom,
    required this.coachName,
    required this.coachEmoji,
    required this.coachColor,
    required this.cardNumber,
  });

  @override
  State<WisdomCard> createState() => _WisdomCardState();
}

class _WisdomCardState extends State<WisdomCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    HapticFeedback.lightImpact();
    if (_flipped) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
    setState(() => _flipped = !_flipped);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final angle = _ctrl.value * 3.14159;
          final showBack = _ctrl.value > 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showBack ? _buildBack() : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.coachColor.withValues(alpha: 0.15),
            AppColors.backgroundDarkElevated,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.coachColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: widget.coachColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.coachColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '✨ WISDOM #${widget.cardNumber}',
                  style: AppTextStyles.caption.copyWith(
                    color: widget.coachColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(widget.coachEmoji, style: const TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.wisdom,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '— ${widget.coachName}',
            style: AppTextStyles.caption.copyWith(color: widget.coachColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to flip',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiaryDark,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    // Mirror the text since we're rotated 180°
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.coachColor.withValues(alpha: 0.25),
              widget.coachColor.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.coachColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.coachEmoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              widget.coachName,
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark),
            ),
            const SizedBox(height: 4),
            Text(
              'Wisdom Card #${widget.cardNumber}',
              style: AppTextStyles.caption.copyWith(color: widget.coachColor),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.coachColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🃏 Collected',
                style: AppTextStyles.labelSmall.copyWith(color: widget.coachColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
