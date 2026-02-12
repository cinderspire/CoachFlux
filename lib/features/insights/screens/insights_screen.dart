import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/analytics_service.dart';
import 'optimization_dashboard_screen.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  AnalyticsData? _data;
  bool _loading = true;
  bool _showMonthly = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await AnalyticsService().getAnalytics();
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPeach))
            : RefreshIndicator(
                color: AppColors.primaryPeach,
                backgroundColor: AppColors.backgroundDarkElevated,
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "You, Optimized" banner
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OptimizationDashboardScreen())),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('You, Optimized', style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text('Your personal growth dashboard', style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Insights',
                                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryDark)),
                          ),
                          GestureDetector(
                            onTap: _exportData,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDarkElevated,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                              ),
                              child: Icon(Icons.download_rounded, size: 20, color: AppColors.textSecondaryDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Growth score
                      _GrowthScoreCard(score: _data!.personalGrowthScore),
                      const SizedBox(height: 16),

                      // Mood chart
                      _buildMoodChart(),
                      const SizedBox(height: 16),

                      // Coach usage
                      if (_data!.coachUsageCounts.isNotEmpty) ...[
                        _CoachUsageChart(usage: _data!.coachUsageCounts),
                        const SizedBox(height: 16),
                      ],

                      // Top topics
                      if (_data!.topicCounts.isNotEmpty) ...[
                        _TopTopics(topics: _data!.topicCounts),
                        const SizedBox(height: 16),
                      ],

                      // Motivational insights
                      if (_data!.motivationalInsights.isNotEmpty)
                        ..._data!.motivationalInsights.map((i) => _InsightCard(text: i)),

                      // Stats
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _miniStat('${_data!.totalSessions}', 'Sessions'),
                          const SizedBox(width: 12),
                          _miniStat('${_data!.totalMessages}', 'Messages'),
                          const SizedBox(width: 12),
                          _miniStat('${_data!.coachUsageCounts.length}', 'Coaches'),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMoodChart() {
    final scores = _showMonthly ? _data!.monthlyMoodScores : _data!.weeklyMoodScores;
    final hasData = scores.any((s) => s >= 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Mood Trend',
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showMonthly = !_showMonthly),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_showMonthly ? '30 days' : '7 days',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primaryPeach)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasData)
            Text('No mood data yet',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark))
          else
            SizedBox(
              height: 120,
              child: CustomPaint(
                size: const Size(double.infinity, 120),
                painter: _MoodChartPainter(scores),
              ),
            ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryPeach)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
          ],
        ),
      ),
    );
  }

  void _exportData() async {
    final data = await AnalyticsService().exportData();
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.backgroundDarkElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Export Data',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
          content: Text(
            'Data exported (${data.length} characters). Copy to clipboard or share.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: AppColors.primaryPeach)),
            ),
          ],
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════
// Growth Score
// ═══════════════════════════════════════════════════════

class _GrowthScoreCard extends StatelessWidget {
  final double score;
  const _GrowthScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.natureGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64, height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (score / 100).clamp(0.0, 1.0),
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(AppColors.backgroundDark.withValues(alpha: 0.5)),
                ),
                Text('${score.round()}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.backgroundDark,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personal Growth Score',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.backgroundDark,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 4),
                Text(
                  score > 70 ? 'Thriving! You\'re making incredible progress 🚀'
                      : score > 40 ? 'Growing steadily — keep showing up! 🌱'
                      : 'Just getting started — every session counts 💫',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.backgroundDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Coach Usage (Pie-like bars)
// ═══════════════════════════════════════════════════════

class _CoachUsageChart extends StatelessWidget {
  final Map<String, int> usage;
  const _CoachUsageChart({required this.usage});

  @override
  Widget build(BuildContext context) {
    final sorted = usage.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold<int>(0, (sum, e) => sum + e.value);
    final colors = [
      AppColors.primaryPeach, AppColors.secondaryLavender, AppColors.tertiarySage,
      AppColors.quaternarySky, const Color(0xFFF97316), const Color(0xFFEC4899),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🥧', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Coach Usage',
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: 16),
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: sorted.asMap().entries.map((entry) {
                  final pct = entry.value.value / total;
                  return Expanded(
                    flex: (pct * 100).round().clamp(1, 100),
                    child: Container(color: colors[entry.key % colors.length]),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...sorted.take(5).toList().asMap().entries.map((entry) {
            final e = entry.value;
            final pct = ((e.value / total) * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: colors[entry.key % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(e.key,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark)),
                  ),
                  Text('$pct%',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiaryDark)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Top Topics
// ═══════════════════════════════════════════════════════

class _TopTopics extends StatelessWidget {
  final Map<String, int> topics;
  const _TopTopics({required this.topics});

  @override
  Widget build(BuildContext context) {
    final sorted = topics.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💬', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Top Topics',
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sorted.take(10).map((e) {
              final opacity = 0.4 + (e.value / sorted.first.value) * 0.6;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLavender.withValues(alpha: opacity * 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondaryLavender.withValues(alpha: opacity * 0.3)),
                ),
                child: Text(
                  '${e.key} (${e.value})',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondaryLavender.withValues(alpha: opacity),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Insight Card
// ═══════════════════════════════════════════════════════

class _InsightCard extends StatelessWidget {
  final String text;
  const _InsightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryLavender.withValues(alpha: 0.08),
            AppColors.primaryPeach.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondaryLavender.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimaryDark,
                  height: 1.4,
                )),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Mood Chart Painter (CustomPaint line graph)
// ═══════════════════════════════════════════════════════

class _MoodChartPainter extends CustomPainter {
  final List<double> scores;
  _MoodChartPainter(this.scores);

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primaryPeach
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = AppColors.primaryPeach
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x40FFB5A7), Color(0x00FFB5A7)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final step = scores.length > 1 ? size.width / (scores.length - 1) : size.width;
    final path = Path();
    final fillPath = Path();
    bool started = false;

    for (int i = 0; i < scores.length; i++) {
      if (scores[i] < 0) continue;
      final x = i * step;
      final y = size.height - (scores[i] * size.height * 0.9) - size.height * 0.05;

      if (!started) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    if (started) {
      final lastIdx = scores.lastIndexWhere((s) => s >= 0);
      fillPath.lineTo(lastIdx * step, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
