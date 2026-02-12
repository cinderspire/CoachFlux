import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/achievement_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<AchievementProgress> _progress = [];
  int _totalXP = 0;
  int _level = 1;
  int _unlockedCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final progress = await AchievementService().getAllProgress();
    final xp = await AchievementService().totalXP;
    final level = await AchievementService().level;
    final unlocked = await AchievementService().unlockedCount;
    if (mounted) {
      setState(() {
        _progress = progress;
        _totalXP = xp;
        _level = level;
        _unlockedCount = unlocked;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = AchievementService.allAchievements.length;
    final xpToNext = (_level * 200) - _totalXP;

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPeach))
            : CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Achievements',
                              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryDark)),
                          const SizedBox(height: 20),

                          // XP / Level card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 56, height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Center(
                                        child: Text('⚡',
                                            style: const TextStyle(fontSize: 28)),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Level $_level',
                                              style: AppTextStyles.headlineSmall.copyWith(
                                                color: AppColors.backgroundDark,
                                                fontWeight: FontWeight.bold,
                                              )),
                                          Text('$_totalXP XP • $_unlockedCount/$total unlocked',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: AppColors.backgroundDark.withValues(alpha: 0.7),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // XP progress to next level
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: 1.0 - (xpToNext / 200).clamp(0.0, 1.0),
                                    minHeight: 8,
                                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.backgroundDark.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  xpToNext > 0 ? '$xpToNext XP to Level ${_level + 1}' : 'Max level reached!',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.backgroundDark.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text('BADGES',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primaryPeach,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              )),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  // Achievement grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final achievement = AchievementService.allAchievements[i];
                          final progress = _progress[i];
                          return _AchievementBadge(
                            achievement: achievement,
                            progress: progress,
                          );
                        },
                        childCount: AchievementService.allAchievements.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final AchievementProgress progress;
  const _AchievementBadge({required this.achievement, required this.progress});

  @override
  Widget build(BuildContext context) {
    final unlocked = progress.unlocked;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showDetail(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: unlocked
              ? AppColors.primaryPeach.withValues(alpha: 0.08)
              : AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: unlocked
                ? AppColors.primaryPeach.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement.emoji,
              style: TextStyle(
                fontSize: 32,
                color: unlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.name,
              style: AppTextStyles.labelSmall.copyWith(
                color: unlocked ? AppColors.textPrimaryDark : AppColors.textTertiaryDark,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            if (!unlocked) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.progress,
                  minHeight: 4,
                  backgroundColor: AppColors.backgroundDark,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primaryPeach),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${progress.currentValue}/${achievement.targetValue}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiaryDark,
                  fontSize: 8,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.tertiarySage.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('✓ ${achievement.xp} XP',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.tertiarySage,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(achievement.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(achievement.name,
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
            const SizedBox(height: 8),
            Text(achievement.description,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              progress.unlocked
                  ? '🎉 Unlocked! +${achievement.xp} XP'
                  : '${progress.currentValue}/${achievement.targetValue} — ${(progress.progress * 100).round()}%',
              style: AppTextStyles.titleSmall.copyWith(
                color: progress.unlocked ? AppColors.tertiarySage : AppColors.primaryPeach,
              ),
            ),
            if (progress.unlocked) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text('Share'),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColors.primaryPeach)),
          ),
        ],
      ),
    );
  }
}
