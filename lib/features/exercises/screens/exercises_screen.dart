import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

// ── Data Models ──────────────────────────────────────────────────────────────

enum ExerciseType { breathing, cognitive, body, focus, sleep }

class ExerciseCategory {
  final String emoji;
  final String label;
  final ExerciseType type;
  const ExerciseCategory(this.emoji, this.label, this.type);
}

class Exercise {
  final String title;
  final String icon;
  final int durationMin;
  final int difficulty; // 1-3
  final ExerciseType type;
  final List<String>? steps;
  final String? prompt;
  // breathing params
  final int? inhale;
  final int? hold;
  final int? exhale;
  final int? holdAfter;

  const Exercise({
    required this.title,
    required this.icon,
    required this.durationMin,
    required this.difficulty,
    required this.type,
    this.steps,
    this.prompt,
    this.inhale,
    this.hold,
    this.exhale,
    this.holdAfter,
  });
}

const _categories = [
  ExerciseCategory('🧘', 'Breathing', ExerciseType.breathing),
  ExerciseCategory('🧠', 'Cognitive', ExerciseType.cognitive),
  ExerciseCategory('💪', 'Body', ExerciseType.body),
  ExerciseCategory('🎯', 'Focus', ExerciseType.focus),
  ExerciseCategory('🌙', 'Sleep', ExerciseType.sleep),
];

const _exercises = <Exercise>[
  // Breathing
  Exercise(title: '4-7-8 Breathing', icon: '🌬️', durationMin: 4, difficulty: 1, type: ExerciseType.breathing, inhale: 4, hold: 7, exhale: 8),
  Exercise(title: 'Box Breathing', icon: '⬜', durationMin: 5, difficulty: 1, type: ExerciseType.breathing, inhale: 4, hold: 4, exhale: 4, holdAfter: 4),
  Exercise(title: 'Coherent Breathing', icon: '🔄', durationMin: 5, difficulty: 1, type: ExerciseType.breathing, inhale: 5, hold: 0, exhale: 5),
  Exercise(title: 'Wim Hof', icon: '❄️', durationMin: 10, difficulty: 3, type: ExerciseType.breathing, inhale: 2, hold: 0, exhale: 2),
  // Cognitive
  Exercise(title: 'Gratitude Journal', icon: '🙏', durationMin: 3, difficulty: 1, type: ExerciseType.cognitive, prompt: 'Write 3 things you\'re grateful for right now.'),
  Exercise(title: 'Thought Record', icon: '📝', durationMin: 5, difficulty: 2, type: ExerciseType.cognitive, prompt: 'What thought is bothering you? Write it down, then challenge it.'),
  Exercise(title: 'Cognitive Defusion', icon: '🎈', durationMin: 3, difficulty: 2, type: ExerciseType.cognitive, prompt: 'Take a negative thought and prefix it with "I notice I\'m having the thought that..."'),
  Exercise(title: 'Reframing', icon: '🖼️', durationMin: 4, difficulty: 2, type: ExerciseType.cognitive, prompt: 'Describe a stressful situation. Now rewrite it from a neutral observer\'s perspective.'),
  // Body
  Exercise(title: 'Progressive Muscle Relaxation', icon: '💆', durationMin: 10, difficulty: 2, type: ExerciseType.body, steps: ['Tense your feet for 5s, then release.', 'Tense your calves for 5s, then release.', 'Tense your thighs for 5s, then release.', 'Tense your abdomen for 5s, then release.', 'Tense your hands for 5s, then release.', 'Tense your shoulders for 5s, then release.', 'Tense your face for 5s, then release.', 'Scan your body. Let go of any remaining tension.']),
  Exercise(title: 'Body Scan', icon: '🧍', durationMin: 8, difficulty: 1, type: ExerciseType.body, steps: ['Close your eyes. Notice your feet on the ground.', 'Move attention up to your legs.', 'Notice your hips and lower back.', 'Feel your chest rising and falling.', 'Relax your shoulders and arms.', 'Soften your face and jaw.', 'Hold awareness of your whole body.', 'Gently open your eyes.']),
  Exercise(title: 'Power Pose', icon: '🦸', durationMin: 2, difficulty: 1, type: ExerciseType.body, steps: ['Stand tall, feet shoulder-width apart.', 'Place hands on hips, chest open.', 'Hold this pose. Breathe deeply.', 'Feel confident energy flowing through you.']),
  Exercise(title: 'Grounding 5-4-3-2-1', icon: '🌍', durationMin: 3, difficulty: 1, type: ExerciseType.body, steps: ['Name 5 things you can SEE.', 'Name 4 things you can TOUCH.', 'Name 3 things you can HEAR.', 'Name 2 things you can SMELL.', 'Name 1 thing you can TASTE.']),
  // Focus
  Exercise(title: 'Pomodoro Timer', icon: '🍅', durationMin: 25, difficulty: 1, type: ExerciseType.focus, steps: ['Focus on one task for 25 minutes.', 'No distractions. Phone away.', 'When the timer ends, take a 5-min break.']),
  Exercise(title: 'Single-task Challenge', icon: '🎯', durationMin: 10, difficulty: 2, type: ExerciseType.focus, steps: ['Choose ONE task.', 'Close all other apps & tabs.', 'Work on only this task for 10 minutes.', 'Notice when your mind wanders — gently return.']),
  Exercise(title: 'Digital Detox Timer', icon: '📵', durationMin: 15, difficulty: 2, type: ExerciseType.focus, steps: ['Put your phone face-down.', 'Set this timer and step away.', 'Notice how it feels to be unplugged.', 'Return refreshed.']),
  Exercise(title: 'Flow Prep', icon: '🌊', durationMin: 3, difficulty: 1, type: ExerciseType.focus, steps: ['Clear your desk of distractions.', 'Take 3 deep breaths.', 'Set a clear intention for your next work block.', 'Begin.']),
  // Sleep
  Exercise(title: 'Wind-down Routine', icon: '🕯️', durationMin: 10, difficulty: 1, type: ExerciseType.sleep, steps: ['Dim the lights.', 'Put away all screens.', 'Do a gentle stretch or body scan.', 'Read something calming or journal.', 'Get into bed. Close your eyes.']),
  Exercise(title: 'Sleep Story', icon: '📖', durationMin: 8, difficulty: 1, type: ExerciseType.sleep, steps: ['Lie down comfortably.', 'Close your eyes.', 'Imagine a quiet forest path...', 'You hear a gentle stream nearby...', 'Each step feels lighter...', 'Your breathing slows naturally...', 'You are safe. You are still.', 'Drift...']),
  Exercise(title: 'Bedtime Check', icon: '✅', durationMin: 2, difficulty: 1, type: ExerciseType.sleep, steps: ['Room temperature cool?', 'Phone on silent / Do Not Disturb?', 'Tomorrow\'s alarm set?', 'One thing you\'re proud of today?', 'Goodnight. You did well.']),
  Exercise(title: 'Melatonin Timer', icon: '🌙', durationMin: 1, difficulty: 1, type: ExerciseType.sleep, steps: ['It\'s time to wind down.', 'Dim screens or enable night mode.', 'Your body needs darkness to produce melatonin.', 'Relax. Sleep is coming.']),
];

// ── Screen ───────────────────────────────────────────────────────────────────

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  ExerciseType _selected = ExerciseType.breathing;
  int? _activeIndex; // which card is expanded

  List<Exercise> get _filtered => _exercises.where((e) => e.type == _selected).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Daily Exercises', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark)),
      ),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, a) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final active = cat.type == _selected;
                return GestureDetector(
                  onTap: () => setState(() { _selected = cat.type; _activeIndex = null; }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primaryPeach.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? AppColors.primaryPeach.withValues(alpha: 0.5) : AppColors.textTertiaryDark.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '${cat.emoji} ${cat.label}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: active ? AppColors.primaryPeach : AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Exercise list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filtered.length,
              separatorBuilder: (_, a) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final ex = _filtered[i];
                final isActive = _activeIndex == i;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) => SizeTransition(sizeFactor: anim, child: child),
                  child: isActive
                      ? _ActiveExerciseCard(key: ValueKey('active_$i'), exercise: ex, onClose: () => setState(() => _activeIndex = null))
                      : _ExerciseCard(key: ValueKey('card_$i'), exercise: ex, onStart: () => setState(() => _activeIndex = i)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Collapsed Card ───────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onStart;
  const _ExerciseCard({super.key, required this.exercise, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textTertiaryDark.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Row(
        children: [
          Text(exercise.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${exercise.durationMin} min', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
                    const SizedBox(width: 10),
                    ...List.generate(3, (d) => Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: d < exercise.difficulty ? AppColors.primaryPeach : AppColors.textTertiaryDark.withValues(alpha: 0.2),
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryPeach.withValues(alpha: 0.4), width: 0.5),
              ),
              child: Text('Start', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryPeach)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active (Expanded) Card ───────────────────────────────────────────────────

class _ActiveExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onClose;
  const _ActiveExerciseCard({super.key, required this.exercise, required this.onClose});

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (exercise.type) {
      case ExerciseType.breathing:
        content = _BreathingUI(exercise: exercise);
      case ExerciseType.cognitive:
        content = _CognitiveUI(exercise: exercise);
      default:
        content = _StepUI(exercise: exercise);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryPeach.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(exercise.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(child: Text(exercise.title, style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark))),
              GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close_rounded, size: 20, color: AppColors.textTertiaryDark),
              ),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }
}

// ── Breathing Animation ──────────────────────────────────────────────────────

class _BreathingUI extends StatefulWidget {
  final Exercise exercise;
  const _BreathingUI({required this.exercise});

  @override
  State<_BreathingUI> createState() => _BreathingUIState();
}

class _BreathingUIState extends State<_BreathingUI> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  String _phase = 'Inhale';
  int _cycles = 0;

  @override
  void initState() {
    super.initState();
    final inhale = widget.exercise.inhale ?? 4;
    final hold = widget.exercise.hold ?? 0;
    final exhale = widget.exercise.exhale ?? 4;
    final holdAfter = widget.exercise.holdAfter ?? 0;
    final total = inhale + hold + exhale + holdAfter;

    _ctrl = AnimationController(vsync: this, duration: Duration(seconds: total))
      ..addListener(() {
        final t = _ctrl.value;
        final iEnd = inhale / total;
        final hEnd = (inhale + hold) / total;
        final eEnd = (inhale + hold + exhale) / total;
        String p;
        if (t < iEnd) {
          p = 'Inhale';
        } else if (t < hEnd) {
          p = 'Hold';
        } else if (t < eEnd) {
          p = 'Exhale';
        } else {
          p = 'Hold';
        }
        if (p != _phase && mounted) setState(() => _phase = p);
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _cycles++;
          if (mounted) setState(() {});
          _ctrl.forward(from: 0);
        }
      })
      ..forward();

    final iEnd = inhale / total;
    final hEnd = (inhale + hold) / total;
    final eEnd = (inhale + hold + exhale) / total;
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: iEnd),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: hEnd - iEnd),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)), weight: eEnd - hEnd),
      TweenSequenceItem(tween: ConstantTween(0.5), weight: 1.0 - eEnd),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _scaleAnim,
          builder: (_, a) => Container(
            width: 120 * _scaleAnim.value + 40,
            height: 120 * _scaleAnim.value + 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primaryPeach.withValues(alpha: 0.3),
                AppColors.secondaryLavender.withValues(alpha: 0.1),
              ]),
              border: Border.all(color: AppColors.primaryPeach.withValues(alpha: 0.3), width: 1),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(_phase, style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
        const SizedBox(height: 4),
        Text('Cycle $_cycles', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
      ],
    );
  }
}

// ── Cognitive / Journal UI ───────────────────────────────────────────────────

class _CognitiveUI extends StatelessWidget {
  final Exercise exercise;
  const _CognitiveUI({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(exercise.prompt ?? '', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark)),
        const SizedBox(height: 14),
        TextField(
          maxLines: 5,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark),
          decoration: InputDecoration(
            hintText: 'Start writing...',
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark),
            filled: true,
            fillColor: AppColors.backgroundDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.textTertiaryDark.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.textTertiaryDark.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primaryPeach.withValues(alpha: 0.4)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Step-by-step UI (Body, Focus, Sleep) ─────────────────────────────────────

class _StepUI extends StatefulWidget {
  final Exercise exercise;
  const _StepUI({required this.exercise});

  @override
  State<_StepUI> createState() => _StepUIState();
}

class _StepUIState extends State<_StepUI> {
  int _step = 0;
  int _seconds = 0;
  Timer? _timer;

  List<String> get steps => widget.exercise.steps ?? ['Follow along.'];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_step < steps.length - 1) {
      setState(() { _step++; _seconds = 0; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${_step + 1} of ${steps.length}',
          style: AppTextStyles.overline.copyWith(color: AppColors.textTertiaryDark),
        ),
        const SizedBox(height: 8),
        Text(steps[_step], style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark)),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('${_seconds}s', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
            const Spacer(),
            if (_step < steps.length - 1)
              GestureDetector(
                onTap: _next,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.tertiarySage.withValues(alpha: 0.4), width: 0.5),
                  ),
                  child: Text('Next Step', style: AppTextStyles.labelSmall.copyWith(color: AppColors.tertiarySage)),
                ),
              )
            else
              Text('✓ Complete', style: AppTextStyles.labelSmall.copyWith(color: AppColors.tertiarySage)),
          ],
        ),
      ],
    );
  }
}
