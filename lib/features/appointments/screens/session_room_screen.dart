import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/coach.dart';
import '../../../core/models/coach_persona.dart';
import '../../../core/models/message.dart';
import '../../../core/services/gemini_service.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';

class SessionRoomScreen extends StatefulWidget {
  final Appointment appointment;
  final Coach coach;

  const SessionRoomScreen({
    super.key,
    required this.appointment,
    required this.coach,
  });

  @override
  State<SessionRoomScreen> createState() => _SessionRoomScreenState();
}

class _SessionRoomScreenState extends State<SessionRoomScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];
  final _gemini = GeminiService();

  late Appointment _appointment;
  late CoachPersona _persona;
  late AnimationController _pulseCtrl;
  late AnimationController _breatheCtrl;
  late Timer _timer;

  AvatarState _avatarState = AvatarState.idle;
  int _remainingSeconds = 0;
  bool _isTyping = false;
  String _streamingText = '';
  bool _sessionEnded = false;
  bool _showMoodPicker = false;
  bool _isMoodBefore = true;
  String _sessionNotes = '';

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    _persona = getPersona(widget.coach.id);
    _remainingSeconds = _appointment.duration.minutes * 60;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0 && !_sessionEnded) {
        setState(() => _remainingSeconds--);
        if (_remainingSeconds == 0) _endSession();
      }
    });

    // Start session
    _startSession();
  }

  Future<void> _startSession() async {
    // Update status
    _appointment = _appointment.copyWith(status: AppointmentStatus.inProgress);
    await AppointmentService().save(_appointment);

    // Show mood picker first
    setState(() {
      _showMoodPicker = true;
      _isMoodBefore = true;
    });
  }

  void _selectMood(int score) async {
    final entry = MoodEntry(score: score, timestamp: DateTime.now());
    if (_isMoodBefore) {
      _appointment = _appointment.copyWith(moodBefore: entry);
      await AppointmentService().save(_appointment);
      setState(() => _showMoodPicker = false);
      // Send greeting
      _sendCoachGreeting();
    } else {
      _appointment = _appointment.copyWith(moodAfter: entry);
      await AppointmentService().save(_appointment);
      setState(() => _showMoodPicker = false);
      _generateSummary();
    }
  }

  Future<void> _sendCoachGreeting() async {
    setState(() {
      _avatarState = AvatarState.thinking;
      _isTyping = true;
    });

    final greeting = await _gemini.chat(
      coach: widget.coach,
      history: [],
      userMessage:
          'This is a scheduled ${_appointment.duration.label} coaching session. '
          'The user\'s current mood is ${_appointment.moodBefore?.score ?? "unknown"}/5. '
          'Greet them warmly, acknowledge their mood, and ask what they\'d like to focus on today. '
          'Keep it brief and warm — this is a premium face-to-face session.',
    );

    if (!mounted) return;
    setState(() {
      _avatarState = AvatarState.speaking;
      _isTyping = false;
      _streamingText = '';
    });

    // Simulate streaming
    await _simulateStreaming(greeting, 'greeting');
  }

  Future<void> _simulateStreaming(String text, String msgId) async {
    setState(() {
      _avatarState = AvatarState.speaking;
      _streamingText = '';
    });

    final words = text.split(' ');
    for (var i = 0; i < words.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 40));
      setState(() {
        _streamingText += (i == 0 ? '' : ' ') + words[i];
      });
      _scrollToBottom();
    }

    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(
        id: msgId,
        coachId: widget.coach.id,
        content: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _streamingText = '';
      _avatarState = AvatarState.idle;
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _sessionEnded) return;
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        coachId: widget.coach.id,
        content: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _avatarState = AvatarState.listening;
    });
    _scrollToBottom();

    // Brief pause to show "listening"
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _avatarState = AvatarState.thinking;
      _isTyping = true;
    });

    final response = await _gemini.chat(
      coach: widget.coach,
      history: _messages,
      userMessage: text,
    );

    if (!mounted) return;
    setState(() => _isTyping = false);
    await _simulateStreaming(
        response, 'coach-${DateTime.now().millisecondsSinceEpoch}');
  }

  void _endSession() async {
    if (_sessionEnded) return;
    _sessionEnded = true;
    _timer.cancel();

    // Ask for mood after
    setState(() {
      _showMoodPicker = true;
      _isMoodBefore = false;
    });
  }

  Future<void> _generateSummary() async {
    setState(() {
      _avatarState = AvatarState.thinking;
      _isTyping = true;
    });

    // Build conversation text for summary
    final convoText = _messages.map((m) {
      return '${m.isUser ? "User" : "Coach"}: ${m.content}';
    }).join('\n');

    final summaryPrompt =
        'Generate a session summary for this coaching session. Include:\n'
        '1. Key topics discussed\n'
        '2. Important insights\n'
        '3. Action items for the user\n\n'
        'Conversation:\n$convoText\n\n'
        'Format: Start with a brief paragraph summary, then list insights as bullet points, '
        'then list action items as numbered steps. Keep it concise and actionable.';

    final summary = await _gemini.chat(
      coach: widget.coach,
      history: [],
      userMessage: summaryPrompt,
    );

    if (!mounted) return;

    // Parse insights and action items (simple extraction)
    final lines = summary.split('\n');
    final insights = <String>[];
    final actions = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*')) {
        insights.add(trimmed.replaceFirst(RegExp(r'^[•\-*]\s*'), ''));
      } else if (RegExp(r'^\d+[.)]').hasMatch(trimmed)) {
        actions.add(trimmed.replaceFirst(RegExp(r'^\d+[.)]\s*'), ''));
      }
    }

    _appointment = _appointment.copyWith(
      status: AppointmentStatus.completed,
      sessionSummary: summary,
      sessionNotes: _sessionNotes.isEmpty ? null : _sessionNotes,
      keyInsights: insights.take(5).toList(),
      actionItems: actions.take(5).toList(),
    );
    await AppointmentService().save(_appointment);

    setState(() {
      _isTyping = false;
      _avatarState = AvatarState.empathizing;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _breatheCtrl.dispose();
    _timer.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final env = _persona.environment;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: env.gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar: timer + coach name
              _buildTopBar(),

              // Avatar area
              Expanded(
                flex: 3,
                child: _showMoodPicker
                    ? _buildMoodPicker()
                    : _sessionEnded &&
                            _appointment.status ==
                                AppointmentStatus.completed
                        ? _buildSummary()
                        : _buildAvatarArea(),
              ),

              // Messages + input
              if (!_showMoodPicker &&
                  !(_sessionEnded &&
                      _appointment.status == AppointmentStatus.completed))
                Expanded(
                  flex: 4,
                  child: _buildChatArea(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final isLow = _remainingSeconds < 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Close/End
          IconButton(
            onPressed: () => _showEndDialog(),
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
          ),
          const Spacer(),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (isLow ? AppColors.error : Colors.white)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: (isLow ? AppColors.error : Colors.white)
                      .withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined,
                    size: 16,
                    color: isLow ? AppColors.error : Colors.white70),
                const SizedBox(width: 6),
                Text(timeStr,
                    style: AppTextStyles.labelLarge.copyWith(
                        color: isLow ? AppColors.error : Colors.white,
                        fontFeatures: [
                          const FontFeature.tabularFigures()
                        ])),
              ],
            ),
          ),
          const Spacer(),
          // Actions
          IconButton(
            onPressed: _showNotesSheet,
            icon: const Icon(Icons.edit_note_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarArea() {
    final emoji =
        _persona.stateEmojis[_avatarState] ?? widget.coach.emoji;

    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, _) {
        final pulse = _pulseCtrl.value;
        final isSpeaking = _avatarState == AvatarState.speaking;
        final isThinking = _avatarState == AvatarState.thinking;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar with glow
            Container(
              width: 140 + (isSpeaking ? 10 * pulse : 0),
              height: 140 + (isSpeaking ? 10 * pulse : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.coach.color
                        .withValues(alpha: 0.15 + (isSpeaking ? 0.2 * pulse : 0.05 * pulse)),
                    blurRadius: 40 + (isSpeaking ? 20 * pulse : 5 * pulse),
                    spreadRadius: 5 + (isSpeaking ? 10 * pulse : 0),
                  ),
                ],
                border: Border.all(
                  color: widget.coach.color
                      .withValues(alpha: 0.3 + 0.3 * pulse),
                  width: 2.5,
                ),
              ),
              child: widget.coach.imagePath != null
                  ? ClipOval(
                      child: Image.asset(
                        widget.coach.imagePath!,
                        width: 130 + (isSpeaking ? 10 * pulse : 0),
                        height: 130 + (isSpeaking ? 10 * pulse : 0),
                        fit: BoxFit.cover,
                        errorBuilder: (e1, e2, e3) => Center(
                          child: Text(emoji,
                              style: TextStyle(
                                  fontSize: 64 + (isSpeaking ? 4 * pulse : 0))),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(emoji,
                          style: TextStyle(
                              fontSize: 64 + (isSpeaking ? 4 * pulse : 0))),
                    ),
            ),
            const SizedBox(height: 16),
            // Coach name
            Text(widget.coach.name,
                style: AppTextStyles.titleLarge
                    .copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            // State indicator
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _stateLabel,
                key: ValueKey(_avatarState),
                style: AppTextStyles.bodySmall.copyWith(
                    color: isThinking
                        ? widget.coach.color
                        : Colors.white54),
              ),
            ),
          ],
        );
      },
    );
  }

  String get _stateLabel {
    switch (_avatarState) {
      case AvatarState.idle:
        return 'Ready';
      case AvatarState.listening:
        return 'Listening...';
      case AvatarState.thinking:
        return 'Thinking...';
      case AvatarState.speaking:
        return 'Speaking...';
      case AvatarState.empathizing:
        return 'Here for you';
    }
  }

  Widget _buildChatArea() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _messages.length + (_streamingText.isNotEmpty ? 1 : 0) + (_isTyping && _streamingText.isEmpty ? 1 : 0),
            itemBuilder: (context, i) {
              // Typing indicator
              if (_isTyping && _streamingText.isEmpty && i == _messages.length) {
                return _buildTypingIndicator();
              }
              // Streaming text
              if (_streamingText.isNotEmpty && i == _messages.length) {
                return _buildMessageBubble(_streamingText, false);
              }
              if (i >= _messages.length) return const SizedBox.shrink();
              final msg = _messages[i];
              return _buildMessageBubble(msg.content, msg.isUser);
            },
          ),
        ),
        // Input
        _buildInput(),
      ],
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser
              ? widget.coach.color.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: Border.all(
            color: isUser
                ? widget.coach.color.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Text(text,
            style: AppTextStyles.bodyMedium
                .copyWith(color: Colors.white.withValues(alpha: 0.9))),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _breatheCtrl,
              builder: (context, _) {
                final offset =
                    ((_breatheCtrl.value + i * 0.3) % 1.0);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.coach.color
                        .withValues(alpha: 0.3 + 0.5 * offset),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: TextField(
                controller: _controller,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Share your thoughts...',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.white30),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.coach.color,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodPicker() {
    final moods = ['😞', '😔', '😐', '🙂', '😊'];
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isMoodBefore
                ? 'How are you feeling right now?'
                : 'How are you feeling after the session?',
            style: AppTextStyles.headlineSmall
                .copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _isMoodBefore
                ? 'This helps your coach understand where you are'
                : 'Let\'s track your progress',
            style: AppTextStyles.bodyMedium
                .copyWith(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => _selectMood(i + 1),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Center(
                          child: Text(moods[i],
                              style: const TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(height: 8),
                    Text('${i + 1}',
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white38)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Completion icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.15),
            ),
            child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: 16),
          Text('Session Complete',
              style: AppTextStyles.headlineSmall
                  .copyWith(color: Colors.white)),
          const SizedBox(height: 8),

          // Mood change
          if (_appointment.moodBefore != null &&
              _appointment.moodAfter != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _moodEmoji(_appointment.moodBefore!.score),
                  const SizedBox(width: 8),
                  Text('→',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: Colors.white54)),
                  const SizedBox(width: 8),
                  _moodEmoji(_appointment.moodAfter!.score),
                  const SizedBox(width: 16),
                  Text(
                    _moodChangeText,
                    style: AppTextStyles.labelLarge.copyWith(
                        color: _moodImproved
                            ? AppColors.success
                            : Colors.white54),
                  ),
                ],
              ),
            ),

          // Summary
          if (_appointment.sessionSummary != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Session Summary',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(_appointment.sessionSummary!,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.white70)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.coach.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Done',
                  style:
                      AppTextStyles.button.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moodEmoji(int score) {
    const emojis = ['', '😞', '😔', '😐', '🙂', '😊'];
    return Text(emojis[score.clamp(1, 5)],
        style: const TextStyle(fontSize: 32));
  }

  bool get _moodImproved =>
      _appointment.moodAfter != null &&
      _appointment.moodBefore != null &&
      _appointment.moodAfter!.score > _appointment.moodBefore!.score;

  String get _moodChangeText {
    if (_appointment.moodAfter == null || _appointment.moodBefore == null) {
      return '';
    }
    final diff =
        _appointment.moodAfter!.score - _appointment.moodBefore!.score;
    if (diff > 0) return '+$diff improvement';
    if (diff < 0) return '$diff change';
    return 'Stable';
  }

  void _showEndDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('End Session?',
            style: AppTextStyles.titleLarge
                .copyWith(color: AppColors.textPrimaryDark)),
        content: Text(
          'Are you sure you want to end this session early?',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Continue',
                style: TextStyle(color: widget.coach.color)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _endSession();
            },
            child: const Text('End Session',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showNotesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDarkElevated,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Session Notes',
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.textPrimaryDark)),
              const SizedBox(height: 16),
              TextField(
                maxLines: 5,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimaryDark),
                decoration: InputDecoration(
                  hintText: 'Jot down your thoughts...',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textTertiaryDark),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => _sessionNotes = v,
                controller: TextEditingController(text: _sessionNotes),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.coach.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
