import 'dart:async';
import 'package:flutter/material.dart';
import '../../voice_call/screens/voice_call_screen.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/coach.dart';
import '../../../core/models/message.dart';
import '../../../core/data/coach_credentials.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/mood_service.dart';
import '../../../core/services/chemistry_service.dart';
import '../../../core/services/engagement_service.dart';
import '../../../core/services/journal_service.dart';
import '../../../core/services/achievement_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../wisdom/screens/wisdom_collection_screen.dart';
import '../../paywall/screens/paywall_screen.dart';
import '../../appointments/screens/book_appointment_screen.dart';
import '../../../core/widgets/coach_photo.dart';

class ChatScreen extends StatefulWidget {
  final Coach coach;
  final String? heroTag;
  const ChatScreen({super.key, required this.coach, this.heroTag});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];
  bool _isTyping = false;
  String _streamingText = '';
  Timer? _streamTimer;
  Mood? _currentMood;
  ChemistryData? _chemistry;
  int _userMessageCount = 0;
  bool _showRelationshipBanner = false;
  RelationshipLevel? _relationshipLevel;
  SocialProofData? _socialProof;
  int _dailyMessageCount = 0;
  bool _isProUser = false;
  late AnimationController _gradientController;
  late DateTime _sessionStart;

  // Session experience state
  bool _showSessionOverlay = true;
  Timer? _sessionTimer;
  int _sessionSeconds = 0;
  int _totalUserMessages = 0;
  bool _sessionClosingTriggered = false;
  CoachCredential? _credential;

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();
    _credential = getCredential(widget.coach.id);
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Start session timer
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _sessionSeconds++);
      }
    });

    // Show session overlay, then build greeting
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _showSessionOverlay = false);
        _buildPersonalizedGreeting();
      }
    });

    _loadData();
  }

  Future<void> _buildPersonalizedGreeting() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final feeling = prefs.getString('user_feeling') ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);
    _dailyMessageCount = prefs.getInt('daily_msg_count_$today') ?? 0;
    _isProUser = prefs.getBool('is_pro_user') ?? false;

    final coachName = widget.coach.name;
    final nameStr = name.isNotEmpty ? name : 'there';
    final cred = _credential;
    final credLine = cred != null ? ' ${cred.credentials}.' : '';

    // Clinical professional opening — NOT a casual chatbot greeting
    String greeting;
    if (widget.coach.id == 'dr-aura') {
      greeting = "Welcome, $nameStr.$credLine\n\n"
          "I'm glad you're here. Before we begin our session — I'd like to understand where you are right now.\n\n"
          "On a scale of 1 to 10, how are you feeling at this moment? Take a breath. There's no rush.";
    } else if (feeling == 'Struggling') {
      greeting = "Welcome, $nameStr. I'm $coachName.$credLine\n\n"
          "I can see you're going through a difficult time, and I want you to know — showing up here is an important step. "
          "Before we dive in, let me ask: on a scale of 1-10, how would you rate how you're feeling right now? "
          "This gives us a baseline we can work from.";
    } else if (feeling == 'Fired Up') {
      greeting = "Welcome, $nameStr. I'm $coachName.$credLine\n\n"
          "I can feel the momentum you're bringing into this session. That energy is valuable — let's channel it. "
          "Before we begin: on a scale of 1-10, where's your focus level right now? "
          "And what's the single most important thing you want to walk away with today?";
    } else if (feeling == 'Exhausted') {
      greeting = "Welcome, $nameStr. I'm $coachName.$credLine\n\n"
          "I appreciate you being here, especially when your energy is low. That takes real commitment. "
          "Let's start gently — on a scale of 1-10, where are you right now, physically and mentally? "
          "We'll pace this session to match where you are.";
    } else {
      greeting = "Welcome, $nameStr. I'm $coachName.$credLine\n\n"
          "This is your space. Before we begin our session, I'd like to check in with you. "
          "On a scale of 1-10, how are you feeling right now? "
          "Take a moment — there's no right answer.";
    }

    _messages.add(ChatMessage(
      id: const Uuid().v4(),
      coachId: widget.coach.id,
      content: greeting,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    final chemistry = await ChemistryService().getChemistry(widget.coach.id);
    final msgCount =
        await EngagementService().getCoachMessageCount(widget.coach.id);
    final rel = EngagementService().getRelationshipLevel(msgCount);
    final social = EngagementService().getSocialProof(widget.coach.id);
    await ChemistryService().recordSession(widget.coach.id);
    await EngagementService().recordActivity();

    if (mounted) {
      setState(() {
        _chemistry = chemistry;
        _userMessageCount = msgCount;
        _relationshipLevel = rel;
        _socialProof = social;
      });
    }
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    _sessionTimer?.cancel();
    _gradientController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectMood(Mood mood) {
    HapticFeedback.mediumImpact();
    setState(() => _currentMood = mood);
    MoodService().record(mood, coachId: widget.coach.id);
  }

  String get _sessionTimerText {
    final m = _sessionSeconds ~/ 60;
    final s = _sessionSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (!_isProUser &&
        _dailyMessageCount >= AppConstants.freeMessagesPerDay) {
      _showDailyLimitReached();
      return;
    }

    HapticFeedback.lightImpact();
    _controller.clear();

    _dailyMessageCount++;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('daily_msg_count_$today', _dailyMessageCount);
    });

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      coachId: widget.coach.id,
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
      _streamingText = '';
      _userMessageCount++;
      _totalUserMessages++;
    });
    _scrollToBottom();

    await ChemistryService().recordMessage(
      widget.coach.id,
      text.length,
      moodScore: _currentMood?.score,
    );
    await EngagementService().incrementCoachMessages(widget.coach.id);

    final newRel =
        EngagementService().getRelationshipLevel(_userMessageCount);
    if (_relationshipLevel != null &&
        newRel.level > _relationshipLevel!.level) {
      _relationshipLevel = newRel;
      _showRelationshipMilestone(newRel);
    } else {
      _relationshipLevel = newRel;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name');
      final userGoals = prefs.getStringList('selected_goals') ?? [];
      final userFeeling = prefs.getString('user_feeling');
      final moodCtx = _currentMood != null
          ? 'Currently feeling ${_currentMood!.label}'
          : '';
      final challenges = <String>[
        if (userFeeling != null) 'Entered app feeling: $userFeeling',
        if (moodCtx.isNotEmpty) moodCtx,
      ];

      // Inject check-in system message every 5 user messages
      String extraContext = '';
      if (_totalUserMessages > 0 && _totalUserMessages % 5 == 0) {
        extraContext =
            '\n[SYSTEM: This is the ${_totalUserMessages}th message. Pause and check in on the user\'s emotional state. '
            'Ask how they\'re feeling right now. Show you\'ve been tracking their narrative throughout the session.]';
      }

      // Trigger session closing after 15+ messages or 20+ minutes
      final sessionMinutes =
          DateTime.now().difference(_sessionStart).inMinutes;
      if (!_sessionClosingTriggered &&
          (_totalUserMessages >= 15 || sessionMinutes >= 20)) {
        _sessionClosingTriggered = true;
        extraContext +=
            '\n[SYSTEM: The session has been going for $sessionMinutes minutes with $_totalUserMessages exchanges. '
            'Begin naturally wrapping up: (1) Summarize the key insights from today\'s session, '
            '(2) Give a specific homework assignment, '
            '(3) Ask "When would you like our next session?", '
            '(4) Do a final mood check: "How are you feeling now, 1-10? Compare to when we started."]';
      }

      final response = await GeminiService().chat(
        coach: widget.coach,
        history: _messages.where((m) => !m.isLoading).toList(),
        userMessage: '$text$extraContext',
        userProfile: UserProfile(
          name: userName,
          goals: userGoals,
          challenges: challenges,
        ),
      );
      _streamResponse(response);
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        _messages.add(ChatMessage(
          id: const Uuid().v4(),
          coachId: widget.coach.id,
          content:
              'I\'m taking a moment to gather my thoughts... 🤔 Could you try that again? Sometimes the connection wavers.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        setState(() {});
        _scrollToBottom();
      }
    }

    await AchievementService().increment('first_session');
    if (_userMessageCount >= 50) {
      await AchievementService()
          .setProgress('deep_diver', _userMessageCount);
    }
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour < 5) {
      await AchievementService().increment('night_owl');
    }
    if (hour >= 4 && hour < 7) {
      await AchievementService().increment('early_bird');
    }
  }

  void _showRelationshipMilestone(RelationshipLevel rel) {
    setState(() => _showRelationshipBanner = true);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showRelationshipBanner = false);
    });
  }

  void _streamResponse(String fullText) {
    int charIndex = 0;
    setState(() {
      _isTyping = false;
      _streamingText = '';
    });

    _streamTimer =
        Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (charIndex >= fullText.length) {
        timer.cancel();
        setState(() {
          _messages.add(ChatMessage(
            id: const Uuid().v4(),
            coachId: widget.coach.id,
            content: fullText,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _streamingText = '';
        });
        _loadData();
        _scrollToBottom();

        final aiMsgCount = _messages.where((m) => !m.isUser).length;
        if (aiMsgCount > 1 &&
            aiMsgCount % (4 + (aiMsgCount % 3)) == 0) {
          _showInsightCard();
        }

        final userMsgCount = _messages.where((m) => m.isUser).length;
        if (!_isProUser && userMsgCount > 0 && userMsgCount % 5 == 0) {
          _showProNudge();
        }

        return;
      }
      setState(() {
        _streamingText = fullText.substring(0, charIndex + 1);
      });
      charIndex++;
      _scrollToBottom();
    });
  }

  void _showDailyLimitReached() {
    HapticFeedback.heavyImpact();
    setState(() {
      _messages.add(ChatMessage(
        id: 'limit-${const Uuid().v4()}',
        coachId: widget.coach.id,
        content:
            "You've used all ${AppConstants.freeMessagesPerDay} messages for today! 💜\n\n"
            "I valued our session — come back tomorrow for more, "
            "or upgrade to Pro for unlimited sessions with all coaches.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _showProNudge();
    });
  }

  void _showProNudge() {
    setState(() {
      _messages.add(ChatMessage(
        id: 'pro-nudge-${const Uuid().v4()}',
        coachId: widget.coach.id,
        content:
            '⭐ Pro members get unlimited sessions + all coaches unlocked',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _showInsightCard() {
    final insight =
        EngagementService().generateInsight(widget.coach.name);
    setState(() {
      _messages.add(ChatMessage(
        id: 'insight-${const Uuid().v4()}',
        coachId: widget.coach.id,
        content: '💡 $insight',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    HapticFeedback.heavyImpact();
    _scrollToBottom();
  }

  void _showSessionSummary() {
    final summary = EngagementService().generateSessionSummary(
      widget.coach.name,
      _userMessageCount,
      _messages.lastOrNull?.content,
    );

    JournalService().addEntry(JournalEntry(
      id: const Uuid().v4(),
      coachId: widget.coach.id,
      coachName: widget.coach.name,
      coachEmoji: widget.coach.emoji,
      timestamp: DateTime.now(),
      messageCount: _messages.length,
      moodLabel: _currentMood?.label,
      moodEmoji: _currentMood?.emoji,
      moodScore: _currentMood?.score,
      keyTopics: [
        widget.coach.category,
        ...widget.coach.expertise.take(2)
      ],
      summary: summary.summary,
      conversationHighlights: [summary.quote],
    ));

    AchievementService().increment('wisdom_collector');
    if (_currentMood == Mood.sad) {
      AchievementService().increment('vulnerability');
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SessionSummarySheet(
        summary: summary,
        coachEmoji: widget.coach.emoji,
        coachId: widget.coach.id,
        coachName: widget.coach.name,
        coachColor: widget.coach.color,
        sessionCount: _userMessageCount,
        sessionStart: _sessionStart,
      ),
    );
  }

  void _showSessionNotes() {
    final notesController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundDarkElevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded,
                      color: AppColors.secondaryLavender, size: 22),
                  const SizedBox(width: 8),
                  Text('Session Notes',
                      style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.textPrimaryDark)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textTertiaryDark, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Private notes — only visible to you.',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiaryDark)),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 6,
                autofocus: true,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimaryDark),
                decoration: InputDecoration(
                  hintText: 'Write your thoughts, key takeaways...',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textTertiaryDark),
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final text = notesController.text.trim();
                    if (text.isNotEmpty) {
                      final prefs =
                          await SharedPreferences.getInstance();
                      final key =
                          'session_notes_${widget.coach.id}_${DateTime.now().toIso8601String().substring(0, 10)}';
                      final existing =
                          prefs.getStringList(key) ?? [];
                      existing.add(text);
                      await prefs.setStringList(key, existing);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text('Save Note',
                      style: AppTextStyles.button.copyWith(
                          color: AppColors.backgroundDark,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final coachColor = widget.coach.color;
    final cred = _credential;

    return Scaffold(
      appBar: _showSessionOverlay
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (_messages.where((m) => m.isUser).length >= 3) {
                    _showSessionSummary();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Hero(
                tag: widget.heroTag ?? 'coach-${widget.coach.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar with verified badge  
                      CoachPhoto(
                        coach: widget.coach,
                        size: 36,
                        showVerified: true,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(widget.coach.name,
                              style: AppTextStyles.titleSmall
                                  .copyWith(
                                      color: AppColors
                                          .textPrimaryDark)),
                          if (cred != null)
                            Text(
                              cred.credentials,
                              style: AppTextStyles.caption
                                  .copyWith(
                                color: AppColors
                                    .textTertiaryDark,
                                fontSize: 10,
                              ),
                            )
                          else if (_relationshipLevel != null)
                            Text(
                              '${_relationshipLevel!.emoji} ${_relationshipLevel!.title}',
                              style: AppTextStyles.caption
                                  .copyWith(
                                      color: AppColors
                                          .secondaryLavender),
                            )
                          else
                            Text(widget.coach.title,
                                style: AppTextStyles.caption
                                    .copyWith(
                                        color: AppColors
                                            .textTertiaryDark)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.phone_rounded,
                      color: AppColors.tertiarySage),
                  tooltip: 'Voice Call',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VoiceCallScreen(
                          coach: widget.coach),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.videocam_rounded,
                      color: AppColors.primaryPeach),
                  tooltip: 'Video Call',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VoiceCallScreen(
                          coach: widget.coach, isVideoCall: true),
                    ),
                  ),
                ),
                if (_chemistry != null &&
                    _chemistry!.messageCount >= 5)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _ChemistryBadge(
                        score: _chemistry!.score),
                  ),
              ],
            ),
      body: Stack(
        children: [
          // Main chat body
          AnimatedBuilder(
            animation: _gradientController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.backgroundDark,
                      Color.lerp(
                          AppColors.backgroundDark,
                          coachColor.withValues(alpha: 0.08),
                          _gradientController.value)!,
                      AppColors.backgroundDark,
                    ],
                    stops: [
                      0.0,
                      0.3 + 0.4 * _gradientController.value,
                      1.0
                    ],
                  ),
                ),
                child: child,
              );
            },
            child: Column(
              children: [
                if (!_showSessionOverlay) ...[
                  // Session timer bar
                  _SessionTimerBar(
                    timerText: _sessionTimerText,
                    coachColor: coachColor,
                  ),
                  // Confidentiality note
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Text(
                      '🔒 This session is confidential',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiaryDark
                            .withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Mood tracker
                  _MoodTracker(
                      currentMood: _currentMood,
                      onMoodSelected: _selectMood),
                  if (_socialProof != null)
                    _SocialProofBar(data: _socialProof!),
                ],
                Expanded(
                  child: _showSessionOverlay
                      ? const SizedBox.shrink()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(
                              16, 8, 16, 8),
                          itemCount: _messages.length +
                              (_isTyping ? 1 : 0) +
                              (_streamingText.isNotEmpty
                                  ? 1
                                  : 0),
                          itemBuilder: (context, i) {
                            if (i < _messages.length) {
                              final msg = _messages[i];
                              if (msg.id
                                  .startsWith('insight-')) {
                                return _InsightCard(
                                    text: msg.content);
                              }
                              if (msg.id
                                  .startsWith('pro-nudge-')) {
                                return _ProNudgeBanner(
                                    onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const PaywallScreen()));
                                });
                              }
                              return _MessageBubble(
                                  message: msg,
                                  index: i,
                                  coachEmoji:
                                      widget.coach.emoji,
                                  isVerified: true);
                            }
                            if (_isTyping) {
                              return _buildTypingIndicator();
                            }
                            if (_streamingText.isNotEmpty) {
                              return _buildStreamingBubble();
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                ),
                if (!_showSessionOverlay)
                  // Input
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                        16, 12, 16, 24),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDarkElevated,
                      border: Border(
                          top: BorderSide(
                              color: Colors.white
                                  .withValues(alpha: 0.05))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: AppTextStyles.bodyMedium
                                .copyWith(
                                    color: AppColors
                                        .textPrimaryDark),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              filled: true,
                              fillColor:
                                  AppColors.backgroundDark,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12),
                            ),
                            onSubmitted: (_) => _send(),
                            textInputAction:
                                TextInputAction.send,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Semantics(
                          button: true,
                          label: 'Send message',
                          child: GestureDetector(
                            onTap: _send,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPeach,
                                borderRadius:
                                    BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                  Icons
                                      .arrow_upward_rounded,
                                  color: AppColors
                                      .backgroundDark,
                                  size: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Session Notes FAB
          if (!_showSessionOverlay)
            Positioned(
              right: 16,
              bottom: 100,
              child: GestureDetector(
                onTap: _showSessionNotes,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDarkElevated,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.secondaryLavender
                            .withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit_note_rounded,
                      color: AppColors.secondaryLavender,
                      size: 22),
                ),
              ),
            ),
          // Relationship milestone banner
          if (_showRelationshipBanner &&
              _relationshipLevel != null)
            Positioned(
              top: 60,
              left: 24,
              right: 24,
              child: _RelationshipBanner(
                coachName: widget.coach.name,
                level: _relationshipLevel!,
              ),
            ),
          // Session Starting Overlay
          if (_showSessionOverlay)
            _SessionStartOverlay(
              coach: widget.coach,
              credential: _credential,
            ),
        ],
      ),
    );
  }

  Widget _buildStreamingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
          ),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Text(
          '$_streamingText▊',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimaryDark,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final cred = _credential;
    final typingMsg = cred?.typingMessage ??
        '${widget.coach.name} is thinking...';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
          ),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDots(),
            const SizedBox(width: 10),
            Text(
              typingMsg,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiaryDark,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SESSION START OVERLAY
// ═══════════════════════════════════════════════════════

class _SessionStartOverlay extends StatefulWidget {
  final Coach coach;
  final CoachCredential? credential;
  const _SessionStartOverlay({required this.coach, this.credential});

  @override
  State<_SessionStartOverlay> createState() =>
      _SessionStartOverlayState();
}

class _SessionStartOverlayState extends State<_SessionStartOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cred = widget.credential;
    return FadeTransition(
      opacity:
          CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
      child: Container(
        color: AppColors.backgroundDark,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Coach avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: widget.coach.color
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: widget.coach.color
                          .withValues(alpha: 0.3),
                      width: 2),
                ),
                child: Center(
                  child: Text(widget.coach.emoji,
                      style: const TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.coach.name,
                style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimaryDark),
              ),
              if (cred != null) ...[
                const SizedBox(height: 4),
                Text(
                  cred.credentials,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondaryDark),
                ),
              ],
              const SizedBox(height: 32),
              Text(
                'Your session is starting...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryPeach,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                      AppColors.primaryPeach
                          .withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SESSION TIMER BAR
// ═══════════════════════════════════════════════════════

class _SessionTimerBar extends StatelessWidget {
  final String timerText;
  final Color coachColor;
  const _SessionTimerBar(
      {required this.timerText, required this.coachColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 6),
      color: AppColors.backgroundDarkElevated
          .withValues(alpha: 0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.tertiarySage,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.tertiarySage.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Session in progress • $timerText',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondaryDark,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SOCIAL PROOF BAR
// ═══════════════════════════════════════════════════════

class _SocialProofBar extends StatelessWidget {
  final SocialProofData data;
  const _SocialProofBar({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.secondaryLavender.withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(Icons.people_outline_rounded,
              size: 14,
              color: AppColors.secondaryLavender
                  .withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${_formatNumber(data.weeklyUsers)} people chatted this week  •  Trending: ${data.topTopic}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiaryDark,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

// ═══════════════════════════════════════════════════════
// INSIGHT CARD (Variable Reward)
// ═══════════════════════════════════════════════════════

class _InsightCard extends StatefulWidget {
  final String text;
  const _InsightCard({required this.text});

  @override
  State<_InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<_InsightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600))
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity:
          CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _ctrl,
                curve: Curves.easeOutCubic)),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondaryLavender
                    .withValues(alpha: 0.12),
                AppColors.primaryPeach
                    .withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.secondaryLavender
                    .withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✨',
                  style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text('Session Insight',
                        style: AppTextStyles.labelSmall
                            .copyWith(
                          color:
                              AppColors.secondaryLavender,
                          letterSpacing: 1,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      widget.text
                          .replaceFirst('💡 ', ''),
                      style: AppTextStyles.bodySmall
                          .copyWith(
                        color:
                            AppColors.textPrimaryDark,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// RELATIONSHIP MILESTONE BANNER
// ═══════════════════════════════════════════════════════

class _RelationshipBanner extends StatefulWidget {
  final String coachName;
  final RelationshipLevel level;
  const _RelationshipBanner(
      {required this.coachName, required this.level});

  @override
  State<_RelationshipBanner> createState() =>
      _RelationshipBannerState();
}

class _RelationshipBannerState
    extends State<_RelationshipBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500))
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity:
          CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _ctrl,
                curve: Curves.easeOutBack)),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondaryLavender
                    .withValues(alpha: 0.9),
                AppColors.primaryPeach
                    .withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryLavender
                    .withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(widget.level.emoji,
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.level.title,
                        style: AppTextStyles.titleSmall
                            .copyWith(
                          color:
                              AppColors.backgroundDark,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(
                        '${widget.coachName} ${widget.level.description}',
                        style: AppTextStyles.caption
                            .copyWith(
                          color: AppColors.backgroundDark
                              .withValues(alpha: 0.8),
                          fontSize: 11,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SESSION SUMMARY SHEET
// ═══════════════════════════════════════════════════════

class _SessionSummarySheet extends StatefulWidget {
  final SessionSummary summary;
  final String coachEmoji;
  final String coachId;
  final String coachName;
  final Color coachColor;
  final int sessionCount;
  final DateTime sessionStart;
  const _SessionSummarySheet({
    required this.summary,
    required this.coachEmoji,
    required this.coachId,
    required this.coachName,
    required this.coachColor,
    required this.sessionCount,
    required this.sessionStart,
  });

  @override
  State<_SessionSummarySheet> createState() =>
      _SessionSummarySheetState();
}

class _SessionSummarySheetState
    extends State<_SessionSummarySheet> {
  int _rating = 0;
  bool _wisdomSaved = false;

  String get _duration {
    final diff =
        DateTime.now().difference(widget.sessionStart);
    if (diff.inMinutes < 1) return 'Less than a minute';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    final wisdom =
        EngagementService().getWisdom(widget.sessionCount);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(widget.coachEmoji,
                style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Session Complete',
                style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimaryDark)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('⏱ $_duration',
                    style: AppTextStyles.bodySmall.copyWith(
                        color:
                            AppColors.textTertiaryDark)),
                const SizedBox(width: 16),
                Text(
                    '💬 ${widget.summary.messageCount} messages',
                    style: AppTextStyles.bodySmall.copyWith(
                        color:
                            AppColors.textTertiaryDark)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(widget.summary.summary,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                      height: 1.5)),
            ),
            const SizedBox(height: 16),
            Text('⭐ Rate this session',
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondaryDark,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () =>
                      setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4),
                    child: Icon(
                      i < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: i < _rating
                          ? AppColors.primaryPeach
                          : AppColors.textTertiaryDark,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  widget.coachColor
                      .withValues(alpha: 0.15),
                  AppColors.backgroundDarkElevated,
                ]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: widget.coachColor
                        .withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Text(
                      '✨ WISDOM #${widget.sessionCount} of ∞',
                      style:
                          AppTextStyles.caption.copyWith(
                        color: widget.coachColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      )),
                  const SizedBox(height: 8),
                  Text('Today\'s wisdom: $wisdom',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall
                          .copyWith(
                        color:
                            AppColors.textPrimaryDark,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      )),
                  const SizedBox(height: 10),
                  if (!_wisdomSaved)
                    GestureDetector(
                      onTap: () async {
                        await saveWisdomCard(WisdomEntry(
                          wisdom: wisdom,
                          coachId: widget.coachId,
                          cardNumber:
                              widget.sessionCount,
                          date: DateTime.now()
                              .toIso8601String(),
                        ));
                        setState(
                            () => _wisdomSaved = true);
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.coachColor
                              .withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
                            'Add to Collection',
                            style: AppTextStyles
                                .labelSmall
                                .copyWith(
                                    color: widget
                                        .coachColor)),
                      ),
                    )
                  else
                    Text('✅ Added to collection!',
                        style: AppTextStyles.caption
                            .copyWith(
                                color: AppColors
                                    .tertiarySage)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Continue tomorrow 👋',
                style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.primaryPeach)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Done',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.backgroundDark,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Message Bubble — Professional card style for coach
// ═══════════════════════════════════════════════════════

class _MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final int index;
  final String coachEmoji;
  final bool isVerified;
  const _MessageBubble({
    required this.message,
    required this.index,
    required this.coachEmoji,
    this.isVerified = false,
  });

  @override
  State<_MessageBubble> createState() =>
      _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;
    final isUser = msg.isUser;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Align(
          alignment: isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                // Coach avatar with verified badge
                Padding(
                  padding: const EdgeInsets.only(
                      right: 8, bottom: 10),
                  child: Stack(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors
                              .backgroundDarkElevated,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                              widget.coachEmoji,
                              style: const TextStyle(
                                  fontSize: 16)),
                        ),
                      ),
                      if (widget.isVerified)
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors
                                  .tertiarySage,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors
                                      .backgroundDark,
                                  width: 1.5),
                            ),
                            child: const Icon(
                                Icons.check_rounded,
                                size: 7,
                                color: AppColors
                                    .backgroundDark),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context).size.width *
                              0.72),
                  margin:
                      const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primaryPeach
                        : AppColors
                            .backgroundDarkElevated,
                    borderRadius: BorderRadius.only(
                      topLeft:
                          const Radius.circular(20),
                      topRight:
                          const Radius.circular(20),
                      bottomLeft: Radius.circular(
                          isUser ? 20 : 6),
                      bottomRight: Radius.circular(
                          isUser ? 6 : 20),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: Colors.white
                                .withValues(
                                    alpha: 0.04)),
                  ),
                  child: Text(
                    msg.content,
                    style: AppTextStyles.bodyMedium
                        .copyWith(
                      color: isUser
                          ? AppColors.backgroundDark
                          : AppColors
                              .textPrimaryDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Mood Tracker
// ═══════════════════════════════════════════════════════

class _MoodTracker extends StatelessWidget {
  final Mood? currentMood;
  final ValueChanged<Mood> onMoodSelected;
  const _MoodTracker(
      {required this.currentMood,
      required this.onMoodSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated
            .withValues(alpha: 0.7),
        border: Border(
            bottom: BorderSide(
                color:
                    Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Text('Mood:',
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiaryDark)),
          const SizedBox(width: 8),
          ...Mood.values.map((mood) {
            final selected = currentMood == mood;
            return Semantics(
              selected: selected,
              label: 'Mood: ${mood.label}',
              button: true,
              child: GestureDetector(
                onTap: () => onMoodSelected(mood),
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryPeach
                            .withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(10),
                    border: selected
                        ? Border.all(
                            color:
                                AppColors.primaryPeach,
                            width: 1.5)
                        : null,
                  ),
                  child: Text(mood.emoji,
                      style: TextStyle(
                          fontSize:
                              selected ? 22 : 18)),
                ),
              ),
            );
          }),
          if (currentMood != null) ...[
            const Spacer(),
            Text(currentMood!.label,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryPeach)),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Chemistry Badge
// ═══════════════════════════════════════════════════════

class _ChemistryBadge extends StatefulWidget {
  final double score;
  const _ChemistryBadge({required this.score});

  @override
  State<_ChemistryBadge> createState() =>
      _ChemistryBadgeState();
}

class _ChemistryBadgeState extends State<_ChemistryBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.score.round();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return GestureDetector(
          onTap: () => _showDialog(context),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (widget.score / 100) *
                      _controller.value,
                  strokeWidth: 3,
                  backgroundColor: Colors.white
                      .withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(
                    pct > 70
                        ? AppColors.tertiarySage
                        : pct > 40
                            ? AppColors.primaryPeach
                            : AppColors
                                .textTertiaryDark,
                  ),
                ),
                Text(
                    '${(pct * _controller.value).round()}',
                    style:
                        AppTextStyles.caption.copyWith(
                      color:
                          AppColors.textPrimaryDark,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            AppColors.backgroundDarkElevated,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Chemistry Score',
            style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimaryDark)),
        content: Text(
          '${widget.score.round()}% — Based on conversation patterns, engagement, mood trends, and session consistency.',
          style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it',
                style: TextStyle(
                    color: AppColors.primaryPeach)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Pro Nudge Banner
// ═══════════════════════════════════════════════════════

class _ProNudgeBanner extends StatefulWidget {
  final VoidCallback onTap;
  const _ProNudgeBanner({required this.onTap});

  @override
  State<_ProNudgeBanner> createState() =>
      _ProNudgeBannerState();
}

class _ProNudgeBannerState extends State<_ProNudgeBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500))
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity:
          CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(
              horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryPeach
                    .withValues(alpha: 0.12),
                AppColors.secondaryLavender
                    .withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primaryPeach
                    .withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Text('⭐',
                  style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text('Unlock Unlimited Sessions',
                        style: AppTextStyles.labelSmall
                            .copyWith(
                          color:
                              AppColors.primaryPeach,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        )),
                    const SizedBox(height: 2),
                    Text(
                        'Unlimited sessions • All coaches • Priority responses',
                        style: AppTextStyles.caption
                            .copyWith(
                          color: AppColors
                              .textSecondaryDark,
                          fontSize: 11,
                        )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPeach,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text('Go Pro',
                    style: AppTextStyles.labelSmall
                        .copyWith(
                      color:
                          AppColors.backgroundDark,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Typing Dots
// ═══════════════════════════════════════════════════════

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true);
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) c.forward();
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _controllers.map((c) {
        return AnimatedBuilder(
          animation: c,
          builder: (_, _) => Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 3),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.textTertiaryDark
                  .withValues(alpha: 0.4 + c.value * 0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      }).toList(),
    );
  }
}
