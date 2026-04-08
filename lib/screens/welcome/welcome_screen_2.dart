import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

const Color _kPrimary = Color(0xFF006286);
const Color _kPrimaryContainer = Color(0xFF2DB7F2);
const LinearGradient _kPrimaryCtaGradient = LinearGradient(
  colors: [_kPrimary, _kPrimaryContainer],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class WelcomeScreen2 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;

  const WelcomeScreen2({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              // Icon/Illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.track_changes,
                  size: 100,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 48),
              // Title
              Text(
                AppLocalizations.of(context)!.welcomeTitle2,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Description
              Text(
                AppLocalizations.of(context)!.welcomeDescription2,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Navigation Buttons
              Row(
                children: [
                  Expanded(
                    child: _OutlinePillButton(
                      onPressed: onPrevious,
                      label: AppLocalizations.of(context)!.previous,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GradientPillButton(
                      onPressed: onNext,
                      label: AppLocalizations.of(context)!.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Skip Button
              _GhostButton(
                label: AppLocalizations.of(context)!.skip,
                onPressed: onSkip,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientPillButton extends StatelessWidget {
  const _GradientPillButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

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
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
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
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: _kPrimary.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: _kPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF445D7F),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

