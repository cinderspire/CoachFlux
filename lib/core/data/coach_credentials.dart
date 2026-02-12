/// Professional credentials and bios for all coaches.
/// Used in coaches screen, chat headers, and session overlays.
class CoachCredential {
  final String coachId;
  final String credentials;
  final List<String> specializations;
  final String approach;
  final String experience;
  final int sessionsCompleted;
  final double rating;
  final String bio;
  final List<String> availableFor;
  final String typingMessage; // Custom "thinking" message

  const CoachCredential({
    required this.coachId,
    required this.credentials,
    required this.specializations,
    required this.approach,
    required this.experience,
    required this.sessionsCompleted,
    required this.rating,
    required this.bio,
    required this.availableFor,
    required this.typingMessage,
  });

  String get specializationsLine => specializations.join(' • ');
  String get sessionCountFormatted {
    if (sessionsCompleted >= 1000) {
      return '${(sessionsCompleted / 1000).toStringAsFixed(1)}k';
    }
    return sessionsCompleted.toString();
  }

  String get ratingLine => '${rating.toStringAsFixed(2)} ★ ($sessionsCompleted sessions)';
}

final Map<String, CoachCredential> coachCredentials = {
  'dr-aura': const CoachCredential(
    coachId: 'dr-aura',
    credentials: 'Ph.D. Clinical Psychology',
    specializations: ['CBT', 'DBT', 'Schema Therapy', 'Trauma-Informed Care'],
    approach:
        'Integrative approach combining Cognitive Behavioral Therapy with Schema Therapy and mindfulness-based interventions',
    experience: '12+ years',
    sessionsCompleted: 3847,
    rating: 4.96,
    bio:
        'Dr. Aura specializes in anxiety, depression, and relationship patterns. Her integrative approach helps clients understand the roots of their struggles while building practical coping strategies. She believes every person has the capacity for transformation.',
    availableFor: [
      'Anxiety',
      'Depression',
      'Self-Esteem',
      'Relationships',
      'Trauma',
      'Life Transitions'
    ],
    typingMessage: 'Dr. Aura is reflecting...',
  ),
  'flow-master': const CoachCredential(
    coachId: 'flow-master',
    credentials: 'Certified Executive Coach (ICF-PCC)',
    specializations: ['Deep Work', 'Flow States', 'Executive Performance'],
    approach:
        'Performance-focused coaching using Csikszentmihalyi\'s Flow Model and attention management science',
    experience: '8+ years',
    sessionsCompleted: 2156,
    rating: 4.92,
    bio:
        'FlowState helps high performers eliminate distractions and achieve sustained focus. His methods are grounded in neuroscience research on attention, flow states, and peak performance.',
    availableFor: [
      'Productivity',
      'Focus',
      'Procrastination',
      'Time Management',
      'Executive Performance'
    ],
    typingMessage: 'FlowState is analyzing...',
  ),
  'zen-mind': const CoachCredential(
    coachId: 'zen-mind',
    credentials: 'Certified MBSR Instructor • Contemplative Psychology M.A.',
    specializations: [
      'MBSR',
      'Mindfulness Meditation',
      'Polyvagal Theory',
      'Stress Reduction'
    ],
    approach:
        'Evidence-based mindfulness practice rooted in MBSR protocol and contemplative neuroscience',
    experience: '15+ years',
    sessionsCompleted: 4210,
    rating: 4.97,
    bio:
        'ZenMind brings 15 years of contemplative practice and clinical mindfulness training. Trained under Jon Kabat-Zinn\'s MBSR lineage, she guides clients from chronic stress to deep, sustainable calm.',
    availableFor: [
      'Stress',
      'Anxiety',
      'Meditation',
      'Emotional Regulation',
      'Burnout',
      'Inner Peace'
    ],
    typingMessage: 'ZenMind is centering...',
  ),
  'iron-will': const CoachCredential(
    coachId: 'iron-will',
    credentials: 'CSCS • Sports Psychology M.Sc.',
    specializations: [
      'Exercise Psychology',
      'Progressive Overload',
      'Habit Science',
      'Nutrition'
    ],
    approach:
        'Science-based fitness coaching combining exercise physiology with behavioral psychology for lasting results',
    experience: '10+ years',
    sessionsCompleted: 2890,
    rating: 4.93,
    bio:
        'IronWill combines exercise science with behavioral psychology to build unbreakable fitness habits. Whether you\'re a beginner or an athlete, he meets you where you are and pushes you where you need to go.',
    availableFor: [
      'Fitness',
      'Energy',
      'Nutrition',
      'Habit Building',
      'Weight Management',
      'Recovery'
    ],
    typingMessage: 'IronWill is preparing your plan...',
  ),
  'career-pilot': const CoachCredential(
    coachId: 'career-pilot',
    credentials: 'MBA • Certified Career Strategist (CCS)',
    specializations: [
      'Negotiation Science',
      'Personal Branding',
      'Interview Mastery',
      'Leadership'
    ],
    approach:
        'Data-driven career strategy using negotiation science, behavioral economics, and personal branding frameworks',
    experience: '11+ years',
    sessionsCompleted: 3124,
    rating: 4.94,
    bio:
        'CareerPilot has coached executives at Fortune 500 companies and ambitious professionals through pivotal career transitions. His negotiation frameworks have helped clients secure an average 23% salary increase.',
    availableFor: [
      'Career Growth',
      'Salary Negotiation',
      'Interview Prep',
      'Leadership',
      'Career Pivot',
      'Personal Branding'
    ],
    typingMessage: 'CareerPilot is strategizing...',
  ),
  'muse': const CoachCredential(
    coachId: 'muse',
    credentials: 'MFA Creative Arts • Design Thinking Certified (IDEO)',
    specializations: [
      'Creativity Science',
      'Design Thinking',
      'Divergent Thinking',
      'Writing Craft'
    ],
    approach:
        'Playful yet structured creativity coaching using Design Thinking, SCAMPER, and neuroscience of imagination',
    experience: '9+ years',
    sessionsCompleted: 1876,
    rating: 4.91,
    bio:
        'Muse has helped thousands of artists, writers, and entrepreneurs break through creative blocks. Her approach blends cognitive science with artistic intuition to unlock ideas you didn\'t know you had.',
    availableFor: [
      'Creative Blocks',
      'Writing',
      'Innovation',
      'Brainstorming',
      'Artistic Expression',
      'Design'
    ],
    typingMessage: 'Muse is gathering inspiration...',
  ),
  'money-mind': const CoachCredential(
    coachId: 'money-mind',
    credentials: 'CFP® • Behavioral Economics Researcher',
    specializations: [
      'Behavioral Economics',
      'Money Psychology',
      'Wealth Building',
      'Financial Independence'
    ],
    approach:
        'Behavioral economics-driven financial coaching that addresses both the numbers and the psychology behind your money decisions',
    experience: '13+ years',
    sessionsCompleted: 2567,
    rating: 4.95,
    bio:
        'MoneyMind combines deep financial expertise with behavioral economics to help clients build wealth without anxiety. He specializes in uncovering the hidden money scripts that drive your financial behaviors.',
    availableFor: [
      'Budgeting',
      'Investing Mindset',
      'Debt Freedom',
      'Financial Anxiety',
      'Wealth Building',
      'FIRE'
    ],
    typingMessage: 'MoneyMind is running the numbers...',
  ),
  'system-builder': const CoachCredential(
    coachId: 'system-builder',
    credentials: 'Systems Engineering M.Sc. • GTD Certified Trainer',
    specializations: [
      'Systems Thinking',
      'GTD',
      'PARA Method',
      'Theory of Constraints'
    ],
    approach:
        'Engineering-grade life systems design using GTD, PARA, Zettelkasten, and Theory of Constraints for maximum throughput',
    experience: '10+ years',
    sessionsCompleted: 1943,
    rating: 4.93,
    bio:
        'SystemBuilder designs life operating systems with the precision of a senior engineer. Clients report 40%+ productivity gains within 30 days using his custom system blueprints.',
    availableFor: [
      'Productivity Systems',
      'Organization',
      'Second Brain',
      'Workflow Design',
      'Automation',
      'Decision Making'
    ],
    typingMessage: 'SystemBuilder is architecting...',
  ),
  'stoic-sage': const CoachCredential(
    coachId: 'stoic-sage',
    credentials: 'Ph.D. Philosophy • Stoic Ethics Researcher',
    specializations: [
      'Stoic Philosophy',
      'Resilience',
      'Existential Wisdom',
      'Virtue Ethics'
    ],
    approach:
        'Applied Stoic philosophy for modern life — transforming ancient wisdom into practical daily resilience',
    experience: '14+ years',
    sessionsCompleted: 2678,
    rating: 4.97,
    bio:
        'StoicSage has spent decades studying and teaching the works of Marcus Aurelius, Seneca, and Epictetus. His clients develop unshakeable inner peace and clarity in the face of life\'s inevitable challenges.',
    availableFor: [
      'Resilience',
      'Life Philosophy',
      'Emotional Strength',
      'Decision Making',
      'Acceptance',
      'Purpose'
    ],
    typingMessage: 'StoicSage is contemplating...',
  ),
  'social-spark': const CoachCredential(
    coachId: 'social-spark',
    credentials: 'Licensed Clinical Social Worker (LCSW) • NVC Trainer',
    specializations: [
      'Nonviolent Communication',
      'Public Speaking',
      'Social Anxiety CBT',
      'Assertiveness'
    ],
    approach:
        'Evidence-based communication coaching combining NVC, CBT for social anxiety, and public speaking science',
    experience: '9+ years',
    sessionsCompleted: 2234,
    rating: 4.91,
    bio:
        'SocialSpark transforms how people connect. From overcoming social anxiety to commanding a stage, she provides the exact scripts, frameworks, and practice that build genuine confidence.',
    availableFor: [
      'Social Anxiety',
      'Communication',
      'Public Speaking',
      'Confidence',
      'Relationships',
      'Assertiveness'
    ],
    typingMessage: 'SocialSpark is crafting a response...',
  ),
  'sleep-whisperer': const CoachCredential(
    coachId: 'sleep-whisperer',
    credentials: 'Board Certified in Sleep Medicine • CBT-I Specialist',
    specializations: [
      'Sleep Science',
      'CBT-I',
      'Circadian Biology',
      'Recovery Optimization'
    ],
    approach:
        'Clinical sleep medicine protocols including CBT-I, chronotype optimization, and evidence-based sleep hygiene',
    experience: '11+ years',
    sessionsCompleted: 2445,
    rating: 4.94,
    bio:
        'DreamGuard brings clinical sleep medicine expertise to help clients reclaim their nights. Her CBT-I protocols have helped thousands overcome chronic insomnia without medication.',
    availableFor: [
      'Insomnia',
      'Sleep Quality',
      'Circadian Rhythm',
      'Recovery',
      'Energy',
      'Wind-Down Routines'
    ],
    typingMessage: 'DreamGuard is reflecting...',
  ),
};

CoachCredential? getCredential(String coachId) => coachCredentials[coachId];
