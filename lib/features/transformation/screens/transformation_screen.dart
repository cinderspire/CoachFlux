import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/mood_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/achievement_service.dart';
import '../../../core/services/journal_service.dart';
import '../../../core/services/engagement_service.dart';

class TransformationScreen extends StatefulWidget {
  const TransformationScreen({super.key});

  @override
  State<TransformationScreen> createState() => _TransformationScreenState();
}

class _TransformationScreenState extends State<TransformationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _loading = true;
  List<MoodEntry> _moods = [];
  // ignore: unused_field
  late AnalyticsData _analytics;
  List<AchievementProgress> _achievements = [];
  List<JournalEntry> _journals = [];
  int _totalSessions = 0;
  int _currentStreak = 0;
  double _transformationScore = 0;
  String _phase = '';
  String _phaseEmoji = '';
  String _phaseDescription = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _load();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final moods = await MoodService().getHistory();
    final analytics = await AnalyticsService().getAnalytics();
    final achievements = await AchievementService().getAllProgress();
    final journals = await JournalService().getEntries();

    final unlocked = achievements.where((a) => a.unlocked).length;
    final totalSessions = analytics.totalSessions;
    final streak = await EngagementService().currentStreak;

    // Calculate transformation score (0-100)
    double score = 0;
    score += (totalSessions.clamp(0, 50) / 50) * 25; // Sessions: max 25pts
    score += (streak.clamp(0, 14) / 14) * 20; // Streak: max 20pts
    score += (unlocked.clamp(0, 20) / 20) * 20; // Achievements: max 20pts
    score += (journals.length.clamp(0, 30) / 30) * 15; // Journal: max 15pts

    // Mood improvement bonus
    if (moods.length >= 5) {
      final recent = moods.take(5).map((m) => m.mood.score).reduce((a, b) => a + b) / 5;
      final older = moods.skip(moods.length ~/ 2).take(5).map((m) => m.mood.score);
      if (older.isNotEmpty) {
        final olderAvg = older.reduce((a, b) => a + b) / older.length;
        if (recent > olderAvg) {
          score += 20; // Improving: max 20pts
        } else {
          score += 10;
        }
      } else {
        score += 10;
      }
    }

    // Determine phase
    String phase, emoji, desc;
    if (score < 15) {
      phase = 'Awakening';
      emoji = '🌱';
      desc = 'You\'ve taken the first step. Every journey begins with awareness.';
    } else if (score < 30) {
      phase = 'Exploring';
      emoji = '🔍';
      desc = 'You\'re discovering patterns and building self-awareness.';
    } else if (score < 50) {
      phase = 'Building';
      emoji = '🏗️';
      desc = 'New habits are forming. You\'re rewiring your responses.';
    } else if (score < 70) {
      phase = 'Transforming';
      emoji = '🦋';
      desc = 'Real change is happening. Others are starting to notice.';
    } else if (score < 90) {
      phase = 'Thriving';
      emoji = '🌟';
      desc = 'You\'ve built resilience and emotional intelligence.';
    } else {
      phase = 'Mastery';
      emoji = '👑';
      desc = 'You\'ve achieved deep self-understanding and growth.';
    }

    if (mounted) {
      setState(() {
        _moods = moods;
        _analytics = analytics;
        _achievements = achievements;
        _journals = journals;
        _totalSessions = totalSessions;
        _currentStreak = streak;
        _transformationScore = score.clamp(0, 100);
        _phase = phase;
        _phaseEmoji = emoji;
        _phaseDescription = desc;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPeach))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimaryDark, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text('My Transformation',
                            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryDark)),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Phase Card
                    _buildPhaseCard(),
                    const SizedBox(height: 24),

                    // Transformation Score Ring
                    _buildScoreRing(),
                    const SizedBox(height: 24),

                    // Journey Timeline
                    Text('Your Journey', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
                    const SizedBox(height: 16),
                    _buildTimeline(),
                    const SizedBox(height: 24),

                    // Mood Evolution
                    Text('Mood Evolution', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
                    const SizedBox(height: 16),
                    _buildMoodEvolution(),
                    const SizedBox(height: 24),

                    // Growth Metrics
                    Text('Growth Metrics', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
                    const SizedBox(height: 16),
                    _buildGrowthMetrics(),
                    const SizedBox(height: 24),

                    // Milestones
                    Text('Milestones Reached', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
                    const SizedBox(height: 16),
                    _buildMilestones(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPhaseCard() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final scale = Curves.elasticOut.transform(_animController.value.clamp(0, 1));
        return Transform.scale(
          scale: 0.8 + (0.2 * scale),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryPeach.withValues(alpha: 0.15),
              const Color(0xFF7C3AED).withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryPeach.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(_phaseEmoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text('Phase: $_phase',
                style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primaryPeach, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_phaseDescription,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryDark, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRing() {
    return Center(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          final progress = _animController.value * (_transformationScore / 100);
          return SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: AppColors.backgroundDarkElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.lerp(const Color(0xFFEF4444), const Color(0xFF22C55E), progress) ??
                          AppColors.primaryPeach,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(_transformationScore * _animController.value).toInt()}',
                        style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold)),
                    Text('/ 100',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark)),
                    const SizedBox(height: 2),
                    Text('Transformation',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryPeach)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline() {
    final milestones = <_TimelineItem>[];

    // First session
    if (_totalSessions > 0) {
      milestones.add(_TimelineItem('🚀', 'First Session', 'You started your journey', true));
    }

    // Journal started
    if (_journals.isNotEmpty) {
      milestones.add(_TimelineItem('📝', 'First Journal Entry', 'Self-reflection began', true));
    }

    // 5 sessions
    if (_totalSessions >= 5) {
      milestones.add(_TimelineItem('💬', '5 Sessions Complete', 'Building a habit', true));
    } else {
      milestones.add(_TimelineItem('💬', '5 Sessions', '${5 - _totalSessions} more to go', false));
    }

    // 3-day streak
    if (_currentStreak >= 3) {
      milestones.add(_TimelineItem('🔥', '3-Day Streak', 'Consistency is key', true));
    } else {
      milestones.add(_TimelineItem('🔥', '3-Day Streak', 'Keep showing up', false));
    }

    // 10 sessions
    if (_totalSessions >= 10) {
      milestones.add(_TimelineItem('🧠', '10 Sessions', 'Deep patterns emerging', true));
    } else {
      milestones.add(_TimelineItem('🧠', '10 Sessions', '${10 - _totalSessions} more to go', false));
    }

    // 7-day streak
    if (_currentStreak >= 7) {
      milestones.add(_TimelineItem('⭐', '7-Day Streak', 'Transformation in progress', true));
    } else {
      milestones.add(_TimelineItem('⭐', '7-Day Streak', 'The real change begins here', false));
    }

    // 30 sessions = mastery
    if (_totalSessions >= 30) {
      milestones.add(_TimelineItem('👑', '30 Sessions', 'Mastery level', true));
    } else {
      milestones.add(_TimelineItem('👑', '30 Sessions', 'The ultimate milestone', false));
    }

    return Column(
      children: milestones.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final isLast = i == milestones.length - 1;
        return _buildTimelineRow(item, isLast);
      }).toList(),
    );
  }

  Widget _buildTimelineRow(_TimelineItem item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line + dot
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.completed
                      ? AppColors.primaryPeach.withValues(alpha: 0.2)
                      : AppColors.backgroundDarkElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.completed ? AppColors.primaryPeach : AppColors.textSecondaryDark.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: item.completed
                      ? Text(item.emoji, style: const TextStyle(fontSize: 14))
                      : Icon(Icons.lock_outline, size: 14,
                          color: AppColors.textSecondaryDark.withValues(alpha: 0.5)),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: item.completed
                      ? AppColors.primaryPeach.withValues(alpha: 0.4)
                      : AppColors.textSecondaryDark.withValues(alpha: 0.15),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AppTextStyles.titleSmall.copyWith(
                        color: item.completed
                            ? AppColors.textPrimaryDark
                            : AppColors.textSecondaryDark.withValues(alpha: 0.5))),
                const SizedBox(height: 2),
                Text(item.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: item.completed
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryDark.withValues(alpha: 0.3))),
              ],
            ),
          ),
        ),
        if (item.completed)
          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
      ],
    );
  }

  Widget _buildMoodEvolution() {
    if (_moods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text('Start logging moods to see your evolution ✨',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
        ),
      );
    }

    // Show last 14 mood entries as mini chart
    final recent = _moods.take(14).toList().reversed.toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: recent.map((entry) {
              return Expanded(
                child: Column(
                  children: [
                    Text(entry.mood.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Container(
                      height: 40 * entry.mood.score,
                      width: 8,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          const Color(0xFFEF4444),
                          const Color(0xFF22C55E),
                          entry.mood.score,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Older', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryDark)),
              Text('Recent', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthMetrics() {
    return Row(
      children: [
        _metricCard('💬', '$_totalSessions', 'Sessions'),
        const SizedBox(width: 12),
        _metricCard('🔥', '$_currentStreak', 'Day Streak'),
        const SizedBox(width: 12),
        _metricCard('📝', '${_journals.length}', 'Journals'),
        const SizedBox(width: 12),
        _metricCard('🏆', '${_achievements.where((a) => a.unlocked).length}', 'Badges'),
      ],
    );
  }

  Widget _metricCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestones() {
    final unlocked = _achievements.where((a) => a.unlocked).toList();
    if (unlocked.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text('Complete sessions to earn milestones 🏅',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: unlocked.take(12).map((a) {
        final achievement = AchievementService.allAchievements
            .where((ac) => ac.id == a.achievementId)
            .firstOrNull;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryPeach.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryPeach.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(achievement?.emoji ?? '🏅', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(achievement?.name ?? a.achievementId, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimaryDark)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TimelineItem {
  final String emoji;
  final String title;
  final String subtitle;
  final bool completed;
  _TimelineItem(this.emoji, this.title, this.subtitle, this.completed);
}
