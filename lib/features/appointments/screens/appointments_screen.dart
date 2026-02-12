import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/coach.dart';
import '../../../core/widgets/glass_card.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../../../core/widgets/coach_photo.dart';
import 'book_appointment_screen.dart';
import 'session_room_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Appointment> _upcoming = [];
  List<Appointment> _past = [];
  bool _loading = true;
  Map<String, dynamic>? _moodStats;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final svc = AppointmentService();
    final upcoming = await svc.getUpcoming();
    final past = await svc.getCompleted();
    final stats = await svc.getMoodStats();
    if (!mounted) return;
    setState(() {
      _upcoming = upcoming;
      _past = past;
      _moodStats = stats;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Appointments',
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.textPrimaryDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: AppColors.primaryPeach),
            onPressed: _showCoachPicker,
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primaryPeach,
          labelColor: AppColors.primaryPeach,
          unselectedLabelColor: AppColors.textTertiaryDark,
          labelStyle: AppTextStyles.labelLarge,
          tabs: [
            Tab(text: 'Upcoming (${_upcoming.length})'),
            Tab(text: 'Past (${_past.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPeach))
          : Column(
              children: [
                // Mood stats card
                if (_moodStats != null && (_moodStats!['sessions'] as int) > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: GlassCard(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success.withValues(alpha: 0.15),
                            ),
                            child: const Center(
                                child: Text('📈',
                                    style: TextStyle(fontSize: 24))),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Growth',
                                    style: AppTextStyles.titleSmall.copyWith(
                                        color: AppColors.textPrimaryDark)),
                                Text(
                                  '${_moodStats!['sessions']} sessions  •  '
                                  'Avg mood: ${(_moodStats!['avgImprovement'] as double) > 0 ? '+' : ''}'
                                  '${(_moodStats!['avgImprovement'] as double).toStringAsFixed(1)} improvement',
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondaryDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildList(_upcoming, isUpcoming: true),
                      _buildList(_past, isUpcoming: false),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCoachPicker,
        backgroundColor: AppColors.primaryPeach,
        icon: const Icon(Icons.video_call_rounded, color: Colors.black87),
        label: Text('Book Session',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.black87)),
      ),
    );
  }

  Widget _buildList(List<Appointment> items, {required bool isUpcoming}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isUpcoming ? '📅' : '📋',
                style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              isUpcoming
                  ? 'No upcoming sessions'
                  : 'No past sessions yet',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 8),
            Text(
              isUpcoming
                  ? 'Book a session with your favorite coach'
                  : 'Your session history will appear here',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textTertiaryDark),
            ),
          ],
        ),
      );
    }

    // Check for in-progress sessions
    final activeSession = isUpcoming
        ? items.where((a) => a.status == AppointmentStatus.inProgress).toList()
        : <Appointment>[];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length + (activeSession.isNotEmpty ? 1 : 0),
      itemBuilder: (context, i) {
        // Show active session banner at top
        if (activeSession.isNotEmpty && i == 0) {
          final active = activeSession.first;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassCard(
              child: InkWell(
                onTap: () => _startSession(active),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success.withValues(alpha: 0.15),
                        ),
                        child: const Center(
                            child: Text('🟢', style: TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Session in Progress',
                                style: AppTextStyles.titleSmall.copyWith(
                                    color: AppColors.success, fontWeight: FontWeight.bold)),
                            Text('Tap to resume your session with ${active.coachName}',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.textSecondaryDark)),
                          ],
                        ),
                      ),
                      const Icon(Icons.play_circle_filled_rounded,
                          color: AppColors.success, size: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final idx = activeSession.isNotEmpty ? i - 1 : i;
        return _buildAppointmentCard(items[idx], isUpcoming);
      },
    );
  }

  Widget _buildAppointmentCard(Appointment apt, bool isUpcoming) {
    final typeIcon = switch (apt.sessionType) {
      SessionType.textChat => '💬',
      SessionType.voiceCall => '🎙️',
      SessionType.videoCall => '📹',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: InkWell(
          onTap: isUpcoming ? () => _startSession(apt) : () => _showDetails(apt),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Builder(
                    builder: (context) {
                      final coach = defaultCoaches.cast<Coach?>().firstWhere(
                        (c) => c!.id == apt.coachId,
                        orElse: () => null,
                      );
                      if (coach != null) {
                        return CoachPhoto(coach: coach, radius: 24);
                      }
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        child: Center(
                            child: Text(apt.coachEmoji,
                                style: const TextStyle(fontSize: 24))),
                      );
                    },
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(apt.coachName,
                            style: AppTextStyles.titleSmall.copyWith(
                                color: AppColors.textPrimaryDark)),
                        Text(
                          '$typeIcon ${apt.duration.label}  •  ${_formatDateTime(apt.scheduledAt)}',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiaryDark),
                        ),
                      ],
                    ),
                  ),
                  if (isUpcoming && apt.status == AppointmentStatus.inProgress)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('Resume',
                              style: AppTextStyles.labelMedium
                                  .copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  else if (isUpcoming)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPeach.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Start',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.primaryPeach)),
                    )
                  else if (apt.moodBefore != null && apt.moodAfter != null)
                    _buildMoodBadge(apt),
                ],
              ),
              if (!isUpcoming && apt.sessionSummary != null) ...[
                const SizedBox(height: 12),
                Text(
                  apt.sessionSummary!.length > 120
                      ? '${apt.sessionSummary!.substring(0, 120)}...'
                      : apt.sessionSummary!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textTertiaryDark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodBadge(Appointment apt) {
    final diff = apt.moodAfter!.score - apt.moodBefore!.score;
    final positive = diff > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (positive ? AppColors.success : AppColors.textTertiaryDark)
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${positive ? '+' : ''}$diff',
        style: AppTextStyles.labelMedium.copyWith(
            color: positive ? AppColors.success : AppColors.textTertiaryDark),
      ),
    );
  }

  void _startSession(Appointment apt) {
    // Find the coach
    final coach = defaultCoaches.firstWhere(
      (c) => c.id == apt.coachId,
      orElse: () => defaultCoaches.first,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionRoomScreen(appointment: apt, coach: coach),
      ),
    ).then((_) => _load());
  }

  void _showDetails(Appointment apt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDarkElevated,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (_, scrollCtrl) {
            return SingleChildScrollView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(apt.coachEmoji,
                          style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(apt.coachName,
                                style: AppTextStyles.headlineSmall
                                    .copyWith(
                                        color: AppColors.textPrimaryDark)),
                            Text(
                              '${apt.duration.label} session  •  ${_formatDateTime(apt.scheduledAt)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondaryDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (apt.sessionSummary != null) ...[
                    const SizedBox(height: 24),
                    Text('Summary',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.textPrimaryDark)),
                    const SizedBox(height: 8),
                    Text(apt.sessionSummary!,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondaryDark)),
                  ],
                  if (apt.keyInsights.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Key Insights',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.textPrimaryDark)),
                    const SizedBox(height: 8),
                    ...apt.keyInsights.map((i) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('💡 ',
                                  style: AppTextStyles.bodySmall),
                              Expanded(
                                  child: Text(i,
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color:
                                              AppColors.textSecondaryDark))),
                            ],
                          ),
                        )),
                  ],
                  if (apt.actionItems.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Action Items',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.textPrimaryDark)),
                    const SizedBox(height: 8),
                    ...apt.actionItems.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${e.key + 1}. ',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primaryPeach)),
                              Expanded(
                                  child: Text(e.value,
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color:
                                              AppColors.textSecondaryDark))),
                            ],
                          ),
                        )),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCoachPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDarkElevated,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose a Coach',
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: AppColors.textPrimaryDark)),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: defaultCoaches.length,
                  itemBuilder: (_, i) {
                    final coach = defaultCoaches[i];
                    return ListTile(
                      leading: CoachPhoto(coach: coach, radius: 22),
                      title: Text(coach.name,
                          style: AppTextStyles.titleSmall
                              .copyWith(color: AppColors.textPrimaryDark)),
                      subtitle: Text(coach.title,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textTertiaryDark)),
                      trailing: Icon(Icons.arrow_forward_ios_rounded,
                          size: 16, color: AppColors.textTertiaryDark),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookAppointmentScreen(coach: coach),
                          ),
                        ).then((_) => _load());
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    String dateStr;
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      dateStr = 'Today';
    } else if (diff.inDays == 1) {
      dateStr = 'Tomorrow';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      dateStr = '${months[dt.month - 1]} ${dt.day}';
    }
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final m = dt.minute.toString().padLeft(2, '0');
    return '$dateStr, $h:$m $ampm';
  }
}
