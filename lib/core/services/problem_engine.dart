import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// PROBLEM ENGINE — CoachFlux Problem Detection & Solution Mapping
// ═══════════════════════════════════════════════════════════════

enum ProblemCategory {
  anxiety,
  depression,
  stress,
  relationships,
  selfEsteem,
  anger,
  sleep,
  addiction,
  trauma,
  purpose,
  procrastination,
  financial,
  career,
  bodyImage,
  grief,
}

// ── Severity from assessment ──
enum ProblemSeverity { mild, moderate, severe }

// ── Assessment question types ──
enum QuestionType { frequency, duration, impact, custom }

class AssessmentQuestion {
  final String text;
  final QuestionType type;
  final List<String> options;

  const AssessmentQuestion({
    required this.text,
    required this.type,
    required this.options,
  });
}

class CoachRecommendation {
  final String coachId;
  final String role; // primary, support, specialist
  final String reason;

  const CoachRecommendation({
    required this.coachId,
    required this.role,
    required this.reason,
  });
}

class TechniqueRecommendation {
  final String name;
  final String reason;

  const TechniqueRecommendation({required this.name, required this.reason});
}

class MicroAction {
  final String time; // morning, afternoon, evening
  final String action;

  const MicroAction({required this.time, required this.action});
}

class ProblemDefinition {
  final ProblemCategory category;
  final String emoji;
  final String title;
  final String subtitle;
  final List<String> rootCauses;
  final List<AssessmentQuestion> questions;
  final List<CoachRecommendation> coaches;
  final List<TechniqueRecommendation> techniques;
  final List<MicroAction> microActions;
  final String timeline;
  final String uniqueApproach;
  final Color accentColor;

  const ProblemDefinition({
    required this.category,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.rootCauses,
    required this.questions,
    required this.coaches,
    required this.techniques,
    required this.microActions,
    required this.timeline,
    required this.uniqueApproach,
    required this.accentColor,
  });
}

// ── Assessment Result ──
class ProblemAssessmentResult {
  final ProblemCategory category;
  final Map<String, String> answers; // question → answer
  final int impactScore; // 1-10
  final ProblemSeverity severity;

  const ProblemAssessmentResult({
    required this.category,
    required this.answers,
    required this.impactScore,
    required this.severity,
  });
}

class UserAssessment {
  final List<ProblemAssessmentResult> results;
  final DateTime completedAt;

  const UserAssessment({required this.results, required this.completedAt});

  ProblemAssessmentResult? get primaryProblem =>
      results.isEmpty ? null : results.first;
}

// ═══════════════════════════════════════════════════════
// ALL 15 PROBLEM DEFINITIONS
// ═══════════════════════════════════════════════════════

final List<ProblemDefinition> allProblems = [
  // ── 1. ANXIETY ──
  ProblemDefinition(
    category: ProblemCategory.anxiety,
    emoji: '😰',
    title: 'Anxiety',
    subtitle: 'Worry, panic, restlessness',
    accentColor: const Color(0xFF7C3AED),
    rootCauses: [
      'Cognitive distortions (catastrophizing, mind reading)',
      'Avoidance patterns reinforcing fear',
      'Nervous system dysregulation',
      'Unresolved uncertainty intolerance',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'How often do you feel anxious or worried?',
        type: QuestionType.frequency,
        options: ['Rarely', 'Sometimes', 'Often', 'Almost always'],
      ),
      const AssessmentQuestion(
        text: 'How long have you been experiencing anxiety?',
        type: QuestionType.duration,
        options: ['A few days', 'Weeks', 'Months', 'Years'],
      ),
      const AssessmentQuestion(
        text: 'Do you experience physical symptoms (racing heart, sweating, tension)?',
        type: QuestionType.custom,
        options: ['Never', 'Sometimes', 'Often', 'Constantly'],
      ),
      const AssessmentQuestion(
        text: 'Do you avoid situations because of anxiety?',
        type: QuestionType.custom,
        options: ['Not at all', 'A little', 'Quite a bit', 'Almost everything'],
      ),
      const AssessmentQuestion(
        text: 'Does anxiety affect your sleep?',
        type: QuestionType.custom,
        options: ['No', 'Sometimes', 'Most nights', 'Every night'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'dr-aura',
        role: 'primary',
        reason: 'CBT cognitive restructuring & exposure techniques',
      ),
      const CoachRecommendation(
        coachId: 'zen-mind',
        role: 'support',
        reason: 'Box breathing, body scan & nervous system regulation',
      ),
      const CoachRecommendation(
        coachId: 'sleep-whisperer',
        role: 'specialist',
        reason: 'Sleep hygiene & CBT-I if sleep is affected',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: 'Box Breathing', reason: 'Activates parasympathetic system in 4 min'),
      const TechniqueRecommendation(name: '5-4-3-2-1 Grounding', reason: 'Breaks anxious thought loops instantly'),
      const TechniqueRecommendation(name: 'Progressive Muscle Relaxation', reason: 'Releases stored physical tension'),
      const TechniqueRecommendation(name: 'Body Scan Meditation', reason: 'Builds interoceptive awareness'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: '3-minute box breathing before starting the day'),
      const MicroAction(time: 'afternoon', action: 'One grounding exercise when anxiety peaks'),
      const MicroAction(time: 'evening', action: 'Write 3 worries and rate them 1-10 — track patterns'),
    ],
    timeline: 'Most users report 40% anxiety reduction within 3 weeks of consistent practice',
    uniqueApproach: 'We treat anxiety not as an enemy to defeat, but as a signal to understand. Your team: Dr. Aura decodes the thought patterns, ZenMind calms your nervous system, and DreamGuard fixes your sleep.',
  ),

  // ── 2. DEPRESSION ──
  ProblemDefinition(
    category: ProblemCategory.depression,
    emoji: '🌧️',
    title: 'Depression',
    subtitle: 'Low mood, hopelessness, loss of interest',
    accentColor: const Color(0xFF6366F1),
    rootCauses: [
      'Negative cognitive triad (self, world, future)',
      'Behavioral withdrawal reducing positive reinforcement',
      'Learned helplessness patterns',
      'Unprocessed grief or loss',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'How often do you feel sad or empty?',
        type: QuestionType.frequency,
        options: ['Rarely', 'Sometimes', 'Often', 'Almost always'],
      ),
      const AssessmentQuestion(
        text: 'Have you lost interest in things you used to enjoy?',
        type: QuestionType.custom,
        options: ['Not really', 'A little', 'Quite a bit', 'Completely'],
      ),
      const AssessmentQuestion(
        text: 'How is your energy level?',
        type: QuestionType.custom,
        options: ['Good', 'Low sometimes', 'Usually low', 'Exhausted constantly'],
      ),
      const AssessmentQuestion(
        text: 'Do you feel hopeless about the future?',
        type: QuestionType.custom,
        options: ['Never', 'Sometimes', 'Often', 'Most of the time'],
      ),
      const AssessmentQuestion(
        text: 'How long have you been feeling this way?',
        type: QuestionType.duration,
        options: ['A few days', 'Weeks', 'Months', 'Years'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'dr-aura',
        role: 'primary',
        reason: 'Behavioral activation & cognitive restructuring',
      ),
      const CoachRecommendation(
        coachId: 'iron-will',
        role: 'support',
        reason: 'Exercise as medicine — movement breaks the cycle',
      ),
      const CoachRecommendation(
        coachId: 'stoic-sage',
        role: 'support',
        reason: 'Meaning-making and philosophical resilience',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: 'Walking Meditation', reason: 'Gentle movement + mindfulness combo'),
      const TechniqueRecommendation(name: '7-Minute Workout', reason: 'Low-barrier exercise to boost BDNF'),
      const TechniqueRecommendation(name: 'Body Scan Meditation', reason: 'Reconnects you with your body'),
      const TechniqueRecommendation(name: 'SMART Goal Framework', reason: 'Micro-goals rebuild sense of agency'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: '5-minute walk outside — sunlight resets circadian rhythm'),
      const MicroAction(time: 'afternoon', action: 'Do ONE small thing you used to enjoy (even for 5 min)'),
      const MicroAction(time: 'evening', action: 'Write 1 thing that went okay today — no matter how small'),
    ],
    timeline: 'Behavioral activation shows effects in 2-3 weeks. Consistent practice builds momentum.',
    uniqueApproach: 'We don\'t tell you to "just think positive." We help you move your body, challenge thought patterns, and find micro-moments of meaning. Small steps, real progress.',
  ),

  // ── 3. STRESS ──
  ProblemDefinition(
    category: ProblemCategory.stress,
    emoji: '🔥',
    title: 'Stress',
    subtitle: 'Overwhelm, burnout, pressure',
    accentColor: const Color(0xFFEF4444),
    rootCauses: [
      'Chronic overcommitment and poor boundaries',
      'Sympathetic nervous system overdrive',
      'Lack of recovery periods',
      'Perfectionism and control needs',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'What is your main source of stress?',
        type: QuestionType.custom,
        options: ['Work', 'Relationships', 'Financial', 'Health', 'Everything'],
      ),
      const AssessmentQuestion(
        text: 'How often do you feel overwhelmed?',
        type: QuestionType.frequency,
        options: ['Rarely', 'Sometimes', 'Often', 'Constantly'],
      ),
      const AssessmentQuestion(
        text: 'Can you relax when you have free time?',
        type: QuestionType.custom,
        options: ['Yes, easily', 'Usually', 'Struggle to', 'Never'],
      ),
      const AssessmentQuestion(
        text: 'How is stress affecting your body?',
        type: QuestionType.custom,
        options: ['No symptoms', 'Mild tension', 'Headaches/pain', 'Multiple symptoms'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'zen-mind',
        role: 'primary',
        reason: 'MBSR protocol & nervous system regulation',
      ),
      const CoachRecommendation(
        coachId: 'system-builder',
        role: 'support',
        reason: 'Systems to eliminate chaos and overwhelm',
      ),
      const CoachRecommendation(
        coachId: 'flow-master',
        role: 'support',
        reason: 'Focus and time management to reduce load',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: 'Box Breathing', reason: 'Instant stress relief in 4 minutes'),
      const TechniqueRecommendation(name: 'Progressive Muscle Relaxation', reason: 'Release physical stress tension'),
      const TechniqueRecommendation(name: 'Time Blocking', reason: 'Structure reduces decision fatigue'),
      const TechniqueRecommendation(name: 'Weekly Review', reason: 'Prevent stress from building up'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'Write your TOP 3 priorities — nothing else matters today'),
      const MicroAction(time: 'afternoon', action: '5-min breathing break between tasks'),
      const MicroAction(time: 'evening', action: 'Brain dump: write everything on your mind, then close the notebook'),
    ],
    timeline: 'Stress management tools show immediate relief. Systemic changes take 2-4 weeks to stabilize.',
    uniqueApproach: 'We attack stress from both sides: ZenMind calms your nervous system NOW, while SystemBuilder and FlowState redesign your life to prevent stress from building up.',
  ),

  // ── 4. RELATIONSHIPS ──
  ProblemDefinition(
    category: ProblemCategory.relationships,
    emoji: '💔',
    title: 'Relationships',
    subtitle: 'Connection, trust, loneliness',
    accentColor: const Color(0xFFF97316),
    rootCauses: [
      'Insecure attachment patterns from childhood',
      'Poor communication skills or avoidance',
      'Unmet emotional needs and unspoken expectations',
      'Fear of vulnerability or abandonment',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'What relationship area concerns you most?',
        type: QuestionType.custom,
        options: ['Romantic', 'Family', 'Friendships', 'Loneliness', 'Trust issues'],
      ),
      const AssessmentQuestion(
        text: 'Do you find it hard to express your needs?',
        type: QuestionType.custom,
        options: ['Not at all', 'Sometimes', 'Often', 'Always'],
      ),
      const AssessmentQuestion(
        text: 'How do you handle conflict?',
        type: QuestionType.custom,
        options: ['Discuss calmly', 'Avoid it', 'Get defensive', 'Shut down'],
      ),
      const AssessmentQuestion(
        text: 'Do you feel emotionally connected to people in your life?',
        type: QuestionType.custom,
        options: ['Very much', 'Somewhat', 'Not really', 'Feel isolated'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'dr-aura',
        role: 'primary',
        reason: 'Attachment patterns & emotional regulation',
      ),
      const CoachRecommendation(
        coachId: 'social-spark',
        role: 'support',
        reason: 'NVC communication & assertiveness skills',
      ),
      const CoachRecommendation(
        coachId: 'stoic-sage',
        role: 'support',
        reason: 'Perspective on expectations and acceptance',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: 'Body Scan Meditation', reason: 'Feel your emotions instead of reacting'),
      const TechniqueRecommendation(name: 'Walking Meditation', reason: 'Reflection time for processing feelings'),
      const TechniqueRecommendation(name: 'SMART Goal Framework', reason: 'Set concrete relationship goals'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'Send one genuine message to someone you care about'),
      const MicroAction(time: 'afternoon', action: 'Practice one NVC observation instead of judgment'),
      const MicroAction(time: 'evening', action: 'Reflect: "What did I need today that I didn\'t ask for?"'),
    ],
    timeline: 'Communication skills improve noticeably in 2-3 weeks. Deeper attachment work takes months.',
    uniqueApproach: 'We help you understand YOUR patterns first, then give you concrete communication tools. Dr. Aura maps your attachment style, SocialSpark teaches you the words.',
  ),

  // ── 5. SELF-ESTEEM ──
  ProblemDefinition(
    category: ProblemCategory.selfEsteem,
    emoji: '🪞',
    title: 'Self-Esteem',
    subtitle: 'Self-doubt, imposter syndrome',
    accentColor: const Color(0xFFEC4899),
    rootCauses: [
      'Defectiveness/shame schema from early experiences',
      'Chronic comparison and social media impact',
      'Imposter syndrome and discounting achievements',
      'Perfectionism masking fear of inadequacy',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'How would you rate your self-confidence?',
        type: QuestionType.custom,
        options: ['Very low', 'Low', 'Moderate', 'Fluctuates a lot'],
      ),
      const AssessmentQuestion(
        text: 'Do you feel like a fraud despite your achievements?',
        type: QuestionType.custom,
        options: ['Never', 'Sometimes', 'Often', 'Constantly'],
      ),
      const AssessmentQuestion(
        text: 'How much do you compare yourself to others?',
        type: QuestionType.custom,
        options: ['Rarely', 'Sometimes', 'Often', 'Obsessively'],
      ),
      const AssessmentQuestion(
        text: 'Can you accept compliments easily?',
        type: QuestionType.custom,
        options: ['Yes', 'Sometimes', 'I deflect them', 'I don\'t believe them'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'dr-aura',
        role: 'primary',
        reason: 'Schema therapy & cognitive restructuring for self-worth',
      ),
      const CoachRecommendation(
        coachId: 'social-spark',
        role: 'support',
        reason: 'Confidence building through social skills',
      ),
      const CoachRecommendation(
        coachId: 'muse',
        role: 'support',
        reason: 'Self-expression and creative identity',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: 'Body Scan Meditation', reason: 'Develop self-compassion through body awareness'),
      const TechniqueRecommendation(name: 'SMART Goal Framework', reason: 'Build evidence of competence through achievements'),
      const TechniqueRecommendation(name: 'Walking Meditation', reason: 'Mindful self-reflection without judgment'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'Write 1 thing you genuinely like about yourself'),
      const MicroAction(time: 'afternoon', action: 'Notice one comparison thought — label it and let it go'),
      const MicroAction(time: 'evening', action: 'Record 1 achievement today, no matter how small'),
    ],
    timeline: 'Self-esteem shifts in 3-4 weeks with daily practice. Deep schema work is ongoing.',
    uniqueApproach: 'We don\'t just say "love yourself." We help you find EVIDENCE of your worth, challenge the inner critic with data, and build confidence through real action.',
  ),

  // ── 6. ANGER ──
  ProblemDefinition(
    category: ProblemCategory.anger,
    emoji: '😤',
    title: 'Anger',
    subtitle: 'Frustration, rage, irritability',
    accentColor: const Color(0xFFDC2626),
    rootCauses: [
      'Unmet needs expressed as frustration',
      'Poor emotional regulation skills',
      'Boundary violations without assertive response',
      'Learned anger patterns from environment',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'How often do you feel angry or irritable?',
        type: QuestionType.frequency,
        options: ['Rarely', 'Sometimes', 'Often', 'Daily'],
      ),
      const AssessmentQuestion(
        text: 'What happens when you get angry?',
        type: QuestionType.custom,
        options: ['I stay calm', 'I get tense', 'I lash out', 'I shut down'],
      ),
      const AssessmentQuestion(
        text: 'Do you regret things you say or do when angry?',
        type: QuestionType.custom,
        options: ['Never', 'Sometimes', 'Often', 'Almost always'],
      ),
      const AssessmentQuestion(
        text: 'Is your anger affecting your relationships?',
        type: QuestionType.custom,
        options: ['Not at all', 'A little', 'Significantly', 'Destroying them'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'dr-aura',
        role: 'primary',
        reason: 'DBT emotion regulation & anger management',
      ),
      const CoachRecommendation(
        coachId: 'zen-mind',
        role: 'support',
        reason: 'Mindfulness to create space between trigger and response',
      ),
      const CoachRecommendation(
        coachId: 'stoic-sage',
        role: 'support',
        reason: 'Seneca\'s wisdom on anger and self-mastery',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: 'Box Breathing', reason: 'Cool down in the heat of the moment'),
      const TechniqueRecommendation(name: '5-4-3-2-1 Grounding', reason: 'Interrupt the anger escalation'),
      const TechniqueRecommendation(name: 'Progressive Muscle Relaxation', reason: 'Release physical anger tension'),
      const TechniqueRecommendation(name: 'Walking Meditation', reason: 'Channel anger into mindful movement'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'Set intention: "Today I pause before reacting"'),
      const MicroAction(time: 'afternoon', action: 'When triggered, take 3 breaths before speaking'),
      const MicroAction(time: 'evening', action: 'Journal: "What need was behind my anger today?"'),
    ],
    timeline: 'Most users gain a meaningful pause before reacting within 2 weeks.',
    uniqueApproach: 'Anger isn\'t bad — it\'s information. We help you decode what your anger is telling you, then give you tools to express it constructively.',
  ),

  // ── 7. SLEEP ──
  ProblemDefinition(
    category: ProblemCategory.sleep,
    emoji: '😴',
    title: 'Sleep',
    subtitle: 'Insomnia, poor sleep quality',
    accentColor: const Color(0xFF6366F1),
    rootCauses: [
      'Circadian rhythm disruption from screens/schedule',
      'Racing mind and rumination at bedtime',
      'Poor sleep hygiene habits',
      'Anxiety or stress spillover into nighttime',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'How long does it take you to fall asleep?',
        type: QuestionType.custom,
        options: ['Under 15 min', '15-30 min', '30-60 min', 'Over an hour'],
      ),
      const AssessmentQuestion(
        text: 'Do you wake up during the night?',
        type: QuestionType.custom,
        options: ['Rarely', 'Once', '2-3 times', 'Many times'],
      ),
      const AssessmentQuestion(
        text: 'How do you feel when you wake up?',
        type: QuestionType.custom,
        options: ['Refreshed', 'Okay', 'Still tired', 'Exhausted'],
      ),
      const AssessmentQuestion(
        text: 'Do you use screens within 1 hour of bed?',
        type: QuestionType.custom,
        options: ['Never', 'Sometimes', 'Usually', 'Always'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'sleep-whisperer',
        role: 'primary',
        reason: 'CBT-I protocol & sleep science expertise',
      ),
      const CoachRecommendation(
        coachId: 'zen-mind',
        role: 'support',
        reason: 'Body scan & breathing for pre-sleep relaxation',
      ),
      const CoachRecommendation(
        coachId: 'dr-aura',
        role: 'specialist',
        reason: 'Address anxiety/rumination keeping you awake',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: 'Progressive Muscle Relaxation', reason: 'Physical relaxation before bed'),
      const TechniqueRecommendation(name: 'Body Scan Meditation', reason: 'Shift from thinking to feeling — induces drowsiness'),
      const TechniqueRecommendation(name: 'Box Breathing', reason: '4-7-8 variation specifically for sleep'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'Get 10 min of sunlight within 30 min of waking'),
      const MicroAction(time: 'afternoon', action: 'No caffeine after 2 PM'),
      const MicroAction(time: 'evening', action: '3-2-1 rule: no food 3h, no liquids 2h, no screens 1h before bed'),
    ],
    timeline: 'Sleep hygiene changes show results in 1-2 weeks. Full CBT-I takes 4-6 weeks.',
    uniqueApproach: 'We don\'t just say "sleep more." DreamGuard rebuilds your sleep architecture scientifically, ZenMind quiets the racing mind, and we track your progress nightly.',
  ),

  // ── 8. ADDICTION ──
  ProblemDefinition(
    category: ProblemCategory.addiction,
    emoji: '🔗',
    title: 'Addiction',
    subtitle: 'Phone, social media, compulsive habits',
    accentColor: const Color(0xFFF59E0B),
    rootCauses: [
      'Dopamine dysregulation from variable reward schedules',
      'Emotional avoidance — numbing instead of feeling',
      'Lack of meaningful alternatives',
      'Social isolation or boredom',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'What do you feel addicted to?',
        type: QuestionType.custom,
        options: ['Phone/social media', 'Substances', 'Gambling', 'Shopping', 'Other'],
      ),
      const AssessmentQuestion(
        text: 'Have you tried to stop or reduce and failed?',
        type: QuestionType.custom,
        options: ['Haven\'t tried', 'Once or twice', 'Multiple times', 'Many times'],
      ),
      const AssessmentQuestion(
        text: 'How much time/money does it consume?',
        type: QuestionType.custom,
        options: ['A little', 'Noticeable', 'Significant', 'Overwhelming'],
      ),
      const AssessmentQuestion(
        text: 'Do you use it to escape negative emotions?',
        type: QuestionType.custom,
        options: ['No', 'Sometimes', 'Usually', 'Always'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'dr-aura',
        role: 'primary',
        reason: 'Motivational interviewing & emotional root cause work',
      ),
      const CoachRecommendation(
        coachId: 'flow-master',
        role: 'support',
        reason: 'Replace dopamine hits with deep work flow states',
      ),
      const CoachRecommendation(
        coachId: 'iron-will',
        role: 'support',
        reason: 'Physical activity as healthy dopamine source',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: '5-4-3-2-1 Grounding', reason: 'Interrupt craving loops'),
      const TechniqueRecommendation(name: 'Pomodoro Technique', reason: 'Structured focus replaces endless scrolling'),
      const TechniqueRecommendation(name: 'Deep Work Protocol', reason: 'Replace dopamine hits with flow'),
      const TechniqueRecommendation(name: 'Box Breathing', reason: 'Manage urges through body regulation'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'First 30 min screen-free — build a new morning ritual'),
      const MicroAction(time: 'afternoon', action: 'When urge hits: 5-4-3-2-1 grounding, then wait 10 min'),
      const MicroAction(time: 'evening', action: 'Track: "What was I feeling right before the urge?"'),
    ],
    timeline: 'Habit interruption visible in 1-2 weeks. Rewiring takes 4-8 weeks of consistent practice.',
    uniqueApproach: 'We don\'t shame you. We help you understand what your brain is REALLY looking for, then redirect that energy toward healthier rewards.',
  ),

  // ── 9. TRAUMA ──
  ProblemDefinition(
    category: ProblemCategory.trauma,
    emoji: '🫂',
    title: 'Trauma',
    subtitle: 'Past wounds, PTSD symptoms',
    accentColor: const Color(0xFF8B5CF6),
    rootCauses: [
      'Unprocessed traumatic memories stored in body/nervous system',
      'Hypervigilance and threat detection',
      'Avoidance patterns limiting life',
      'Dissociation or emotional numbing',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'Do past events still affect your daily life?',
        type: QuestionType.custom,
        options: ['Not much', 'Sometimes', 'Often', 'Constantly'],
      ),
      const AssessmentQuestion(
        text: 'Do you experience flashbacks or intrusive memories?',
        type: QuestionType.custom,
        options: ['Never', 'Rarely', 'Sometimes', 'Frequently'],
      ),
      const AssessmentQuestion(
        text: 'Do you feel on edge or easily startled?',
        type: QuestionType.custom,
        options: ['No', 'A little', 'Often', 'Always'],
      ),
      const AssessmentQuestion(
        text: 'Do you avoid places, people, or topics that remind you?',
        type: QuestionType.custom,
        options: ['Not at all', 'A little', 'Quite a bit', 'Extensively'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'dr-aura',
        role: 'primary',
        reason: 'Trauma-informed support with IFS & ACT approaches',
      ),
      const CoachRecommendation(
        coachId: 'zen-mind',
        role: 'support',
        reason: 'Polyvagal regulation & grounding for safety',
      ),
      const CoachRecommendation(
        coachId: 'stoic-sage',
        role: 'support',
        reason: 'Meaning-making and post-traumatic growth',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: '5-4-3-2-1 Grounding', reason: 'Anchor to present when triggered'),
      const TechniqueRecommendation(name: 'Box Breathing', reason: 'Regulate nervous system activation'),
      const TechniqueRecommendation(name: 'Body Scan Meditation', reason: 'Gently reconnect with body safely'),
      const TechniqueRecommendation(name: 'Progressive Muscle Relaxation', reason: 'Release trauma-held tension'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'Grounding: feel your feet on the floor for 1 minute'),
      const MicroAction(time: 'afternoon', action: 'If triggered, use 5-4-3-2-1 to come back to now'),
      const MicroAction(time: 'evening', action: 'Write one safe, positive memory — build your "safety file"'),
    ],
    timeline: 'Grounding tools work immediately. Trauma processing is a longer journey — we walk it with you.',
    uniqueApproach: 'We go slowly. We prioritize SAFETY above everything. Dr. Aura creates a safe space, ZenMind regulates your nervous system. We never push faster than you\'re ready. ⚠️ For severe trauma, we strongly recommend working with a human therapist alongside CoachFlux.',
  ),

  // ── 10. PURPOSE ──
  ProblemDefinition(
    category: ProblemCategory.purpose,
    emoji: '🧭',
    title: 'Purpose',
    subtitle: 'Meaninglessness, lost direction',
    accentColor: const Color(0xFF0EA5E9),
    rootCauses: [
      'Disconnection from personal values',
      'Living by others\' expectations instead of own',
      'Existential questioning after major life transition',
      'Success without fulfillment',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'Do you feel a sense of purpose in your daily life?',
        type: QuestionType.custom,
        options: ['Strong purpose', 'Some purpose', 'Very little', 'None at all'],
      ),
      const AssessmentQuestion(
        text: 'Are you living by your own values or others\' expectations?',
        type: QuestionType.custom,
        options: ['My own values', 'Mostly mine', 'Mostly others\'', 'Completely others\''],
      ),
      const AssessmentQuestion(
        text: 'How long have you felt directionless?',
        type: QuestionType.duration,
        options: ['A few days', 'Weeks', 'Months', 'Years'],
      ),
      const AssessmentQuestion(
        text: 'What triggered this feeling?',
        type: QuestionType.custom,
        options: ['Life transition', 'Achievement that felt empty', 'Gradual', 'Don\'t know'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'stoic-sage',
        role: 'primary',
        reason: 'Existential wisdom & values clarification',
      ),
      const CoachRecommendation(
        coachId: 'career-pilot',
        role: 'support',
        reason: 'IKIGAI framework & career purpose alignment',
      ),
      const CoachRecommendation(
        coachId: 'muse',
        role: 'support',
        reason: 'Creative exploration to discover passions',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: 'SMART Goal Framework', reason: 'Turn vague purpose into concrete experiments'),
      const TechniqueRecommendation(name: 'Walking Meditation', reason: 'Reflective thinking for clarity'),
      const TechniqueRecommendation(name: 'Energy Audit', reason: 'Discover what energizes vs. drains you'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'Ask: "What would make today meaningful?"'),
      const MicroAction(time: 'afternoon', action: 'Try one new activity or conversation — explore'),
      const MicroAction(time: 'evening', action: 'Write: "Today I felt most alive when..."'),
    ],
    timeline: 'Values clarity emerges in 2-3 weeks. Purpose unfolds over months of exploration.',
    uniqueApproach: 'We don\'t hand you a purpose — we help you DISCOVER it. StoicSage asks the deep questions, CareerPilot maps your strengths, Muse unlocks what excites you.',
  ),

  // ── 11. PROCRASTINATION ──
  ProblemDefinition(
    category: ProblemCategory.procrastination,
    emoji: '⏰',
    title: 'Procrastination',
    subtitle: 'Delaying, avoiding, struggling to start',
    accentColor: const Color(0xFF3B82F6),
    rootCauses: [
      'Fear of failure disguised as laziness',
      'Perfectionism — "if I can\'t do it perfectly, why start?"',
      'Temporal discounting — future feels unreal',
      'Task aversion and emotional avoidance',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'How often do you delay important tasks?',
        type: QuestionType.frequency,
        options: ['Rarely', 'Sometimes', 'Often', 'Almost everything'],
      ),
      const AssessmentQuestion(
        text: 'What do you do instead of the task?',
        type: QuestionType.custom,
        options: ['Social media', 'Easy tasks', 'Nothing', 'Other distractions'],
      ),
      const AssessmentQuestion(
        text: 'Why do you think you procrastinate?',
        type: QuestionType.custom,
        options: ['Fear of failure', 'Overwhelmed', 'Bored', 'Perfectionism', 'Don\'t know'],
      ),
      const AssessmentQuestion(
        text: 'How much does procrastination cost you?',
        type: QuestionType.custom,
        options: ['Minor inconvenience', 'Missed opportunities', 'Serious consequences', 'Life-altering'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'flow-master',
        role: 'primary',
        reason: 'Implementation intentions & deep work protocols',
      ),
      const CoachRecommendation(
        coachId: 'dr-aura',
        role: 'support',
        reason: 'Address the emotional root — fear, perfectionism',
      ),
      const CoachRecommendation(
        coachId: 'system-builder',
        role: 'support',
        reason: 'Build systems that make starting automatic',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: 'Pomodoro Technique', reason: '25 min is small enough to start'),
      const TechniqueRecommendation(name: '2-Minute Rule', reason: 'Start so small you can\'t say no'),
      const TechniqueRecommendation(name: 'Time Blocking', reason: 'Remove the "when" decision'),
      const TechniqueRecommendation(name: 'Deep Work Protocol', reason: 'Create conditions for real focus'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'Pick your ONE most important task. Do 5 min on it FIRST.'),
      const MicroAction(time: 'afternoon', action: 'When resisting: "What am I feeling right now?" Name it.'),
      const MicroAction(time: 'evening', action: 'Prepare tomorrow\'s workspace — reduce starting friction'),
    ],
    timeline: '2-minute rule shows results on day 1. Building consistent habits takes 3-4 weeks.',
    uniqueApproach: 'Procrastination isn\'t laziness — it\'s emotion management. We fix the FEELING first (Dr. Aura), then build the SYSTEM (FlowState + SystemBuilder).',
  ),

  // ── 12. FINANCIAL ──
  ProblemDefinition(
    category: ProblemCategory.financial,
    emoji: '💸',
    title: 'Financial Stress',
    subtitle: 'Money worries, debt, saving struggles',
    accentColor: const Color(0xFF22C55E),
    rootCauses: [
      'Money scripts from childhood shaping behavior',
      'Emotional spending as coping mechanism',
      'Lack of financial literacy and systems',
      'Present bias — prioritizing now over future',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'What is your main financial concern?',
        type: QuestionType.custom,
        options: ['Debt', 'Can\'t save', 'Overspending', 'Income too low', 'No plan'],
      ),
      const AssessmentQuestion(
        text: 'How often do you worry about money?',
        type: QuestionType.frequency,
        options: ['Rarely', 'Sometimes', 'Often', 'Constantly'],
      ),
      const AssessmentQuestion(
        text: 'Do you spend emotionally (when stressed, bored, sad)?',
        type: QuestionType.custom,
        options: ['Never', 'Sometimes', 'Often', 'It\'s my main coping'],
      ),
      const AssessmentQuestion(
        text: 'Do you have a budget or financial system?',
        type: QuestionType.custom,
        options: ['Yes, detailed', 'Basic one', 'Tried but failed', 'No system'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'money-mind',
        role: 'primary',
        reason: 'Behavioral economics & money psychology',
      ),
      const CoachRecommendation(
        coachId: 'system-builder',
        role: 'support',
        reason: 'Build automated financial systems',
      ),
      const CoachRecommendation(
        coachId: 'dr-aura',
        role: 'specialist',
        reason: 'Address emotional spending and money scripts',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: '50/30/20 Budget', reason: 'Simple framework to organize spending'),
      const TechniqueRecommendation(name: 'No-Spend Challenge', reason: 'Break emotional spending patterns'),
      const TechniqueRecommendation(name: 'Savings Goal Visualizer', reason: 'Make future rewards feel real NOW'),
      const TechniqueRecommendation(name: 'SMART Goal Framework', reason: 'Set concrete financial milestones'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'Check: "Is today a need-spend or want-spend day?"'),
      const MicroAction(time: 'afternoon', action: 'Before buying: wait 24 hours on anything over \$20'),
      const MicroAction(time: 'evening', action: 'Log today\'s spending — awareness is the first step'),
    ],
    timeline: 'Spending awareness in 1 week. Budget habits solidify in 4-6 weeks.',
    uniqueApproach: 'Money problems are usually EMOTION problems. MoneyMind teaches the numbers, Dr. Aura heals the feelings, SystemBuilder automates the solutions.',
  ),

  // ── 13. CAREER ──
  ProblemDefinition(
    category: ProblemCategory.career,
    emoji: '💼',
    title: 'Career',
    subtitle: 'Burnout, dissatisfaction, stuck',
    accentColor: const Color(0xFFF59E0B),
    rootCauses: [
      'Misalignment between values and work',
      'Burnout from chronic overwork without recovery',
      'Imposter syndrome limiting growth',
      'Fear of change keeping you stuck',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'What\'s your main career concern?',
        type: QuestionType.custom,
        options: ['Burnout', 'Want to change', 'Feel stuck', 'Undervalued', 'No direction'],
      ),
      const AssessmentQuestion(
        text: 'How satisfied are you with your current work?',
        type: QuestionType.custom,
        options: ['Very satisfied', 'Somewhat', 'Dissatisfied', 'Miserable'],
      ),
      const AssessmentQuestion(
        text: 'Do you dread going to work?',
        type: QuestionType.frequency,
        options: ['Never', 'Sometimes', 'Most days', 'Every day'],
      ),
      const AssessmentQuestion(
        text: 'What\'s stopping you from making a change?',
        type: QuestionType.custom,
        options: ['Financial fear', 'Don\'t know what else', 'Lack of skills', 'Fear of failure'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'career-pilot',
        role: 'primary',
        reason: 'Career strategy, pivots & negotiation',
      ),
      const CoachRecommendation(
        coachId: 'flow-master',
        role: 'support',
        reason: 'Prevent burnout with focus management',
      ),
      const CoachRecommendation(
        coachId: 'stoic-sage',
        role: 'support',
        reason: 'Courage and clarity for career decisions',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: 'SMART Goal Framework', reason: 'Concrete 90-day career sprint'),
      const TechniqueRecommendation(name: 'Skill Gap Analysis', reason: 'Map what you need to learn'),
      const TechniqueRecommendation(name: 'Networking Challenge', reason: 'Build connections strategically'),
      const TechniqueRecommendation(name: 'Energy Audit', reason: 'Find what energizes you at work'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'Ask: "What would make today\'s work meaningful?"'),
      const MicroAction(time: 'afternoon', action: 'Spend 15 min on a career-growth activity'),
      const MicroAction(time: 'evening', action: 'Reflect: "What did I learn today? What drained me?"'),
    ],
    timeline: 'Career clarity in 2-3 weeks. Pivot execution takes 2-6 months with a plan.',
    uniqueApproach: 'CareerPilot builds the strategy, FlowState prevents burnout, StoicSage gives you the courage. We plan, execute, and iterate.',
  ),

  // ── 14. BODY IMAGE ──
  ProblemDefinition(
    category: ProblemCategory.bodyImage,
    emoji: '🪷',
    title: 'Body Image',
    subtitle: 'Body dissatisfaction, eating concerns',
    accentColor: const Color(0xFFDB2777),
    rootCauses: [
      'Internalized cultural beauty standards',
      'Social comparison amplified by social media',
      'Control needs manifesting through body/food',
      'Defectiveness schema and shame',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'How do you feel about your body?',
        type: QuestionType.custom,
        options: ['Mostly positive', 'Neutral', 'Often negative', 'Strongly negative'],
      ),
      const AssessmentQuestion(
        text: 'How often do you compare your body to others?',
        type: QuestionType.frequency,
        options: ['Rarely', 'Sometimes', 'Often', 'Constantly'],
      ),
      const AssessmentQuestion(
        text: 'Does body image affect your eating habits?',
        type: QuestionType.custom,
        options: ['No', 'A little', 'Significantly', 'Controls my eating'],
      ),
      const AssessmentQuestion(
        text: 'Do you avoid activities because of your appearance?',
        type: QuestionType.custom,
        options: ['Never', 'Sometimes', 'Often', 'Frequently'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'dr-aura',
        role: 'primary',
        reason: 'Schema work on shame & self-compassion',
      ),
      const CoachRecommendation(
        coachId: 'iron-will',
        role: 'support',
        reason: 'Healthy relationship with exercise and body',
      ),
      const CoachRecommendation(
        coachId: 'zen-mind',
        role: 'support',
        reason: 'Body scan to reconnect with body kindly',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: 'Body Scan Meditation', reason: 'Relate to your body with kindness, not judgment'),
      const TechniqueRecommendation(name: '7-Minute Workout', reason: 'Move for strength, not punishment'),
      const TechniqueRecommendation(name: 'Walking Meditation', reason: 'Embodied mindfulness'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'Say one kind thing to your body: "Thank you for carrying me"'),
      const MicroAction(time: 'afternoon', action: 'Unfollow one social account that makes you feel worse'),
      const MicroAction(time: 'evening', action: 'Write: "My body helped me today by..."'),
    ],
    timeline: 'Reduced negative self-talk in 2-3 weeks. Deeper healing is ongoing.',
    uniqueApproach: 'We shift the focus from how your body LOOKS to what it DOES. Dr. Aura heals the shame, IronWill rebuilds a healthy movement relationship, ZenMind reconnects you with your body.',
  ),

  // ── 15. GRIEF ──
  ProblemDefinition(
    category: ProblemCategory.grief,
    emoji: '🕊️',
    title: 'Grief',
    subtitle: 'Loss, mourning, heartbreak',
    accentColor: const Color(0xFF64748B),
    rootCauses: [
      'Natural response to loss — not a problem to fix',
      'Complicated grief when processing gets stuck',
      'Society\'s pressure to "move on" too quickly',
      'Multiple losses compounding',
    ],
    questions: [
      const AssessmentQuestion(
        text: 'What kind of loss are you experiencing?',
        type: QuestionType.custom,
        options: ['Death of loved one', 'Breakup/divorce', 'Friendship loss', 'Life change', 'Other'],
      ),
      const AssessmentQuestion(
        text: 'How recent is this loss?',
        type: QuestionType.custom,
        options: ['Very recent', 'Weeks ago', 'Months ago', 'Years ago'],
      ),
      const AssessmentQuestion(
        text: 'Are you able to function in daily life?',
        type: QuestionType.custom,
        options: ['Yes, mostly', 'With difficulty', 'Barely', 'Not at all'],
      ),
      const AssessmentQuestion(
        text: 'Do you have people to talk to about your loss?',
        type: QuestionType.custom,
        options: ['Yes, good support', 'Some support', 'Very little', 'No one'],
      ),
    ],
    coaches: [
      const CoachRecommendation(
        coachId: 'dr-aura',
        role: 'primary',
        reason: 'Grief processing with compassion and depth',
      ),
      const CoachRecommendation(
        coachId: 'stoic-sage',
        role: 'support',
        reason: 'Wisdom on impermanence, amor fati, and meaning',
      ),
      const CoachRecommendation(
        coachId: 'zen-mind',
        role: 'support',
        reason: 'Present-moment anchor when grief overwhelms',
      ),
    ],
    techniques: [
      const TechniqueRecommendation(name: 'Body Scan Meditation', reason: 'Feel grief in your body safely'),
      const TechniqueRecommendation(name: 'Walking Meditation', reason: 'Gentle movement through heavy emotions'),
      const TechniqueRecommendation(name: '5-4-3-2-1 Grounding', reason: 'Anchor when grief waves hit'),
      const TechniqueRecommendation(name: 'Box Breathing', reason: 'Steady yourself in overwhelming moments'),
    ],
    microActions: [
      const MicroAction(time: 'morning', action: 'Allow yourself to feel — set a 5-min "grief time"'),
      const MicroAction(time: 'afternoon', action: 'Do one small thing that honors the memory'),
      const MicroAction(time: 'evening', action: 'Write a letter to who/what you lost — unsent is fine'),
    ],
    timeline: 'Grief has no timeline. We walk with you. Coping tools help immediately; healing unfolds naturally.',
    uniqueApproach: 'We don\'t rush grief. We don\'t say "move on." We sit with you in it. Dr. Aura holds space, StoicSage helps find meaning, ZenMind keeps you grounded. Your pain is valid.',
  ),
];

// ═══════════════════════════════════════════════════════
// PROBLEM ENGINE SERVICE
// ═══════════════════════════════════════════════════════

class ProblemEngine {
  static ProblemDefinition getDefinition(ProblemCategory category) {
    return allProblems.firstWhere((p) => p.category == category);
  }

  static ProblemSeverity calculateSeverity(
    Map<String, String> answers,
    int impactScore,
  ) {
    // Count high-severity answers (last 1-2 options are typically severe)
    int severeCount = 0;
    for (final answer in answers.values) {
      final lowerAnswer = answer.toLowerCase();
      if (lowerAnswer.contains('always') ||
          lowerAnswer.contains('constantly') ||
          lowerAnswer.contains('completely') ||
          lowerAnswer.contains('every') ||
          lowerAnswer.contains('not at all') ||
          lowerAnswer.contains('destroying') ||
          lowerAnswer.contains('overwhelming') ||
          lowerAnswer.contains('exhausted') ||
          lowerAnswer.contains('years') ||
          lowerAnswer.contains('extensively')) {
        severeCount++;
      }
    }

    if (impactScore >= 8 || severeCount >= 3) return ProblemSeverity.severe;
    if (impactScore >= 5 || severeCount >= 1) return ProblemSeverity.moderate;
    return ProblemSeverity.mild;
  }

  static String severityLabel(ProblemSeverity severity) {
    switch (severity) {
      case ProblemSeverity.mild:
        return 'Mild';
      case ProblemSeverity.moderate:
        return 'Moderate';
      case ProblemSeverity.severe:
        return 'Significant';
    }
  }

  static Color severityColor(ProblemSeverity severity) {
    switch (severity) {
      case ProblemSeverity.mild:
        return const Color(0xFF22C55E);
      case ProblemSeverity.moderate:
        return const Color(0xFFF59E0B);
      case ProblemSeverity.severe:
        return const Color(0xFFEF4444);
    }
  }

  /// Build a context string for coaches based on assessment
  static String buildCoachContext(List<ProblemAssessmentResult> results) {
    if (results.isEmpty) return '';
    final buffer = StringBuffer();
    buffer.writeln('USER ASSESSMENT RESULTS:');
    for (final r in results) {
      final def = getDefinition(r.category);
      buffer.writeln('- ${def.title} (${severityLabel(r.severity)}): Impact ${r.impactScore}/10');
    }
    buffer.writeln('\nTailor your responses to address these areas. Be aware of severity levels.');
    return buffer.toString();
  }
}
