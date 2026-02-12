import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/coach.dart';
import 'problem_engine.dart';

// ═══════════════════════════════════════════════════════════════
// RECOMMENDATION SERVICE — Smart Coach & Technique Matching
// ═══════════════════════════════════════════════════════════════

class RecommendationResult {
  final Coach coach;
  final String role;
  final String reason;
  final double relevanceScore;

  const RecommendationResult({
    required this.coach,
    required this.role,
    required this.reason,
    required this.relevanceScore,
  });
}

class TechniqueCombo {
  final String name;
  final String reason;
  final String timing;

  const TechniqueCombo({
    required this.name,
    required this.reason,
    required this.timing,
  });
}

class PersonalizedPlan {
  final List<RecommendationResult> coaches;
  final List<TechniqueCombo> techniques;
  final List<MicroAction> dailyActions;
  final String summary;
  final String timeline;

  const PersonalizedPlan({
    required this.coaches,
    required this.techniques,
    required this.dailyActions,
    required this.summary,
    required this.timeline,
  });
}

class RecommendationService {
  static const _assessmentKey = 'user_assessment_data';
  static const _assessmentDateKey = 'user_assessment_date';
  static const _assessmentCompleteKey = 'assessment_complete';

  /// Save assessment results to SharedPreferences
  static Future<void> saveAssessment(List<ProblemAssessmentResult> results) async {
    final prefs = await SharedPreferences.getInstance();
    final data = results.map((r) {
      return {
        'category': r.category.index,
        'answers': r.answers,
        'impactScore': r.impactScore,
        'severity': r.severity.index,
      };
    }).toList();
    await prefs.setString(_assessmentKey, jsonEncode(data));
    await prefs.setString(_assessmentDateKey, DateTime.now().toIso8601String());
    await prefs.setBool(_assessmentCompleteKey, true);
  }

  /// Load saved assessment
  static Future<List<ProblemAssessmentResult>?> loadAssessment() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_assessmentKey);
    if (raw == null) return null;
    try {
      final List<dynamic> data = jsonDecode(raw);
      return data.map((d) {
        return ProblemAssessmentResult(
          category: ProblemCategory.values[d['category'] as int],
          answers: Map<String, String>.from(d['answers'] as Map),
          impactScore: d['impactScore'] as int,
          severity: ProblemSeverity.values[d['severity'] as int],
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }

  /// Check if assessment has been completed
  static Future<bool> isAssessmentComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_assessmentCompleteKey) ?? false;
  }

  /// Clear assessment (for reassessment)
  static Future<void> clearAssessment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_assessmentKey);
    await prefs.remove(_assessmentDateKey);
    await prefs.setBool(_assessmentCompleteKey, false);
  }

  /// Generate personalized plan from assessment results
  static PersonalizedPlan generatePlan(List<ProblemAssessmentResult> results) {
    // Collect all coach recommendations, ranked by frequency and severity
    final coachScores = <String, double>{};
    final coachRoles = <String, String>{};
    final coachReasons = <String, String>{};

    for (final result in results) {
      final def = ProblemEngine.getDefinition(result.category);
      final severityMultiplier = switch (result.severity) {
        ProblemSeverity.severe => 3.0,
        ProblemSeverity.moderate => 2.0,
        ProblemSeverity.mild => 1.0,
      };

      for (final rec in def.coaches) {
        final roleWeight = switch (rec.role) {
          'primary' => 3.0,
          'support' => 1.5,
          _ => 1.0,
        };
        final score = severityMultiplier * roleWeight;
        coachScores[rec.coachId] = (coachScores[rec.coachId] ?? 0) + score;
        // Keep highest-role entry
        if (rec.role == 'primary' || !coachRoles.containsKey(rec.coachId)) {
          coachRoles[rec.coachId] = rec.role;
          coachReasons[rec.coachId] = rec.reason;
        }
      }
    }

    // Sort coaches by score
    final sortedCoachIds = coachScores.keys.toList()
      ..sort((a, b) => coachScores[b]!.compareTo(coachScores[a]!));

    final recommendedCoaches = <RecommendationResult>[];
    for (final id in sortedCoachIds.take(4)) {
      final coach = defaultCoaches.where((c) => c.id == id).firstOrNull;
      if (coach != null) {
        recommendedCoaches.add(RecommendationResult(
          coach: coach,
          role: coachRoles[id] ?? 'support',
          reason: coachReasons[id] ?? '',
          relevanceScore: coachScores[id] ?? 0,
        ));
      }
    }

    // Collect techniques (deduplicated, scored)
    final techScores = <String, double>{};
    final techReasons = <String, String>{};
    for (final result in results) {
      final def = ProblemEngine.getDefinition(result.category);
      for (final tech in def.techniques) {
        techScores[tech.name] = (techScores[tech.name] ?? 0) + 1;
        techReasons[tech.name] ??= tech.reason;
      }
    }

    final sortedTechs = techScores.keys.toList()
      ..sort((a, b) => techScores[b]!.compareTo(techScores[a]!));

    final techniques = sortedTechs.take(6).map((name) {
      return TechniqueCombo(
        name: name,
        reason: techReasons[name] ?? '',
        timing: 'Daily',
      );
    }).toList();

    // Collect micro-actions (top problems only)
    final actions = <MicroAction>[];
    for (final result in results.take(2)) {
      final def = ProblemEngine.getDefinition(result.category);
      actions.addAll(def.microActions);
    }

    // Build summary
    final problemNames = results
        .map((r) => ProblemEngine.getDefinition(r.category).title)
        .join(', ');
    final primary = results.isNotEmpty
        ? ProblemEngine.getDefinition(results.first.category)
        : null;

    return PersonalizedPlan(
      coaches: recommendedCoaches,
      techniques: techniques,
      dailyActions: actions,
      summary: 'Your focus areas: $problemNames',
      timeline: primary?.timeline ?? 'Consistent practice shows results in 2-4 weeks.',
    );
  }

  /// Get adaptive recommendation based on usage duration
  static String? getAdaptiveInsight(
    List<ProblemAssessmentResult> results,
    int daysSinceAssessment,
  ) {
    if (results.isEmpty || daysSinceAssessment < 7) return null;

    final primary = ProblemEngine.getDefinition(results.first.category);

    if (daysSinceAssessment >= 14 && daysSinceAssessment < 21) {
      return 'You\'ve been working on ${primary.title.toLowerCase()} for 2 weeks. '
          'Consider adding a new technique to keep progressing.';
    }
    if (daysSinceAssessment >= 21) {
      return '3 weeks of practice! ${primary.timeline} '
          'Ready for a reassessment to track your growth?';
    }
    return null;
  }
}
