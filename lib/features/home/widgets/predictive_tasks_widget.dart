import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class _PredictedTask {
  final String icon;
  final String title;
  final String duration;
  final String? route;
  const _PredictedTask(this.icon, this.title, this.duration, [this.route]);
}

class PredictiveTasksWidget extends StatelessWidget {
  const PredictiveTasksWidget({super.key});

  List<_PredictedTask> get _tasks {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return const [
        _PredictedTask('🌬️', 'Morning breathwork', '2 min', '/exercises'),
        _PredictedTask('🎯', 'Set today\'s intention', '2 min', '/journal'),
        _PredictedTask('🙏', 'Gratitude practice', '3 min', '/exercises'),
      ];
    } else if (hour >= 12 && hour < 17) {
      return const [
        _PredictedTask('🔄', 'Mid-day reset', '2 min', '/exercises'),
        _PredictedTask('🎯', 'Focus session', '5 min', '/exercises'),
        _PredictedTask('⚡', 'Energy check-in', '2 min', '/exercises'),
      ];
    } else if (hour >= 17 && hour < 21) {
      return const [
        _PredictedTask('🌅', 'Evening reflection', '3 min', '/journal'),
        _PredictedTask('🌬️', 'Wind-down breathing', '3 min', '/exercises'),
        _PredictedTask('📝', 'Journal entry', '5 min', '/journal'),
      ];
    } else {
      return const [
        _PredictedTask('🌙', 'Sleep preparation', '3 min', '/exercises'),
        _PredictedTask('🧍', 'Body scan', '5 min', '/exercises'),
        _PredictedTask('🪨', 'Touchstone session', '3 min', '/touchstone'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _tasks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Predicted For You ✨',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 88,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: tasks.length,
            separatorBuilder: (_, a) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final t = tasks[i];
              return GestureDetector(
                onTap: () {
                  if (t.route != null) Navigator.of(context).pushNamed(t.route!);
                },
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDarkElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.textTertiaryDark.withValues(alpha: 0.1), width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.icon, style: const TextStyle(fontSize: 20)),
                      const Spacer(),
                      Text(t.title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimaryDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(t.duration, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark, fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
