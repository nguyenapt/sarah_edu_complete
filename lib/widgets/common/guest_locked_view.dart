import 'package:flutter/material.dart';
import '../../core/ads/ad_ids.dart';
import '../../core/ads/ads_factory.dart';
import '../../core/ads/widgets/banner_ad_widget.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/horizon_colors.dart';

const Color _kSurface = Color(0xFFF4F6FF);
const Color _kOnSurface = Color(0xFF14304F);
const Color _kOnSurfaceVariant = Color(0xFF445D7F);
const Color _kPrimary = Color(0xFF006286);
const Color _kPrimaryContainer = Color(0xFF2DB7F2);
const Color _kSurfaceContainer = Color(0xFFDDE9FF);

const LinearGradient _kPrimaryCtaGradient = LinearGradient(
  colors: [_kPrimary, _kPrimaryContainer],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class GuestLockedScaffold extends StatelessWidget {
  const GuestLockedScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final horizon = HorizonColors.of(context);
    return Scaffold(
      backgroundColor: isDark ? horizon.surface : _kSurface,
      appBar: AppBar(
        backgroundColor: isDark ? horizon.surface : _kSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isDark ? horizon.onSurface : _kOnSurface,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(child: child),
    );
  }
}

class GuestLockedView extends StatelessWidget {
  const GuestLockedView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onLogin,
    this.onRegister,
    this.icon = Icons.lock_outline_rounded,
  });

  final String title;
  final String subtitle;
  final VoidCallback onLogin;
  final VoidCallback? onRegister;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: _kSurfaceContainer,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, size: 44, color: _kPrimary.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _kOnSurface,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: _kOnSurfaceVariant.withValues(alpha: 0.82),
              ),
            ),
            const SizedBox(height: 22),
            _GradientPillButton(
              label: loc.login,
              onPressed: onLogin,
              icon: Icons.login_rounded,
            ),
            if (onRegister != null) ...[
              const SizedBox(height: 12),
              _OutlinePillButton(
                label: loc.register,
                onPressed: onRegister!,
                icon: Icons.person_add_alt_1_rounded,
              ),
            ],
            const SizedBox(height: 18),
            Center(
              child: BannerAdWidget(
                factory: AdsFactory(),
                adUnitId: AdMobIds.bannerHome,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientPillButton extends StatelessWidget {
  const _GradientPillButton({
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _kPrimaryCtaGradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinePillButton extends StatelessWidget {
  const _OutlinePillButton({
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _kPrimary.withValues(alpha: 0.35)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _kPrimary, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: _kPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

