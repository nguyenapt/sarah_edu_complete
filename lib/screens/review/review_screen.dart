import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/level_model.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../practice/practice_screen.dart';
import '../auth/login_screen.dart';
import '../../widgets/common/practice_top_app_bar.dart';
import '../settings/settings_screen.dart';
import '../main_navigation.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<LevelModel> _levels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final levels = await _firestoreService.getLevels();
      
      if (mounted) {
        setState(() {
          _levels = levels;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading levels: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Lấy danh sách các level đã hoàn thành
  List<String> _getCompletedLevels(String currentLevel) {
    const levelOrder = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final currentIndex = levelOrder.indexOf(currentLevel);
    if (currentIndex <= 0) return [];
    return levelOrder.sublist(0, currentIndex); // Các level trước currentLevel
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Nếu guest user, hiển thị màn hình yêu cầu đăng nhập
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.review),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.pleaseLogin,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.loginToUseReviewFeature,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: Text(AppLocalizations.of(context)!.login),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    final currentLevel = authProvider.user?.currentLevel ?? 'A1';
    final completedLevels = _getCompletedLevels(currentLevel);

    if (_isLoading) {
      return Scaffold(
        appBar: PracticeTopAppBar(
          title: AppLocalizations.of(context)!.review,
          onAvatarTap: () {
            final scope = MainNavigationScope.of(context);
            if (scope != null) {
              scope.goToTab(4);
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: PracticeTopAppBar(
        title: AppLocalizations.of(context)!.review,
        onAvatarTap: () {
          final scope = MainNavigationScope.of(context);
          if (scope != null) {
            scope.goToTab(4);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const SettingsScreen(),
            ),
          );
        },
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _levels.length,
        itemBuilder: (context, index) {
          final level = _levels[index];
          final isCompleted = completedLevels.contains(level.id);
          final isCurrentLevel = level.id == currentLevel;
          final isEnabled = isCompleted || isCurrentLevel;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isEnabled
                    ? (AppTheme.levelColors[level.id] ?? AppTheme.primaryColor)
                    : Colors.grey[300],
                child: Text(
                  level.id,
                  style: TextStyle(
                    color: isEnabled ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                level.id,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? null : Colors.grey,
                ),
              ),
              subtitle: Text(
                isCurrentLevel
                    ? AppLocalizations.of(context)!.currentLevelText
                    : isCompleted
                        ? AppLocalizations.of(context)!.completed
                        : AppLocalizations.of(context)!.notUnlocked,
                style: TextStyle(
                  color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              trailing: isEnabled
                  ? const Icon(Icons.arrow_forward_ios, size: 16)
                  : Icon(Icons.lock, color: Colors.grey[400]),
              onTap: isEnabled
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PracticeScreen(
                            reviewMode: true,
                            reviewLevel: level.id,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}

