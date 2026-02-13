import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/services/revenuecat_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  int _selectedTier = 1; // 0=free, 1=pro, 2=coach

  @override
  void initState() {
    super.initState();
    ref.read(subscriptionProvider.notifier).loadOfferings();
  }

  @override
  Widget build(BuildContext context) {
    final sub = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Upgrade', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Text('Unlock Your Full Potential',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryDark),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Choose the plan that fits your journey',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),

            // Tier cards
            _buildTierCard(
              index: 0,
              name: 'Free',
              price: '\$0',
              color: AppColors.textSecondaryDark,
              features: [
                '3 coaches',
                '10 messages/day',
                '1 custom coach',
                'Basic insights',
              ],
            ),
            const SizedBox(height: 12),
            _buildTierCard(
              index: 1,
              name: 'Pro',
              price: AppConstants.proMonthlyPrice,
              color: AppColors.primaryPeach,
              badge: 'Popular',
              features: [
                'All coaches unlocked',
                'Unlimited messages',
                '10 custom coaches',
                'Advanced insights',
                'Priority support',
              ],
            ),
            const SizedBox(height: 12),
            _buildTierCard(
              index: 2,
              name: 'Coach',
              price: AppConstants.coachMonthlyPrice,
              color: AppColors.secondaryLavender,
              features: [
                'Everything in Pro',
                'Unlimited custom coaches',
                'Publish to marketplace',
                'Analytics dashboard',
                'White-label option',
              ],
            ),
            const SizedBox(height: 24),

            // CTA
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: sub.isLoading
                    ? null
                    : () {
                        if (_selectedTier == 0) {
                          Navigator.pop(context);
                        } else {
                          _handlePurchase(sub);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTier == 1
                      ? AppColors.primaryPeach
                      : _selectedTier == 2
                          ? AppColors.secondaryLavender
                          : AppColors.backgroundDarkElevated,
                ),
                child: sub.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.backgroundDark),
                      )
                    : Text(
                        _selectedTier == 0 ? 'Stay on Free' : 'Subscribe Now',
                        style: AppTextStyles.button.copyWith(
                          color: _selectedTier == 0 ? AppColors.textSecondaryDark : AppColors.backgroundDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Restore
            TextButton(
              onPressed: () => ref.read(subscriptionProvider.notifier).restore(),
              child: Text('Restore Purchases',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark)),
            ),
            const SizedBox(height: 12),

            // Legal links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://playtools.top/privacy-policy.html'), mode: LaunchMode.externalApplication),
                  child: Text('Privacy Policy',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiaryDark,
                        decoration: TextDecoration.underline,
                      )),
                ),
                Text('  •  ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark)),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://playtools.top/terms-of-service.html'), mode: LaunchMode.externalApplication),
                  child: Text('Terms of Service',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiaryDark,
                        decoration: TextDecoration.underline,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase(SubscriptionState sub) async {
    // Find matching package from offerings
    final packages = sub.availablePackages;
    if (packages.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No packages available. Configure RevenueCat API keys.')),
        );
      }
      return;
    }

    // Match tier to package identifier
    final targetId = _selectedTier == 1 ? 'pro_monthly' : 'coach_monthly';
    Package? package;
    for (final p in packages) {
      if (p.identifier == targetId || p.identifier == '\$rc_monthly') {
        package = p;
        break;
      }
    }
    package ??= packages.first;

    final success = await ref.read(subscriptionProvider.notifier).purchase(package);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Welcome to Pro!')),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildTierCard({
    required int index,
    required String name,
    required String price,
    required Color color,
    required List<String> features,
    String? badge,
  }) {
    final selected = _selectedTier == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTier = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.white.withValues(alpha: 0.05),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(name, style: AppTextStyles.titleMedium.copyWith(color: color)),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(badge, style: AppTextStyles.caption.copyWith(color: color)),
                      ),
                    ],
                  ],
                ),
                Text(price, style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, size: 16, color: color),
                  const SizedBox(width: 8),
                  Text(f, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
