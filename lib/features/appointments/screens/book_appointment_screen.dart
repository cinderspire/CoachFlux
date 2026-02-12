import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/coach.dart';
import '../../../core/services/revenuecat_service.dart';
import '../../../core/widgets/glass_card.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../../../core/widgets/coach_photo.dart';
import 'session_room_screen.dart';
import '../../paywall/screens/paywall_screen.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final Coach coach;
  const BookAppointmentScreen({super.key, required this.coach});

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends ConsumerState<BookAppointmentScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedSlot;
  SessionDuration _duration = SessionDuration.medium30;
  SessionType _sessionType = SessionType.textChat;
  bool _isBooking = false;
  List<DateTime> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  void _loadSlots() {
    _availableSlots = AppointmentService().getAvailableSlots(_selectedDate);
    _selectedSlot = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sub = ref.watch(subscriptionProvider);
    final coach = widget.coach;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Book Session',
            style: AppTextStyles.titleLarge
                .copyWith(color: AppColors.textPrimaryDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coach card
            GlassCard(
              child: Row(
                children: [
                  CoachPhoto(coach: coach, radius: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(coach.name,
                            style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.textPrimaryDark)),
                        const SizedBox(height: 4),
                        Text(coach.title,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondaryDark)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Date picker
            _sectionLabel('Select Date'),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (context, i) {
                  final date = DateTime.now().add(Duration(days: i + 1));
                  final selected = _selectedDate.year == date.year &&
                      _selectedDate.month == date.month &&
                      _selectedDate.day == date.day;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        _selectedDate = date;
                        _loadSlots();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        decoration: BoxDecoration(
                          color: selected
                              ? coach.color.withValues(alpha: 0.2)
                              : AppColors.backgroundDarkElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? coach.color
                                : Colors.white.withValues(alpha: 0.06),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _dayName(date.weekday),
                              style: AppTextStyles.caption.copyWith(
                                  color: selected
                                      ? coach.color
                                      : AppColors.textTertiaryDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: AppTextStyles.titleLarge.copyWith(
                                  color: selected
                                      ? coach.color
                                      : AppColors.textPrimaryDark),
                            ),
                            Text(
                              _monthName(date.month),
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiaryDark,
                                  fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Time slots
            _sectionLabel('Select Time'),
            const SizedBox(height: 12),
            if (_availableSlots.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No slots available for this date',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textTertiaryDark)),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _availableSlots.map((slot) {
                  final selected = _selectedSlot == slot;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSlot = slot),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? coach.color.withValues(alpha: 0.2)
                            : AppColors.backgroundDarkElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? coach.color
                              : Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        _formatTime(slot),
                        style: AppTextStyles.labelLarge.copyWith(
                            color: selected
                                ? coach.color
                                : AppColors.textSecondaryDark),
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 28),

            // Duration
            _sectionLabel('Session Duration'),
            const SizedBox(height: 12),
            Row(
              children: SessionDuration.values.map((d) {
                final selected = _duration == d;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right:
                            d != SessionDuration.values.last ? 10 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _duration = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: selected
                              ? coach.color.withValues(alpha: 0.2)
                              : AppColors.backgroundDarkElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? coach.color
                                : Colors.white.withValues(alpha: 0.06),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(d.label,
                                style: AppTextStyles.titleMedium.copyWith(
                                    color: selected
                                        ? coach.color
                                        : AppColors.textPrimaryDark)),
                            const SizedBox(height: 4),
                            Text(d.priceLabel,
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: selected
                                        ? coach.color
                                        : AppColors.textTertiaryDark)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Session type
            _sectionLabel('Session Type'),
            const SizedBox(height: 12),
            ..._buildSessionTypeOption(
                SessionType.textChat, '💬', 'Text Chat', 'Type your thoughts',
                coach.color),
            const SizedBox(height: 8),
            ..._buildSessionTypeOption(
                SessionType.voiceCall, '🎙️', 'Voice Call',
                'Speak naturally', coach.color),
            const SizedBox(height: 8),
            ..._buildSessionTypeOption(
                SessionType.videoCall, '📹', 'Video Call',
                'Face to face  •  +\$2.99', coach.color),
            const SizedBox(height: 32),

            // Price summary
            GlassCard(
              child: Column(
                children: [
                  _priceRow('Session (${_duration.label})', _duration.priceLabel),
                  if (_sessionType == SessionType.videoCall)
                    _priceRow('Video upgrade', '\$2.99'),
                  const Divider(color: Colors.white12, height: 24),
                  _priceRow(
                    'Total',
                    '\$${_totalPrice.toStringAsFixed(2)}',
                    bold: true,
                  ),
                  if (sub.isPro || sub.isCoachTier)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded,
                              size: 16, color: AppColors.primaryPeach),
                          const SizedBox(width: 6),
                          Text(
                            sub.isCoachTier
                                ? 'Unlimited sessions with Coach tier'
                                : 'Pro: 2 free sessions/month',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryPeach),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Book button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    _selectedSlot != null && !_isBooking ? _book : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: coach.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isBooking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Confirm & Book',
                        style: AppTextStyles.button
                            .copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  double get _totalPrice {
    var p = _duration.price;
    if (_sessionType == SessionType.videoCall) p += 2.99;
    return p;
  }

  List<Widget> _buildSessionTypeOption(SessionType type, String icon,
      String title, String subtitle, Color color) {
    final selected = _sessionType == type;
    return [
      GestureDetector(
        onTap: () => setState(() {
          _sessionType = type;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.12)
                : AppColors.backgroundDarkElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : Colors.white.withValues(alpha: 0.06),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.titleSmall.copyWith(
                            color: selected
                                ? color
                                : AppColors.textPrimaryDark)),
                    Text(subtitle,
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiaryDark)),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: color, size: 24),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _priceRow(String label, String price, {bool bold = false}) {
    final style = bold
        ? AppTextStyles.titleMedium
        : AppTextStyles.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: style.copyWith(color: AppColors.textSecondaryDark)),
          Text(price,
              style: style.copyWith(color: AppColors.textPrimaryDark)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: AppTextStyles.titleSmall
            .copyWith(color: AppColors.textSecondaryDark));
  }

  Future<void> _book() async {
    if (_selectedSlot == null) return;

    // Check if free user → show upgrade prompt with campaign
    final sub = ref.read(subscriptionProvider);
    if (sub.isFree) {
      _showProUpgradePrompt();
      return;
    }

    setState(() => _isBooking = true);

    final appointment = Appointment(
      id: const Uuid().v4(),
      coachId: widget.coach.id,
      coachName: widget.coach.name,
      coachEmoji: widget.coach.emoji,
      sessionType: _sessionType,
      duration: _duration,
      scheduledAt: _selectedSlot!,
      status: AppointmentStatus.upcoming,
      isPaid: true,
      isVideoAddon: _sessionType == SessionType.videoCall,
    );

    await AppointmentService().save(appointment);

    if (!mounted) return;
    setState(() => _isBooking = false);

    // Show success and navigate
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDarkElevated,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.15),
              ),
              child: const Center(
                  child: Text('✅', style: TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 20),
            Text('Session Booked!',
                style: AppTextStyles.headlineSmall
                    .copyWith(color: AppColors.textPrimaryDark)),
            const SizedBox(height: 8),
            Text(
              '${widget.coach.emoji} ${widget.coach.name}\n'
              '${_formatDate(_selectedSlot!)} at ${_formatTime(_selectedSlot!)}\n'
              '${_duration.label} session',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Done',
                        style: AppTextStyles.button
                            .copyWith(color: AppColors.textSecondaryDark)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessionRoomScreen(
                            appointment: appointment,
                            coach: widget.coach,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.coach.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text('Start Now',
                        style: AppTextStyles.button
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _dayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
  }

  String _formatDate(DateTime dt) {
    return '${_dayName(dt.weekday)}, ${_monthName(dt.month)} ${dt.day}';
  }

  void _showProUpgradePrompt() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDarkElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Pro badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPeach,
                    AppColors.secondaryLavender,
                  ],
                ),
              ),
              child: const Center(
                  child: Text('👑', style: TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: 20),

            Text('Pro Feature',
                style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Face-to-face sessions are available for Pro members.\nGet personalized 1-on-1 coaching with expert AI coaches.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondaryDark, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Campaign offer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPeach.withValues(alpha: 0.15),
                    AppColors.secondaryLavender.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryPeach.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text('LIMITED OFFER',
                          style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primaryPeach,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
                      const SizedBox(width: 8),
                      const Text('🔥', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$1',
                          style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.primaryPeach,
                              fontWeight: FontWeight.bold,
                              fontSize: 40)),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('first session',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondaryDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try a 4-min coaching session for just \$1',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textTertiaryDark),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('15 min = \$4.99',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiaryDark,
                            decoration: TextDecoration.lineThrough,
                          )),
                      Text('  →  4 min = \$1',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryPeach,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CTA buttons
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // TODO: Trigger RevenueCat $1 trial purchase
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Setting up your \$1 trial session...'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPeach,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text('Try for \$1',
                    style: AppTextStyles.button.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryPeach.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('See All Plans',
                    style: AppTextStyles.button.copyWith(
                        color: AppColors.primaryPeach)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Maybe later',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textTertiaryDark)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
