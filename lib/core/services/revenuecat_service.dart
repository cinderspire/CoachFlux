import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../constants/app_constants.dart';

class SubscriptionState {
  final bool isPro;
  final bool isCoachTier;
  final bool isLoading;
  final String? error;
  final List<Package> availablePackages;

  const SubscriptionState({
    this.isPro = false,
    this.isCoachTier = false,
    this.isLoading = false,
    this.error,
    this.availablePackages = const [],
  });

  bool get isFree => !isPro && !isCoachTier;

  int get coachLimit => isPro || isCoachTier ? 999 : AppConstants.freeCoachLimit;
  int get dailyMessageLimit => isPro || isCoachTier ? 999 : AppConstants.freeMessagesPerDay;
  int get customCoachLimit => isCoachTier ? 999 : (isPro ? 10 : AppConstants.freeCustomCoachLimit);
  bool get canPublishToMarketplace => isCoachTier;

  SubscriptionState copyWith({
    bool? isPro,
    bool? isCoachTier,
    bool? isLoading,
    String? error,
    List<Package>? availablePackages,
  }) => SubscriptionState(
    isPro: isPro ?? this.isPro,
    isCoachTier: isCoachTier ?? this.isCoachTier,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    availablePackages: availablePackages ?? this.availablePackages,
  );
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(SubscriptionState(isPro: kDebugMode));

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final key = Platform.isIOS
          ? AppConstants.rcAppleApiKey
          : AppConstants.rcGoogleApiKey;

      if (key.contains('YOUR_') || key.contains('XXXX') || key.isEmpty) {
        debugPrint('[RevenueCat] Skipping — placeholder API key');
        _initialized = true;
        return;
      }

      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(PurchasesConfiguration(key));
      await _checkSubscription();
      _initialized = true;
    } catch (e) {
      debugPrint('[RevenueCat] Init error: $e');
      _initialized = true;
    }
  }

  Future<void> _checkSubscription() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final isPro = info.entitlements.active.containsKey(AppConstants.rcPremiumEntitlement);
      final isCoach = info.entitlements.active.containsKey(AppConstants.rcCoachEntitlement);
      state = state.copyWith(isPro: isPro, isCoachTier: isCoach);
    } catch (e) {
      debugPrint('[RevenueCat] Check error: $e');
    }
  }

  Future<void> loadOfferings() async {
    state = state.copyWith(isLoading: true);
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null) {
        state = state.copyWith(
          availablePackages: current.availablePackages,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> purchase(Package package) async {
    try {
      state = state.copyWith(isLoading: true);
      await Purchases.purchasePackage(package);
      await _checkSubscription();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> restore() async {
    try {
      state = state.copyWith(isLoading: true);
      await Purchases.restorePurchases();
      await _checkSubscription();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});
