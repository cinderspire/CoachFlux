import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/coach.dart';
import '../../../core/services/mood_service.dart';
import '../../../core/services/chemistry_service.dart';
import '../../../core/services/engagement_service.dart';
import '../../../core/services/goal_service.dart';
import '../../../core/widgets/shimmer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../coaches/screens/coaches_screen.dart';
import '../../chat/screens/chat_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../insights/screens/insights_screen.dart';
import '../../techniques/screens/techniques_screen.dart';
import '../../transformation/screens/transformation_screen.dart';
import '../../../core/widgets/coach_photo.dart';
import '../../appointments/screens/appointments_screen.dart';
import '../../../core/services/problem_engine.dart';
import '../../../core/services/recommendation_service.dart';
import '../../../core/services/retention_service.dart';

final _navIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(_navIndexProvider);

    final screens = [
      const _HomeTab(),
      const CoachesScreen(),
      const TechniquesScreen(),
      const InsightsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => ref.read(_navIndexProvider.notifier).state = i,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Coaches'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology_rounded), label: 'Techniques'),
            BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Insights'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// HOME TAB
// ═══════════════════════════════════════════════════════

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with TickerProviderStateMixin {
  bool _loading = true;
  String? _topCoachId;
  int _streak = 0;
  bool _streakAtRisk = false;
  String? _moodSummary;
  String? _dailyTip;

  // Goal system
  List<String> _goals = [];
  Map<String, bool> _goalDone = {};
  Map<String, int> _goalStreaks = {};
  Map<String, double> _goalProgress = {};

  // Daily plan
  List<MapEntry<String, String>> _dailyPlan = [];
  int _dailyPlanCompleted = 0;
  bool _showCelebration = false;

  // Problem assessment
  List<ProblemAssessmentResult>? _assessmentResults;

  // Retention
  ComebackMessage? _comebackMessage;
  WeeklyChallenge? _weeklyChallenge;

  late AnimationController _affirmationCtrl;

  @override
  void initState() {
    super.initState();
    _affirmationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _load();
  }

  @override
  void dispose() {
    _affirmationCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final topId = await ChemistryService().getTopCoachId();
    final streak = await EngagementService().currentStreak;
    final atRisk = await EngagementService().isStreakAtRisk;
    final scores = await MoodService().last7DaysScores();

    // Load goals
    final goalService = GoalService();
    final goals = await goalService.getSelectedGoals();
    final goalDone = <String, bool>{};
    final goalStreaks = <String, int>{};
    final goalProgress = <String, double>{};
    for (final g in goals) {
      goalDone[g] = await goalService.isActionComplete(g);
      goalStreaks[g] = await goalService.getStreak(g);
      goalProgress[g] = await goalService.getProgress(g);
    }

    // Assessment results
    final assessmentResults = await RecommendationService.loadAssessment();

    // Retention
    final retention = RetentionService();
    final comebackMsg = await retention.checkComeback();
    final weeklyChallenge = await retention.getCurrentChallenge();
    await retention.recordSessionSimple();
    await retention.checkAndUnlockMilestonesCompat(sessionCount: streak);

    // Daily tip
    final dailyTip = await _loadDailyTip();

    // Daily plan
    final dailyPlan = await goalService.getDailyPlan();
    final dailyPlanCompleted = await goalService.getDailyPlanCompleted();

    String? summary;
    final validScores = scores.where((s) => s >= 0).toList();
    if (validScores.length >= 3) {
      final avg = validScores.reduce((a, b) => a + b) / validScores.length;
      final happyPct = (avg * 100).round();
      if (avg >= 0.7) {
        summary = 'You felt positive $happyPct% of the time this week — keep it up! 📈';
      } else if (avg >= 0.5) {
        summary = 'Your mood averaged $happyPct% this week — steady progress 🌱';
      } else {
        summary = 'It\'s been a tough week ($happyPct%). Your coaches are here for you 💜';
      }
    }

    if (mounted) {
      setState(() {
        _assessmentResults = assessmentResults;
        _comebackMessage = comebackMsg;
        _weeklyChallenge = weeklyChallenge;
        _dailyTip = dailyTip;
        _topCoachId = topId;
        _streak = streak;
        _streakAtRisk = atRisk;
        _moodSummary = summary;
        _goals = goals;
        _goalDone = goalDone;
        _goalStreaks = goalStreaks;
        _goalProgress = goalProgress;
        _dailyPlan = dailyPlan;
        _dailyPlanCompleted = dailyPlanCompleted;
        _loading = false;
      });
      _affirmationCtrl.forward();
    }
  }

  static const _coachingTips = [
    '💡 Small progress is still progress. Celebrate the tiny wins.',
    '🧠 Your brain can\'t tell the difference between vividly imagining success and actually experiencing it.',
    '⏰ The two-minute rule: if it takes less than 2 minutes, do it now.',
    '🌱 Growth happens outside your comfort zone — lean into the discomfort.',
    '🎯 Focus on systems, not goals. Goals set the direction; systems make the progress.',
    '😮‍💨 Stressed? Try 4-7-8 breathing: inhale 4s, hold 7s, exhale 8s.',
    '📵 Your phone checks you more than you check it. Set intentional screen-free blocks.',
    '🏃 A 10-minute walk boosts creativity by 60% (Stanford study).',
    '📝 Writing down your goals makes you 42% more likely to achieve them.',
    '🛌 Sleep is the #1 performance enhancer. Protect your 7-8 hours.',
    '🤝 You are the average of the 5 people you spend the most time with.',
    '🧘 Mindfulness isn\'t about emptying your mind — it\'s about noticing what\'s there.',
    '💪 Discipline is choosing between what you want now and what you want most.',
    '📚 Reading 20 minutes a day exposes you to 1.8 million words per year.',
    '🌊 Emotions are like waves — you can\'t stop them, but you can learn to surf.',
  ];

  Future<String> _loadDailyTip() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('daily_tip_date');
    if (savedDate == today) {
      return prefs.getString('daily_tip') ?? _coachingTips[0];
    }
    // Pick a deterministic-random tip based on the date
    final dayHash = today.hashCode.abs() % _coachingTips.length;
    final tip = _coachingTips[dayHash];
    await prefs.setString('daily_tip_date', today);
    await prefs.setString('daily_tip', tip);
    return tip;
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Welcome Back';
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Welcome Back';
  }

  String _motivationalSubtitle() {
    final day = DateTime.now().weekday;
    final hour = DateTime.now().hour;
    final subs = [
      'Your mind. Upgraded.',
      'Become who you\'re meant to be',
      'Your mind is your greatest asset',
      'Small steps, extraordinary results',
      'Every session makes you stronger',
      'Today\'s effort is tomorrow\'s edge',
      'Invest in yourself — it compounds',
      'Growth happens one conversation at a time',
      'Progress is built daily, not overnight',
      'You showed up. That matters.',
    ];
    if (day == DateTime.monday) return 'New week, new level ⚡';
    if (day == DateTime.friday) return 'Finish the week strong 💪';
    if (day == DateTime.sunday) return 'Reflect, recharge, rise 🌿';
    return subs[(day + hour ~/ 4) % subs.length];
  }

  String _greetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return '✨';
    }
    if (hour < 12) {
      return '☀️';
    }
    if (hour < 17) {
      return '🌤️';
    }
    if (hour < 21) {
      return '🌆';
    }
    return '🌙';
  }

  Future<void> _toggleGoalAction(String goal) async {
    final current = _goalDone[goal] ?? false;
    await GoalService().markActionComplete(goal, !current);
    HapticFeedback.mediumImpact();
    await _load();

    // Check celebration
    if (_dailyPlanCompleted >= _dailyPlan.length && _dailyPlan.isNotEmpty) {
      setState(() => _showCelebration = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showCelebration = false);
      });
    }
  }

  List<Widget> _buildProblemToolkitCards() {
    final widgets = <Widget>[];
    for (final result in _assessmentResults!.take(2)) {
      final def = ProblemEngine.getDefinition(result.category);
      final primaryCoachRec = def.coaches.where((c) => c.role == 'primary').firstOrNull;
      final primaryCoach = primaryCoachRec != null
          ? defaultCoaches.where((c) => c.id == primaryCoachRec.coachId).firstOrNull
          : null;

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: def.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: def.accentColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(def.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your ${def.title} Toolkit',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: def.accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ProblemEngine.severityColor(result.severity).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ProblemEngine.severityLabel(result.severity),
                      style: AppTextStyles.caption.copyWith(
                        color: ProblemEngine.severityColor(result.severity),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Quick access: primary coach + top 2 techniques
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (primaryCoach != null)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChatScreen(coach: primaryCoach)),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryCoach.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(primaryCoach.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              primaryCoach.name,
                              style: AppTextStyles.caption.copyWith(
                                color: primaryCoach.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  for (final tech in def.techniques.take(2))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tech.name,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondaryDark,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final freeCoaches = defaultCoaches.where((c) => !c.isPremium).take(6).toList();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.primaryPeach,
              backgroundColor: AppColors.backgroundDarkElevated,
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Row(
                      children: [
                        Text(_greetingEmoji(), style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_greeting(),
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
                              Text(_motivationalSubtitle(),
                                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
                            ],
                          ),
                        ),
                        if (_streak > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Text('$_streak',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.backgroundDark,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── COMEBACK MESSAGE ──
                    if (_comebackMessage != null && !_loading) ...[
                      _ComebackCard(message: _comebackMessage!),
                      const SizedBox(height: 16),
                    ],

                    // ── DAILY TIP ──
                    if (_dailyTip != null && !_loading)
                      _DailyTipCard(tip: _dailyTip!),
                    if (_dailyTip != null && !_loading) const SizedBox(height: 16),

                    // ── WEEKLY CHALLENGE ──
                    if (_weeklyChallenge != null && !_loading) ...[
                      _WeeklyChallengeCard(
                        challenge: _weeklyChallenge!,
                        onComplete: () async {
                          await RetentionService().markChallengeDayComplete();
                          _load();
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── PROBLEM TOOLKIT ──
                    if (_assessmentResults != null && _assessmentResults!.isNotEmpty && !_loading)
                      ..._buildProblemToolkitCards(),

                    // ── QUICK START ──
                    if (_topCoachId != null && !_loading)
                      _QuickStartButton(
                        topCoachId: _topCoachId!,
                        onChatOpened: _load,
                      ),
                    if (_topCoachId != null && !_loading) const SizedBox(height: 16),

                    // ── BOOK SESSION CTA ──
                    _BookSessionCard(),
                    const SizedBox(height: 16),

                    // ── CELEBRATION CARD ──
                    if (_dailyPlan.isNotEmpty && _dailyPlanCompleted >= _dailyPlan.length) ...[
                      _CelebrationCard(),
                      const SizedBox(height: 16),
                    ],

                    // ── TODAY'S PLAN ──
                    if (_dailyPlan.isNotEmpty) ...[
                      _DailyPlanCard(
                        plan: _dailyPlan,
                        goalDone: _goalDone,
                        completed: _dailyPlanCompleted,
                        total: _dailyPlan.length,
                        onToggle: _toggleGoalAction,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── STREAK AT RISK ──
                    if (_streakAtRisk && _streak > 0)
                      _StreakRiskBanner(streak: _streak),
                    if (_streakAtRisk && _streak > 0) const SizedBox(height: 16),

                    // ── YOUR GOALS ──
                    if (_goals.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Your Goals',
                              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TechniquesScreen()),
                            ),
                            child: Text('Explore Techniques →',
                                style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryPeach)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final goal in _goals)
                        _GoalCard(
                          goalName: goal,
                          config: GoalService().getConfig(goal),
                          todayAction: GoalService().getTodayAction(goal),
                          isDone: _goalDone[goal] ?? false,
                          streak: _goalStreaks[goal] ?? 0,
                          progress: _goalProgress[goal] ?? 0,
                          onToggle: () => _toggleGoalAction(goal),
                          onExploreTechniques: () {
                            // Map goal to technique category
                            String? cat;
                            if (goal.contains('Focus') || goal.contains('Productivity')) {
                              cat = 'Focus & Productivity';
                            } else if (goal.contains('Mindfulness') || goal.contains('Calm')) {
                              cat = 'Mindfulness & Calm';
                            } else if (goal.contains('Fitness') || goal.contains('Energy')) {
                              cat = 'Fitness & Energy';
                            } else if (goal.contains('Career')) {
                              cat = 'Career Growth';
                            } else if (goal.contains('Financial')) {
                              cat = 'Financial Freedom';
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => TechniquesScreen(initialCategory: cat)),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                    ],

                    // ── MOOD SUMMARY ──
                    if (_moodSummary != null) _IdentityCard(summary: _moodSummary!),
                    if (_moodSummary != null) const SizedBox(height: 16),

                    // Transformation Journey Card
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TransformationScreen()),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF7C3AED).withValues(alpha: 0.2),
                              AppColors.primaryPeach.withValues(alpha: 0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Text('🦋', style: TextStyle(fontSize: 36)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('My Transformation',
                                      style: AppTextStyles.titleSmall.copyWith(
                                          color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Track your psychological growth journey',
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: AppColors.textSecondaryDark.withValues(alpha: 0.5), size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Daily check-in
                    _DailyCheckIn(),
                    const SizedBox(height: 24),

                    // Your Coaches
                    Text('Your Coaches',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: _loading
                          ? ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 4,
                              separatorBuilder: (_, i2) => const SizedBox(width: 12),
                              itemBuilder: (_, i3) => const ShimmerCoachCard(),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: freeCoaches.length,
                              separatorBuilder: (_, i2) => const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                final coach = freeCoaches[i];
                                final isTop = coach.id == _topCoachId;
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ChatScreen(coach: coach, heroTag: 'home-coach-${coach.id}')),
                                  ).then((_) => _load()),
                                  child: Stack(
                                    children: [
                                      Hero(
                                        tag: 'home-coach-${coach.id}',
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            width: 110,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppColors.backgroundDarkElevated,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isTop
                                                    ? AppColors.primaryPeach.withValues(alpha: 0.4)
                                                    : Colors.white.withValues(alpha: 0.05),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                CoachPhoto(
                                                  coach: coach,
                                                  radius: 24,
                                                  showBorder: true,
                                                ),
                                                const SizedBox(height: 10),
                                                Text(coach.name,
                                                    style: AppTextStyles.labelMedium
                                                        .copyWith(color: AppColors.textPrimaryDark),
                                                    textAlign: TextAlign.center),
                                                const SizedBox(height: 2),
                                                Text(coach.category,
                                                    style: AppTextStyles.caption
                                                        .copyWith(color: AppColors.textTertiaryDark)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isTop)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryPeach,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text('⭐ Top',
                                                style: AppTextStyles.caption.copyWith(
                                                  color: AppColors.backgroundDark,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Celebration overlay
            if (_showCelebration)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 72)),
                      const SizedBox(height: 16),
                      Text('All tasks complete!',
                          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primaryPeach)),
                      const SizedBox(height: 8),
                      Text('Amazing work today! 🌟',
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// DAILY TIP CARD
// ═══════════════════════════════════════════════════════

class _DailyTipCard extends StatelessWidget {
  final String tip;
  const _DailyTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.quaternarySky.withValues(alpha: 0.1),
            AppColors.secondaryLavender.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.quaternarySky.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Coaching Tip',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.quaternarySky,
                      letterSpacing: 1,
                    )),
                const SizedBox(height: 4),
                Text(tip,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      height: 1.5,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// TODAY'S PLAN CARD
// ═══════════════════════════════════════════════════════

class _DailyPlanCard extends StatelessWidget {
  final List<MapEntry<String, String>> plan;
  final Map<String, bool> goalDone;
  final int completed;
  final int total;
  final Function(String) onToggle;

  const _DailyPlanCard({
    required this.plan,
    required this.goalDone,
    required this.completed,
    required this.total,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPeach.withValues(alpha: 0.12),
            AppColors.secondaryLavender.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryPeach.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text('Today\'s Plan',
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: completed >= total
                      ? AppColors.tertiarySage.withValues(alpha: 0.2)
                      : AppColors.primaryPeach.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  completed >= total ? '🎉 All done!' : '$completed of $total complete 🎯',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: completed >= total ? AppColors.tertiarySage : AppColors.primaryPeach,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final entry in plan)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onToggle(entry.key),
                child: Row(
                  children: [
                    Icon(
                      (goalDone[entry.key] ?? false)
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: (goalDone[entry.key] ?? false)
                          ? AppColors.tertiarySage
                          : AppColors.textTertiaryDark,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: (goalDone[entry.key] ?? false)
                              ? AppColors.textTertiaryDark
                              : AppColors.textPrimaryDark,
                          decoration: (goalDone[entry.key] ?? false)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Text(
                      GoalService().getConfig(entry.key)?.emoji ?? '🎯',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// GOAL CARD
// ═══════════════════════════════════════════════════════

class _GoalCard extends StatelessWidget {
  final String goalName;
  final GoalConfig? config;
  final String todayAction;
  final bool isDone;
  final int streak;
  final double progress;
  final VoidCallback onToggle;
  final VoidCallback onExploreTechniques;

  const _GoalCard({
    required this.goalName,
    required this.config,
    required this.todayAction,
    required this.isDone,
    required this.streak,
    required this.progress,
    required this.onToggle,
    required this.onExploreTechniques,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = config?.emoji ?? '🎯';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone
              ? AppColors.tertiarySage.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goalName,
                        style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
                    if (streak > 0)
                      Text('🔥 $streak day streak',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primaryPeach)),
                  ],
                ),
              ),
              // Progress percentage
              Text('${(progress * 100).round()}%',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: progress > 0.5 ? AppColors.tertiarySage : AppColors.textTertiaryDark,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.backgroundDark,
              valueColor: AlwaysStoppedAnimation(
                progress > 0.7 ? AppColors.tertiarySage : AppColors.primaryPeach,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Today's action
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.tertiarySage.withValues(alpha: 0.1)
                    : AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDone
                      ? AppColors.tertiarySage.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                    color: isDone ? AppColors.tertiarySage : AppColors.textTertiaryDark,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Today\'s action',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiaryDark,
                              letterSpacing: 0.5,
                            )),
                        Text(
                          todayAction,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDone ? AppColors.textTertiaryDark : AppColors.textPrimaryDark,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDone) const Text('✅', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Explore techniques button
          GestureDetector(
            onTap: onExploreTechniques,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Explore Techniques',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.quaternarySky)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.quaternarySky),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// STREAK RISK BANNER
// ═══════════════════════════════════════════════════════

class _StreakRiskBanner extends StatelessWidget {
  final int streak;
  const _StreakRiskBanner({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEF4444)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$streak day streak at risk! Complete a task to keep it going 🔥',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.backgroundDark, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// IDENTITY CARD
// ═══════════════════════════════════════════════════════

class _IdentityCard extends StatelessWidget {
  final String summary;
  const _IdentityCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryLavender.withValues(alpha: 0.1),
            AppColors.primaryPeach.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryLavender.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Text('🪞', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Week',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.secondaryLavender,
                      letterSpacing: 1,
                    )),
                const SizedBox(height: 2),
                Text(summary,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      height: 1.4,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// DAILY CHECK-IN
// ═══════════════════════════════════════════════════════

class _DailyCheckIn extends StatefulWidget {
  @override
  State<_DailyCheckIn> createState() => _DailyCheckInState();
}

class _DailyCheckInState extends State<_DailyCheckIn> {
  Mood? _selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌅', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text('Daily Check-in',
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _selected != null
                ? 'Feeling ${_selected!.label.toLowerCase()} today'
                : 'How are you feeling today?',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: Mood.values.map((mood) {
              final active = _selected == mood;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _selected = mood);
                  MoodService().record(mood);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primaryPeach.withValues(alpha: 0.2)
                        : AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(14),
                    border: active ? Border.all(color: AppColors.primaryPeach, width: 2) : null,
                  ),
                  child: Center(
                    child: Text(mood.emoji, style: TextStyle(fontSize: active ? 26 : 24)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// QUICK START BUTTON
// ═══════════════════════════════════════════════════════

class _QuickStartButton extends StatelessWidget {
  final String topCoachId;
  final VoidCallback onChatOpened;

  const _QuickStartButton({required this.topCoachId, required this.onChatOpened});

  @override
  Widget build(BuildContext context) {
    final coach = defaultCoaches.firstWhere(
      (c) => c.id == topCoachId,
      orElse: () => defaultCoaches.first,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatScreen(coach: coach)),
        ).then((_) => onChatOpened());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPeach.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CoachPhoto(coach: coach, radius: 20, showBorder: false),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Start',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.backgroundDark,
                        fontWeight: FontWeight.bold,
                      )),
                  Text('Chat with ${coach.name} — your top coach',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.backgroundDark.withValues(alpha: 0.8),
                      )),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded,
                color: AppColors.backgroundDark, size: 22),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// CELEBRATION CARD
// ═══════════════════════════════════════════════════════

class _CelebrationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tertiarySage.withValues(alpha: 0.15),
            AppColors.primaryPeach.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tertiarySage.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('🎉🌟🏆', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text('All tasks complete!',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.tertiarySage)),
          const SizedBox(height: 4),
          Text('You crushed it today. Take a moment to celebrate! 🥳',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryDark,
                height: 1.4,
              ),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// BOOK SESSION CTA CARD
// ═══════════════════════════════════════════════════════

class _BookSessionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      accentColor: AppColors.primaryPeach,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPeach.withValues(alpha: 0.25),
                  AppColors.secondaryLavender.withValues(alpha: 0.15),
                ],
              ),
            ),
            child: const Center(child: Text('📹', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Face-to-Face Sessions',
                    style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Book a premium 1-on-1 coaching session',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryDark)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPeach.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.primaryPeach),
          ),
        ],
      ),
    );
  }
}

// ── COMEBACK CARD ──
class _ComebackCard extends StatelessWidget {
  final ComebackMessage message;
  const _ComebackCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryPeach.withValues(alpha: 0.15), AppColors.secondaryLavender.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryPeach.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message.title, style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
          const SizedBox(height: 8),
          Text(message.message, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark, height: 1.5)),
        ],
      ),
    );
  }
}

// ── WEEKLY CHALLENGE CARD ──
class _WeeklyChallengeCard extends StatelessWidget {
  final WeeklyChallenge challenge;
  final VoidCallback onComplete;
  const _WeeklyChallengeCard({required this.challenge, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Weekly Challenge', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryTeal)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${challenge.completedDays}/${challenge.daysRequired}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(challenge.title, style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
          const SizedBox(height: 6),
          Text(challenge.description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark)),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: challenge.progress,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color: AppColors.primaryTeal,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: challenge.isCompleted ? null : onComplete,
              icon: Icon(challenge.isCompleted ? Icons.check_circle : Icons.bolt, size: 18),
              label: Text(
                challenge.isCompleted ? 'Completed! +${challenge.xpReward} XP' : 'Mark Today Done',
                style: AppTextStyles.labelMedium.copyWith(
                  color: challenge.isCompleted ? AppColors.success : AppColors.primaryTeal,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: challenge.isCompleted ? AppColors.success.withValues(alpha: 0.3) : AppColors.primaryTeal.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── MODERN GLASS CARD ──
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? accentColor;
  final VoidCallback? onTap;

  const _GlassCard({
    required this.child,
    this.padding,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (accentColor ?? Colors.white).withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (accentColor ?? AppColors.primaryPeach).withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
