import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OptimizationDashboardScreen extends StatefulWidget {
  const OptimizationDashboardScreen({super.key});

  @override
  State<OptimizationDashboardScreen> createState() =>
      _OptimizationDashboardScreenState();
}

class _OptimizationDashboardScreenState
    extends State<OptimizationDashboardScreen>
    with SingleTickerProviderStateMixin {
  // Data
  int _growthScore = 0;
  List<double> _moodData = [];
  List<_CoachChemistry> _coaches = [];
  _WeekComparison _weekComparison = _WeekComparison.empty();
  List<_NextStep> _nextSteps = [];
  List<_Milestone> _milestones = [];

  late AnimationController _animController;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scoreAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final score = prefs.getInt('optimization_growth_score') ?? 72;

    // Mood data: 14 days
    final moodRaw = prefs.getStringList('optimization_mood_14d');
    final moods = moodRaw?.map((e) => double.tryParse(e) ?? 5.0).toList() ??
        [4, 5, 6, 5, 7, 6, 8, 7, 6, 8, 7, 9, 8, 8]
            .map((e) => e.toDouble())
            .toList();

    final coaches = [
      _CoachChemistry('🧘', 'FlowState', prefs.getInt('coach_rapport_flowstate') ?? 87),
      _CoachChemistry('🌙', 'Dr. Aura', prefs.getInt('coach_rapport_aura') ?? 74),
      _CoachChemistry('🔥', 'Blaze', prefs.getInt('coach_rapport_blaze') ?? 62),
    ];

    final week = _WeekComparison(
      sessionsThis: prefs.getInt('week_sessions_this') ?? 5,
      sessionsLast: prefs.getInt('week_sessions_last') ?? 3,
      moodThis: prefs.getDouble('week_mood_this') ?? 7.8,
      moodLast: prefs.getDouble('week_mood_last') ?? 6.5,
      streakThis: prefs.getInt('week_streak_this') ?? 6,
      streakLast: prefs.getInt('week_streak_last') ?? 4,
    );

    final steps = [
      _NextStep(Icons.self_improvement_rounded, 'Try a 10-min meditation', 'Boost your mindfulness streak'),
      _NextStep(Icons.edit_note_rounded, 'Journal your wins', 'Reflect on 3 things that went well'),
      _NextStep(Icons.chat_bubble_outline_rounded, 'Chat with Dr. Aura', 'Explore emotional patterns'),
    ];

    final milestones = [
      _Milestone('First Session', 'Started your journey', true),
      _Milestone('7-Day Streak', 'Consistency unlocked', true),
      _Milestone('50 Sessions', 'Halfway to mastery', true),
      _Milestone('Growth Score 80+', 'Almost there...', false),
      _Milestone('100 Sessions', 'Elite tier', false),
    ];

    if (!mounted) return;
    setState(() {
      _growthScore = score;
      _moodData = moods;
      _coaches = coaches;
      _weekComparison = week;
      _nextSteps = steps;
      _milestones = milestones;
    });
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          color: AppColors.textSecondaryDark, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You, Optimized',
                        style: AppTextStyles.headlineMedium
                            .copyWith(color: AppColors.textPrimaryDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _buildGrowthScore(),
                  const SizedBox(height: 20),
                  _buildMoodEvolution(),
                  const SizedBox(height: 20),
                  _buildCoachChemistry(),
                  const SizedBox(height: 20),
                  _buildWeekComparison(),
                  const SizedBox(height: 20),
                  _buildNextSteps(),
                  const SizedBox(height: 20),
                  _buildGrowthTimeline(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section builders ──────────────────────────────────────────────────────

  Widget _buildGrowthScore() {
    return _Card(
      child: Column(
        children: [
          Text('GROWTH SCORE',
              style: AppTextStyles.overline
                  .copyWith(color: AppColors.textTertiaryDark)),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _scoreAnim,
            builder: (context, _) {
              return SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: _GrowthRingPainter(
                    progress: _scoreAnim.value * _growthScore / 100,
                    gradientColors: const [
                      AppColors.primaryPeach,
                      AppColors.secondaryLavender,
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${(_scoreAnim.value * _growthScore).round()}',
                      style: AppTextStyles.displayMedium
                          .copyWith(color: AppColors.textPrimaryDark),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text('Keep going — you\'re in the top 15%',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }

  Widget _buildMoodEvolution() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MOOD EVOLUTION',
              style: AppTextStyles.overline
                  .copyWith(color: AppColors.textTertiaryDark)),
          const SizedBox(height: 4),
          Text('Last 14 days',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textTertiaryDark)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _MoodChartPainter(
                data: _moodData,
                lineColor: AppColors.primaryPeach,
                fillColor: AppColors.primaryPeach,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachChemistry() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COACH CHEMISTRY',
              style: AppTextStyles.overline
                  .copyWith(color: AppColors.textTertiaryDark)),
          const SizedBox(height: 16),
          ..._coaches.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Text(c.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: AppTextStyles.titleSmall
                                  .copyWith(color: AppColors.textPrimaryDark)),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: c.rapport / 100,
                              minHeight: 6,
                              backgroundColor:
                                  AppColors.textTertiaryDark.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.secondaryLavender),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${c.rapport}%',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.secondaryLavender)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildWeekComparison() {
    final w = _weekComparison;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THIS WEEK VS LAST WEEK',
              style: AppTextStyles.overline
                  .copyWith(color: AppColors.textTertiaryDark)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _comparisonCol(
                      'Sessions', w.sessionsThis, w.sessionsLast)),
              Expanded(
                  child: _comparisonCol(
                      'Mood', w.moodThis, w.moodLast,
                      isDouble: true)),
              Expanded(
                  child: _comparisonCol(
                      'Streak', w.streakThis, w.streakLast)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _comparisonCol(String label, num current, num previous,
      {bool isDouble = false}) {
    final diff = current - previous;
    final isUp = diff >= 0;
    final arrow = isUp ? '↑' : '↓';
    final color = isUp ? AppColors.success : AppColors.error;
    final display =
        isDouble ? current.toStringAsFixed(1) : current.toString();

    return Column(
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textTertiaryDark)),
        const SizedBox(height: 8),
        Text(display,
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.textPrimaryDark)),
        const SizedBox(height: 4),
        Text('$arrow ${diff.abs().toStringAsFixed(isDouble ? 1 : 0)}',
            style: AppTextStyles.labelSmall.copyWith(color: color)),
      ],
    );
  }

  Widget _buildNextSteps() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECOMMENDED NEXT STEPS',
              style: AppTextStyles.overline
                  .copyWith(color: AppColors.textTertiaryDark)),
          const SizedBox(height: 16),
          ..._nextSteps.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(s.icon,
                                color: AppColors.backgroundDark, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.title,
                                    style: AppTextStyles.titleSmall.copyWith(
                                        color: AppColors.textPrimaryDark)),
                                const SizedBox(height: 2),
                                Text(s.subtitle,
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textTertiaryDark)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textTertiaryDark, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGrowthTimeline() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GROWTH TIMELINE',
              style: AppTextStyles.overline
                  .copyWith(color: AppColors.textTertiaryDark)),
          const SizedBox(height: 16),
          ..._milestones.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            final isLast = i == _milestones.length - 1;
            final dotColor =
                m.achieved ? AppColors.primaryPeach : AppColors.textTertiaryDark;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: AppColors.textTertiaryDark
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.title,
                              style: AppTextStyles.titleSmall.copyWith(
                                  color: m.achieved
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textTertiaryDark)),
                          const SizedBox(height: 2),
                          Text(m.subtitle,
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiaryDark)),
                        ],
                      ),
                    ),
                  ),
                  if (m.achieved)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 18),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Card wrapper ──────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _CoachChemistry {
  final String emoji;
  final String name;
  final int rapport;
  _CoachChemistry(this.emoji, this.name, this.rapport);
}

class _WeekComparison {
  final int sessionsThis, sessionsLast;
  final double moodThis, moodLast;
  final int streakThis, streakLast;
  _WeekComparison({
    required this.sessionsThis,
    required this.sessionsLast,
    required this.moodThis,
    required this.moodLast,
    required this.streakThis,
    required this.streakLast,
  });
  factory _WeekComparison.empty() => _WeekComparison(
        sessionsThis: 0, sessionsLast: 0,
        moodThis: 0, moodLast: 0,
        streakThis: 0, streakLast: 0,
      );
}

class _NextStep {
  final IconData icon;
  final String title;
  final String subtitle;
  _NextStep(this.icon, this.title, this.subtitle);
}

class _Milestone {
  final String title;
  final String subtitle;
  final bool achieved;
  _Milestone(this.title, this.subtitle, this.achieved);
}

// ── Custom Painters ───────────────────────────────────────────────────────────

class _GrowthRingPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final List<Color> gradientColors;

  _GrowthRingPainter({required this.progress, required this.gradientColors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 10.0;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.textTertiaryDark.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Gradient ring
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradientPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: 3 * pi / 2,
          colors: gradientColors,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        gradientPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthRingPainter old) =>
      old.progress != progress;
}

class _MoodChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;

  _MoodChartPainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minVal = data.reduce(min) - 1;
    final maxVal = data.reduce(max) + 1;
    final range = maxVal - minVal;

    double xOf(int i) => (i / (data.length - 1)) * size.width;
    double yOf(double v) => size.height - ((v - minVal) / range) * size.height;

    // Build path
    final path = Path()..moveTo(xOf(0), yOf(data[0]));
    for (var i = 1; i < data.length; i++) {
      final prevX = xOf(i - 1);
      final currX = xOf(i);
      final midX = (prevX + currX) / 2;
      path.cubicTo(midX, yOf(data[i - 1]), midX, yOf(data[i]), currX, yOf(data[i]));
    }

    // Line
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor.withValues(alpha: 0.3), fillColor.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _MoodChartPainter old) => old.data != data;
}
