import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._();

  late FirebaseRemoteConfig _remoteConfig;
  bool _initialized = false;

  // Default values (fallback if Firebase unreachable)
  static const _defaults = {
    'gemini_api_key_primary': 'AIzaSyA1jZXrjeL_aMXopAzku2Qcvv0fjcRwo_8',
    'gemini_api_key_secondary': 'AIzaSyCDy_xWXe3F5D7cBYjIW3hcloV7vBHhdQA',
    'gemini_model': 'gemini-2.5-flash',
    'maintenance_mode': false,
    'premium_monthly_price': '4.99',
    'app_announcement': '',
    'force_update_version': '0.0.0',
    'max_daily_messages_free': 10,
    'max_daily_messages_premium': 1000,
  };

  Future<void> init() async {
    if (_initialized) return;
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.setDefaults(
          _defaults.map((k, v) => MapEntry(k, v.toString())));
      await _remoteConfig.fetchAndActivate();
      _initialized = true;
      debugPrint('RemoteConfig initialized');
    } catch (e) {
      debugPrint('RemoteConfig init failed: $e — using defaults');
    }
  }

  String get geminiPrimaryKey => _initialized
      ? _remoteConfig.getString('gemini_api_key_primary')
      : _defaults['gemini_api_key_primary'] as String;

  String get geminiSecondaryKey => _initialized
      ? _remoteConfig.getString('gemini_api_key_secondary')
      : _defaults['gemini_api_key_secondary'] as String;

  List<String> get geminiApiKeys => [geminiPrimaryKey, geminiSecondaryKey];

  String get geminiModel => _initialized
      ? _remoteConfig.getString('gemini_model')
      : _defaults['gemini_model'] as String;

  bool get maintenanceMode => _initialized
      ? _remoteConfig.getBool('maintenance_mode')
      : false;

  String get appAnnouncement => _initialized
      ? _remoteConfig.getString('app_announcement')
      : '';

  int get maxDailyMessagesFree => _initialized
      ? _remoteConfig.getInt('max_daily_messages_free')
      : 10;

  int get maxDailyMessagesPremium => _initialized
      ? _remoteConfig.getInt('max_daily_messages_premium')
      : 1000;
}
