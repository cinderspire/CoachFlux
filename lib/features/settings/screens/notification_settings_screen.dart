import 'package:flutter/material.dart';

import '../../../core/services/smart_notifications_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Notification preferences screen with master toggle, per-category controls,
/// and time pickers for scheduled categories.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _service = SmartNotificationsService.instance;

  bool _masterEnabled = true;
  final Map<NotificationCategory, bool> _categoryToggles = {};
  final Map<NotificationCategory, TimeOfDay> _categoryTimes = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final master = await _service.isMasterEnabled();
    for (final cat in NotificationCategory.values) {
      _categoryToggles[cat] = await _service.isCategoryEnabled(cat);
      if (cat.defaultHour != null) {
        final t = await _service.getTimeForCategory(cat);
        _categoryTimes[cat] = TimeOfDay(hour: t.hour, minute: t.minute);
      }
    }
    setState(() {
      _masterEnabled = master;
      _loading = false;
    });
  }

  Future<void> _toggleMaster(bool value) async {
    setState(() => _masterEnabled = value);
    await _service.setMasterEnabled(value);
    if (value) {
      await _service.scheduleAllEnabled();
    }
  }

  Future<void> _toggleCategory(NotificationCategory cat, bool value) async {
    setState(() => _categoryToggles[cat] = value);
    await _service.setCategoryEnabled(cat, value);
    if (value && _masterEnabled) {
      await _service.scheduleCategory(cat);
    }
  }

  Future<void> _pickTime(NotificationCategory cat) async {
    final current = _categoryTimes[cat] ?? const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryPeach,
              onPrimary: AppColors.backgroundDark,
              surface: AppColors.backgroundDarkElevated,
              onSurface: AppColors.textPrimaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _categoryTimes[cat] = picked);
      await _service.setTimeForCategory(cat, picked.hour, picked.minute);
      if (_masterEnabled && (_categoryToggles[cat] ?? true)) {
        await _service.scheduleCategory(cat);
      }
    }
  }

  IconData _iconForCategory(NotificationCategory cat) {
    return switch (cat) {
      NotificationCategory.morningIntention => Icons.wb_sunny_outlined,
      NotificationCategory.coachingNudge => Icons.chat_bubble_outline,
      NotificationCategory.eveningReflection => Icons.nightlight_outlined,
      NotificationCategory.milestone => Icons.emoji_events_outlined,
      NotificationCategory.coachMessage => Icons.person_outline,
      NotificationCategory.weeklyInsight => Icons.insights_outlined,
      NotificationCategory.reEngagement => Icons.favorite_outline,
    };
  }

  Color _colorForCategory(NotificationCategory cat) {
    return switch (cat) {
      NotificationCategory.morningIntention => AppColors.primaryPeach,
      NotificationCategory.coachingNudge => AppColors.secondaryLavender,
      NotificationCategory.eveningReflection => AppColors.secondaryLavender,
      NotificationCategory.milestone => AppColors.tertiarySage,
      NotificationCategory.coachMessage => AppColors.primaryPeach,
      NotificationCategory.weeklyInsight => AppColors.tertiarySage,
      NotificationCategory.reEngagement => AppColors.primaryPeach,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Text('Notifications', style: AppTextStyles.headlineSmall),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPeach))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // ── Master Toggle ──
                _buildMasterToggle(),
                const SizedBox(height: 24),
                // ── Section Header ──
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'CATEGORIES',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textTertiaryDark,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                // ── Category Tiles ──
                ...NotificationCategory.values.map(_buildCategoryTile),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildMasterToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_outlined, color: AppColors.backgroundDark, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Push Notifications', style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(
                  _masterEnabled ? 'Enabled' : 'Disabled',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _masterEnabled ? AppColors.success : AppColors.textTertiaryDark,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _masterEnabled,
            onChanged: _toggleMaster,
            activeThumbColor: AppColors.primaryPeach,
            activeTrackColor: AppColors.primaryPeach.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textTertiaryDark,
            inactiveTrackColor: AppColors.backgroundDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(NotificationCategory cat) {
    final enabled = _categoryToggles[cat] ?? true;
    final hasTime = cat.defaultHour != null;
    final time = _categoryTimes[cat];
    final color = _colorForCategory(cat);

    return AnimatedOpacity(
      opacity: _masterEnabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 250),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(_iconForCategory(cat), color: color, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat.title, style: AppTextStyles.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        cat.description,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: enabled && _masterEnabled,
                  onChanged: _masterEnabled ? (v) => _toggleCategory(cat, v) : null,
                  activeThumbColor: color,
                  activeTrackColor: color.withValues(alpha: 0.3),
                  inactiveThumbColor: AppColors.textTertiaryDark,
                  inactiveTrackColor: AppColors.backgroundDark,
                ),
              ],
            ),
            if (hasTime && enabled && _masterEnabled) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _pickTime(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: AppColors.textTertiaryDark, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        time != null ? time.format(context) : 'Set time',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: AppColors.textTertiaryDark, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
