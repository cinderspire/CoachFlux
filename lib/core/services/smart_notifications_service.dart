import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Notification category definitions.
enum NotificationCategory {
  morningIntention(
    id: 'morning_intention',
    title: 'Morning Intention',
    description: 'Start your day with purpose and clarity',
    defaultHour: 8,
    defaultMinute: 0,
  ),
  coachingNudge(
    id: 'coaching_nudge',
    title: 'Coaching Nudge',
    description: 'Gentle reminders to check in with yourself',
    defaultHour: 14,
    defaultMinute: 0,
  ),
  eveningReflection(
    id: 'evening_reflection',
    title: 'Evening Reflection',
    description: 'Wind down and journal your thoughts',
    defaultHour: 21,
    defaultMinute: 0,
  ),
  milestone(
    id: 'milestone',
    title: 'Milestone Celebrations',
    description: 'Celebrate your progress and achievements',
  ),
  coachMessage(
    id: 'coach_message',
    title: 'Coach Messages',
    description: 'Personalized insights from your coach',
  ),
  weeklyInsight(
    id: 'weekly_insight',
    title: 'Weekly Insights',
    description: 'Sunday summary of your growth journey',
    defaultHour: 10,
    defaultMinute: 0,
  ),
  reEngagement(
    id: 're_engagement',
    title: 'Welcome Back',
    description: 'Warm reminders when you\'ve been away',
  );

  const NotificationCategory({
    required this.id,
    required this.title,
    required this.description,
    this.defaultHour,
    this.defaultMinute,
  });

  final String id;
  final String title;
  final String description;
  final int? defaultHour;
  final int? defaultMinute;
}

/// Local notification scheduling service with 7 categories and 70+ messages.
class SmartNotificationsService {
  SmartNotificationsService._();
  static final SmartNotificationsService instance = SmartNotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final Random _random = Random();

  // ─── Prefs Keys ────────────────────────────────────────────────────────────

  static const _keyMasterEnabled = 'notif_master_enabled';
  static const _keyCategoryPrefix = 'notif_cat_';
  static const _keyTimePrefix = 'notif_time_';

  // ─── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap — can be extended with navigation logic.
  }

  // ─── Preferences ───────────────────────────────────────────────────────────

  Future<bool> isMasterEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMasterEnabled) ?? true;
  }

  Future<void> setMasterEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMasterEnabled, enabled);
    if (!enabled) {
      await cancelAll();
    }
  }

  Future<bool> isCategoryEnabled(NotificationCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyCategoryPrefix${category.id}') ?? true;
  }

  Future<void> setCategoryEnabled(NotificationCategory category, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyCategoryPrefix${category.id}', enabled);
    if (!enabled) {
      await cancelCategory(category);
    }
  }

  Future<({int hour, int minute})> getTimeForCategory(NotificationCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('$_keyTimePrefix${category.id}_hour') ?? category.defaultHour ?? 9;
    final minute = prefs.getInt('$_keyTimePrefix${category.id}_minute') ?? category.defaultMinute ?? 0;
    return (hour: hour, minute: minute);
  }

  Future<void> setTimeForCategory(NotificationCategory category, int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyTimePrefix${category.id}_hour', hour);
    await prefs.setInt('$_keyTimePrefix${category.id}_minute', minute);
  }

  // ─── Scheduling ────────────────────────────────────────────────────────────

  Future<void> scheduleCategory(NotificationCategory category) async {
    final masterEnabled = await isMasterEnabled();
    final categoryEnabled = await isCategoryEnabled(category);
    if (!masterEnabled || !categoryEnabled) return;

    final messages = _messages[category]!;
    final message = messages[_random.nextInt(messages.length)];
    final time = await getTimeForCategory(category);

    final notificationId = category.index * 100;

    await _plugin.zonedSchedule(
      id: notificationId,
      title: message.title,
      body: message.body,
      scheduledDate: _nextInstanceOfTime(time.hour, time.minute),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'coachflux_${category.id}',
          category.title,
          channelDescription: category.description,
          importance: Importance.high,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: category == NotificationCategory.weeklyInsight
          ? DateTimeComponents.dayOfWeekAndTime
          : DateTimeComponents.time,
    );
  }

  Future<void> scheduleAllEnabled() async {
    for (final category in NotificationCategory.values) {
      if (category.defaultHour != null) {
        await scheduleCategory(category);
      }
    }
  }

  Future<void> showImmediate(NotificationCategory category) async {
    final messages = _messages[category]!;
    final message = messages[_random.nextInt(messages.length)];

    await _plugin.show(
      id: category.index * 100 + 50,
      title: message.title,
      body: message.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'coachflux_${category.id}',
          category.title,
          channelDescription: category.description,
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelCategory(NotificationCategory category) async {
    await _plugin.cancel(id: category.index * 100);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ─── Message Data (70+ messages across 7 categories) ──────────────────────

  static const Map<NotificationCategory, List<_NotifMessage>> _messages = {
    // ── MORNING INTENTION (8 AM) ──
    NotificationCategory.morningIntention: [
      _NotifMessage('Good morning ☀️', 'What\'s one thing that would make today meaningful?'),
      _NotifMessage('Rise & Shine', 'Take a deep breath. Set one clear intention for today.'),
      _NotifMessage('New Day, New You', 'Today is a blank page. What story will you write?'),
      _NotifMessage('Morning Check-In', 'Before the world rushes in, what matters most to you today?'),
      _NotifMessage('Your Morning Spark', 'Small steps lead to big changes. What\'s your first step today?'),
      _NotifMessage('Wake Up Inspired', 'You showed up yesterday. Show up even stronger today.'),
      _NotifMessage('Start With Purpose', 'Align your energy with what truly matters this morning.'),
      _NotifMessage('Fresh Start', 'Every sunrise is an invitation to grow. Accept it.'),
      _NotifMessage('Morning Wisdom', 'You don\'t need to be perfect—just present. Let\'s begin.'),
      _NotifMessage('Today\'s Promise', 'Promise yourself one act of self-care today. You deserve it.'),
    ],

    // ── COACHING NUDGE (2 PM) ──
    NotificationCategory.coachingNudge: [
      _NotifMessage('Quick Check-In 💭', 'How are you feeling right now? Take 30 seconds to notice.'),
      _NotifMessage('Midday Pause', 'You\'ve been going strong. A quick breather can do wonders.'),
      _NotifMessage('Your Coach Says Hi', 'Haven\'t seen you today — even 2 minutes of journaling helps.'),
      _NotifMessage('Gentle Reminder', 'Progress isn\'t always visible. Trust the process.'),
      _NotifMessage('Breathe & Reset', 'Pause. Inhale for 4, hold for 4, exhale for 4. Better?'),
      _NotifMessage('Afternoon Nudge', 'Your goals are waiting. One small action right now?'),
      _NotifMessage('Hey There 👋', 'Just checking in. How\'s your energy level?'),
      _NotifMessage('Stay the Course', 'You\'re doing better than you think. Keep going.'),
      _NotifMessage('Mindful Moment', 'Name three things you can see right now. Be present.'),
      _NotifMessage('Reflect & Redirect', 'Is your afternoon aligned with your morning intention?'),
    ],

    // ── EVENING REFLECTION (9 PM) ──
    NotificationCategory.eveningReflection: [
      _NotifMessage('Evening Wind-Down 🌙', 'What went well today? Capture it before it fades.'),
      _NotifMessage('Journal Time', 'Three things you\'re grateful for from today — go.'),
      _NotifMessage('Reflect & Release', 'Let go of what didn\'t serve you. Keep what did.'),
      _NotifMessage('Night Check-In', 'Rate your day 1-10. No judgment, just awareness.'),
      _NotifMessage('Peaceful Close', 'You made it through another day. That\'s enough.'),
      _NotifMessage('Before You Sleep', 'Write one sentence about today. That\'s all it takes.'),
      _NotifMessage('Gratitude Moment', 'Who made your day better? Maybe tell them tomorrow.'),
      _NotifMessage('Unwind', 'Put the phone down after this. You\'ve earned some rest.'),
      _NotifMessage('Day\'s End Review', 'What did you learn about yourself today?'),
      _NotifMessage('Moonlight Thoughts', 'Tomorrow is a gift. Tonight, just breathe and be.'),
    ],

    // ── MILESTONE ──
    NotificationCategory.milestone: [
      _NotifMessage('🎉 Milestone Reached!', 'You\'ve hit a new streak! Consistency is your superpower.'),
      _NotifMessage('🏆 Achievement Unlocked', 'Look at you go! Another goal crushed.'),
      _NotifMessage('⭐ You Did It!', 'This moment deserves celebration. Be proud of yourself.'),
      _NotifMessage('🔥 On Fire!', 'Your dedication is paying off. Keep that flame alive.'),
      _NotifMessage('💪 Level Up', 'You just leveled up in your growth journey!'),
      _NotifMessage('🌟 Shining Bright', 'Your progress is inspiring. Seriously.'),
      _NotifMessage('🎯 Bullseye!', 'You set a target and you hit it. That\'s discipline.'),
      _NotifMessage('🚀 Liftoff!', 'You\'re breaking through barriers. Nothing can stop you.'),
      _NotifMessage('💎 Gem Unlocked', 'Another piece of your best self revealed. Beautiful.'),
      _NotifMessage('🌈 Breakthrough!', 'Every milestone started as a single step. Look how far you\'ve come.'),
    ],

    // ── COACH MESSAGE ──
    NotificationCategory.coachMessage: [
      _NotifMessage('Coach\'s Corner', 'Your coach noticed you\'ve been consistent. That\'s rare and powerful.'),
      _NotifMessage('A Word From Your Coach', 'Growth isn\'t linear. Plateaus are part of the climb.'),
      _NotifMessage('Coach Check-In', 'I see your effort even when you don\'t. Keep showing up.'),
      _NotifMessage('Your Coach Believes', 'You\'re closer to a breakthrough than you realize.'),
      _NotifMessage('Coaching Insight', 'Try reframing one negative thought today. Watch what shifts.'),
      _NotifMessage('From Your Coach', 'The fact that you\'re here means you\'re already winning.'),
      _NotifMessage('Coach\'s Tip', 'Focus on progress, not perfection. Always.'),
      _NotifMessage('Personal Note', 'Your journey is unique. Stop comparing, start appreciating.'),
      _NotifMessage('Coach Says', 'Rest is not the opposite of productivity. It\'s part of it.'),
      _NotifMessage('Wisdom Drop', 'The best investment you\'ll ever make is in yourself.'),
    ],

    // ── WEEKLY INSIGHT (Sunday) ──
    NotificationCategory.weeklyInsight: [
      _NotifMessage('📊 Weekly Recap', 'Your week in review is ready. See how far you\'ve come!'),
      _NotifMessage('Sunday Summary', 'Time to reflect on your week. What patterns do you notice?'),
      _NotifMessage('Week in Review', 'Seven days of growth. Let\'s look at the highlights.'),
      _NotifMessage('Weekly Wisdom', 'What was your biggest lesson this week? Hold onto it.'),
      _NotifMessage('Growth Report 📈', 'Your weekly insights reveal something interesting...'),
      _NotifMessage('Reflect & Plan', 'Review your week, then set one intention for the next.'),
      _NotifMessage('Sunday Check-In', 'How would you rate this week? What would you change?'),
      _NotifMessage('Week Wrap-Up', 'Celebrate your wins, learn from the rest. That\'s the formula.'),
      _NotifMessage('Insight Alert', 'Your patterns this week tell a story. Come read it.'),
      _NotifMessage('Fresh Week Ahead', 'Close this chapter with gratitude. A new week awaits.'),
    ],

    // ── RE-ENGAGEMENT ──
    NotificationCategory.reEngagement: [
      _NotifMessage('We Miss You 💙', 'It\'s been a while. Your journal is waiting patiently.'),
      _NotifMessage('Welcome Back?', 'No guilt, no pressure. Just a door that\'s always open.'),
      _NotifMessage('Hey Stranger 👋', 'Life gets busy. But you\'re worth 2 minutes of reflection.'),
      _NotifMessage('Still Here For You', 'Whenever you\'re ready, we\'re ready. No rush.'),
      _NotifMessage('Your Space Awaits', 'Your growth journey paused, not ended. Pick up anytime.'),
      _NotifMessage('Thinking of You', 'Just a gentle reminder that self-care isn\'t selfish.'),
      _NotifMessage('Come Back Stronger', 'Breaks are healthy. Coming back is brave.'),
      _NotifMessage('Open Invitation', 'One check-in. That\'s all. You might surprise yourself.'),
      _NotifMessage('You\'re Missed', 'Your streak may have reset, but your growth never does.'),
      _NotifMessage('Ready When You Are', 'No judgment. No timers. Just you and your thoughts.'),
    ],
  };
}

/// Internal message model.
class _NotifMessage {
  const _NotifMessage(this.title, this.body);
  final String title;
  final String body;
}
