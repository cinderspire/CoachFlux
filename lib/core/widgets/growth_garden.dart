import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Visual growth metaphor: a plant that grows based on streak / session count.
/// Wilts if streak is at risk.
class GrowthGarden extends StatefulWidget {
  final int streak;
  final int totalSessions;
  final bool atRisk;

  const GrowthGarden({
    super.key,
    required this.streak,
    required this.totalSessions,
    this.atRisk = false,
  });

  @override
  State<GrowthGarden> createState() => _GrowthGardenState();
}

class _GrowthGardenState extends State<GrowthGarden> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Growth stages: seed → sprout → seedling → sapling → tree → full bloom
  _GrowthStage get _stage {
    final s = widget.totalSessions;
    if (s <= 0) return _GrowthStage('🌰', 'Seed', 'Plant your first session!');
    if (s <= 2) return _GrowthStage('🌱', 'Sprout', 'Your growth journey begins');
    if (s <= 5) return _GrowthStage('🪴', 'Seedling', 'Growing steadily');
    if (s <= 10) return _GrowthStage('🌿', 'Sapling', 'Reaching for the light');
    if (s <= 20) return _GrowthStage('🌳', 'Tree', 'Strong and rooted');
    return _GrowthStage('🌸', 'Full Bloom', 'You\'re flourishing!');
  }

  @override
  Widget build(BuildContext context) {
    final stage = _stage;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final sway = widget.atRisk ? 0.0 : _ctrl.value;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.atRisk
                  ? [
                      const Color(0xFF1A1510),
                      AppColors.backgroundDarkElevated,
                    ]
                  : [
                      AppColors.tertiarySage.withValues(alpha: 0.06),
                      AppColors.backgroundDarkElevated,
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.atRisk
                  ? AppColors.warning.withValues(alpha: 0.2)
                  : AppColors.tertiarySage.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              // Plant with subtle sway
              Transform.rotate(
                angle: widget.atRisk ? 0.15 : (sway - 0.5) * 0.06,
                child: Text(
                  widget.atRisk ? '🥀' : stage.emoji,
                  style: const TextStyle(fontSize: 44),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.atRisk ? 'Your garden needs care!' : stage.title,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: widget.atRisk
                                ? AppColors.warning
                                : AppColors.textPrimaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!widget.atRisk && widget.streak > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.tertiarySage.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${widget.streak}🔥',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.tertiarySage,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.atRisk
                          ? 'Chat with a coach to water your plant 💧'
                          : stage.subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Growth progress dots
                    Row(
                      children: List.generate(6, (i) {
                        final filled = widget.totalSessions > [0, 2, 5, 10, 20, 30][i];
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: filled
                                ? AppColors.tertiarySage
                                : AppColors.backgroundDark,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.tertiarySage.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GrowthStage {
  final String emoji;
  final String title;
  final String subtitle;
  _GrowthStage(this.emoji, this.title, this.subtitle);
}
