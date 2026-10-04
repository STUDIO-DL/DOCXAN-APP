/// Single source of truth for AdMob identifiers. Docxan only uses banners.
abstract final class AdConfig {
  static const bool adsEnabled = true;

  /// Google's official Android test banner unit. Safe to click.
  static const String androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/9214589741';

  /// Real unit goes in `env.json` as `ADMOB_ANDROID_BANNER_AD_UNIT_ID`.
  static const String androidBannerAdUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_AD_UNIT_ID',
    defaultValue: androidTestBannerAdUnitId,
  );
}
