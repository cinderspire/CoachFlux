import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// MindFlow App Theme - Zen Deep Theme
class AppTheme {
  AppTheme._();

  // Dark Theme (Primary - Zen Deep)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryPeach,
      secondary: AppColors.secondaryLavender,
      tertiary: AppColors.tertiarySage,
      surface: AppColors.backgroundDarkCard,
      surfaceContainerHighest: AppColors.backgroundDarkElevated,
      error: AppColors.error,
      onPrimary: AppColors.backgroundDark,
      onSecondary: AppColors.backgroundDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      onError: AppColors.backgroundDark,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.backgroundDark,
    
    // AppBar
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimaryDark,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
    ),
    
    // Card
    cardTheme: CardThemeData(
      color: AppColors.backgroundDarkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // Softer corners
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.all(8),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundDarkElevated,
      selectedItemColor: AppColors.primaryPeach,
      unselectedItemColor: AppColors.textTertiaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryPeach,
      foregroundColor: AppColors.backgroundDark,
      elevation: 4,
      shape: CircleBorder(),
    ),
    
    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPeach,
        foregroundColor: AppColors.backgroundDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // Pill shape
        ),
        textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
      ),
    ),
    
    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryPeach,
        textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryPeach,
        side: const BorderSide(color: AppColors.primaryPeach, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    
    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundDarkElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryPeach, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textTertiaryDark,
      ),
    ),
    
    // Divider
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.1),
      thickness: 1,
      space: 1,
    ),
    
    // Typography
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimaryDark),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimaryDark),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimaryDark),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimaryDark),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimaryDark),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryDark),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryDark),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondaryDark),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryDark),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiaryDark),
    ),
  );

  // Light Theme (Clean, Soft, Premium)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryPeachDark,
      secondary: AppColors.secondaryLavenderDark,
      tertiary: AppColors.tertiarySageDark,
      surface: AppColors.backgroundLightCard,
      surfaceContainerHighest: AppColors.backgroundLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      onError: Colors.white,
    ),
    
    scaffoldBackgroundColor: AppColors.backgroundLight,
    
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimaryLight,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
    ),
    
    cardTheme: CardThemeData(
      color: AppColors.backgroundLightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.all(8),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundLightElevated,
      selectedItemColor: AppColors.primaryPeachDark,
      unselectedItemColor: AppColors.textTertiaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryPeachDark,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPeachDark,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.bold),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryPeachDark,
        textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryPeachDark,
        side: const BorderSide(color: AppColors.primaryPeachDark, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        textStyle: AppTextStyles.button.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundLightElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryPeachDark, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textTertiaryLight,
      ),
    ),
    
    dividerTheme: DividerThemeData(
      color: Colors.black.withValues(alpha: 0.1),
      thickness: 1,
      space: 1,
    ),
    
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimaryLight),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimaryLight),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimaryLight),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimaryLight),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimaryLight),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryLight),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryLight),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryLight),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryLight),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryLight),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondaryLight),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryLight),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiaryLight),
    ),
  );
}
