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
import '../../widgets/common/guest_locked_view.dart';
import '../auth/register_screen.dart';
import '../../core/utils/cefr_level_order.dart';

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
      sortLevelsByCefr(levels);

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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Nếu guest user, hiển thị màn hình yêu cầu đăng nhập
    if (!authProvider.isAuthenticated) {
      final loc = AppLocalizations.of(context)!;
      return GuestLockedScaffold(
        title: loc.review,
        child: GuestLockedView(
          title: loc.pleaseLogin,
          subtitle: loc.loginToUseReviewFeature,
          onLogin: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          onRegister: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            );
          },
        ),
      );
    }
    
    final userMaxLevel = normalizeCefrLevelId(authProvider.user?.currentLevel ?? 'A1');

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
          final levelIdNorm = normalizeCefrLevelId(level.id);
          final isUnlocked = isLevelAtOrBelowUserMax(levelIdNorm, userMaxLevel);
          final isCurrent = levelIdNorm == userMaxLevel;
          final isPast = compareCefrLevel(levelIdNorm, userMaxLevel) < 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isUnlocked
                    ? (AppTheme.levelColors[level.id] ?? AppTheme.primaryColor)
                    : Colors.grey[300],
                child: Text(
                  level.id,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                level.id,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
              subtitle: Text(
                isCurrent
                    ? AppLocalizations.of(context)!.currentLevelText
                    : isUnlocked && isPast
                        ? AppLocalizations.of(context)!.completed
                        : AppLocalizations.of(context)!.notUnlocked,
                style: TextStyle(
                  color: isUnlocked ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              trailing: isUnlocked
                  ? const Icon(Icons.arrow_forward_ios, size: 16)
                  : Icon(Icons.lock, color: Colors.grey[400]),
              onTap: isUnlocked
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PracticeScreen(
                            reviewMode: true,
                            reviewLevel: levelIdNorm,
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

