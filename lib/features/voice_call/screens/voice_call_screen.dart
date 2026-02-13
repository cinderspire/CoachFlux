import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/models/coach.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/widgets/coach_photo.dart';

/// Premium voice/video call screen with AI coach.
/// Speech-to-Text → Gemini → Text-to-Speech pipeline.
class VoiceCallScreen extends StatefulWidget {
  final Coach coach;
  final bool isVideoCall;
  const VoiceCallScreen({super.key, required this.coach, this.isVideoCall = false});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen>
    with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final GeminiService _gemini = GeminiService();

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isProcessing = false;
  bool _callActive = true;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  String _recognizedText = '';
  String _coachResponse = '';
  Duration _callDuration = Duration.zero;
  Timer? _timer;
  final List<String> _conversationHistory = [];

  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _initSpeech();
    _initTts();
    _startCallTimer();
    _greetUser();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (_recognizedText.isNotEmpty && _callActive) {
            _processUserInput(_recognizedText);
          }
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
        // Auto-listen after coach finishes speaking
        if (_callActive && !_isMuted) {
          Future.delayed(const Duration(milliseconds: 500), _startListening);
        }
      }
    });
  }

  void _startCallTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _callActive) {
        setState(() => _callDuration += const Duration(seconds: 1));
      }
    });
  }

  Future<void> _greetUser() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted || !_callActive) return;

    final greeting = "Hi there! I'm ${widget.coach.name}. "
        "Welcome to our voice session. How are you feeling today?";

    setState(() {
      _coachResponse = greeting;
      _isSpeaking = true;
    });
    _conversationHistory.add('Coach: $greeting');
    await _tts.speak(greeting);
  }

  Future<void> _startListening() async {
    if (!_callActive || _isSpeaking || _isMuted) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() => _recognizedText = result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _processUserInput(String text) async {
    if (text.trim().isEmpty || !_callActive) return;

    setState(() {
      _isProcessing = true;
      _coachResponse = '';
    });

    _conversationHistory.add('User: $text');

    try {
      // Build context from conversation history
      final context = _conversationHistory.takeLast(10).join('\n');
      final prompt = '''You are ${widget.coach.name}, an AI coach in a live voice call.
Keep your response SHORT (2-3 sentences max) and conversational — this is a voice call, not text.
Be warm, direct, and helpful. No bullet points or formatting.

Conversation so far:
$context

Respond naturally to the user's latest message.''';

      final response = await _gemini.chat(
        coach: widget.coach,
        history: [],
        userMessage: prompt,
      );
      if (!mounted || !_callActive) return;

      _conversationHistory.add('Coach: $response');
      setState(() {
        _coachResponse = response;
        _isProcessing = false;
        _isSpeaking = true;
      });

      await _tts.speak(response);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _coachResponse = "I'm having trouble connecting. Could you repeat that?";
          _isSpeaking = true;
        });
        await _tts.speak(_coachResponse);
      }
    }
  }

  void _toggleMute() {
    HapticFeedback.mediumImpact();
    setState(() => _isMuted = !_isMuted);
    if (_isMuted && _isListening) _stopListening();
  }

  void _toggleSpeaker() {
    HapticFeedback.mediumImpact();
    setState(() => _isSpeakerOn = !_isSpeakerOn);
  }

  void _endCall() {
    HapticFeedback.heavyImpact();
    _tts.stop();
    _speech.stop();
    setState(() => _callActive = false);
    _timer?.cancel();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _fadeCtrl.dispose();
    _timer?.cancel();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
        child: Stack(
          children: [
            // Animated background gradient
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2 + 0.3 * _pulseCtrl.value,
                      colors: [
                        widget.coach.color.withValues(alpha: 0.08 + 0.04 * _pulseCtrl.value),
                        AppColors.backgroundDark,
                      ],
                    ),
                  ),
                );
              },
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Call type indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.coach.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: widget.coach.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isVideoCall ? Icons.videocam_rounded : Icons.phone_rounded,
                          size: 16,
                          color: widget.coach.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.isVideoCall ? 'Video Session' : 'Voice Session',
                          style: AppTextStyles.caption.copyWith(
                            color: widget.coach.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(_callDuration),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Coach avatar with pulse animation
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, child) {
                      final scale = _isSpeaking
                          ? 1.0 + 0.05 * _pulseCtrl.value
                          : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow rings
                        if (_isSpeaking || _isListening)
                          ...List.generate(3, (i) {
                            return AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (context, _) {
                                final size = 160.0 + (i * 30) + 10 * _pulseCtrl.value;
                                return Container(
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: (_isSpeaking ? widget.coach.color : AppColors.tertiarySage)
                                          .withValues(alpha: 0.2 - i * 0.05),
                                      width: 2,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        // Coach photo
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.coach.color.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CoachPhoto(
                            coach: widget.coach,
                            size: 140,
                            showVerified: true,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Coach name
                  Text(
                    widget.coach.name,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.coach.title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiaryDark,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Status / Live transcript
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isProcessing
                          ? Row(
                              key: const ValueKey('processing'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: widget.coach.color,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.coach.name} is thinking...',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondaryDark,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            )
                          : _isListening
                              ? Column(
                                  key: const ValueKey('listening'),
                                  children: [
                                    // Sound wave animation
                                    _SoundWave(
                                      color: AppColors.tertiarySage,
                                      animation: _waveCtrl,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _recognizedText.isNotEmpty
                                          ? _recognizedText
                                          : 'Listening...',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: _recognizedText.isNotEmpty
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textTertiaryDark,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                )
                              : _isSpeaking
                                  ? Column(
                                      key: const ValueKey('speaking'),
                                      children: [
                                        _SoundWave(
                                          color: widget.coach.color,
                                          animation: _waveCtrl,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _coachResponse,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.textSecondaryDark,
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    )
                                  : Text(
                                      key: const ValueKey('idle'),
                                      'Tap the microphone to speak',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textTertiaryDark,
                                      ),
                                    ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Control buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mute
                        _CallButton(
                          icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                          label: _isMuted ? 'Unmute' : 'Mute',
                          color: _isMuted ? Colors.red : AppColors.textSecondaryDark,
                          bgColor: AppColors.backgroundDarkElevated,
                          onTap: _toggleMute,
                        ),

                        // Main mic button (tap to talk)
                        GestureDetector(
                          onTap: _isListening ? _stopListening : _startListening,
                          child: AnimatedBuilder(
                            animation: _waveCtrl,
                            builder: (context, child) {
                              final scale = _isListening
                                  ? 1.0 + 0.08 * _waveCtrl.value
                                  : 1.0;
                              return Transform.scale(scale: scale, child: child);
                            },
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isListening
                                    ? AppColors.tertiarySage
                                    : widget.coach.color,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isListening
                                            ? AppColors.tertiarySage
                                            : widget.coach.color)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isListening
                                    ? Icons.hearing_rounded
                                    : Icons.mic_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),

                        // Speaker
                        _CallButton(
                          icon: _isSpeakerOn
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          label: 'Speaker',
                          color: _isSpeakerOn
                              ? widget.coach.color
                              : AppColors.textSecondaryDark,
                          bgColor: AppColors.backgroundDarkElevated,
                          onTap: _toggleSpeaker,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // End call button
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.shade700,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'End Session',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.red.shade300,
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Call Control Button ─────────────────────────────────────────

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiaryDark,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sound Wave Animation ────────────────────────────────────────

class _SoundWave extends StatelessWidget {
  final Color color;
  final Animation<double> animation;

  const _SoundWave({required this.color, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (i) {
            final phase = (i - 3).abs() / 3.0;
            final height = 8.0 + 20.0 * (1 - phase) * animation.value;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.5 + 0.5 * animation.value),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

extension _TakeLast<T> on List<T> {
  List<T> takeLast(int n) => length <= n ? this : sublist(length - n);
}
