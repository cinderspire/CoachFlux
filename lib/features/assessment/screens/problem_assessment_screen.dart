import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/problem_engine.dart';
import '../../../core/services/recommendation_service.dart';
import '../../home/screens/home_screen.dart';
import '../../chat/screens/chat_screen.dart';
import 'solution_detail_screen.dart';

// ═══════════════════════════════════════════════════════════════
// PROBLEM ASSESSMENT SCREEN — 3-step assessment flow
// ═══════════════════════════════════════════════════════════════

class ProblemAssessmentScreen extends StatefulWidget {
  final bool isReassessment;
  const ProblemAssessmentScreen({super.key, this.isReassessment = false});

  @override
  State<ProblemAssessmentScreen> createState() => _ProblemAssessmentScreenState();
}

class _ProblemAssessmentScreenState extends State<ProblemAssessmentScreen>
    with TickerProviderStateMixin {
  int _step = 0; // 0=select problems, 1=depth questions, 2=plan
  final Set<ProblemCategory> _selectedProblems = {};

  // Depth question state
  int _currentProblemIndex = 0;
  int _currentQuestionIndex = 0;
  final Map<ProblemCategory, Map<String, String>> _answers = {};
  final Map<ProblemCategory, int> _impactScores = {};

  // Results
  PersonalizedPlan? _plan;
  List<ProblemAssessmentResult>? _results;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _animateTransition(VoidCallback action) {
    _fadeCtrl.reverse().then((_) {
      action();
      _fadeCtrl.forward();
    });
  }

  void _goToDepthQuestions() {
    if (_selectedProblems.isEmpty) return;
    _animateTransition(() {
      setState(() {
        _step = 1;
        _currentProblemIndex = 0;
        _currentQuestionIndex = 0;
        for (final p in _selectedProblems) {
          _answers[p] = {};
          _impactScores[p] = 5;
        }
      });
    });
  }

  void _answerQuestion(String answer) {
    final problems = _selectedProblems.toList();
    final problem = problems[_currentProblemIndex];
    final def = ProblemEngine.getDefinition(problem);
    final question = def.questions[_currentQuestionIndex];

    _answers[problem]![question.text] = answer;

    _animateTransition(() {
      setState(() {
        if (_currentQuestionIndex < def.questions.length - 1) {
          _currentQuestionIndex++;
        } else {
          // Move to impact score for this problem
          if (_currentProblemIndex < problems.length - 1) {
            _currentProblemIndex++;
            _currentQuestionIndex = 0;
          } else {
            _buildResults();
          }
        }
      });
    });
  }

  void _buildResults() {
    final results = <ProblemAssessmentResult>[];
    for (final category in _selectedProblems) {
      final answers = _answers[category] ?? {};
      final impact = _impactScores[category] ?? 5;
      results.add(ProblemAssessmentResult(
        category: category,
        answers: answers,
        impactScore: impact,
        severity: ProblemEngine.calculateSeverity(answers, impact),
      ));
    }
    // Sort by severity
    results.sort((a, b) => b.severity.index.compareTo(a.severity.index));

    RecommendationService.saveAssessment(results);

    _results = results;
    _plan = RecommendationService.generatePlan(results);
    setState(() => _step = 2);
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: switch (_step) {
            0 => _buildStep1(),
            1 => _buildStep2(),
            2 => _buildStep3(),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }

  // ═════════════════════════════════════════
  // STEP 1: Select Problems
  // ═════════════════════════════════════════

  Widget _buildStep1() {
    return Column(
      children: [
        _buildHeader(
          title: 'What brings you here today?',
          subtitle: 'Select everything that resonates. No judgment.',
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: allProblems.length,
            itemBuilder: (context, i) {
              final problem = allProblems[i];
              final selected = _selectedProblems.contains(problem.category);
              return _ProblemCard(
                problem: problem,
                selected: selected,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    if (selected) {
                      _selectedProblems.remove(problem.category);
                    } else {
                      _selectedProblems.add(problem.category);
                    }
                  });
                },
              );
            },
          ),
        ),
        _buildBottomButton(
          label: 'Continue (${_selectedProblems.length} selected)',
          enabled: _selectedProblems.isNotEmpty,
          onTap: _goToDepthQuestions,
        ),
      ],
    );
  }

  // ═════════════════════════════════════════
  // STEP 2: Depth Questions
  // ═════════════════════════════════════════

  Widget _buildStep2() {
    final problems = _selectedProblems.toList();
    final problem = problems[_currentProblemIndex];
    final def = ProblemEngine.getDefinition(problem);
    final question = def.questions[_currentQuestionIndex];

    final totalQuestions = _selectedProblems.fold<int>(
      0,
      (sum, p) => sum + ProblemEngine.getDefinition(p).questions.length,
    );
    final answeredSoFar = _selectedProblems.toList().sublist(0, _currentProblemIndex).fold<int>(
      0,
      (sum, p) => sum + ProblemEngine.getDefinition(p).questions.length,
    ) + _currentQuestionIndex;

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${def.emoji} ${def.title}',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: def.accentColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${answeredSoFar + 1}/$totalQuestions',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalQuestions > 0 ? (answeredSoFar + 1) / totalQuestions : 0,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(def.accentColor),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Question
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            question.text,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimaryDark,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Options
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: question.options.length,
            itemBuilder: (context, i) {
              final option = question.options[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OptionCard(
                  text: option,
                  accentColor: def.accentColor,
                  onTap: () => _answerQuestion(option),
                ),
              );
            },
          ),
        ),
        // Impact slider (show after last question of each problem)
        if (_currentQuestionIndex == def.questions.length - 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How much does ${def.title.toLowerCase()} impact your daily life?',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('1', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: def.accentColor,
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                          thumbColor: def.accentColor,
                          overlayColor: def.accentColor.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: (_impactScores[problem] ?? 5).toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          onChanged: (v) =>
                              setState(() => _impactScores[problem] = v.round()),
                        ),
                      ),
                    ),
                    Text('10', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
                  ],
                ),
                Center(
                  child: Text(
                    '${_impactScores[problem] ?? 5}/10',
                    style: AppTextStyles.titleSmall.copyWith(color: def.accentColor),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ═════════════════════════════════════════
  // STEP 3: Your Personalized Plan
  // ═════════════════════════════════════════

  Widget _buildStep3() {
    final plan = _plan!;
    final results = _results!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Header
        Center(
          child: Text('✨', style: const TextStyle(fontSize: 48)),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Your Personalized Plan',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            plan.summary,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),

        // Problem summaries with severity
        for (final result in results) ...[
          _buildProblemSummaryCard(result),
          const SizedBox(height: 12),
        ],

        const SizedBox(height: 16),
        _buildSectionTitle('🧠 Your Coach Team'),
        const SizedBox(height: 8),
        for (final rec in plan.coaches) ...[
          _buildCoachCard(rec),
          const SizedBox(height: 8),
        ],

        const SizedBox(height: 16),
        _buildSectionTitle('🛠️ Recommended Techniques'),
        const SizedBox(height: 8),
        for (final tech in plan.techniques) ...[
          _buildTechniqueCard(tech),
          const SizedBox(height: 8),
        ],

        const SizedBox(height: 16),
        _buildSectionTitle('📅 Daily Micro-Actions'),
        const SizedBox(height: 8),
        for (final action in plan.dailyActions) ...[
          _buildActionCard(action),
          const SizedBox(height: 6),
        ],

        const SizedBox(height: 16),
        // Timeline
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              const Text('⏱️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  plan.timeline,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Start Journey button
        _buildStartButton(),
        const SizedBox(height: 40),
      ],
    );
  }

  // ═════════════════════════════════════════
  // SHARED WIDGETS
  // ═════════════════════════════════════════

  Widget _buildHeader({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isReassessment)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: AppColors.textTertiaryDark),
                    const SizedBox(width: 4),
                    Text('Back',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textTertiaryDark)),
                  ],
                ),
              ),
            ),
          Text(title,
              style: AppTextStyles.titleLarge
                  .copyWith(color: AppColors.textPrimaryDark)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textTertiaryDark)),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)])
                : null,
            color: enabled ? null : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: enabled ? Colors.white : AppColors.textTertiaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: AppTextStyles.titleSmall.copyWith(
        color: AppColors.textPrimaryDark,
      ),
    );
  }

  Widget _buildProblemSummaryCard(ProblemAssessmentResult result) {
    final def = ProblemEngine.getDefinition(result.category);
    final severityColor = ProblemEngine.severityColor(result.severity);
    final severityLabel = ProblemEngine.severityLabel(result.severity);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: def.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: def.accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(def.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(def.title,
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.textPrimaryDark)),
                const SizedBox(height: 2),
                Text('Impact: ${result.impactScore}/10',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textTertiaryDark)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              severityLabel,
              style: AppTextStyles.caption.copyWith(
                color: severityColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachCard(RecommendationResult rec) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(coach: rec.coach),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: rec.coach.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: rec.coach.color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Text(rec.coach.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(rec.coach.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleSmall
                                .copyWith(color: AppColors.textPrimaryDark)),
                      ),
                      if (rec.role == 'primary') ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: rec.coach.color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('PRIMARY',
                              style: AppTextStyles.caption.copyWith(
                                  color: rec.coach.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(rec.reason,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textTertiaryDark)),
                ],
              ),
            ),
            Icon(Icons.chat_bubble_outline_rounded,
                size: 18, color: rec.coach.color),
          ],
        ),
      ),
    );
  }

  Widget _buildTechniqueCard(TechniqueCombo tech) {
    return GestureDetector(
      onTap: () {
        if (_results != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SolutionDetailScreen(
                techniqueName: tech.name,
                reason: tech.reason,
                results: _results!,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded,
                size: 18, color: Color(0xFFA78BFA)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tech.name,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimaryDark)),
                  Text(tech.reason,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textTertiaryDark)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textTertiaryDark),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(MicroAction action) {
    final timeEmoji = switch (action.time) {
      'morning' => '🌅',
      'afternoon' => '☀️',
      'evening' => '🌙',
      _ => '📌',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(timeEmoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(action.action,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondaryDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _finish,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Start Your Journey 🚀',
            style: AppTextStyles.button.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// PROBLEM CARD WIDGET
// ═══════════════════════════════════════════════════════

class _ProblemCard extends StatelessWidget {
  final ProblemDefinition problem;
  final bool selected;
  final VoidCallback onTap;

  const _ProblemCard({
    required this.problem,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected
              ? problem.accentColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? problem.accentColor.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
            width: selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(problem.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              problem.title,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected
                    ? problem.accentColor
                    : AppColors.textPrimaryDark,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              problem.subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiaryDark,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.check_circle_rounded,
                    size: 18, color: problem.accentColor),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// OPTION CARD WIDGET
// ═══════════════════════════════════════════════════════

class _OptionCard extends StatelessWidget {
  final String text;
  final Color accentColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.text,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
      ),
    );
  }
}
