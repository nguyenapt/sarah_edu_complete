import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../platform/ad_platform_gate.dart';

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({
    super.key,
    required this.adUnitId,
    required this.factoryId,
    /// Giới hạn chiều cao tối đa để tránh platform view chiếm quá nhiều không gian
    /// trong scroll (đặc biệt Android hybrid composition).
    this.maxHeight = 200,
  });

  /// Must match the registered native ad factory id (platform side).
  final String factoryId;
  final String adUnitId;
  final double maxHeight;

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!AdPlatformGate.adsSupported) return;
    final ad = NativeAd(
      adUnitId: widget.adUnitId,
      factoryId: widget.factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint(
            '❌ NativeAd failed: code=${err.code} domain=${err.domain} message=${err.message}',
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
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.maxHeight,
              minHeight: 72,
            ),
            child: SizedBox(
              width: double.infinity,
              child: AdWidget(ad: ad),
            ),
          ),
        ),
      ),
    );
  }
}

