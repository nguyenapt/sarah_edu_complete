import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/placement_test_model.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../auth/login_screen.dart';
import '../main_navigation.dart';

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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.placementTestResult),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Level Card
            Card(
              color: _getLevelColor(widget.result.assessedLevel),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Level',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.result.assessedLevel.toString(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Score Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
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
                          AppTheme.primaryColor,
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Breakdown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.timer, color: AppTheme.primaryColor),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time Spent',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(widget.result.timeSpentSeconds!),
                              style: Theme.of(context).textTheme.bodyLarge,
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Đăng nhập để lưu kết quả',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainNavigation(),
                  ),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Quay lại Home',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
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

  Color _getLevelColor(PlacementTestLevel level) {
    switch (level) {
      case PlacementTestLevel.a1:
        return Colors.blue;
      case PlacementTestLevel.a2:
        return Colors.lightBlue;
      case PlacementTestLevel.b1:
        return Colors.green;
      case PlacementTestLevel.b2:
        return Colors.orange;
      case PlacementTestLevel.c1:
        return Colors.red;
    }
  }

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

