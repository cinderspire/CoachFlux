import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/journal_service.dart';
import '../../../core/models/coach.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalEntry> _entries = [];
  List<String> _insights = [];
  bool _loading = true;
  String? _filterCoachId;
  String? _filterMood;
  bool _showInsights = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entries = await JournalService().getEntries(
      coachId: _filterCoachId,
      moodLabel: _filterMood,
    );
    final insights = await JournalService().getInsights();
    if (mounted) {
      setState(() {
        _entries = entries;
        _insights = insights;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Journal',
                        style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryDark)),
                  ),
                  if (_insights.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() => _showInsights = !_showInsights),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _showInsights
                              ? AppColors.secondaryLavender.withValues(alpha: 0.2)
                              : AppColors.backgroundDarkElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _showInsights
                                ? AppColors.secondaryLavender
                                : Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lightbulb_outline_rounded,
                                size: 16,
                                color: _showInsights ? AppColors.secondaryLavender : AppColors.textSecondaryDark),
                            const SizedBox(width: 4),
                            Text('Insights',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: _showInsights ? AppColors.secondaryLavender : AppColors.textSecondaryDark,
                                )),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildFilters(),
            ),
            const SizedBox(height: 12),

            // Insights section
            if (_showInsights && _insights.isNotEmpty)
              _InsightsSection(insights: _insights),

            // Entries
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPeach))
                  : _entries.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: AppColors.primaryPeach,
                          backgroundColor: AppColors.backgroundDarkElevated,
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            itemCount: _entries.length,
                            itemBuilder: (context, i) => _JournalEntryCard(
                              entry: _entries[i],
                              onTap: () => _showEntryDetail(_entries[i]),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final coaches = defaultCoaches.where((c) => !c.isPremium).toList();
    final moods = ['Happy', 'Neutral', 'Sad', 'Angry', 'Tired'];

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip('All', _filterCoachId == null && _filterMood == null, () {
            setState(() { _filterCoachId = null; _filterMood = null; });
            _load();
          }),
          const SizedBox(width: 6),
          ...coaches.map((c) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _filterChip('${c.emoji} ${c.name}', _filterCoachId == c.id, () {
              setState(() { _filterCoachId = _filterCoachId == c.id ? null : c.id; });
              _load();
            }),
          )),
          ...moods.map((m) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _filterChip(m, _filterMood == m, () {
              setState(() { _filterMood = _filterMood == m ? null : m; });
              _load();
            }),
          )),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryPeach.withValues(alpha: 0.15) : AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? AppColors.primaryPeach : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Text(label,
            style: AppTextStyles.labelSmall.copyWith(
              color: active ? AppColors.primaryPeach : AppColors.textSecondaryDark,
            )),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📖', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Your journal is waiting',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
            const SizedBox(height: 8),
            Text(
              'Start a coaching session and your journey will be captured here. Every conversation is a step forward.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Semantics(
              button: true,
              label: 'Start your first coaching session',
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                  label: Text('Start a Session',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.backgroundDark,
                        fontWeight: FontWeight.bold,
                      )),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEntryDetail(JournalEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EntryDetailSheet(entry: entry),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  const _JournalEntryCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(entry.timestamp);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline dot
            Column(
              children: [
                Text(entry.coachEmoji, style: const TextStyle(fontSize: 28)),
                if (entry.moodEmoji != null) ...[
                  const SizedBox(height: 4),
                  Text(entry.moodEmoji!, style: const TextStyle(fontSize: 14)),
                ],
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(entry.coachName,
                            style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark)),
                      ),
                      Text(dateStr,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (entry.summary.isNotEmpty)
                    Text(entry.summary,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  if (entry.keyTopics.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: entry.keyTopics.take(3).map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLavender.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(t,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryLavender,
                              fontSize: 9,
                            )),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text('${entry.messageCount} messages',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiaryDark),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }
}

class _InsightsSection extends StatelessWidget {
  final List<String> insights;
  const _InsightsSection({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryLavender.withValues(alpha: 0.1),
            AppColors.primaryPeach.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryLavender.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔮', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('AI Insights',
                  style: AppTextStyles.titleSmall.copyWith(color: AppColors.secondaryLavender)),
            ],
          ),
          const SizedBox(height: 10),
          ...insights.map((i) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryPeach)),
                Expanded(
                  child: Text(i,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimaryDark,
                        height: 1.4,
                      )),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _EntryDetailSheet extends StatelessWidget {
  final JournalEntry entry;
  const _EntryDetailSheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkElevated,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(entry.coachEmoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('Session with ${entry.coachName}',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
            const SizedBox(height: 4),
            Text(_formatFullDate(entry.timestamp),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark)),
            if (entry.moodEmoji != null) ...[
              const SizedBox(height: 8),
              Text('Mood: ${entry.moodEmoji} ${entry.moodLabel ?? ''}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark)),
            ],
            const SizedBox(height: 16),
            if (entry.summary.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(entry.summary,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimaryDark,
                      height: 1.5,
                    )),
              ),
            if (entry.conversationHighlights.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Key Moments',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryPeach,
                      letterSpacing: 1,
                    )),
              ),
              const SizedBox(height: 8),
              ...entry.conversationHighlights.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✦ ', style: TextStyle(color: AppColors.primaryPeach, fontSize: 12)),
                    Expanded(
                      child: Text(h,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryDark,
                            height: 1.4,
                          )),
                    ),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 16),
            Text('${entry.messageCount} messages exchanged',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiaryDark)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close',
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

  String _formatFullDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}
