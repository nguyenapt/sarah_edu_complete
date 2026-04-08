import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../../core/services/welcome_service.dart';
import '../main_navigation.dart';

const Color _kPrimary = Color(0xFF006286);
const Color _kPrimaryContainer = Color(0xFF2DB7F2);
const LinearGradient _kPrimaryCtaGradient = LinearGradient(
  colors: [_kPrimary, _kPrimaryContainer],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class WelcomeScreen3 extends StatelessWidget {
  final VoidCallback onPrevious;

  const WelcomeScreen3({
    super.key,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Icon/Illustration
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.language,
                          size: 100,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        AppLocalizations.of(context)!.welcomeTitle3,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Description
                      Text(
                        AppLocalizations.of(context)!.welcomeDescription3,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Language Selection
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.selectLanguage,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: languageProvider.availableLanguages.map((lang) {
                                final isSelected = languageProvider.currentLanguageCode == lang['code'];
                                return FilterChip(
                                  selected: isSelected,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(lang['flag']!),
                                      const SizedBox(width: 8),
                                      Text(lang['name']!),
                                    ],
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      languageProvider.setLanguage(lang['code']!);
                                    }
                                  },
                                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                                  checkmarkColor: AppTheme.primaryColor,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
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
                      label: AppLocalizations.of(context)!.getStarted,
                      onPressed: () async {
                        // Đánh dấu đã xem welcome
                        await WelcomeService.setHasSeenWelcome(true);
                        // Navigate to main app
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const MainNavigation(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
            padding: const EdgeInsets.symmetric(vertical: 12),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
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

