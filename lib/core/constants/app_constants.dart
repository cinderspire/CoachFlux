class AppConstants {
  AppConstants._();

  static const String appName = 'AI CoachFlux';
  static const String appTagline = 'Become Who You\'re Meant To Be';
  static const String appMotto = 'Your Mind. Upgraded.';
  static const String appMission = '11 expert AI coaches. One goal: the best version of you.';
  static const String appVersion = '1.0.0';

  // Gemini API
  static const String geminiModel = 'gemini-2.5-flash';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  // TODO: Move to env/secrets
  static const List<String> geminiApiKeys = [
    'AIzaSyA1jZXrjeL_aMXopAzku2Qcvv0fjcRwo_8', // Primary
    'AIzaSyCDy_xWXe3F5D7cBYjIW3hcloV7vBHhdQA', // Secondary
  ];
  static const String geminiApiKey = 'AIzaSyA1jZXrjeL_aMXopAzku2Qcvv0fjcRwo_8'; // legacy compat

  // RevenueCat
  static const String rcAppleApiKey = 'appl_FLpanJEaekzoZngMDjtWwLbeBfA';
  static const String rcGoogleApiKey = 'goog_YOUR_REVENUECAT_GOOGLE_API_KEY';
  static const String rcPremiumEntitlement = 'pro';
  static const String rcCoachEntitlement = 'coach_tier';

  // Limits
  static const int freeCoachLimit = 3;
  static const int freeMessagesPerDay = 50;
  static const int freeCustomCoachLimit = 1;
  static const int maxContextLength = 500;

  // Pricing
  static const String proMonthlyPrice = '\$12.99/mo';
  static const String coachMonthlyPrice = '\$99/mo';

  // Appointment Products (RevenueCat Consumables)
  static const String appointment15min = 'appointment_15min';
  static const String appointment30min = 'appointment_30min';
  static const String appointment60min = 'appointment_60min';
  static const String appointmentVideoAddon = 'appointment_video_addon';

  // Appointment Limits
  static const int proFreeAppointmentsPerMonth = 2;
  static const int coachTierFreeAppointments = 999; // unlimited

  // Categories
  static const List<String> coachCategories = [
    'Productivity',
    'Mindset',
    'Health',
    'Career',
    'Creative',
    'Finance',
  ];
}
