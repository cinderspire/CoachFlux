import 'package:flutter/material.dart';

/// CoachFlux Color Palette - Modern Energizing Theme
/// Premium, vibrant, human-centered design.
class AppColors {
  AppColors._();

  // ─── Base Palette ──────────────────────────────────────────────────────────

  // Backgrounds - Deep with warm undertone
  static const Color backgroundDark = Color(0xFF0C0F14); // Deep night with warmth
  static const Color backgroundDarkElevated = Color(0xFF161A22); // Card surface - slightly warm
  static const Color backgroundDarkCard = Color(0xFF161A22);

  // Light Mode
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundLightElevated = Color(0xFFFFFFFF);
  static const Color backgroundLightCard = Color(0xFFFFFFFF);

  // ─── Accents ───────────────────────────────────────────────────────────────

  // Primary: Vibrant Coral - Energizing, motivating, warm
  static const Color primaryPeach = Color(0xFFFF7F6B);
  static const Color primaryPeachDark = Color(0xFFE8634F);

  // Secondary: Electric Indigo - Modern, premium, sharp
  static const Color secondaryLavender = Color(0xFFB4A0FF);
  static const Color secondaryLavenderDark = Color(0xFF8B7AE8);

  // Tertiary: Vibrant Emerald - Growth, vitality, life
  static const Color tertiarySage = Color(0xFF5AEDC4);
  static const Color tertiarySageDark = Color(0xFF36D4A8);

  // Quaternary: Electric Cyan - Clarity, intelligence
  static const Color quaternarySky = Color(0xFF5CC8FF);

  // ─── Functional Colors ─────────────────────────────────────────────────────

  // Text
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Moods (Vibrant & Energizing)
  static const Color moodExcellent = Color(0xFFFF7F6B); // Coral
  static const Color moodGood = Color(0xFF5AEDC4);    // Emerald
  static const Color moodNeutral = Color(0xFF5CC8FF); // Cyan
  static const Color moodPoor = Color(0xFFFFBE6B);    // Amber
  static const Color moodTerrible = Color(0xFFFF6B8A); // Hot Pink

  // Status
  static const Color success = Color(0xFF5AEDC4);
  static const Color warning = Color(0xFFFFBE6B);
  static const Color error = Color(0xFFFF6B8A);
  static const Color info = Color(0xFF5CC8FF);

  // ─── Gradients ─────────────────────────────────────────────────────────────

  // Subtle, premium gradients. No harsh transitions.

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF7F6B), Color(0xFFE8634F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calmGradient = LinearGradient(
    colors: [Color(0xFF5CC8FF), Color(0xFFB4A0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient natureGradient = LinearGradient(
    colors: [Color(0xFF5AEDC4), Color(0xFF36D4A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // NEW: Energizing coral-to-purple gradient
  static const LinearGradient energyGradient = LinearGradient(
    colors: [Color(0xFFFF7F6B), Color(0xFFB4A0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient deepBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0C0F14), Color(0xFF131720)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Legacy / Compatibility ────────────────────────────────────────────────
  
  // Mapping old names to new palette to prevent breaks, 
  // but values are updated to the new design system.
  static const Color primaryNavy = backgroundDark;
  static const Color primaryNavyLight = backgroundDarkElevated;
  static const Color primaryNavyDeep = Color(0xFF050505);
  
  static const Color accentStarWhite = textPrimaryDark;
  static const Color accentMoonGlow = textSecondaryDark;
  
  static const Color secondaryLavenderLight = Color(0xFFCDBFFF);

  static Color glassDark = const Color(0xFF181B21).withValues(alpha: 0.85); // More solid
  static Color glassLight = const Color(0xFFFFFFFF).withValues(alpha: 0.9);
  static Color glassBorder = const Color(0xFFFFFFFF).withValues(alpha: 0.05);

  static Color shadowDark = const Color(0xFF000000).withValues(alpha: 0.3);
  static Color shadowLight = const Color(0xFF000000).withValues(alpha: 0.05);

  // Deprecated aliases rerouted
  static const Color primaryPurple = secondaryLavender;
  static const Color primaryBlue = quaternarySky;
  static const Color primaryTeal = tertiarySage;
  static const LinearGradient cosmicGradient = primaryGradient;
  static const LinearGradient auroraGradient = calmGradient;
  static const LinearGradient meditationGradient = natureGradient;
}
