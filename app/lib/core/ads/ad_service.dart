import 'package:docxan/core/ads/ad_config.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract final class AdService {
  static Future<void>? _initialization;

  static bool get isSupported =>
      AdConfig.adsEnabled &&
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android;

  // TODO(ads): integrate Google's User Messaging Platform (UMP) consent flow
  // before production if the app's audience or regions require it.
  static Future<void> initialize() {
    if (!isSupported) return Future<void>.value();
    return _initialization ??= _start();
  }

  static Future<void> _start() async {
    try {
      await MobileAds.instance.initialize();
    } catch (error) {
      AppLogger.debug('Mobile Ads omitido: $error');
    }
  }
}
