import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TouchstoneScreen extends StatefulWidget {
  const TouchstoneScreen({super.key});

  @override
  State<TouchstoneScreen> createState() => _TouchstoneScreenState();
}

class _TouchstoneScreenState extends State<TouchstoneScreen> with TickerProviderStateMixin {
  // Touch state
  bool _touching = false;
  Offset _touchPos = Offset.zero;
  int _touchSeconds = 0;
  Timer? _timer;

  // Calming words
  static const _words = ['breathe', 'calm', 'present', 'safe', 'here', 'peace', 'release', 'let go'];
  String _currentWord = 'breathe';
  int _wordIndex = 0;

  // Word fade animation
  late AnimationController _wordCtrl;
  late Animation<double> _wordOpacity;

  // Stone glow animation
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _wordCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _wordOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_wordCtrl);

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wordCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _onTouchStart(Offset pos) {
    HapticFeedback.lightImpact();
    setState(() { _touching = true; _touchPos = pos; _touchSeconds = 0; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _touchSeconds++);
      // Cycle words every 4 seconds
      if (_touchSeconds % 4 == 0) {
        _wordIndex = (_wordIndex + 1) % _words.length;
        _currentWord = _words[_wordIndex];
        _wordCtrl.forward(from: 0);
      }
    });
    _wordCtrl.forward(from: 0);
  }

  void _onTouchUpdate(Offset pos) {
    HapticFeedback.selectionClick();
    setState(() => _touchPos = pos);
  }

  void _onTouchEnd() {
    _timer?.cancel();
    setState(() => _touching = false);
  }

  String get _formattedTime {
    final m = _touchSeconds ~/ 60;
    final s = _touchSeconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String? get _milestone {
    if (_touchSeconds >= 120) return 'Your heart rate is slowing. Feel the weight lifting.';
    if (_touchSeconds >= 30) return 'You\'re doing great. Stay here as long as you need.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2 - 40);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Touchstone', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
            Text('Your moment of calm', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
          ],
        ),
      ),
      body: GestureDetector(
        onPanStart: (d) => _onTouchStart(d.localPosition),
        onPanUpdate: (d) => _onTouchUpdate(d.localPosition),
        onPanEnd: (_) => _onTouchEnd(),
        onTapDown: (d) => _onTouchStart(d.localPosition),
        onTapUp: (_) => _onTouchEnd(),
        child: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, a) => CustomPaint(
            painter: _TouchstonePainter(
              touchPos: _touching ? _touchPos : null,
              center: center,
              glowValue: _glowCtrl.value,
            ),
            child: SizedBox.expand(
              child: Stack(
                children: [
                  // Calming word
                  if (_touching)
                    Positioned(
                      top: center.dy + 100,
                      left: 0,
                      right: 0,
                      child: FadeTransition(
                        opacity: _wordOpacity,
                        child: Text(
                          _currentWord,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.textPrimaryDark.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  // Timer + milestone
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        if (_touching) ...[
                          Text(
                            '$_formattedTime of stillness',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark),
                          ),
                          if (_milestone != null) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 48),
                              child: Text(
                                _milestone!,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryLavender.withValues(alpha: 0.8)),
                              ),
                            ),
                          ],
                        ] else
                          Text(
                            'Touch the stone',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark.withValues(alpha: 0.5)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TouchstonePainter extends CustomPainter {
  final Offset? touchPos;
  final Offset center;
  final double glowValue;

  _TouchstonePainter({this.touchPos, required this.center, required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle radial bg glow
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (center.dx / size.width) * 2 - 1,
          (center.dy / size.height) * 2 - 1,
        ),
        radius: 0.5,
        colors: [
          AppColors.backgroundDarkElevated.withValues(alpha: 0.6),
          AppColors.backgroundDark,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Stone
    final stoneW = 180.0;
    final stoneH = 130.0;
    final stoneRect = Rect.fromCenter(center: center, width: stoneW, height: stoneH);
    final stoneRRect = RRect.fromRectAndRadius(stoneRect, const Radius.circular(65));

    // Shadow
    canvas.drawRRect(
      stoneRRect.shift(const Offset(0, 8)),
      Paint()..color = Colors.black.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Gradient shifts with touch position
    double gradAngle = glowValue * pi * 0.3;
    if (touchPos != null) {
      gradAngle += (touchPos!.dx - center.dx) / size.width * pi * 0.5;
    }

    final Color c1 = touchPos != null ? AppColors.primaryPeach.withValues(alpha: 0.7) : AppColors.primaryPeach.withValues(alpha: 0.4);
    final Color c2 = touchPos != null ? AppColors.secondaryLavender.withValues(alpha: 0.6) : AppColors.secondaryLavender.withValues(alpha: 0.3);

    final stonePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(cos(gradAngle), sin(gradAngle)),
        end: Alignment(-cos(gradAngle), -sin(gradAngle)),
        colors: [c1, c2],
      ).createShader(stoneRect);

    canvas.drawRRect(stoneRRect, stonePaint);

    // Subtle inner highlight
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 0.8,
        colors: [Colors.white.withValues(alpha: 0.08 + glowValue * 0.04), Colors.transparent],
      ).createShader(stoneRect);
    canvas.drawRRect(stoneRRect, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _TouchstonePainter old) => true;
}
