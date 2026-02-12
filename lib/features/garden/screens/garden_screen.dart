import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/engagement_service.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> with TickerProviderStateMixin {
  int _totalSessions = 0;
  int _streak = 0;
  bool _loading = true;
  late AnimationController _pulseCtrl;
  late AnimationController _swayCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _swayCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _load();
  }

  Future<void> _load() async {
    final sessions = await EngagementService().totalSessionCount;
    final streak = await EngagementService().currentStreak;
    if (mounted) {
      setState(() {
        _totalSessions = sessions;
        _streak = streak;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _swayCtrl.dispose();
    super.dispose();
  }

  _GardenStage get _stage {
    if (_totalSessions >= 50) return _GardenStage(5, '🌳', 'Mighty Oak', 'You are a force of nature!', const Color(0xFF166534), 0);
    if (_totalSessions >= 30) return _GardenStage(4, '🌸', 'Flowering', 'Beautiful growth in bloom!', const Color(0xFF15803D), 50 - _totalSessions);
    if (_totalSessions >= 15) return _GardenStage(3, '🌿', 'Tree', 'Strong roots, reaching high!', const Color(0xFF16A34A), 30 - _totalSessions);
    if (_totalSessions >= 7) return _GardenStage(2, '🪴', 'Sapling', 'Growing taller every day!', const Color(0xFF22C55E), 15 - _totalSessions);
    if (_totalSessions >= 3) return _GardenStage(1, '🌱', 'Sprout', 'Life is emerging!', const Color(0xFF4ADE80), 7 - _totalSessions);
    return _GardenStage(0, '🌰', 'Seed', 'Ready to grow!', const Color(0xFF86EFAC), 3 - _totalSessions);
  }

  String get _nextStageName {
    if (_totalSessions >= 50) return '';
    if (_totalSessions >= 30) return 'Mighty Oak';
    if (_totalSessions >= 15) return 'Flowering';
    if (_totalSessions >= 7) return 'Tree';
    if (_totalSessions >= 3) return 'Sapling';
    return 'Sprout';
  }

  @override
  Widget build(BuildContext context) {
    final stage = _stage;
    final needsWatering = _streak == 0 && _totalSessions > 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Growth Garden',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark)),
        automaticallyImplyLeading: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Main plant visualization
                  AnimatedBuilder(
                    animation: _swayCtrl,
                    builder: (context, _) {
                      return Transform.rotate(
                        angle: needsWatering ? 0.1 : (_swayCtrl.value - 0.5) * 0.04,
                        child: Text(
                          needsWatering ? '🥀' : stage.emoji,
                          style: const TextStyle(fontSize: 100),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Stage name
                  Text(
                    needsWatering ? 'Your garden needs watering!' : stage.name,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: needsWatering ? Colors.orange : AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    needsWatering
                        ? 'Start a session to revive it 💧'
                        : stage.subtitle,
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_totalSessions sessions total',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark),
                  ),
                  const SizedBox(height: 32),

                  // Progress to next stage
                  if (stage.toNext > 0) ...[
                    Text(
                      '🌱 ${stage.toNext} more session${stage.toNext == 1 ? '' : 's'} to become a $_nextStageName!',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.tertiarySage),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Growth stages timeline
                  ...List.generate(6, (i) {
                    final stages = [
                      ('🌰', 'Seed', '0 sessions', 0),
                      ('🌱', 'Sprout', '3 sessions', 3),
                      ('🪴', 'Sapling', '7 sessions', 7),
                      ('🌿', 'Tree', '15 sessions', 15),
                      ('🌸', 'Flowering', '30 sessions', 30),
                      ('🌳', 'Mighty Oak', '50+ sessions', 50),
                    ];
                    final s = stages[i];
                    final reached = _totalSessions >= s.$4;
                    final current = stage.level == i;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: current
                            ? AppColors.tertiarySage.withValues(alpha: 0.1)
                            : AppColors.backgroundDarkElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: current
                              ? AppColors.tertiarySage.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(s.$1, style: TextStyle(fontSize: 28, color: reached ? null : Colors.white.withValues(alpha: 0.3))),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.$2,
                                    style: AppTextStyles.titleSmall.copyWith(
                                      color: reached ? AppColors.textPrimaryDark : AppColors.textTertiaryDark,
                                    )),
                                Text(s.$3,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textTertiaryDark,
                                    )),
                              ],
                            ),
                          ),
                          if (reached)
                            Icon(Icons.check_circle_rounded, size: 20, color: AppColors.tertiarySage)
                          else
                            Icon(Icons.radio_button_unchecked_rounded, size: 20, color: AppColors.textTertiaryDark.withValues(alpha: 0.3)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _GardenStage {
  final int level;
  final String emoji;
  final String name;
  final String subtitle;
  final Color color;
  final int toNext;
  _GardenStage(this.level, this.emoji, this.name, this.subtitle, this.color, this.toNext);
}
