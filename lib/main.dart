import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/coaches/screens/coaches_screen.dart';
import 'features/coach_builder/screens/coach_builder_screen.dart';
import 'features/paywall/screens/paywall_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/journal/screens/journal_screen.dart';
import 'features/achievements/screens/achievements_screen.dart';
import 'features/insights/screens/insights_screen.dart';
import 'features/techniques/screens/techniques_screen.dart';
import 'core/services/revenuecat_service.dart';
import 'features/chat/screens/chat_screen.dart';
import 'core/models/coach.dart';
import 'features/transformation/screens/transformation_screen.dart';
import 'features/garden/screens/garden_screen.dart';
import 'features/assessment/screens/problem_assessment_screen.dart';
import 'features/insights/screens/optimization_dashboard_screen.dart';
import 'features/exercises/screens/exercises_screen.dart';
import 'features/touchstone/screens/touchstone_screen.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final onboardingCompleteProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.getBool('onboarding_complete') ?? false;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  final prefs = await SharedPreferences.getInstance();

  // Global error boundary for framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // Initialize RevenueCat (non-blocking)
  final subNotifier = SubscriptionNotifier();
  unawaited(subNotifier.init());

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        subscriptionProvider.overrideWith((_) => subNotifier),
      ],
      child: const CoachFluxApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void debugNavigateTo(String screen) {
  final nav = navigatorKey.currentState!;
  switch (screen) {
    case 'chat_flowstate':
      nav.push(MaterialPageRoute(builder: (_) => ChatScreen(coach: defaultCoaches[0])));
    case 'chat_aura':
      final aura = defaultCoaches.firstWhere((c) => c.id == 'dr-aura', orElse: () => defaultCoaches.last);
      nav.push(MaterialPageRoute(builder: (_) => ChatScreen(coach: aura)));
    case 'transformation':
      nav.push(MaterialPageRoute(builder: (_) => const TransformationScreen()));
    case 'garden':
      nav.push(MaterialPageRoute(builder: (_) => const GardenScreen()));
    default:
      nav.pushNamed('/$screen');
  }
}

class CoachFluxApp extends ConsumerWidget {
  const CoachFluxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CoachFlux',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // BouncingScrollPhysics globally for iOS-like premium feel
      scrollBehavior: const _BouncingScrollBehavior(),
      home: const SplashScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/coaches': (_) => const CoachesScreen(),
        '/coach-builder': (_) => const CoachBuilderScreen(),
        '/paywall': (_) => const PaywallScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/journal': (_) => const JournalScreen(),
        '/achievements': (_) => const AchievementsScreen(),
        '/insights': (_) => const InsightsScreen(),
        '/techniques': (_) => const TechniquesScreen(),
        '/assessment': (_) => const ProblemAssessmentScreen(),
        '/optimization': (_) => const OptimizationDashboardScreen(),
        '/exercises': (_) => const ExercisesScreen(),
        '/touchstone': (_) => const TouchstoneScreen(),
      },
      // Error widget override for release
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return _ErrorScreen(details: details);
        };
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// Global BouncingScrollPhysics for all scrollables
class _BouncingScrollBehavior extends ScrollBehavior {
  const _BouncingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}

/// Friendly error screen shown when a widget tree crashes
class _ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;
  const _ErrorScreen({required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😵', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text('Something went wrong',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark)),
              const SizedBox(height: 8),
              Text(
                'Don\'t worry — your data is safe.\nTry going back or restarting the app.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiaryDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Semantics(
                button: true,
                label: 'Go back',
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text('Go Back',
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
      ),
    );
  }
}

/// Connectivity banner — wraps any screen to show offline indicator
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _isOffline = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _checkConnectivity());
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      if (mounted) setState(() => _isOffline = result.isEmpty);
    } catch (_) {
      if (mounted) setState(() => _isOffline = true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isOffline)
          Semantics(
            liveRegion: true,
            label: 'No internet connection',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: AppColors.error.withValues(alpha: 0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'No internet connection',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _checkConnectivity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Retry',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Reusable error-retry widget for network failures
class NetworkErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const NetworkErrorWidget({
    super.key,
    this.message = 'Coach is thinking extra hard...\nTry again?',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤔', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(message,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Semantics(
              button: true,
              label: 'Retry',
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try Again'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
