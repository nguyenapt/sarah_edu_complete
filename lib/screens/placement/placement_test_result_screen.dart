import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/placement_test_model.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../auth/login_screen.dart';
import '../main_navigation.dart';

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

class PlacementTestResultScreen extends StatefulWidget {
  final PlacementTestResult result;

  const PlacementTestResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<PlacementTestResultScreen> createState() => _PlacementTestResultScreenState();
}

class _PlacementTestResultScreenState extends State<PlacementTestResultScreen> {
  bool _wasUnauthenticated = true;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _wasUnauthenticated = !authProvider.isAuthenticated;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;
    final loc = AppLocalizations.of(context)!;

    // Nếu user vừa đăng nhập thành công (chuyển từ unauthenticated sang authenticated)
    if (_wasUnauthenticated && isAuthenticated && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigation(),
          ),
          (route) => false,
        );
      });
    }

    return Scaffold(
      backgroundColor: _kSurface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 10),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: _kOnSurface,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: Text(
                        loc.placementTestResult,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _kOnSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _kSurfaceContainer,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        icon: const Icon(Icons.person_rounded, size: 20),
                        color: _kOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Level Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: _kPrimaryCtaGradient,
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Level',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.result.assessedLevel.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Score Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _kOnSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildScoreItem(
                          context,
                          'Correct',
                          '${widget.result.correctAnswers}',
                          Colors.green,
                        ),
                        _buildScoreItem(
                          context,
                          'Total',
                          '${widget.result.totalQuestions}',
                          _kPrimary,
                        ),
                        _buildScoreItem(
                          context,
                          'Score',
                          '${widget.result.scorePercentage.toStringAsFixed(1)}%',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Breakdown
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Breakdown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _kOnSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.result.categoryTotals.entries.map((entry) {
                      final category = entry.key;
                      final total = entry.value;
                      final score = widget.result.categoryScores[category] ?? 0;
                      final percentage = total > 0 ? (score / total * 100) : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getCategoryLabel(category),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  '$score / $total (${percentage.toStringAsFixed(1)}%)',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getCategoryColor(category),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time Spent
            if (widget.result.timeSpentSeconds != null)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_rounded, color: _kPrimary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time Spent',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: _kOnSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(widget.result.timeSpentSeconds!),
                              style: TextStyle(
                                color: _kOnSurfaceVariant.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Action Buttons
            if (!isAuthenticated)
              _GradientPillButton(
                label: loc.loginToSaveResult,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            const SizedBox(height: 12),
            _OutlinePillButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainNavigation(),
                  ),
                  (route) => false,
                );
              },
              label: loc.backToHome,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  // Removed legacy level color helper (replaced by gradient card).

  String _getCategoryLabel(PlacementTestCategory category) {
    switch (category) {
      case PlacementTestCategory.vocabulary:
        return 'Vocabulary';
      case PlacementTestCategory.grammar:
        return 'Grammar';
      case PlacementTestCategory.reading:
        return 'Reading';
      case PlacementTestCategory.listening:
        return 'Listening';
    }
  }

  Color _getCategoryColor(PlacementTestCategory category) {
    switch (category) {
      case PlacementTestCategory.vocabulary:
        return Colors.purple;
      case PlacementTestCategory.grammar:
        return Colors.blue;
      case PlacementTestCategory.reading:
        return Colors.green;
      case PlacementTestCategory.listening:
        return Colors.orange;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }
}

class _GradientPillButton extends StatelessWidget {
  const _GradientPillButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? _kPrimaryCtaGradient : null,
          color: enabled ? null : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(999),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
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
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _kPrimary.withValues(alpha: 0.35)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
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

