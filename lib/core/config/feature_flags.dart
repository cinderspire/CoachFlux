/// Central feature toggle for AI CoachFlux.
/// Flip a bool to add/remove any feature instantly.
/// Firebase Remote Config can override at runtime.
class FeatureFlags {
  FeatureFlags._();

  // ─── AI Core ───
  static bool aiChat = true;           // 1-on-1 AI coaching chat
  static bool aiCoachBuilder = true;   // Custom coach personality creator
  static bool aiInsights = true;       // AI-powered personal insights

  // ─── Coaching Features ───
  static bool coaches = true;          // Coach roster/selection
  static bool techniques = true;       // Coaching techniques library
  static bool appointments = true;     // Scheduled coaching sessions

  // ─── Growth & Tracking ───
  static bool journal = true;          // Reflection journal
  static bool achievements = false;    // Achievement badges (disabled — gamification)
  static bool garden = false;          // Growth garden visualization (disabled — gimmick)
  static bool affirmations = false;    // Daily affirmations (disabled — fluff)

  // ─── Engagement ───
  static bool streak = false;          // Day streak (removed)
  static bool moodTracking = false;    // Mood check-in (coming soon)

  /// Apply overrides from Firebase Remote Config.
  static void applyRemoteOverrides(Map<String, dynamic> overrides) {
    overrides.forEach((key, value) {
      if (value is! bool) return;
      switch (key) {
        case 'ai_chat': aiChat = value;
        case 'ai_coach_builder': aiCoachBuilder = value;
        case 'ai_insights': aiInsights = value;
        case 'coaches': coaches = value;
        case 'journal': journal = value;
        case 'achievements': achievements = value;
        case 'garden': garden = value;
        case 'affirmations': affirmations = value;
        case 'streak': streak = value;
      }
    });
  }
}
