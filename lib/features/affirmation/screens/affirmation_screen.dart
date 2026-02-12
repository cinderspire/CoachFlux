import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_mesh_bg.dart';

/// Fullscreen daily affirmation splash — appears on app open.
/// Personalized greeting + motivational quote. Fades in beautifully.
class AffirmationScreen extends StatefulWidget {
  final Widget nextScreen;
  const AffirmationScreen({super.key, required this.nextScreen});

  @override
  State<AffirmationScreen> createState() => _AffirmationScreenState();
}

class _AffirmationScreenState extends State<AffirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late AnimationController _exitCtrl;
  String _name = '';
  late String _quote;
  late String _subtext;

  final _quotes = [
    ['Every day is a new chance to grow.', 'Your coach believes in you 💜'],
    ['You are capable of extraordinary things.', 'Let\'s make today count ✨'],
    ['The best investment is in yourself.', 'Your growth matters 🌱'],
    ['Small steps lead to big transformations.', 'You\'re already moving forward 🚀'],
    ['Your potential is limitless.', 'Let\'s unlock it together 💎'],
    ['Be gentle with yourself. Progress isn\'t linear.', 'You\'re doing great 🌊'],
    ['Today\'s effort is tomorrow\'s reward.', 'Keep showing up 🔥'],
    ['You have the power to rewrite your story.', 'Start a new chapter today 📖'],
  ];

  @override
  void initState() {
    super.initState();
    final rand = Random();
    final pair = _quotes[rand.nextInt(_quotes.length)];
    _quote = pair[0];
    _subtext = pair[1];

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _loadName();

    // Auto-dismiss after 3.5s
    Future.delayed(const Duration(milliseconds: 3500), _dismiss);
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _name = prefs.getString('user_name') ?? '');
    }
  }

  void _dismiss() {
    if (!mounted) return;
    _exitCtrl.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, a1, a2) => widget.nextScreen,
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (_, anim, a3, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _exitCtrl,
          builder: (context, child) {
            return Opacity(
              opacity: 1.0 - _exitCtrl.value,
              child: child,
            );
          },
          child: GradientMeshBackground(
            intensity: 1.5,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    // Greeting
                    FadeTransition(
                      opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic)),
                        child: Text(
                          _name.isNotEmpty
                              ? '${_greeting()}, $_name'
                              : _greeting(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Main quote
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _fadeCtrl,
                        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.4),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideCtrl,
                          curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
                        )),
                        child: Text(
                          _quote,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Subtext
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _fadeCtrl,
                        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                      ),
                      child: Text(
                        _subtext,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryPeach,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(flex: 4),
                    // Tap hint
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _fadeCtrl,
                        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                      ),
                      child: Text(
                        'Tap anywhere to continue',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
