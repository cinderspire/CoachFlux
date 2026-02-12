import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

// ═══════════════════════════════════════════════════════
// TECHNIQUE MODEL
// ═══════════════════════════════════════════════════════

class Technique {
  final String name;
  final String emoji;
  final String description;
  final String duration;
  final String difficulty;
  final String evidence;
  final String category;
  final Widget Function(BuildContext) builder;

  const Technique({
    required this.name,
    required this.emoji,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.evidence,
    required this.category,
    required this.builder,
  });
}

// ═══════════════════════════════════════════════════════
// ALL TECHNIQUES
// ═══════════════════════════════════════════════════════

final List<Technique> allTechniques = [
  // FOCUS & PRODUCTIVITY
  Technique(
    name: 'Pomodoro Technique',
    emoji: '🍅',
    description: '25 minutes of focused work followed by a 5-minute break. Repeat 4 times, then take a longer break.',
    duration: '25 min',
    difficulty: 'Easy',
    evidence: 'Cirillo (2006). Improves focus and reduces mental fatigue through structured intervals.',
    category: 'Focus & Productivity',
    builder: (ctx) => const _PomodoroTimer(),
  ),
  Technique(
    name: 'Time Blocking',
    emoji: '📅',
    description: 'Schedule specific tasks into dedicated time blocks. Assign every hour a purpose.',
    duration: '5 min setup',
    difficulty: 'Easy',
    evidence: 'Cal Newport\'s Deep Work (2016). Reduces decision fatigue and context switching.',
    category: 'Focus & Productivity',
    builder: (ctx) => const _TimeBlockPlanner(),
  ),
  Technique(
    name: '2-Minute Rule',
    emoji: '⚡',
    description: 'If a task takes less than 2 minutes, do it immediately. Don\'t add it to a list.',
    duration: '2 min',
    difficulty: 'Easy',
    evidence: 'David Allen, Getting Things Done (2001). Prevents task buildup and mental clutter.',
    category: 'Focus & Productivity',
    builder: (ctx) => const _TwoMinuteRule(),
  ),
  Technique(
    name: 'Deep Work Protocol',
    emoji: '🧠',
    description: 'Eliminate all distractions. Set a clear goal. Work with full intensity for 60-90 minutes.',
    duration: '60-90 min',
    difficulty: 'Hard',
    evidence: 'Cal Newport (2016). Deep work produces 2-5x more valuable output than shallow work.',
    category: 'Focus & Productivity',
    builder: (ctx) => const _DeepWorkProtocol(),
  ),
  // MINDFULNESS & CALM
  Technique(
    name: 'Box Breathing',
    emoji: '🫁',
    description: 'Breathe in 4 seconds, hold 4, exhale 4, hold 4. Repeat 4 times.',
    duration: '4 min',
    difficulty: 'Easy',
    evidence: 'Used by Navy SEALs. Activates parasympathetic nervous system, reduces cortisol.',
    category: 'Mindfulness & Calm',
    builder: (ctx) => const _BoxBreathing(),
  ),
  Technique(
    name: 'Body Scan Meditation',
    emoji: '🧘',
    description: 'Systematically focus attention on each body part, releasing tension.',
    duration: '10 min',
    difficulty: 'Medium',
    evidence: 'Kabat-Zinn (1990). MBSR program. Reduces anxiety and improves body awareness.',
    category: 'Mindfulness & Calm',
    builder: (ctx) => const _BodyScan(),
  ),
  Technique(
    name: '5-4-3-2-1 Grounding',
    emoji: '🌍',
    description: 'Name 5 things you see, 4 you touch, 3 you hear, 2 you smell, 1 you taste.',
    duration: '3 min',
    difficulty: 'Easy',
    evidence: 'CBT grounding technique. Effective for anxiety and panic attacks.',
    category: 'Mindfulness & Calm',
    builder: (ctx) => const _Grounding54321(),
  ),
  Technique(
    name: 'Progressive Muscle Relaxation',
    emoji: '💆',
    description: 'Tense each muscle group for 5 seconds, then release. Work from toes to head.',
    duration: '15 min',
    difficulty: 'Easy',
    evidence: 'Jacobson (1938). Reduces physical tension and anxiety. APA recommended.',
    category: 'Mindfulness & Calm',
    builder: (ctx) => const _PMR(),
  ),
  // FITNESS & ENERGY
  Technique(
    name: '7-Minute Workout',
    emoji: '🏋️',
    description: '12 high-intensity exercises, 30 seconds each, 10 seconds rest between.',
    duration: '7 min',
    difficulty: 'Medium',
    evidence: 'ACSM Journal (2013). Comparable benefits to prolonged endurance training.',
    category: 'Fitness & Energy',
    builder: (ctx) => const _SevenMinWorkout(),
  ),
  Technique(
    name: 'Walking Meditation',
    emoji: '🚶',
    description: 'Walk slowly and deliberately, focusing on each step and your breathing.',
    duration: '10 min',
    difficulty: 'Easy',
    evidence: 'Thich Nhat Hanh tradition. Combines physical activity with mindfulness benefits.',
    category: 'Fitness & Energy',
    builder: (ctx) => const _WalkingMeditation(),
  ),
  Technique(
    name: 'Desk Stretches',
    emoji: '🪑',
    description: '5 stretches you can do at your desk to relieve tension and boost energy.',
    duration: '5 min',
    difficulty: 'Easy',
    evidence: 'OSHA ergonomic guidelines. Reduces RSI risk and improves circulation.',
    category: 'Fitness & Energy',
    builder: (ctx) => const _DeskStretches(),
  ),
  Technique(
    name: 'Energy Audit',
    emoji: '⚡',
    description: 'Rate your energy hourly to find your peak performance windows.',
    duration: '1 min/hr',
    difficulty: 'Easy',
    evidence: 'Daniel Pink, When (2018). Chronotype awareness improves productivity 20-30%.',
    category: 'Fitness & Energy',
    builder: (ctx) => const _EnergyAudit(),
  ),
  // CAREER GROWTH
  Technique(
    name: 'SMART Goal Framework',
    emoji: '🎯',
    description: 'Set goals that are Specific, Measurable, Achievable, Relevant, and Time-bound.',
    duration: '10 min',
    difficulty: 'Medium',
    evidence: 'Doran (1981). SMART goals are 33% more likely to be achieved than vague goals.',
    category: 'Career Growth',
    builder: (ctx) => const _SmartGoalForm(),
  ),
  Technique(
    name: 'Weekly Review',
    emoji: '📋',
    description: 'Review your week: wins, lessons, next week\'s priorities.',
    duration: '15 min',
    difficulty: 'Easy',
    evidence: 'David Allen GTD. Regular reviews keep projects on track and reduce anxiety.',
    category: 'Career Growth',
    builder: (ctx) => const _WeeklyReview(),
  ),
  Technique(
    name: 'Skill Gap Analysis',
    emoji: '📊',
    description: 'Identify skills needed vs. skills you have. Create a learning plan.',
    duration: '20 min',
    difficulty: 'Medium',
    evidence: 'HR development best practice. Focuses learning effort for maximum career impact.',
    category: 'Career Growth',
    builder: (ctx) => const _SkillGapAnalysis(),
  ),
  Technique(
    name: 'Networking Challenge',
    emoji: '🤝',
    description: 'Reach out to 1 new person per week. Build genuine professional relationships.',
    duration: '10 min/week',
    difficulty: 'Medium',
    evidence: 'Granovetter (1973). Weak ties are the #1 source of job opportunities.',
    category: 'Career Growth',
    builder: (ctx) => const _NetworkingChallenge(),
  ),
  // FINANCIAL
  Technique(
    name: '50/30/20 Budget',
    emoji: '💵',
    description: '50% needs, 30% wants, 20% savings. Calculate your split.',
    duration: '5 min',
    difficulty: 'Easy',
    evidence: 'Elizabeth Warren, All Your Worth (2005). Simple framework for financial health.',
    category: 'Financial Freedom',
    builder: (ctx) => const _BudgetCalculator(),
  ),
  Technique(
    name: 'No-Spend Challenge',
    emoji: '🚫',
    description: 'Track consecutive no-spend days. Build awareness of spending habits.',
    duration: 'All day',
    difficulty: 'Medium',
    evidence: 'Behavioral economics. Awareness of spending reduces impulse purchases 30-40%.',
    category: 'Financial Freedom',
    builder: (ctx) => const _NoSpendTracker(),
  ),
  Technique(
    name: 'Savings Goal Visualizer',
    emoji: '🏦',
    description: 'Set a savings target and track your progress visually.',
    duration: '2 min',
    difficulty: 'Easy',
    evidence: 'Goal visualization increases savings rate by 73% (Soman & Zhao, 2011).',
    category: 'Financial Freedom',
    builder: (ctx) => const _SavingsVisualizer(),
  ),
];

// ═══════════════════════════════════════════════════════
// TECHNIQUES SCREEN
// ═══════════════════════════════════════════════════════

class TechniquesScreen extends StatefulWidget {
  final String? initialCategory;
  const TechniquesScreen({super.key, this.initialCategory});

  @override
  State<TechniquesScreen> createState() => _TechniquesScreenState();
}

class _TechniquesScreenState extends State<TechniquesScreen> {
  String? _selectedCategory;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final _categories = [
    'Focus & Productivity',
    'Mindfulness & Calm',
    'Fitness & Energy',
    'Career Growth',
    'Financial Freedom',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Technique> get _filteredTechniques {
    var list = _selectedCategory == null
        ? allTechniques
        : allTechniques.where((t) => t.category == _selectedCategory).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) =>
          t.name.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTechniques;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Techniques Library',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark),
              decoration: InputDecoration(
                hintText: 'Search techniques...',
                hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiaryDark, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () => setState(() { _searchController.clear(); _searchQuery = ''; }),
                        child: Icon(Icons.close_rounded, color: AppColors.textTertiaryDark, size: 18),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundDarkElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Category chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip('All', _selectedCategory == null, () => setState(() => _selectedCategory = null)),
                for (final cat in _categories)
                  _chip(cat, _selectedCategory == cat, () => setState(() => _selectedCategory = cat)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryPeach,
              backgroundColor: AppColors.backgroundDarkElevated,
              onRefresh: () async {
                setState(() {}); // Re-render the list
              },
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          Text('No techniques found',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiaryDark)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) => _TechniqueCard(technique: filtered[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Chip(
          label: Text(label,
              style: AppTextStyles.labelSmall.copyWith(
                color: selected ? AppColors.backgroundDark : AppColors.textSecondaryDark,
              )),
          backgroundColor: selected ? AppColors.primaryPeach : AppColors.backgroundDarkElevated,
          side: BorderSide(color: selected ? AppColors.primaryPeach : Colors.white.withValues(alpha: 0.1)),
        ),
      ),
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  final Technique technique;
  const _TechniqueCard({required this.technique});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _TechniqueDetail(technique: technique)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Text(technique.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(technique.name,
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
                  const SizedBox(height: 2),
                  Text(technique.description,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _tag(technique.duration, AppColors.quaternarySky),
                      const SizedBox(width: 6),
                      _tag(technique.difficulty, technique.difficulty == 'Easy'
                          ? AppColors.tertiarySage
                          : technique.difficulty == 'Medium'
                              ? AppColors.primaryPeach
                              : AppColors.error),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiaryDark, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class _TechniqueDetail extends StatelessWidget {
  final Technique technique;
  const _TechniqueDetail({required this.technique});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(technique.name,
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(technique.emoji, style: const TextStyle(fontSize: 64))),
            const SizedBox(height: 16),
            Text(technique.description,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimaryDark, height: 1.6)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.quaternarySky.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('📚', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(technique.evidence,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark, height: 1.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Interactive widget
            technique.builder(context),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// INTERACTIVE WIDGETS
// ═══════════════════════════════════════════════════════

// ── BOX BREATHING with animated circle ──
class _BoxBreathing extends StatefulWidget {
  const _BoxBreathing();
  @override
  State<_BoxBreathing> createState() => _BoxBreathingState();
}

class _BoxBreathingState extends State<_BoxBreathing> with TickerProviderStateMixin {
  bool _running = false;
  int _phase = 0; // 0=inhale, 1=hold, 2=exhale, 3=hold
  int _round = 0;
  int _seconds = 4;
  Timer? _timer;
  late AnimationController _breathCtrl;

  final _phases = ['Breathe In', 'Hold', 'Breathe Out', 'Hold'];
  final _colors = [AppColors.quaternarySky, AppColors.secondaryLavender, AppColors.tertiarySage, AppColors.primaryPeach];

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  }

  void _start() {
    setState(() { _running = true; _phase = 0; _round = 0; _seconds = 4; });
    _breathCtrl.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _seconds--;
        if (_seconds <= 0) {
          _phase++;
          if (_phase > 3) {
            _phase = 0;
            _round++;
            if (_round >= 4) {
              _stop();
              return;
            }
          }
          _seconds = 4;
          if (_phase == 0) {
            _breathCtrl.forward(from: 0);
          } else if (_phase == 2) {
            _breathCtrl.reverse(from: 1);
          }
        }
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    _breathCtrl.stop();
    setState(() => _running = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _breathCtrl,
          builder: (ctx, child) {
            final size = 120.0 + (_breathCtrl.value * 80.0);
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_running ? _colors[_phase] : AppColors.quaternarySky).withValues(alpha: 0.3),
                border: Border.all(
                  color: _running ? _colors[_phase] : AppColors.quaternarySky,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  _running ? '$_seconds' : '🫁',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: _running ? _colors[_phase] : AppColors.textPrimaryDark,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        if (_running) ...[
          Text(_phases[_phase],
              style: AppTextStyles.titleMedium.copyWith(color: _colors[_phase])),
          const SizedBox(height: 4),
          Text('Round ${_round + 1} of 4',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _running ? _stop : _start,
          style: ElevatedButton.styleFrom(
            backgroundColor: _running ? AppColors.error : AppColors.primaryPeach,
            foregroundColor: AppColors.backgroundDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: Text(_running ? 'Stop' : 'Start Breathing Exercise'),
        ),
      ],
    );
  }
}

// ── POMODORO TIMER ──
class _PomodoroTimer extends StatefulWidget {
  const _PomodoroTimer();
  @override
  State<_PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<_PomodoroTimer> {
  bool _running = false;
  bool _isBreak = false;
  int _secondsLeft = 25 * 60;
  int _pomodorosCompleted = 0;
  Timer? _timer;

  void _start() {
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          HapticFeedback.heavyImpact();
          if (_isBreak) {
            _isBreak = false;
            _secondsLeft = 25 * 60;
          } else {
            _pomodorosCompleted++;
            _isBreak = true;
            _secondsLeft = _pomodorosCompleted % 4 == 0 ? 15 * 60 : 5 * 60;
          }
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _isBreak = false;
      _secondsLeft = 25 * 60;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final progress = _isBreak
        ? 1 - (_secondsLeft / (_pomodorosCompleted % 4 == 0 ? 15 * 60 : 5 * 60))
        : 1 - (_secondsLeft / (25 * 60));

    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppColors.backgroundDarkElevated,
                  valueColor: AlwaysStoppedAnimation(
                    _isBreak ? AppColors.tertiarySage : AppColors.primaryPeach,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_format(_secondsLeft),
                      style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimaryDark)),
                  Text(_isBreak ? 'Break Time' : 'Focus Time',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('🍅 × $_pomodorosCompleted',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryPeach)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _running ? _pause : _start,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPeach,
                foregroundColor: AppColors.backgroundDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              child: Text(_running ? 'Pause' : 'Start'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}

// ── 50/30/20 BUDGET CALCULATOR ──
class _BudgetCalculator extends StatefulWidget {
  const _BudgetCalculator();
  @override
  State<_BudgetCalculator> createState() => _BudgetCalculatorState();
}

class _BudgetCalculatorState extends State<_BudgetCalculator> {
  final _incomeCtrl = TextEditingController();
  double? _income;

  @override
  void dispose() {
    _incomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter your monthly income:',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark)),
        const SizedBox(height: 8),
        TextField(
          controller: _incomeCtrl,
          keyboardType: TextInputType.number,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark),
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryPeach),
            filled: true,
            fillColor: AppColors.backgroundDarkElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (v) => setState(() => _income = double.tryParse(v)),
        ),
        if (_income != null && _income! > 0) ...[
          const SizedBox(height: 20),
          _budgetRow('Needs (50%)', _income! * 0.5, AppColors.primaryPeach, '🏠 Rent, food, bills'),
          const SizedBox(height: 10),
          _budgetRow('Wants (30%)', _income! * 0.3, AppColors.secondaryLavender, '🎉 Fun, dining, hobbies'),
          const SizedBox(height: 10),
          _budgetRow('Savings (20%)', _income! * 0.2, AppColors.tertiarySage, '💰 Emergency fund, investments'),
        ],
      ],
    );
  }

  Widget _budgetRow(String label, double amount, Color color, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.titleSmall.copyWith(color: color)),
                Text(desc, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
              ],
            ),
          ),
          Text('\$${amount.toStringAsFixed(0)}',
              style: AppTextStyles.titleLarge.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── 5-4-3-2-1 GROUNDING ──
class _Grounding54321 extends StatefulWidget {
  const _Grounding54321();
  @override
  State<_Grounding54321> createState() => _Grounding54321State();
}

class _Grounding54321State extends State<_Grounding54321> {
  int _step = 0;
  final _steps = [
    ('👀', '5 things you can SEE', 5),
    ('✋', '4 things you can TOUCH', 4),
    ('👂', '3 things you can HEAR', 3),
    ('👃', '2 things you can SMELL', 2),
    ('👅', '1 thing you can TASTE', 1),
  ];
  final _checked = <int, Set<int>>{};

  @override
  Widget build(BuildContext context) {
    if (_step >= 5) {
      return Center(
        child: Column(
          children: [
            const Text('✅', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text('You\'re grounded!',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.tertiarySage)),
            Text('Notice how you feel now.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() { _step = 0; _checked.clear(); }),
              child: const Text('Start Over'),
            ),
          ],
        ),
      );
    }

    final (emoji, prompt, count) = _steps[_step];
    _checked.putIfAbsent(_step, () => {});

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(prompt, style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
        const SizedBox(height: 16),
        for (int i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() {
                HapticFeedback.lightImpact();
                _checked[_step]!.contains(i) ? _checked[_step]!.remove(i) : _checked[_step]!.add(i);
              }),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _checked[_step]!.contains(i)
                      ? AppColors.tertiarySage.withValues(alpha: 0.15)
                      : AppColors.backgroundDarkElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _checked[_step]!.contains(i)
                        ? AppColors.tertiarySage
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _checked[_step]!.contains(i)
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: _checked[_step]!.contains(i)
                          ? AppColors.tertiarySage
                          : AppColors.textTertiaryDark,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text('Item ${i + 1}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (_checked[_step]!.length >= count)
          ElevatedButton(
            onPressed: () => setState(() => _step++),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPeach,
              foregroundColor: AppColors.backgroundDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Next →'),
          ),
      ],
    );
  }
}

// ── INTERACTIVE TECHNIQUE WIDGETS ──

class _TimeBlockPlanner extends StatefulWidget {
  const _TimeBlockPlanner();
  @override
  State<_TimeBlockPlanner> createState() => _TimeBlockPlannerState();
}

class _TimeBlockPlannerState extends State<_TimeBlockPlanner> {
  final _blocks = <String>['', '', '', ''];
  final _hours = ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plan your next 4 hours:',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
        const SizedBox(height: 12),
        for (int i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(_hours[i],
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryPeach)),
                ),
                Expanded(
                  child: TextField(
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark),
                    decoration: InputDecoration(
                      hintText: 'What will you do?',
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark),
                      filled: true,
                      fillColor: AppColors.backgroundDarkElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (v) => _blocks[i] = v,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TwoMinuteRule extends StatefulWidget {
  const _TwoMinuteRule();
  @override
  State<_TwoMinuteRule> createState() => _TwoMinuteRuleState();
}

class _TwoMinuteRuleState extends State<_TwoMinuteRule> {
  bool _timerRunning = false;
  int _seconds = 120;
  Timer? _timer;

  void _startTimer() {
    setState(() { _timerRunning = true; _seconds = 120; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _seconds--;
        if (_seconds <= 0) {
          _timer?.cancel();
          HapticFeedback.heavyImpact();
          _timerRunning = false;
        }
      });
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Think of a quick task. If it takes < 2 min, DO IT NOW.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Text(_timerRunning ? '${_seconds}s' : '2:00',
            style: AppTextStyles.displayMedium.copyWith(
                color: _seconds <= 30 ? AppColors.error : AppColors.primaryPeach)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _timerRunning ? null : _startTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPeach,
            foregroundColor: AppColors.backgroundDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: Text(_timerRunning ? 'Go! Go! Go!' : 'Start 2-Minute Timer'),
        ),
        if (_seconds <= 0)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('✅ Done! One less thing on your mind.',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.tertiarySage)),
          ),
      ],
    );
  }
}

class _DeepWorkProtocol extends StatelessWidget {
  const _DeepWorkProtocol();
  @override
  Widget build(BuildContext context) {
    final steps = [
      ('1️⃣', 'Close all tabs except what you need'),
      ('2️⃣', 'Put phone on airplane mode'),
      ('3️⃣', 'Set a clear goal: "I will finish ___"'),
      ('4️⃣', 'Set timer for 60-90 minutes'),
      ('5️⃣', 'Work with full intensity — no switching'),
      ('6️⃣', 'Take a real break when done'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (icon, text) in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(child: Text(text,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark))),
              ],
            ),
          ),
      ],
    );
  }
}

class _BodyScan extends StatefulWidget {
  const _BodyScan();
  @override
  State<_BodyScan> createState() => _BodyScanState();
}

class _BodyScanState extends State<_BodyScan> {
  int _step = -1;
  final _bodyParts = [
    ('🦶', 'Feet', 'Notice any tension in your toes and soles. Breathe into them.'),
    ('🦵', 'Legs', 'Feel your calves and thighs. Let them become heavy and relaxed.'),
    ('🫃', 'Belly', 'Notice your belly rising and falling with each breath.'),
    ('🫁', 'Chest', 'Feel your chest expand. Release any tightness.'),
    ('💪', 'Arms', 'Let your arms go limp. Feel the weight in your hands.'),
    ('🤲', 'Hands', 'Notice each finger. Let them curl naturally.'),
    ('🫀', 'Shoulders', 'Drop your shoulders away from your ears. Let go.'),
    ('😌', 'Face', 'Relax your jaw, forehead, and eyes. Soften everything.'),
    ('🧠', 'Head', 'Feel the crown of your head. Notice your whole body at once.'),
  ];

  @override
  Widget build(BuildContext context) {
    if (_step < 0) {
      return Center(
        child: ElevatedButton(
          onPressed: () => setState(() => _step = 0),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryLavender,
            foregroundColor: AppColors.backgroundDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: const Text('Begin Body Scan'),
        ),
      );
    }
    if (_step >= _bodyParts.length) {
      return Center(
        child: Column(
          children: [
            const Text('🙏', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Scan complete. Notice how your body feels now.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }
    final (emoji, part, instruction) = _bodyParts[_step];
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        Text(part, style: AppTextStyles.titleMedium.copyWith(color: AppColors.secondaryLavender)),
        const SizedBox(height: 8),
        Text(instruction,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark, height: 1.6),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('${_step + 1} of ${_bodyParts.length}',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => setState(() => _step++),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryLavender,
            foregroundColor: AppColors.backgroundDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(_step < _bodyParts.length - 1 ? 'Next →' : 'Complete'),
        ),
      ],
    );
  }
}

class _PMR extends StatefulWidget {
  const _PMR();
  @override
  State<_PMR> createState() => _PMRState();
}

class _PMRState extends State<_PMR> {
  int _step = -1;
  final _muscles = [
    ('🦶', 'Feet', 'Curl your toes tightly for 5 seconds... now release.'),
    ('🦵', 'Calves', 'Point your toes up, tense your calves... hold... release.'),
    ('🦵', 'Thighs', 'Squeeze your thigh muscles tight... hold... release.'),
    ('✊', 'Hands', 'Make tight fists... hold 5 seconds... open and release.'),
    ('💪', 'Arms', 'Flex your biceps hard... hold... let arms go limp.'),
    ('🫁', 'Chest', 'Take a deep breath, hold your chest tight... exhale and release.'),
    ('🤷', 'Shoulders', 'Shrug your shoulders to your ears... hold... drop them.'),
    ('😬', 'Face', 'Scrunch your face tight... hold... relax everything.'),
  ];

  @override
  Widget build(BuildContext context) {
    if (_step < 0) {
      return Center(
        child: ElevatedButton(
          onPressed: () => setState(() => _step = 0),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPeach,
            foregroundColor: AppColors.backgroundDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          ),
          child: const Text('Begin PMR'),
        ),
      );
    }
    if (_step >= _muscles.length) {
      return Center(
        child: Column(
          children: [
            const Text('😌', style: TextStyle(fontSize: 48)),
            Text('All muscles relaxed!',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.tertiarySage)),
          ],
        ),
      );
    }
    final (emoji, muscle, instr) = _muscles[_step];
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(muscle, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryPeach)),
        const SizedBox(height: 8),
        Text(instr,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark, height: 1.5),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => setState(() => _step++),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPeach,
            foregroundColor: AppColors.backgroundDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(_step < _muscles.length - 1 ? 'Next Muscle →' : 'Done!'),
        ),
      ],
    );
  }
}

class _SevenMinWorkout extends StatefulWidget {
  const _SevenMinWorkout();
  @override
  State<_SevenMinWorkout> createState() => _SevenMinWorkoutState();
}

class _SevenMinWorkoutState extends State<_SevenMinWorkout> {
  int _current = -1;
  int _seconds = 30;
  bool _resting = false;
  Timer? _timer;

  final _exercises = [
    ('🏃', 'Jumping Jacks'),
    ('🧱', 'Wall Sit'),
    ('💪', 'Push-Ups'),
    ('🔄', 'Crunches'),
    ('🪑', 'Step-Ups'),
    ('🦵', 'Squats'),
    ('💺', 'Tricep Dips'),
    ('🧘', 'Plank'),
    ('🦵', 'High Knees'),
    ('🦵', 'Lunges'),
    ('🔄', 'Push-Up & Rotation'),
    ('🧘', 'Side Plank'),
  ];

  void _startWorkout() {
    setState(() { _current = 0; _seconds = 30; _resting = false; });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _seconds--;
        if (_seconds <= 0) {
          HapticFeedback.mediumImpact();
          if (_resting) {
            _resting = false;
            _seconds = 30;
          } else {
            _current++;
            if (_current >= _exercises.length) {
              _timer?.cancel();
              return;
            }
            _resting = true;
            _seconds = 10;
          }
        }
      });
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_current < 0) {
      return Column(
        children: [
          for (int i = 0; i < _exercises.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(_exercises[i].$1, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text('${i + 1}. ${_exercises[i].$2}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _startWorkout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: const Text('Start Workout! 💪'),
          ),
        ],
      );
    }

    if (_current >= _exercises.length) {
      return Center(
        child: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            Text('Workout Complete!',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.tertiarySage)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(_resting ? '😮‍💨' : _exercises[_current].$1, style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 12),
        Text(_resting ? 'Rest' : _exercises[_current].$2,
            style: AppTextStyles.titleLarge.copyWith(
                color: _resting ? AppColors.quaternarySky : AppColors.primaryPeach)),
        const SizedBox(height: 8),
        Text('$_seconds',
            style: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimaryDark)),
        const SizedBox(height: 4),
        Text('Exercise ${_current + 1} of ${_exercises.length}',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
      ],
    );
  }
}

class _WalkingMeditation extends StatelessWidget {
  const _WalkingMeditation();
  @override
  Widget build(BuildContext context) {
    final steps = [
      'Stand still. Feel your feet on the ground.',
      'Begin walking very slowly.',
      'Notice the lifting of each foot.',
      'Feel the movement through the air.',
      'Notice the placing of each foot down.',
      'Coordinate your breath with your steps.',
      'If your mind wanders, gently return to your feet.',
      'Walk for 10 minutes with this awareness.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${i + 1}.', style: AppTextStyles.labelMedium.copyWith(color: AppColors.tertiarySage)),
                const SizedBox(width: 10),
                Expanded(child: Text(steps[i],
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark))),
              ],
            ),
          ),
      ],
    );
  }
}

class _DeskStretches extends StatefulWidget {
  const _DeskStretches();
  @override
  State<_DeskStretches> createState() => _DeskStretchesState();
}

class _DeskStretchesState extends State<_DeskStretches> {
  int _current = 0;
  final _stretches = [
    ('🙆', 'Neck Rolls', 'Slowly roll your head in a circle, 5 times each direction.'),
    ('🤷', 'Shoulder Shrugs', 'Raise shoulders to ears, hold 3 sec, drop. Repeat 10x.'),
    ('🙏', 'Chest Opener', 'Clasp hands behind back, squeeze shoulder blades, hold 15 sec.'),
    ('🔄', 'Seated Twist', 'Cross legs, twist torso to one side, hold 15 sec. Switch.'),
    ('🙌', 'Overhead Stretch', 'Interlace fingers above head, stretch up and lean side to side.'),
  ];

  @override
  Widget build(BuildContext context) {
    final (emoji, name, desc) = _stretches[_current];
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 8),
        Text(name, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryPeach)),
        const SizedBox(height: 8),
        Text(desc,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark, height: 1.5),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('${_current + 1} of ${_stretches.length}',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_current > 0)
              TextButton(onPressed: () => setState(() => _current--), child: const Text('← Back')),
            const SizedBox(width: 16),
            if (_current < _stretches.length - 1)
              ElevatedButton(
                onPressed: () => setState(() => _current++),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPeach,
                  foregroundColor: AppColors.backgroundDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Next Stretch →'),
              ),
            if (_current == _stretches.length - 1)
              const Text('✅ All done!', style: TextStyle(fontSize: 20)),
          ],
        ),
      ],
    );
  }
}

class _EnergyAudit extends StatefulWidget {
  const _EnergyAudit();
  @override
  State<_EnergyAudit> createState() => _EnergyAuditState();
}

class _EnergyAuditState extends State<_EnergyAudit> {
  final _ratings = <int, int>{}; // hour -> rating 1-5

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().hour;
    final hours = List.generate(12, (i) => (now - 6 + i) % 24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rate your energy throughout the day:',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark)),
        const SizedBox(height: 12),
        for (final h in hours)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 55,
                  child: Text('${h.toString().padLeft(2, '0')}:00',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryDark)),
                ),
                for (int r = 1; r <= 5; r++)
                  GestureDetector(
                    onTap: () => setState(() => _ratings[h] = r),
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      width: 36,
                      height: 28,
                      decoration: BoxDecoration(
                        color: (_ratings[h] ?? 0) >= r
                            ? _energyColor(r).withValues(alpha: 0.8)
                            : AppColors.backgroundDarkElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text('$r',
                            style: AppTextStyles.caption.copyWith(
                              color: (_ratings[h] ?? 0) >= r
                                  ? Colors.white
                                  : AppColors.textTertiaryDark,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Color _energyColor(int r) {
    switch (r) {
      case 1: return AppColors.error;
      case 2: return AppColors.primaryPeach;
      case 3: return AppColors.quaternarySky;
      case 4: return AppColors.tertiarySage;
      case 5: return AppColors.tertiarySageDark;
      default: return AppColors.textTertiaryDark;
    }
  }
}

class _SmartGoalForm extends StatefulWidget {
  const _SmartGoalForm();
  @override
  State<_SmartGoalForm> createState() => _SmartGoalFormState();
}

class _SmartGoalFormState extends State<_SmartGoalForm> {
  final _ctrls = List.generate(5, (_) => TextEditingController());
  final _labels = ['Specific — What exactly?', 'Measurable — How will you measure?', 'Achievable — Is it realistic?', 'Relevant — Why does it matter?', 'Time-bound — By when?'];
  final _hints = ['I will learn Flutter', 'Complete 1 tutorial per week', 'Yes, 1hr/day available', 'Career transition to mobile dev', 'By March 30, 2026'];

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < 5; i++) ...[
          Text(_labels[i], style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryPeach)),
          const SizedBox(height: 4),
          TextField(
            controller: _ctrls[i],
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark),
            decoration: InputDecoration(
              hintText: _hints[i],
              hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark),
              filled: true,
              fillColor: AppColors.backgroundDarkElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _WeeklyReview extends StatelessWidget {
  const _WeeklyReview();
  @override
  Widget build(BuildContext context) {
    final prompts = [
      ('🏆', 'What were my 3 biggest wins this week?'),
      ('📖', 'What did I learn?'),
      ('😤', 'What frustrated me? How can I fix it?'),
      ('🎯', 'Top 3 priorities for next week?'),
      ('🙏', 'What am I grateful for?'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (emoji, prompt) in prompts) ...[
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(child: Text(prompt,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark))),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            maxLines: 2,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.backgroundDarkElevated,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SkillGapAnalysis extends StatelessWidget {
  const _SkillGapAnalysis();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('1. What role/position do you want?',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryPeach)),
        const SizedBox(height: 4),
        _buildField('e.g., Senior Flutter Developer'),
        const SizedBox(height: 12),
        Text('2. Skills required for that role:',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryPeach)),
        const SizedBox(height: 4),
        _buildField('e.g., Dart, Flutter, CI/CD, Testing'),
        const SizedBox(height: 12),
        Text('3. Skills you already have:',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.tertiarySage)),
        const SizedBox(height: 4),
        _buildField('e.g., Dart, Flutter basics'),
        const SizedBox(height: 12),
        Text('4. Your gap (skills to learn):',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.error)),
        const SizedBox(height: 4),
        _buildField('e.g., CI/CD, Testing, State management'),
        const SizedBox(height: 12),
        Text('5. Learning plan (1 skill at a time):',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.quaternarySky)),
        const SizedBox(height: 4),
        _buildField('e.g., This month: Master Riverpod'),
      ],
    );
  }

  Widget _buildField(String hint) {
    return TextField(
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark),
        filled: true,
        fillColor: AppColors.backgroundDarkElevated,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _NetworkingChallenge extends StatelessWidget {
  const _NetworkingChallenge();
  @override
  Widget build(BuildContext context) {
    final tips = [
      ('💬', 'Comment thoughtfully on 1 LinkedIn post today'),
      ('📧', 'Send a "just thinking of you" message to an old colleague'),
      ('☕', 'Invite someone for a virtual coffee chat'),
      ('🎯', 'Attend 1 industry event or webinar this week'),
      ('📝', 'Write and share 1 post about something you learned'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This week\'s networking actions:',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
        const SizedBox(height: 12),
        for (final (emoji, tip) in tips)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(child: Text(tip,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark))),
              ],
            ),
          ),
      ],
    );
  }
}

class _NoSpendTracker extends StatefulWidget {
  const _NoSpendTracker();
  @override
  State<_NoSpendTracker> createState() => _NoSpendTrackerState();
}

class _NoSpendTrackerState extends State<_NoSpendTracker> {
  int _noSpendDays = 0;
  bool _todayNoSpend = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$_noSpendDays', style: AppTextStyles.displayLarge.copyWith(color: AppColors.tertiarySage)),
        Text('No-Spend Days', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondaryDark)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              _todayNoSpend = !_todayNoSpend;
              if (_todayNoSpend) {
                _noSpendDays++;
              } else if (_noSpendDays > 0) {
                _noSpendDays--;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: _todayNoSpend ? AppColors.tertiarySage.withValues(alpha: 0.2) : AppColors.backgroundDarkElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _todayNoSpend ? AppColors.tertiarySage : Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              _todayNoSpend ? '✅ Today is a no-spend day!' : 'Tap to mark today as no-spend',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _todayNoSpend ? AppColors.tertiarySage : AppColors.textPrimaryDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SavingsVisualizer extends StatefulWidget {
  const _SavingsVisualizer();
  @override
  State<_SavingsVisualizer> createState() => _SavingsVisualizerState();
}

class _SavingsVisualizerState extends State<_SavingsVisualizer> {
  final _goalCtrl = TextEditingController();
  final _savedCtrl = TextEditingController();

  @override
  void dispose() { _goalCtrl.dispose(); _savedCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final goal = double.tryParse(_goalCtrl.text) ?? 0;
    final saved = double.tryParse(_savedCtrl.text) ?? 0;
    final progress = goal > 0 ? (saved / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Savings Goal:', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryPeach)),
        const SizedBox(height: 4),
        TextField(
          controller: _goalCtrl,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
          decoration: InputDecoration(
            prefixText: '\$ ',
            filled: true, fillColor: AppColors.backgroundDarkElevated,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 8),
        Text('Amount Saved:', style: AppTextStyles.labelSmall.copyWith(color: AppColors.tertiarySage)),
        const SizedBox(height: 4),
        TextField(
          controller: _savedCtrl,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
          decoration: InputDecoration(
            prefixText: '\$ ',
            filled: true, fillColor: AppColors.backgroundDarkElevated,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        if (goal > 0) ...[
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 20,
              backgroundColor: AppColors.backgroundDarkElevated,
              valueColor: const AlwaysStoppedAnimation(AppColors.tertiarySage),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).toStringAsFixed(1)}% — \$${saved.toStringAsFixed(0)} of \$${goal.toStringAsFixed(0)}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark)),
          if (progress >= 1.0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('🎉 Goal reached!',
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.tertiarySage)),
            ),
        ],
      ],
    );
  }
}

// Fix: AnimatedBuilder doesn't exist, use AnimatedBuilder = AnimatedWidget pattern
// Actually AnimatedBuilder is correct in Flutter. Let me check - it's AnimatedBuilder in Flutter.
// Correction: Flutter has AnimatedBuilder. Let me verify the import works.
