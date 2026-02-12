import 'package:shared_preferences/shared_preferences.dart';

class GoalConfig {
  final String name;
  final String emoji;
  final List<String> dailyActions;

  const GoalConfig({required this.name, required this.emoji, required this.dailyActions});
}

const Map<String, GoalConfig> goalConfigs = {
  'Focus & Productivity': GoalConfig(
    name: 'Focus & Productivity',
    emoji: '🎯',
    dailyActions: [
      'Do a 5-minute Pomodoro session',
      'Block out 30 min for deep work',
      'Apply the 2-Minute Rule to one task',
      'Identify your #1 priority for today',
      'Turn off notifications for 25 minutes',
      'Write down 3 things to accomplish today',
      'Single-task for 15 minutes straight',
    ],
  ),
  'Mindfulness & Calm': GoalConfig(
    name: 'Mindfulness & Calm',
    emoji: '🧘',
    dailyActions: [
      'Do 4 rounds of Box Breathing (4-4-4-4)',
      'Practice 5-4-3-2-1 grounding exercise',
      'Meditate for 3 minutes',
      'Do a 2-minute body scan',
      'Take 5 mindful breaths before a meal',
      'Notice 3 things you can hear right now',
      'Practice progressive muscle relaxation',
    ],
  ),
  'Fitness & Energy': GoalConfig(
    name: 'Fitness & Energy',
    emoji: '💪',
    dailyActions: [
      'Do the 7-Minute Workout',
      'Take a 10-minute walk',
      'Do 5 desk stretches',
      'Drink a full glass of water now',
      'Do 20 squats',
      'Stretch for 5 minutes',
      'Rate your energy level right now',
    ],
  ),
  'Career Growth': GoalConfig(
    name: 'Career Growth',
    emoji: '🚀',
    dailyActions: [
      'Write one SMART goal for this week',
      'Reach out to one person in your network',
      'Spend 15 min learning a new skill',
      'Update one section of your resume/portfolio',
      'Read one industry article',
      'Identify one skill gap to work on',
      'Do a 5-minute weekly review',
    ],
  ),
  'Creativity': GoalConfig(
    name: 'Creativity',
    emoji: '🎨',
    dailyActions: [
      'Free-write for 5 minutes',
      'Sketch or doodle for 5 minutes',
      'Brainstorm 10 ideas on any topic',
      'Try something you\'ve never done before',
      'Look at 3 pieces of art for inspiration',
      'Combine two random ideas into one',
      'Create something small and share it',
    ],
  ),
  'Financial Freedom': GoalConfig(
    name: 'Financial Freedom',
    emoji: '💰',
    dailyActions: [
      'Track all spending today',
      'Review your budget categories',
      'Find one subscription you can cancel',
      'Set up or review a savings goal',
      'Read one personal finance tip',
      'Calculate your 50/30/20 split',
      'Have a no-spend day today',
    ],
  ),
  'Better Sleep': GoalConfig(
    name: 'Better Sleep',
    emoji: '😴',
    dailyActions: [
      'Set a bedtime alarm for tonight',
      'No screens 30 min before bed',
      'Do a relaxation exercise before sleep',
      'Write down tomorrow\'s to-do before bed',
      'Make your bedroom 1°C cooler',
      'Avoid caffeine after 2pm today',
      'Practice the 4-7-8 breathing technique',
    ],
  ),
  'Communication': GoalConfig(
    name: 'Communication',
    emoji: '🗣️',
    dailyActions: [
      'Practice active listening in one conversation',
      'Give someone a genuine compliment',
      'Ask an open-ended question today',
      'Practice a 30-second elevator pitch',
      'Have a difficult conversation you\'ve been avoiding',
      'Summarize what someone said back to them',
      'Write a thoughtful message to someone',
    ],
  ),
  'Learning': GoalConfig(
    name: 'Learning',
    emoji: '📚',
    dailyActions: [
      'Read for 15 minutes',
      'Watch an educational video',
      'Teach someone one thing you know',
      'Take notes on something you learned',
      'Quiz yourself on recent learning',
      'Explore a topic you know nothing about',
      'Write a summary of what you learned today',
    ],
  ),
  'Relationships': GoalConfig(
    name: 'Relationships',
    emoji: '❤️',
    dailyActions: [
      'Send a thoughtful message to someone you care about',
      'Plan quality time with a loved one',
      'Express gratitude to someone today',
      'Listen without interrupting in one conversation',
      'Ask someone how they\'re really doing',
      'Do something kind for someone unexpectedly',
      'Reflect on one relationship you want to strengthen',
    ],
  ),
};

class GoalService {
  static final GoalService _instance = GoalService._();
  factory GoalService() => _instance;
  GoalService._();

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<List<String>> getSelectedGoals() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('selected_goals') ?? [];
  }

  GoalConfig? getConfig(String goalName) {
    return goalConfigs[goalName];
  }

  String getTodayAction(String goalName) {
    final config = goalConfigs[goalName];
    if (config == null) return 'Work on your goal for 5 minutes';
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return config.dailyActions[dayOfYear % config.dailyActions.length];
  }

  Future<bool> isActionComplete(String goalName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'goal_done_${goalName}_${_todayKey()}';
    return prefs.getBool(key) ?? false;
  }

  Future<void> markActionComplete(String goalName, bool done) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'goal_done_${goalName}_${_todayKey()}';
    await prefs.setBool(key, done);
    // Update streak
    if (done) {
      await _updateStreak(goalName);
    }
  }

  Future<int> getStreak(String goalName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('goal_streak_$goalName') ?? 0;
  }

  Future<void> _updateStreak(String goalName) async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('goal_streak_last_$goalName');
    final today = _todayKey();
    final yesterday = () {
      final y = DateTime.now().subtract(const Duration(days: 1));
      return '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
    }();

    int streak = prefs.getInt('goal_streak_$goalName') ?? 0;
    if (lastDate == today) return; // Already counted today
    if (lastDate == yesterday) {
      streak++;
    } else {
      streak = 1;
    }
    await prefs.setInt('goal_streak_$goalName', streak);
    await prefs.setString('goal_streak_last_$goalName', today);
  }

  Future<double> getProgress(String goalName) async {
    final prefs = await SharedPreferences.getInstance();
    // Progress = days completed in last 7 days / 7
    int completed = 0;
    for (int i = 0; i < 7; i++) {
      final d = DateTime.now().subtract(Duration(days: i));
      final key = 'goal_done_${goalName}_${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      if (prefs.getBool(key) ?? false) completed++;
    }
    return completed / 7.0;
  }

  // Daily plan: pick top 3 actions from user's goals
  Future<List<MapEntry<String, String>>> getDailyPlan() async {
    final goals = await getSelectedGoals();
    final plan = <MapEntry<String, String>>[];
    for (final goal in goals.take(3)) {
      plan.add(MapEntry(goal, getTodayAction(goal)));
    }
    // If fewer than 3 goals, pad with remaining
    if (plan.length < 3 && goals.length > 3) {
      for (final goal in goals.skip(3)) {
        if (plan.length >= 3) break;
        plan.add(MapEntry(goal, getTodayAction(goal)));
      }
    }
    return plan;
  }

  Future<int> getDailyPlanCompleted() async {
    final plan = await getDailyPlan();
    int count = 0;
    for (final entry in plan) {
      if (await isActionComplete(entry.key)) count++;
    }
    return count;
  }

  // Get recent activity summary for AI context
  Future<String> getActivitySummary() async {
    final goals = await getSelectedGoals();
    final parts = <String>[];
    for (final goal in goals) {
      final streak = await getStreak(goal);
      final progress = await getProgress(goal);
      final done = await isActionComplete(goal);
      parts.add('$goal: ${(progress * 100).round()}% weekly, ${streak}d streak, today ${done ? "done" : "pending"}');
    }
    return parts.join('; ');
  }
}
