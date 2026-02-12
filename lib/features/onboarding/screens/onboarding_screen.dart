import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/engagement_service.dart';
import '../../../core/widgets/gradient_mesh_bg.dart';
import '../../assessment/screens/problem_assessment_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  int _currentPage = 0;
  final _nameController = TextEditingController();
  String? _selectedFeeling;
  final Set<String> _selectedCoaches = {};
  final Set<String> _selectedGoals = {};
  String? _commitmentGoal;

  late AnimationController _fadeCtrl;
  late AnimationController _progressCtrl;

  static const _totalPages = 5;

  final _feelings = [
    ('😊', 'Great', 'Ready to level up'),
    ('😐', 'Okay', 'Looking for direction'),
    ('😔', 'Struggling', 'Need some support'),
    ('🔥', 'Fired Up', 'Ambitious and driven'),
    ('😴', 'Exhausted', 'Running on empty'),
  ];

  final _goals = [
    ('🎯', 'Focus & Productivity'),
    ('🧘', 'Mindfulness & Calm'),
    ('💪', 'Fitness & Energy'),
    ('🚀', 'Career Growth'),
    ('🎨', 'Creativity'),
    ('💰', 'Financial Freedom'),
    ('😴', 'Better Sleep'),
    ('🗣️', 'Communication'),
    ('📚', 'Learning'),
    ('❤️', 'Relationships'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400),
    )..forward();
    _progressCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _fadeCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  bool get _canContinue {
    switch (_currentPage) {
      case 0: return true; // Welcome — always
      case 1: return _nameController.text.trim().isNotEmpty;
      case 2: return _selectedFeeling != null;
      case 3: return _selectedGoals.isNotEmpty;
      case 4: return true; // Commitment is optional
      default: return true;
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('user_feeling', _selectedFeeling ?? '');
    await prefs.setStringList('selected_coaches', _selectedCoaches.toList());
    await prefs.setStringList('selected_goals',
        _selectedGoals.map((g) => g.replaceAll(RegExp(r'^[^\s]+ '), '')).toList());
    if (_commitmentGoal != null) {
      await EngagementService().setCommitmentGoal(_commitmentGoal!);
    }
    // Save personalized first message context
    await prefs.setString('onboarding_context', _buildPersonalizedContext());
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ProblemAssessmentScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, anim, secondaryAnim, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  String _buildPersonalizedContext() {
    final parts = <String>[];
    final name = _nameController.text.trim();
    if (name.isNotEmpty) parts.add('User\'s name is $name.');
    if (_selectedFeeling != null) parts.add('They are currently feeling: $_selectedFeeling.');
    if (_selectedGoals.isNotEmpty) {
      parts.add('Their goals: ${_selectedGoals.join(", ")}.');
    }
    if (_commitmentGoal != null) {
      parts.add('They committed to a 21-day challenge: $_commitmentGoal.');
    }
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientMeshBackground(
        intensity: 0.6,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Animated progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _AnimatedProgressBar(
                  progress: (_currentPage + 1) / _totalPages,
                ),
              ),
              const SizedBox(height: 4),
              // Skip button
              if (_currentPage > 0 && _currentPage < _totalPages - 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: TextButton(
                      onPressed: _finish,
                      child: Text('Skip', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondaryDark)),
                    ),
                  ),
                ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildWelcome(),
                    _buildNamePage(),
                    _buildFeelingPage(),
                    _buildGoalsPage(),
                    _buildCommitment(),
                  ],
                ),
              ),
              // Bottom button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Semantics(
                  button: true,
                  label: _currentPage == _totalPages - 1 ? 'Get Started' : 'Continue',
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _canContinue ? 1.0 : 0.4,
                      child: ElevatedButton(
                        onPressed: _canContinue ? _next : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentPage == _totalPages - 1 ? 'Begin My Journey ✨' : 'Continue',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.backgroundDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  // ─── PAGE 1: Welcome ──────────────────────────────────────────────

  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            label: 'CoachFlux logo',
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPeach.withValues(alpha: 0.3),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: const Center(
                child: Text('⚡', style: TextStyle(fontSize: 56)),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text('Welcome to\nCoachFlux',
            textAlign: TextAlign.center,
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text('Your Mind. Upgraded.',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primaryPeach,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '11 expert AI coaches trained in CBT, DBT, MBSR, Stoic philosophy, and more — working together to build the best version of you.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondaryDark,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          // Trust indicators
          _TrustBadge(icon: Icons.psychology_rounded, text: 'Real therapeutic techniques, not generic advice'),
          const SizedBox(height: 8),
          _TrustBadge(icon: Icons.verified_rounded, text: 'Every method backed by peer-reviewed research'),
          const SizedBox(height: 8),
          _TrustBadge(icon: Icons.lock_rounded, text: '100% private — your data never leaves your device'),
        ],
      ),
    );
  }

  // ─── PAGE 2: Name ─────────────────────────────────────────────────

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👋', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 24),
          Text('What should we call you?',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text('Your coaches will use this to personalize every conversation.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Semantics(
            label: 'Enter your name',
            child: TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              textAlign: TextAlign.center,
              autofocus: false,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              decoration: InputDecoration(
                hintText: 'Your first name',
                hintStyle: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textTertiaryDark.withValues(alpha: 0.4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.backgroundDarkElevated,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PAGE 3: How are you feeling? ─────────────────────────────────

  Widget _buildFeelingPage() {
    final name = _nameController.text.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Text(
            name.isNotEmpty ? 'Hey $name 💜' : 'Hey there 💜',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primaryPeach),
          ),
          const SizedBox(height: 8),
          Text('How are you feeling right now?',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 8),
          Text('This helps us match you with the right coaching tone.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...List.generate(_feelings.length, (i) {
            final (emoji, label, desc) = _feelings[i];
            final selected = _selectedFeeling == label;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Semantics(
                selected: selected,
                label: '$label — $desc',
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _selectedFeeling = label);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryPeach.withValues(alpha: 0.1)
                          : AppColors.backgroundDarkElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? AppColors.primaryPeach : Colors.white.withValues(alpha: 0.05),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(emoji, style: TextStyle(fontSize: selected ? 30 : 26)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label,
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: selected ? AppColors.primaryPeach : AppColors.textPrimaryDark,
                                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                                )),
                              Text(desc,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textTertiaryDark,
                                )),
                            ],
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle_rounded, color: AppColors.primaryPeach, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── PAGE 4: Goals ─────────────────────────────────────────────────

  Widget _buildGoalsPage() {
    String encouragement = '';
    if (_selectedFeeling == 'Struggling') {
      encouragement = 'We\'re glad you\'re here. Let\'s find what lifts you up.';
    } else if (_selectedFeeling == 'Fired Up') {
      encouragement = 'Love that energy! Let\'s channel it.';
    } else if (_selectedFeeling == 'Exhausted') {
      encouragement = 'Rest is growth too. Let\'s find balance.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('What matters to you?',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryDark)),
          const SizedBox(height: 4),
          Text('Pick as many as you like — we\'ll find coaches to match.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
          if (encouragement.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondaryLavender.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(encouragement,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryLavender,
                  fontStyle: FontStyle.italic,
                )),
            ),
          ],
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _goals.map((g) {
                  final (emoji, label) = g;
                  final full = '$emoji $label';
                  final selected = _selectedGoals.contains(full);
                  return Semantics(
                    selected: selected,
                    label: label,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          selected ? _selectedGoals.remove(full) : _selectedGoals.add(full);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryPeach.withValues(alpha: 0.15)
                              : AppColors.backgroundDarkElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? AppColors.primaryPeach : Colors.white.withValues(alpha: 0.05),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(full,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: selected ? AppColors.primaryPeach : AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PAGE 5: 21-Day Commitment ────────────────────────────────────

  Widget _buildCommitment() {
    final commitments = [
      'Build a morning routine',
      'Reduce daily stress',
      'Advance my career',
      'Exercise consistently',
      'Improve my focus',
      'Read more books',
      'Practice mindfulness',
      'Build better habits',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('One last thing ✨',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryDark)),
          const SizedBox(height: 4),
          Text('Pick a 21-day challenge — your coach will guide you daily.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tertiarySage.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tertiarySage.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Text('📅', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('21 days of daily coaching to reach your goal',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.tertiarySage)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: commitments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final c = commitments[i];
                final selected = _commitmentGoal == c;
                return Semantics(
                  selected: selected,
                  label: c,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _commitmentGoal = selected ? null : c);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.tertiarySage.withValues(alpha: 0.12)
                            : AppColors.backgroundDarkElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? AppColors.tertiarySage : Colors.white.withValues(alpha: 0.05),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.tertiarySage : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected ? AppColors.tertiarySage : AppColors.textTertiaryDark,
                                width: 2,
                              ),
                            ),
                            child: selected
                                ? const Icon(Icons.check_rounded, size: 14, color: AppColors.backgroundDark)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(c,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: selected ? AppColors.tertiarySage : AppColors.textSecondaryDark,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              )),
                          ),
                          if (selected)
                            Text('21 days',
                              style: AppTextStyles.caption.copyWith(color: AppColors.tertiarySage)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Trust badge for onboarding credibility
class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TrustBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.tertiarySage.withValues(alpha: 0.8)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondaryDark,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// Smooth animated progress bar with gradient fill
class _AnimatedProgressBar extends StatelessWidget {
  final double progress;
  const _AnimatedProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Onboarding progress ${(progress * 100).round()}%',
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(3),
        ),
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
