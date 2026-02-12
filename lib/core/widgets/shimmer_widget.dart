import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-1.0 + 2.0 * _controller.value + 1, 0),
              colors: [
                AppColors.backgroundDarkElevated,
                AppColors.backgroundDarkElevated.withValues(alpha: 0.5),
                AppColors.backgroundDarkElevated,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerCoachCard extends StatelessWidget {
  const ShimmerCoachCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerWidget(width: 40, height: 40, borderRadius: BorderRadius.circular(20)),
          const SizedBox(height: 10),
          ShimmerWidget(width: 60, height: 12, borderRadius: BorderRadius.circular(6)),
          const SizedBox(height: 6),
          ShimmerWidget(width: 40, height: 10, borderRadius: BorderRadius.circular(5)),
        ],
      ),
    );
  }
}
