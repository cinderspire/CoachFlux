import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/problem_engine.dart';
import '../../../core/models/coach.dart';
import '../../chat/screens/chat_screen.dart';

// ═══════════════════════════════════════════════════════════════
// SOLUTION DETAIL SCREEN — Deep-dive into a recommended technique
// ═══════════════════════════════════════════════════════════════

class SolutionDetailScreen extends StatelessWidget {
  final String techniqueName;
  final String reason;
  final List<ProblemAssessmentResult> results;

  const SolutionDetailScreen({
    super.key,
    required this.techniqueName,
    required this.reason,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final info = _techniqueInfo[techniqueName] ?? _defaultInfo;
    // Find best coach for this technique
    final bestCoach = _findBestCoach(techniqueName);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.backgroundDark,
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      info.color.withValues(alpha: 0.3),
                      AppColors.backgroundDark,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(info.emoji, style: const TextStyle(fontSize: 64)),
                ),
              ),
              title: Text(
                techniqueName,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Why recommended
                  _buildSection(
                    '🎯 Why We Recommend This',
                    reason,
                    info.color,
                  ),
                  const SizedBox(height: 20),

                  // What it is
                  _buildSection(
                    '📖 What Is It?',
                    info.description,
                    info.color,
                  ),
                  const SizedBox(height: 20),

                  // Evidence
                  _buildSection(
                    '🔬 The Science',
                    info.evidence,
                    info.color,
                  ),
                  const SizedBox(height: 20),

                  // CoachFlux approach
                  _buildSection(
                    '✨ The CoachFlux Approach',
                    info.coachFluxApproach,
                    info.color,
                  ),
                  const SizedBox(height: 20),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: info.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: info.color.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        _buildStat('⏱️', info.duration, 'Duration'),
                        _buildDivider(),
                        _buildStat('📊', info.difficulty, 'Difficulty'),
                        _buildDivider(),
                        _buildStat('🎯', info.effectiveness, 'Effectiveness'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Try with Coach button
                  if (bestCoach != null) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(coach: bestCoach),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              bestCoach.color,
                              bestCoach.color.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: bestCoach.color.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(bestCoach.emoji,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Text(
                              'Try with ${bestCoach.name}',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.titleSmall
                .copyWith(color: AppColors.textPrimaryDark)),
        const SizedBox(height: 8),
        Text(content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
              height: 1.6,
            )),
      ],
    );
  }

  Widget _buildStat(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.textPrimaryDark)),
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textTertiaryDark, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Coach? _findBestCoach(String technique) {
    // Map techniques to best coach
    const techToCoach = {
      'Box Breathing': 'zen-mind',
      'Body Scan Meditation': 'zen-mind',
      '5-4-3-2-1 Grounding': 'zen-mind',
      'Progressive Muscle Relaxation': 'zen-mind',
      'Walking Meditation': 'zen-mind',
      'Pomodoro Technique': 'flow-master',
      'Time Blocking': 'flow-master',
      '2-Minute Rule': 'flow-master',
      'Deep Work Protocol': 'flow-master',
      '7-Minute Workout': 'iron-will',
      'Desk Stretches': 'iron-will',
      'Energy Audit': 'iron-will',
      'SMART Goal Framework': 'career-pilot',
      'Weekly Review': 'system-builder',
      'Skill Gap Analysis': 'career-pilot',
      'Networking Challenge': 'social-spark',
      '50/30/20 Budget': 'money-mind',
      'No-Spend Challenge': 'money-mind',
      'Savings Goal Visualizer': 'money-mind',
    };
    final coachId = techToCoach[technique];
    if (coachId == null) return null;
    return defaultCoaches.where((c) => c.id == coachId).firstOrNull;
  }
}

// ═══════════════════════════════════════════════════════
// TECHNIQUE INFO DATABASE
// ═══════════════════════════════════════════════════════

class _TechniqueInfo {
  final String emoji;
  final String description;
  final String evidence;
  final String coachFluxApproach;
  final String duration;
  final String difficulty;
  final String effectiveness;
  final Color color;

  const _TechniqueInfo({
    required this.emoji,
    required this.description,
    required this.evidence,
    required this.coachFluxApproach,
    required this.duration,
    required this.difficulty,
    required this.effectiveness,
    required this.color,
  });
}

const _defaultInfo = _TechniqueInfo(
  emoji: '✨',
  description: 'An evidence-based technique curated by our expert coaches.',
  evidence: 'Backed by clinical research and real-world application.',
  coachFluxApproach: 'We guide you through this technique step-by-step, adapting to your unique needs and pace.',
  duration: '5-15 min',
  difficulty: 'Easy',
  effectiveness: 'High',
  color: Color(0xFFA78BFA),
);

final Map<String, _TechniqueInfo> _techniqueInfo = {
  'Box Breathing': const _TechniqueInfo(
    emoji: '🫁',
    description: 'A controlled breathing pattern: inhale for 4 seconds, hold for 4, exhale for 4, hold for 4. This creates a "box" pattern that activates your parasympathetic nervous system.',
    evidence: 'Used by Navy SEALs for acute stress management. Research shows it reduces cortisol levels by up to 25% in just 4 minutes and improves heart rate variability.',
    coachFluxApproach: 'ZenMind guides you through a visual breathing exercise with gentle animation. We start with shorter counts if 4 seconds is too much, and gradually build. Your nervous system learns to self-regulate.',
    duration: '4 min',
    difficulty: 'Easy',
    effectiveness: '92%',
    color: Color(0xFFA78BFA),
  ),
  '5-4-3-2-1 Grounding': const _TechniqueInfo(
    emoji: '🌍',
    description: 'Name 5 things you see, 4 you touch, 3 you hear, 2 you smell, 1 you taste. This sensory exercise anchors your awareness to the present moment, breaking anxiety and panic spirals.',
    evidence: 'Widely used in CBT and trauma therapy. Activates the prefrontal cortex, pulling attention away from the amygdala\'s fear response.',
    coachFluxApproach: 'ZenMind walks you through each sense slowly and gently. We add a guided audio version for moments when reading feels overwhelming. It becomes your instant "reset button."',
    duration: '3 min',
    difficulty: 'Easy',
    effectiveness: '88%',
    color: Color(0xFF22C55E),
  ),
  'Progressive Muscle Relaxation': const _TechniqueInfo(
    emoji: '💆',
    description: 'Systematically tense and release each muscle group in your body. By creating deliberate tension first, the release feels deeper and more complete.',
    evidence: 'Developed by Edmund Jacobson (1938). Meta-analysis of 30+ studies shows significant reductions in anxiety, insomnia, and chronic pain.',
    coachFluxApproach: 'ZenMind guides you through each muscle group with precise timing. We track which areas hold the most tension over time, helping you develop body awareness and prevent stress buildup.',
    duration: '10-15 min',
    difficulty: 'Easy',
    effectiveness: '85%',
    color: Color(0xFF6366F1),
  ),
  'Body Scan Meditation': const _TechniqueInfo(
    emoji: '🧘',
    description: 'A mindfulness practice where you slowly scan your attention from head to toe, noticing sensations without trying to change them. It\'s about OBSERVING, not fixing.',
    evidence: 'Core component of MBSR (Kabat-Zinn, 1990). Reduces anxiety, improves body awareness, and has been shown to decrease rumination by 40% with regular practice.',
    coachFluxApproach: 'ZenMind offers both a guided 10-minute version and a quick 3-minute version. We use it not just for relaxation but as a diagnostic tool — your body tells us where you\'re holding stress.',
    duration: '10 min',
    difficulty: 'Medium',
    effectiveness: '90%',
    color: Color(0xFFA78BFA),
  ),
  'Walking Meditation': const _TechniqueInfo(
    emoji: '🚶',
    description: 'Slow, deliberate walking with full attention on the physical sensation of each step. "Walk as if you are kissing the earth with your feet." — Thich Nhat Hanh',
    evidence: 'Research shows walking meditation reduces depression scores by 40% in 12 weeks. Combines physical movement benefits with mindfulness.',
    coachFluxApproach: 'ZenMind guides you through this as a gentle movement meditation. Perfect for people who find sitting meditation too difficult. We recommend it especially for depression and grief.',
    duration: '10-20 min',
    difficulty: 'Easy',
    effectiveness: '82%',
    color: Color(0xFF22C55E),
  ),
  'Pomodoro Technique': const _TechniqueInfo(
    emoji: '🍅',
    description: '25 minutes of focused work followed by a 5-minute break. After 4 cycles, take a longer 15-30 minute break. The key is SINGLE-TASKING during each Pomodoro.',
    evidence: 'Developed by Francesco Cirillo (2006). Reduces mental fatigue through structured intervals and prevents the cognitive cost of multitasking.',
    coachFluxApproach: 'FlowState coaches you on what to focus on during each Pomodoro and what constitutes a REAL break (no screens!). We track your focus sessions and celebrate streaks.',
    duration: '25 min',
    difficulty: 'Easy',
    effectiveness: '87%',
    color: Color(0xFFEF4444),
  ),
  'Time Blocking': const _TechniqueInfo(
    emoji: '📅',
    description: 'Schedule every hour of your day with a specific purpose. Instead of a to-do list, you have a time-MAP. This eliminates decision fatigue and makes deep work non-negotiable.',
    evidence: 'Cal Newport\'s Deep Work (2016). Reduces decision fatigue by up to 40% and increases productive output by 2-5x compared to reactive task management.',
    coachFluxApproach: 'FlowState helps you design your ideal day template, then SystemBuilder automates it. We focus on protecting your "biological prime time" for your hardest work.',
    duration: '5 min setup',
    difficulty: 'Easy',
    effectiveness: '85%',
    color: Color(0xFF3B82F6),
  ),
  '2-Minute Rule': const _TechniqueInfo(
    emoji: '⚡',
    description: 'If a task takes less than 2 minutes, do it NOW. Don\'t add it to a list, don\'t think about it — just do it. This prevents small tasks from accumulating into overwhelming piles.',
    evidence: 'David Allen, Getting Things Done (2001). Prevents task buildup and the cognitive load of maintaining growing to-do lists.',
    coachFluxApproach: 'FlowState combines this with the "starting" version: make any task\'s first step take only 2 minutes. This breaks procrastination by making starting frictionless.',
    duration: '2 min',
    difficulty: 'Easy',
    effectiveness: '90%',
    color: Color(0xFFF59E0B),
  ),
  'Deep Work Protocol': const _TechniqueInfo(
    emoji: '🧠',
    description: 'Eliminate ALL distractions. Set ONE clear goal. Work with full cognitive intensity for 60-90 minutes. Phone in another room. All notifications off. This is how elite performers work.',
    evidence: 'Cal Newport (2016). Deep work produces 2-5x more valuable output than shallow work. Phone in another room increases cognitive capacity by 26% (Ward et al., 2017).',
    coachFluxApproach: 'FlowState helps you set up your "deep work cockpit" — everything you need, nothing you don\'t. We guide you through the ritual and track your deep work hours over time.',
    duration: '60-90 min',
    difficulty: 'Hard',
    effectiveness: '95%',
    color: Color(0xFF3B82F6),
  ),
  '7-Minute Workout': const _TechniqueInfo(
    emoji: '💪',
    description: 'High-intensity circuit training: 12 exercises, 30 seconds each, with 10-second rest intervals. A complete workout using just your body weight.',
    evidence: 'Published in ACSM Health & Fitness Journal. Provides comparable benefits to longer endurance and resistance training for time-constrained individuals.',
    coachFluxApproach: 'IronWill coaches you through each exercise with proper form. We use this as a "starter" workout — the goal is consistency, not perfection. Once this is a habit, we level up.',
    duration: '7 min',
    difficulty: 'Medium',
    effectiveness: '83%',
    color: Color(0xFFEF4444),
  ),
  'SMART Goal Framework': const _TechniqueInfo(
    emoji: '🎯',
    description: 'Goals must be: Specific (what exactly?), Measurable (how will you know?), Achievable (is it realistic?), Relevant (does it matter?), Time-bound (by when?).',
    evidence: 'Doran (1981). SMART goals are 33% more likely to be achieved than vague goals. Combined with implementation intentions, success rate increases further.',
    coachFluxApproach: 'CareerPilot helps you turn vague wishes into SMART goals, then FlowState breaks them into daily actions. We review progress weekly and adjust the plan.',
    duration: '10 min',
    difficulty: 'Easy',
    effectiveness: '85%',
    color: Color(0xFFF59E0B),
  ),
  'Weekly Review': const _TechniqueInfo(
    emoji: '📋',
    description: 'A weekly ritual to clear inboxes, review projects, update next actions, and plan the coming week. This is what makes any productivity system actually work.',
    evidence: 'David Allen, GTD. "The Weekly Review is what makes the system work. Without it, you just have a fancy list app." Prevents stress from accumulating.',
    coachFluxApproach: 'SystemBuilder guides you through a structured 30-minute weekly review. We build it into your calendar and make it a habit. Over time, it becomes your weekly "reset button."',
    duration: '30 min',
    difficulty: 'Medium',
    effectiveness: '88%',
    color: Color(0xFF06B6D4),
  ),
  'Energy Audit': const _TechniqueInfo(
    emoji: '🔋',
    description: 'Track your energy levels throughout the day for one week. Note what activities energize you vs. drain you. This data reveals your optimal schedule.',
    evidence: 'Based on ultradian rhythm research. Understanding your energy patterns allows you to schedule demanding work during peak hours, increasing output by 20-40%.',
    coachFluxApproach: 'IronWill and FlowState analyze your energy data together. We identify your "biological prime time" and redesign your day around it.',
    duration: '5 min/day',
    difficulty: 'Easy',
    effectiveness: '80%',
    color: Color(0xFFEF4444),
  ),
  'Skill Gap Analysis': const _TechniqueInfo(
    emoji: '📊',
    description: 'Map your current skills against your desired role. Identify gaps. Create a learning plan for each gap with specific resources and timelines.',
    evidence: 'Career development research shows structured skill-building is 3x more effective than unstructured learning. 100 focused hours puts you ahead of 95% in any new field.',
    coachFluxApproach: 'CareerPilot conducts a strategic skill assessment and creates a 90-day learning sprint tailored to your career goals.',
    duration: '15 min',
    difficulty: 'Medium',
    effectiveness: '82%',
    color: Color(0xFFF59E0B),
  ),
  'Networking Challenge': const _TechniqueInfo(
    emoji: '🤝',
    description: 'Structured networking: reach out to 1 new person per week, attend 1 event per month, follow up within 48 hours. Build relationships before you need them.',
    evidence: '85% of jobs are filled through networking. 30 informational interviews teach more than 30 hours of research about a career path.',
    coachFluxApproach: 'SocialSpark gives you scripts and confidence for outreach. CareerPilot helps you target the RIGHT people strategically.',
    duration: '15 min/week',
    difficulty: 'Medium',
    effectiveness: '78%',
    color: Color(0xFFF97316),
  ),
  '50/30/20 Budget': const _TechniqueInfo(
    emoji: '💰',
    description: '50% of income to needs (rent, food, bills), 30% to wants (entertainment, dining), 20% to savings/debt. Simple, effective, and flexible.',
    evidence: 'Elizabeth Warren\'s budgeting framework. Simple enough to follow consistently, which is more important than a "perfect" budget you abandon after a week.',
    coachFluxApproach: 'MoneyMind helps you categorize your spending and find where to optimize. We focus on making the system automatic — savings happen BEFORE you see the money.',
    duration: '10 min setup',
    difficulty: 'Easy',
    effectiveness: '85%',
    color: Color(0xFF22C55E),
  ),
  'No-Spend Challenge': const _TechniqueInfo(
    emoji: '🚫',
    description: 'Choose a time period (1 day, 1 week) and spend only on true necessities. This resets your spending habits and builds awareness of impulse purchases.',
    evidence: 'Research shows a "spending fast" reduces overall monthly spending by 15-25% in the following month due to increased awareness.',
    coachFluxApproach: 'MoneyMind supports you through the challenge with daily check-ins. When you feel the urge to spend, Dr. Aura helps you explore what emotion you\'re trying to fill.',
    duration: '1-7 days',
    difficulty: 'Hard',
    effectiveness: '80%',
    color: Color(0xFF22C55E),
  ),
  'Savings Goal Visualizer': const _TechniqueInfo(
    emoji: '🎯',
    description: 'Set a specific savings target with a visual tracker. Seeing progress toward a concrete goal leverages the brain\'s reward system to maintain motivation.',
    evidence: 'Behavioral economics shows that making future rewards visible and concrete counteracts present bias and temporal discounting.',
    coachFluxApproach: 'MoneyMind helps you set a meaningful savings goal, then we visualize your progress. Celebrating milestones releases dopamine for the RIGHT reasons.',
    duration: '5 min setup',
    difficulty: 'Easy',
    effectiveness: '75%',
    color: Color(0xFF22C55E),
  ),
  'Desk Stretches': const _TechniqueInfo(
    emoji: '🤸',
    description: 'A series of stretches you can do at your desk: neck rolls, shoulder shrugs, wrist circles, seated twists, hip flexor stretches. Your body is not designed for chairs.',
    evidence: 'Research shows movement breaks every 45-60 minutes reduce musculoskeletal pain by 40% and improve cognitive performance.',
    coachFluxApproach: 'IronWill reminds you to move and guides you through quick desk stretches. We call them "movement snacks" — small but powerful.',
    duration: '3 min',
    difficulty: 'Easy',
    effectiveness: '78%',
    color: Color(0xFFEF4444),
  ),
};
