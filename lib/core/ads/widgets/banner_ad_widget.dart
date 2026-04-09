import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads_factory.dart';
import '../platform/ad_platform_gate.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({
    super.key,
    required this.factory,
    required this.adUnitId,
    this.size = AdSize.banner,
  });

  final AdsFactory factory;
  final String adUnitId;
  final AdSize size;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!AdPlatformGate.adsSupported) return;
    final ad = widget.factory.createBanner(
      size: widget.size,
      adUnitId: widget.adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint(
            '❌ BannerAd failed: code=${err.code} domain=${err.domain} message=${err.message}',
          );
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _ad = null;
            _loaded = false;
          });
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdPlatformGate.adsSupported) return const SizedBox.shrink();
    final ad = _ad;
    final height = widget.size.height.toDouble();

    // Không giữ chỗ khi load thất bại (_ad đã bị dispose và gán null).
    if (ad == null) return const SizedBox.shrink();

    // Reserve space to avoid layout jump when ad loads.
    if (!_loaded) {
      return SizedBox(height: height);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.hardEdge,
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}

