import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/revenuecat_service.dart';
import '../../../core/services/mood_service.dart';
import '../../../core/services/engagement_service.dart';
import '../../../core/models/coach.dart';
import '../../../core/widgets/wisdom_card.dart';
import '../../paywall/screens/paywall_screen.dart';
import '../../assessment/screens/problem_assessment_screen.dart';
import '../../coach_builder/screens/coach_builder_screen.dart';
import '../../journal/screens/journal_screen.dart';
import '../../achievements/screens/achievements_screen.dart';
import '../../wisdom/screens/wisdom_collection_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController(text: '');
  final Set<String> _values = {};
  final Set<String> _goals = {};
  final Set<String> _challenges = {};
  int _sessionCount = 0;
  int _streak = 0;
  int _coachCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final sessions = await EngagementService().totalSessionCount;
    final streak = await EngagementService().currentStreak;
    final coaches = defaultCoaches.where((c) => !c.isPremium).length;
    if (mounted) {
      setState(() {
        _sessionCount = sessions;
        _streak = streak;
        _coachCount = coaches;
      });
    }
  }

  final _allValues = [
    'Growth', 'Balance', 'Creativity', 'Discipline', 'Freedom',
    'Authenticity', 'Connection', 'Health', 'Impact', 'Curiosity',
  ];
  final _allGoals = [
    'Build habits', 'Reduce stress', 'Career growth', 'Get fit',
    'Learn skills', 'Better sleep', 'Save money', 'Be creative',
  ];
  final _allChallenges = [
    'Procrastination', 'Overthinking', 'Low energy', 'Time management',
    'Focus issues', 'Self-doubt', 'Burnout', 'Motivation',
  ];

  @override
  Widget build(BuildContext context) {
    final sub = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryDark)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.textSecondaryDark),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Stats row
              Row(
                children: [
                  _statCard('$_sessionCount', 'Sessions', AppColors.primaryPeach),
                  const SizedBox(width: 12),
                  _statCard('$_streak', 'Streak', AppColors.tertiarySage),
                  const SizedBox(width: 12),
                  _statCard('$_coachCount', 'Coaches', AppColors.secondaryLavender),
                ],
              ),
              const SizedBox(height: 24),

              // Mood Trend
              const _MoodSparkline(),
              const SizedBox(height: 16),

              // Milestone & Wisdom
              const _MilestoneSection(),
              const SizedBox(height: 24),

              // Subscription
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen())),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: sub.isFree ? null : AppColors.primaryGradient,
                    color: sub.isFree ? AppColors.backgroundDarkElevated : null,
                    borderRadius: BorderRadius.circular(16),
                    border: sub.isFree
                        ? Border.all(color: Colors.white.withValues(alpha: 0.05))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        sub.isFree ? Icons.star_outline_rounded : Icons.star_rounded,
                        color: sub.isFree ? AppColors.textSecondaryDark : AppColors.backgroundDark,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          sub.isFree ? 'Upgrade to Pro' : (sub.isCoachTier ? 'Coach Tier' : 'Pro Plan'),
                          style: AppTextStyles.titleSmall.copyWith(
                            color: sub.isFree ? AppColors.textPrimaryDark : AppColors.backgroundDark,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: sub.isFree ? AppColors.textTertiaryDark : AppColors.backgroundDark),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Name
              _label('Your Name'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                decoration: const InputDecoration(hintText: 'Enter your name'),
              ),
              const SizedBox(height: 24),

              // Values
              _label('Core Values'),
              const SizedBox(height: 8),
              _chipSection(_allValues, _values),
              const SizedBox(height: 24),

              // Goals
              _label('Current Goals'),
              const SizedBox(height: 8),
              _chipSection(_allGoals, _goals),
              const SizedBox(height: 24),

              // Challenges
              _label('Challenges'),
              const SizedBox(height: 8),
              _chipSection(_allChallenges, _challenges),
              const SizedBox(height: 32),

              // Actions
              _actionTile(Icons.menu_book_rounded, 'Journal', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const JournalScreen()));
              }),
              _actionTile(Icons.emoji_events_rounded, 'Achievements', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AchievementsScreen()));
              }),
              _actionTile(Icons.auto_awesome_rounded, 'Wisdom Cards', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const WisdomCollectionScreen()));
              }),
              _actionTile(Icons.add_circle_outline_rounded, 'Create Custom Coach', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CoachBuilderScreen()));
              }),
              _actionTile(Icons.psychology_alt_rounded, 'Reassess My Needs', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProblemAssessmentScreen(isReassessment: true)));
              }),
              _actionTile(Icons.info_outline_rounded, 'About CoachFlux', () {
                Navigator.pushNamed(context, '/settings');
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) =>
      Text(text, style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark));

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.headlineMedium.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
          ],
        ),
      ),
    );
  }

  Widget _chipSection(List<String> all, Set<String> selected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: all.map((item) {
        final active = selected.contains(item);
        return GestureDetector(
          onTap: () => setState(() {
            active ? selected.remove(item) : selected.add(item);
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primaryPeach.withValues(alpha: 0.15)
                  : AppColors.backgroundDarkElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.primaryPeach : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Text(item,
                style: AppTextStyles.labelSmall.copyWith(
                    color: active ? AppColors.primaryPeach : AppColors.textSecondaryDark)),
          ),
        );
      }).toList(),
    );
  }

  Widget _actionTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondaryDark, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textTertiaryDark),
          ],
        ),
      ),
    );
  }
}

// === Mood Sparkline ===

class _MoodSparkline extends StatefulWidget {
  const _MoodSparkline();

  @override
  State<_MoodSparkline> createState() => _MoodSparklineState();
}

class _MoodSparklineState extends State<_MoodSparkline> {
  List<double>? _scores;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final scores = await MoodService().last7DaysScores();
    if (mounted) setState(() => _scores = scores);
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _scores != null && _scores!.any((s) => s >= 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Mood Trend (7 days)',
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasData)
            Text('No mood data yet. Use the daily check-in!',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark))
          else
            SizedBox(
              height: 60,
              child: CustomPaint(
                size: const Size(double.infinity, 60),
                painter: _SparklinePainter(_scores!),
              ),
            ),
          if (hasData) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final day = DateTime.now().subtract(Duration(days: 6 - i));
                return Text(
                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1],
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark, fontSize: 9),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

// === Milestone & Wisdom Collection ===

class _MilestoneSection extends StatefulWidget {
  const _MilestoneSection();

  @override
  State<_MilestoneSection> createState() => _MilestoneSectionState();
}

class _MilestoneSectionState extends State<_MilestoneSection> {
  int _totalSessions = 0;
  int _wisdomCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final total = await EngagementService().totalSessionCount;
    if (mounted) {
      setState(() {
        _totalSessions = total;
        _wisdomCount = total ~/ 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_totalSessions < 3) return const SizedBox.shrink();

    // Milestone thresholds
    final milestones = [10, 25, 50, 100];
    final nextMilestone = milestones.firstWhere((m) => m > _totalSessions, orElse: () => 100);
    final lastMilestone = milestones.lastWhere((m) => m <= _totalSessions, orElse: () => 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Milestone badge
        if (lastMilestone > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPeach.withValues(alpha: 0.12),
                  AppColors.secondaryLavender.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryPeach.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$lastMilestone Messages Milestone!',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.primaryPeach,
                            fontWeight: FontWeight.bold,
                          )),
                      Text('Next: $nextMilestone messages (${nextMilestone - _totalSessions} to go)',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        // Latest wisdom card
        if (_wisdomCount > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Latest Wisdom',
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
              Text('$_wisdomCount collected 🃏',
                  style: AppTextStyles.caption.copyWith(color: AppColors.secondaryLavender)),
            ],
          ),
          const SizedBox(height: 8),
          WisdomCard(
            wisdom: EngagementService().getWisdom(_wisdomCount),
            coachName: defaultCoaches.first.name,
            coachEmoji: defaultCoaches.first.emoji,
            coachColor: defaultCoaches.first.color,
            cardNumber: _wisdomCount,
          ),
        ],
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> scores;
  _SparklinePainter(this.scores);

  @override
  void paint(Canvas canvas, Size size) {
    final validScores = scores.where((s) => s >= 0).toList();
    if (validScores.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primaryPeach
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = AppColors.primaryPeach
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x40FFB5A7), Color(0x00FFB5A7)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final step = size.width / (scores.length - 1);
    bool started = false;

    for (int i = 0; i < scores.length; i++) {
      if (scores[i] < 0) continue;
      final x = i * step;
      final y = size.height - (scores[i] * size.height);

      if (!started) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    // Close fill path
    if (started) {
      final lastValidIdx = scores.lastIndexWhere((s) => s >= 0);
      fillPath.lineTo(lastValidIdx * step, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
