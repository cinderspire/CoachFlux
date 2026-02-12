import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/coach.dart';
import '../../../core/data/coach_credentials.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/engagement_service.dart';
import '../../../core/widgets/gradient_mesh_bg.dart';
import '../../../core/widgets/coach_photo.dart';
import '../../chat/screens/chat_screen.dart';
import '../../paywall/screens/paywall_screen.dart';

class CoachesScreen extends StatefulWidget {
  const CoachesScreen({super.key});

  @override
  State<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends State<CoachesScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _query = '';

  List<Coach> get _filtered {
    var list = defaultCoaches.toList();
    if (_selectedCategory != 'All') {
      list = list.where((c) => c.category == _selectedCategory).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.title.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...AppConstants.coachCategories];

    return Scaffold(
      body: GradientMeshBackground(
        intensity: 0.6,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Coaches',
                    style: AppTextStyles.headlineSmall
                        .copyWith(color: AppColors.textPrimaryDark)),
                const SizedBox(height: 4),
                Text('Evidence-based professionals, available 24/7',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textTertiaryDark)),
                const SizedBox(height: 16),

                // Search
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimaryDark),
                      decoration: InputDecoration(
                        hintText: 'Search coaches...',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.textTertiaryDark),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon:
                                    const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.backgroundDarkElevated
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Filter chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = categories[i];
                      final active = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = cat),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primaryPeach
                                    .withValues(alpha: 0.15)
                                : AppColors.backgroundDarkElevated
                                    .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: active
                                  ? AppColors.primaryPeach
                                  : Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Text(cat,
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: active
                                      ? AppColors.primaryPeach
                                      : AppColors.textSecondaryDark)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // List (not grid — professional profiles need more space)
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(48),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔍',
                                    style: TextStyle(fontSize: 56)),
                                const SizedBox(height: 16),
                                Text('No coaches found',
                                    style: AppTextStyles.titleMedium
                                        .copyWith(
                                            color: AppColors
                                                .textPrimaryDark)),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a different search or category',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color:
                                          AppColors.textTertiaryDark),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final coach = _filtered[i];
                            final cred = getCredential(coach.id);
                            return _CoachProfessionalCard(
                              coach: coach,
                              credential: cred,
                              onTap: () {
                                if (coach.isPremium) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const PaywallScreen()));
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ChatScreen(
                                                  coach: coach)));
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoachProfessionalCard extends StatelessWidget {
  final Coach coach;
  final CoachCredential? credential;
  final VoidCallback onTap;

  const _CoachProfessionalCard({
    required this.coach,
    required this.credential,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cred = credential;
    final social = EngagementService().getSocialProof(coach.id);

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'coach-${coach.id}',
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDarkElevated
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: avatar + name + availability
                    Row(
                      children: [
                        // Avatar with verified badge
                        CoachPhoto(
                          coach: coach,
                          size: 52,
                          showVerified: true,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(coach.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.titleSmall
                                            .copyWith(
                                                color: AppColors
                                                    .textPrimaryDark)),
                                  ),
                                  if (coach.isPremium) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors
                                            .secondaryLavender
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                          Icons.lock_rounded,
                                          size: 12,
                                          color: AppColors
                                              .secondaryLavender),
                                    ),
                                  ],
                                ],
                              ),
                              if (cred != null)
                                Text(
                                  cred.credentials,
                                  style:
                                      AppTextStyles.caption.copyWith(
                                    color:
                                        AppColors.textSecondaryDark,
                                    fontSize: 11,
                                  ),
                                )
                              else
                                Text(coach.title,
                                    style: AppTextStyles.caption
                                        .copyWith(
                                            color: AppColors
                                                .textTertiaryDark)),
                            ],
                          ),
                        ),
                        // Availability indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.tertiarySage
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.tertiarySage,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text('Available',
                                  style:
                                      AppTextStyles.caption.copyWith(
                                    color: AppColors.tertiarySage,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (cred != null) ...[
                      const SizedBox(height: 12),
                      // Specializations tags
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: cred.specializations.take(3).map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: coach.color
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text(s,
                                style: AppTextStyles.caption
                                    .copyWith(
                                  color: coach.color,
                                  fontSize: 9,
                                )),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      // Bio
                      Text(
                        cred.bio,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryDark,
                          height: 1.3,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Stats row: rating + sessions + experience
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${cred.rating.toStringAsFixed(1)} ★',
                            style:
                                AppTextStyles.caption.copyWith(
                              color: AppColors.primaryPeach,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '${_formatNumber(cred.sessionsCompleted)} sessions',
                            style:
                                AppTextStyles.caption.copyWith(
                              color:
                                  AppColors.textTertiaryDark,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            cred.experience,
                            style:
                                AppTextStyles.caption.copyWith(
                              color:
                                  AppColors.textTertiaryDark,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Book Session button
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                coach.color.withValues(alpha: 0.15),
                            foregroundColor: coach.color,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                              side: BorderSide(
                                  color: coach.color
                                      .withValues(alpha: 0.3)),
                            ),
                          ),
                          child: Text(
                            coach.isPremium
                                ? 'Unlock Coach'
                                : 'Start Session',
                            style:
                                AppTextStyles.labelSmall.copyWith(
                              color: coach.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Fallback for coaches without credentials
                      const SizedBox(height: 8),
                      Text(coach.title,
                          style: AppTextStyles.bodySmall.copyWith(
                              color:
                                  AppColors.textTertiaryDark)),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatNumber(social.weeklyUsers)} this week',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiaryDark,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              coach.color.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                        child: Text(coach.category,
                            style: AppTextStyles.caption
                                .copyWith(color: coach.color)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}
