import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/next_exercise_service.dart';
import '../../models/level_model.dart';
import '../../models/unit_model.dart';
import '../../models/lesson_model.dart';
import '../../models/progress_model.dart';
import '../../providers/auth_provider.dart';
import '../learning/exercise_screen.dart';
import '../auth/login_screen.dart';
import '../placement/placement_test_screen.dart';
import '../vocabulary/vocabulary_collection_screen.dart';
import '../weak_skills/weak_skill_screen.dart';
import '../progress/progress_screen.dart';
import '../practice/practice_screen.dart';
import '../level_skip/level_skip_test_screen.dart';
import '../../core/services/level_skip_test_service.dart';
import '../../widgets/common/practice_top_app_bar.dart';
import '../settings/settings_screen.dart';
import '../main_navigation.dart';

/// Đồng bộ màu với nút Continue trong `exercise_screen.dart`.
const Color _kPrimary = Color(0xFF006286);
const Color _kPrimaryContainer = Color(0xFF2DB7F2);
const LinearGradient _kPrimaryCtaGradient = LinearGradient(
  colors: [_kPrimary, _kPrimaryContainer],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// Guest Home palette (gần mockup Fluent Horizon)
const Color _kGuestHeroStart = Color(0xFF155E75);
const Color _kGuestHeroEnd = Color(0xFF38BDF8);
const Color _kGuestSurface = Color(0xFFF4F6FF);
const Color _kGuestOnSurface = Color(0xFF14304F);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _ResumeLessonButton extends StatelessWidget {
  const _ResumeLessonButton({
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_circle_fill,
                color: _kPrimary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: _kPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientCtaButton extends StatelessWidget {
  const _GradientCtaButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? _kPrimaryCtaGradient : null,
          color: enabled ? null : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final NextExerciseService _nextExerciseService = NextExerciseService();
  final LevelSkipTestService _levelSkipTestService = LevelSkipTestService();
  List<LevelModel> _levels = [];
  bool _isLoading = true;
  UserProgressModel? _userProgress;
  bool _canSkipLevel = false;
  bool _hasDailyLimit = false;
  String? _nextLevel;

  Future<void> _handleContinueLearningTap() async {
    if (!mounted) return;

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Lấy highestProgress để tìm exercise tiếp theo
      final highestProgress = _userProgress?.highestProgress;

      // Tìm exercise tiếp theo
      final nextExercise = highestProgress != null
          ? await _nextExerciseService.getNextExercise(highestProgress)
          : await _nextExerciseService.getFirstExercise();

      if (!mounted) return;
      Navigator.pop(context); // Đóng loading dialog

      if (nextExercise != null) {
        // Navigate to exercise
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseScreen(exercise: nextExercise),
          ),
        );
      } else {
        // Đã học hết
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.allLessonsCompleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Đóng loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadUserProgress(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseConstants.userProgressCollection)
          .doc(userId)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _userProgress = UserProgressModel.fromFirestore(doc);
        });
        
        // Check level skip test availability
        _checkLevelSkipAvailability(userId);
      }
    } catch (e) {
      debugPrint('Error loading user progress: $e');
    }
  }
  
  Future<void> _checkLevelSkipAvailability(String userId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.user != null) {
        final currentLevel = authProvider.user!.currentLevel;
        final nextLevel = _levelSkipTestService.getNextLevel(currentLevel);
        
        if (nextLevel != null) {
          final hasLimit = await _levelSkipTestService.checkDailyLimit(userId);
          if (mounted) {
            setState(() {
              _canSkipLevel = true;
              _hasDailyLimit = hasLimit;
              _nextLevel = nextLevel;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _canSkipLevel = false;
              _hasDailyLimit = false;
              _nextLevel = null;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking level skip availability: $e');
    }
  }
  
  Future<void> _handleLevelSkipTest() async {
    if (_nextLevel == null) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseLogin),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Check daily limit again
    final hasLimit = await _levelSkipTestService.checkDailyLimit(
      authProvider.user!.id,
    );
    
    if (hasLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dailyLimitReached),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Navigate to level skip test screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelSkipTestScreen(
          targetLevel: _nextLevel!,
        ),
      ),
    );
    
    // If test passed and level was unlocked, reload data
    if (result == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        _loadUserProgress(authProvider.user!.id);
      }
    }
  }

  Future<void> _loadLevels() async {
    try {
      final levels = await _firestoreService.getLevels();
      setState(() {
        _levels = levels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorLoadingData(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (!authProvider.isAuthenticated) {
              return AppBar(
                backgroundColor: _kGuestSurface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                titleSpacing: 4,
                leading: IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: _kGuestOnSurface,
                  onPressed: () {},
                ),
                title: Text(
                  loc.appName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _kGuestOnSurface,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFE8F3FF),
                        child: Icon(
                          Icons.person_rounded,
                          color: _kGuestOnSurface,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return PracticeTopAppBar(
              title: loc.appName,
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
            );
          },
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Load user progress khi user đã đăng nhập
          if (authProvider.isAuthenticated && authProvider.user != null) {
            if (_userProgress == null || _userProgress!.userId != authProvider.user!.id) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadUserProgress(authProvider.user!.id);
              });
            }
          } else {
            // Reset user progress khi user đăng xuất
            if (_userProgress != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _userProgress = null;
                  });
                }
              });
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...[
                  // Nếu đã đăng nhập: hiển thị Continue Learning
                  if (authProvider.isAuthenticated) ...[
                    // Continue Learning
                    _buildContinueLearning(),
                    const SizedBox(height: 24),
                  ] else ...[
                    _buildGuestHero(loc),
                    const SizedBox(height: 18),
                    const Text(
                      'The Learning Arc',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _kGuestOnSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A three-step approach to absolute fluency.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _kGuestOnSurface.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildGuestArcCard(
                      title: 'Test your level',
                      body:
                          'Our AI-driven assessment pinpoint your exact starting point in 5 minutes.',
                      icon: Icons.quiz_outlined,
                      bg: Colors.white,
                      iconBg: const Color(0xFFE8F3FF),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const PlacementTestScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildGuestArcCard(
                      title: 'Learn',
                      body:
                          'Engage with immersive, bite-sized lessons tailored your cognitive pace.',
                      icon: Icons.menu_book_outlined,
                      bg: const Color(0xFF0E7490),
                      iconBg: Colors.white.withValues(alpha: 0.14),
                      fg: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const PracticeScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildGuestArcCard(
                      title: 'Master',
                      body:
                          'Lock in knowledge with active recall sessions and real-world conversation practice.',
                      icon: Icons.star_outline_rounded,
                      bg: const Color(0xFFFED01B),
                      iconBg: Colors.black.withValues(alpha: 0.08),
                      fg: const Color(0xFF594700),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                const VocabularyCollectionScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildGuestQuickTile(
                      eyebrow: 'EXPAND KNOWLEDGE',
                      title: loc.vocabulary,
                      subtitle: 'Review your saved terms and idioms',
                      icon: Icons.insert_chart_outlined_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                const VocabularyCollectionScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildGuestQuickTile(
                      eyebrow: 'CUSTOMIZE EXPERIENCE',
                      title: loc.settings,
                      subtitle: 'Profile, notifications and preferences',
                      icon: Icons.tune_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Nếu đã đăng nhập: thêm các section bổ sung
                  if (authProvider.isAuthenticated) ...[
                    // Vocabulary và Weak Skills (2 cột)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildCompactSection(
                            AppLocalizations.of(context)!.vocabulary,
                            Icons.book,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VocabularyCollectionScreen(),
                                ),
                              );
                            },
                            showComingSoon: false,
                            subtitle: null,
                            iconColor: const Color(0xFFFFA726),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCompactSection(
                            AppLocalizations.of(context)!.weakSkills,
                            Icons.trending_down,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WeakSkillScreen(),
                                ),
                              );
                            },
                            showComingSoon: false,
                            subtitle: null,
                            iconColor: const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Learning Progress và Overview (2 cột)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildLearningProgressSection(authProvider),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCompactSection(
                            AppLocalizations.of(context)!.overview,
                            Icons.dashboard,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProgressScreen(),
                                ),
                              );
                            },
                            showComingSoon: false,
                            subtitle: null,
                            iconColor: const Color(0xFF43A047),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuestHero(AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [_kGuestHeroStart, _kGuestHeroEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _kGuestHeroStart.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Text(
                'WELCOME TO ${loc.appName.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Where Language\nFinds its Flow.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.05,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Master any language through our buoyant learning ecosystem. Experience education designed for clarity and growth.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const PlacementTestScreen(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF86EFAC),
                    foregroundColor: const Color(0xFF064E3B),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Start Assessment',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestArcCard({
    required String title,
    required String body,
    required IconData icon,
    required Color bg,
    required Color iconBg,
    required VoidCallback onTap,
    Color? fg,
  }) {
    final foreground = fg ?? _kGuestOnSurface;
    return Material(
      color: bg,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: foreground, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: TextStyle(
                        color: foreground.withValues(alpha: 0.82),
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: foreground.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestQuickTile({
    required String eyebrow,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFEFF6FF),
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.9,
                        color: _kGuestOnSurface.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _kGuestOnSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: _kGuestOnSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(icon, color: _kGuestOnSurface, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Removed legacy welcome card section per request.

  // Removed legacy stat chip (used only by removed welcome section).

  Widget _buildContinueLearning() {
    final loc = AppLocalizations.of(context)!;
    final highestProgress = _userProgress?.highestProgress;
    final languageCode = Localizations.localeOf(context).languageCode;

    // Progress (fallback an toàn)
    final levelId = highestProgress?.levelId ??
        Provider.of<AuthProvider>(context, listen: false).user?.currentLevel ??
        '';
    final levelProgress = _userProgress?.levelProgress[levelId];
    final mastery = (levelProgress?.mastery ?? 0.0).clamp(0.0, 1.0);

    // Fallback: completedUnits/totalUnits
    int totalUnits = 0;
    if (_levels.isNotEmpty && levelId.isNotEmpty) {
      final currentLevelModel = _levels.firstWhere(
        (level) => level.id == levelId,
        orElse: () => _levels.first,
      );
      totalUnits = currentLevelModel.totalUnits;
    }
    final completedUnitsCount = levelProgress?.completedUnits.length ?? 0;
    final fallbackProgress = totalUnits > 0
        ? (completedUnitsCount / totalUnits).clamp(0.0, 1.0)
        : 0.0;
    final progress = mastery > 0 ? mastery : fallbackProgress;
    final percentText = '${(progress * 100).round()}%';

    Future<(UnitModel?, LessonModel?)> loadMeta() async {
      if (highestProgress == null) return (null, null);
      final unit = await _firestoreService.getUnit(highestProgress.unitId);
      final lesson = await _firestoreService.getLesson(highestProgress.lessonId);
      return (unit, lesson);
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleContinueLearningTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: _kPrimaryCtaGradient,
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: FutureBuilder<(UnitModel?, LessonModel?)>(
              future: loadMeta(),
              builder: (context, snapshot) {
                final unit = snapshot.data?.$1;
                final lesson = snapshot.data?.$2;

                final unitTitle = unit?.getTitle(languageCode).trim();
                final lessonTitle = lesson?.getTitle(languageCode).trim();

                final unitNumberRaw = unit?.order ?? 0;
                final lessonNumberRaw = lesson?.order ?? 0;
                final unitNumber = unitNumberRaw > 0 ? unitNumberRaw : unitNumberRaw + 1;
                final lessonNumber =
                    lessonNumberRaw > 0 ? lessonNumberRaw : lessonNumberRaw + 1;

                final title = (unitTitle != null && unitTitle.isNotEmpty)
                    ? 'Unit $unitNumber: $unitTitle – Lesson $lessonNumber'
                    : (highestProgress != null
                        ? 'Unit ${highestProgress.unitId} – Lesson ${highestProgress.lessonId}'
                        : loc.continueLearning);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Text(
                        loc.continueLearning.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    if (lessonTitle != null && lessonTitle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        lessonTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.learningProgress,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          percentText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 10,
                        color: Colors.white.withOpacity(0.22),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF7CFFB2).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: _ResumeLessonButton(
                        label: loc.continueLearning,
                        onPressed: _handleContinueLearningTap,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Removed legacy guest placement test card (replaced by new guest hero + arc).

  // Learning Progress Section với thông tin thực tế
  Widget _buildLearningProgressSection(AuthProvider authProvider) {
    final currentLevel = authProvider.user?.currentLevel ?? 'A1';
    final levelProgress = _userProgress?.levelProgress[currentLevel];
    final completedUnitsCount = levelProgress?.completedUnits.length ?? 0;
    
    // Lấy tổng số unit của level hiện tại
    int totalUnits = 0;
    if (_levels.isNotEmpty) {
      final currentLevelModel = _levels.firstWhere(
        (level) => level.id == currentLevel,
        orElse: () => _levels.first,
      );
      totalUnits = currentLevelModel.totalUnits;
    } else {
      // Fallback nếu chưa load được levels
      totalUnits = 10; // Giá trị mặc định
    }

    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to learning progress screen
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.learningProgress,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Current Level
              Row(
                children: [
                  Icon(
                    Icons.school,
                    size: 20,
                    color: _kPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.currentLevel,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          currentLevel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Units Completed
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: _kPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.unitsCompleted,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '$completedUnitsCount/$totalUnits',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Level Skip Test Button
              if (_canSkipLevel && _nextLevel != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _GradientCtaButton(
                    label: AppLocalizations.of(context)!.skipToLevel(_nextLevel!),
                    icon: Icons.flash_on,
                    onPressed: _hasDailyLimit ? null : _handleLevelSkipTest,
                  ),
                ),
                if (_hasDailyLimit)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      AppLocalizations.of(context)!.dailyLimitReached,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[700],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Compact Section Widget (cho 2 cột)
  Widget _buildCompactSection(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool showComingSoon = true,
    String? subtitle,
    Color? iconColor,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 40,
                      color: iconColor ?? Colors.grey[400],
                    ),
                    if (showComingSoon || subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle ?? AppLocalizations.of(context)!.featureComingSoon,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

