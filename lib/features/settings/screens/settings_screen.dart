import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = true;
  bool _hapticFeedback = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionHeader('Preferences'),
          const SizedBox(height: 12),
          _navTile(
            icon: Icons.notifications_outlined,
            title: 'Smart Notifications',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
          ),
          _toggleTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Night sky theme',
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
          _toggleTile(
            icon: Icons.vibration_outlined,
            title: 'Haptic Feedback',
            subtitle: 'Subtle vibrations on actions',
            value: _hapticFeedback,
            onChanged: (v) => setState(() => _hapticFeedback = v),
          ),
          const SizedBox(height: 32),
          _sectionHeader('Account'),
          const SizedBox(height: 12),
          _navTile(
            icon: Icons.workspace_premium_outlined,
            title: 'Manage Subscription',
            onTap: () => Navigator.pushNamed(context, '/paywall'),
          ),
          _navTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => launchUrl(Uri.parse('https://playtools.top/privacy-policy.html'), mode: LaunchMode.externalApplication),
          ),
          _navTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => launchUrl(Uri.parse('https://playtools.top/privacy-policy.html'), mode: LaunchMode.externalApplication),
          ),
          const SizedBox(height: 32),
          _sectionHeader('About'),
          const SizedBox(height: 12),
          _navTile(
            icon: Icons.info_outline,
            title: 'About CoachFlux',
            onTap: () => _showAbout(context),
          ),
          const SizedBox(height: 40),
          Center(
            child: TextButton(
              onPressed: () => _showSignOutConfirm(context),
              child: Text(
                'Sign Out',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.primaryPeach,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.secondaryLavender, size: 22),
        title: Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark)),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark)),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primaryPeach,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showSignOutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryDark)),
        content: Text(
          'Your local data will be preserved. You can sign back in anytime.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textTertiaryDark)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Signed out successfully'),
                  backgroundColor: AppColors.backgroundDarkElevated,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'CoachFlux',
      applicationVersion: '1.0.0 (Build 1)',
      applicationIcon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('⚡', style: TextStyle(fontSize: 28))),
      ),
      children: [
        const SizedBox(height: 8),
        Text(
          'AI Coaching, Your Way.\n\nCoachFlux helps you grow with personalized AI coaching across productivity, mindset, health, career, creativity, and finance.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark),
        ),
        const SizedBox(height: 16),
        Text(
          '© 2026 CoachFlux. All rights reserved.',
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark),
        ),
      ],
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondaryLavender, size: 22),
        title: Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark)),
        trailing: trailing ?? Icon(Icons.chevron_right, color: AppColors.textTertiaryDark, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
