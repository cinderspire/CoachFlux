import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/wisdom_card.dart';
import '../../../core/models/coach.dart';

class WisdomCollectionScreen extends StatefulWidget {
  const WisdomCollectionScreen({super.key});

  @override
  State<WisdomCollectionScreen> createState() => _WisdomCollectionScreenState();
}

class _WisdomCollectionScreenState extends State<WisdomCollectionScreen> {
  List<WisdomEntry> _cards = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('wisdom_cards') ?? [];
    final cards = raw.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return WisdomEntry.fromJson(map);
    }).toList();
    if (mounted) setState(() { _cards = cards; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Wisdom Collection',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🃏', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text('No wisdom cards yet',
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondaryDark)),
                      const SizedBox(height: 8),
                      Text('Complete coaching sessions to earn cards',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, i) {
                    final entry = _cards[i];
                    final coach = defaultCoaches.firstWhere(
                      (c) => c.id == entry.coachId,
                      orElse: () => defaultCoaches.first,
                    );
                    return GestureDetector(
                      onTap: () => _showCard(context, entry, coach),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              coach.color.withValues(alpha: 0.15),
                              AppColors.backgroundDarkElevated,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: coach.color.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('#${entry.cardNumber}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: coach.color,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Text(coach.emoji, style: const TextStyle(fontSize: 20)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: Text(
                                entry.wisdom,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimaryDark,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('— ${coach.name}',
                                style: AppTextStyles.caption.copyWith(color: coach.color)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showCard(BuildContext context, WisdomEntry entry, Coach coach) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: WisdomCard(
          wisdom: entry.wisdom,
          coachName: coach.name,
          coachEmoji: coach.emoji,
          coachColor: coach.color,
          cardNumber: entry.cardNumber,
        ),
      ),
    );
  }
}

class WisdomEntry {
  final String wisdom;
  final String coachId;
  final int cardNumber;
  final String date;

  WisdomEntry({
    required this.wisdom,
    required this.coachId,
    required this.cardNumber,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'wisdom': wisdom,
    'coachId': coachId,
    'cardNumber': cardNumber,
    'date': date,
  };

  factory WisdomEntry.fromJson(Map<String, dynamic> json) => WisdomEntry(
    wisdom: json['wisdom'],
    coachId: json['coachId'],
    cardNumber: json['cardNumber'],
    date: json['date'] ?? '',
  );
}

/// Helper to save a wisdom card
Future<void> saveWisdomCard(WisdomEntry entry) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getStringList('wisdom_cards') ?? [];
  raw.add(jsonEncode(entry.toJson()));
  await prefs.setStringList('wisdom_cards', raw);
}

/// Get count of collected wisdom cards
Future<int> getWisdomCardCount() async {
  final prefs = await SharedPreferences.getInstance();
  return (prefs.getStringList('wisdom_cards') ?? []).length;
}
