import 'package:docxan/app/theme/palette.dart';
import 'package:docxan/core/ads/ad_config.dart';
import 'package:docxan/core/ads/ad_service.dart';
import 'package:docxan/core/logging/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Compact anchored adaptive banner. Renders nothing until an ad has loaded.
class DocxanBannerAd extends StatefulWidget {
  const DocxanBannerAd({super.key});

  @override
  State<DocxanBannerAd> createState() => _DocxanBannerAdState();
}

class _DocxanBannerAdState extends State<DocxanBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;
  int? _width;
  int _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AdService.isSupported) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (width <= 0 || width == _width) return;
    _width = width;
    _load(width);
  }

  Future<void> _load(int width) async {
    final generation = ++_generation;
    _disposeAd();
    try {
      await AdService.initialize();
      // Large anchored adaptive is taller; Docxan keeps the standard compact one.
      // ignore: deprecated_member_use
      final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        width,
      );
      if (!mounted || generation != _generation || size == null) return;

      final ad = BannerAd(
        adUnitId: AdConfig.androidBannerAdUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          // Superseded ads were already disposed by _disposeAd or dispose().
          onAdLoaded: (ad) {
            if (!mounted || generation != _generation) return;
            setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            AppLogger.debug('Banner sin anuncio: ${error.code}');
            if (generation != _generation) return;
            ad.dispose();
            _ad = null;
          },
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (error) {
      AppLogger.debug('Banner omitido: $error');
      if (generation == _generation && mounted) setState(_disposeAd);
    }
  }

  void _disposeAd() {
    _ad?.dispose();
    _ad = null;
    _loaded = false;
  }

  @override
  void dispose() {
    _generation++;
    _ad?.dispose();
    _ad = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.paper,
        border: Border(top: BorderSide(color: palette.hairline)),
      ),
      child: Center(
        heightFactor: 1,
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}
