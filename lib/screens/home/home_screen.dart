import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/firebase_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/next_exercise_service.dart';
import '../../models/level_model.dart';
import '../../models/progress_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../learning/level_selection_screen.dart';
import '../learning/exercise_screen.dart';
import '../auth/login_screen.dart';
import '../placement/placement_test_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final NextExerciseService _nextExerciseService = NextExerciseService();
  List<LevelModel> _levels = [];
  bool _isLoading = true;
  UserProgressModel? _userProgress;

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
      }
    } catch (e) {
      debugPrint('Error loading user progress: $e');
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
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sarah Edu'),
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
                  // Welcome Section
                  _buildWelcomeSection(),
                  const SizedBox(height: 24),
                  
                  // Nếu đã đăng nhập: hiển thị Continue Learning
                  if (authProvider.isAuthenticated) ...[
                    // Continue Learning
                    _buildContinueLearning(),
                    const SizedBox(height: 24),
                  ] else ...[
                    // Placement Test Card cho guest user
                    _buildPlacementTestCard(),
                    const SizedBox(height: 24),
                    
                    // Vocabulary và Practice Section (2 cột)
                    Row(
                      children: [
                        Expanded(
                          child: _buildCompactSection(
                            AppLocalizations.of(context)!.vocabulary,
                            Icons.book,
                            () {
                              // TODO: Navigate to vocabulary screen
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCompactSection(
                            AppLocalizations.of(context)!.practice,
                            Icons.fitness_center,
                            () {
                              // TODO: Navigate to practice screen
                            },
                          ),
                        ),
                      ],
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
                              // TODO: Navigate to vocabulary screen
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCompactSection(
                            AppLocalizations.of(context)!.weakSkills,
                            Icons.trending_down,
                            () {
                              // TODO: Navigate to weak skills screen
                            },
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
                              // TODO: Navigate to overview screen
                            },
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

  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isAuthenticated = authProvider.isAuthenticated;
        final userName = authProvider.user?.displayName ?? 'Bạn';
        final streak = authProvider.user?.streak ?? 0;
        final xp = authProvider.user?.totalXP ?? 0;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAuthenticated 
                    ? '${AppLocalizations.of(context)!.welcomeBack}, $userName!' 
                    : AppLocalizations.of(context)!.welcome,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.whatToLearnToday,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                if (isAuthenticated) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatItem(Icons.local_fire_department, '$streak', AppLocalizations.of(context)!.daysStreak),
                      const SizedBox(width: 24),
                      _buildStatItem(Icons.star, '$xp', 'XP'),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.loginToSync,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, 
                            size: 16, 
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildContinueLearning() {
    // Lấy highestProgress để hiển thị thông tin
    final highestProgress = _userProgress?.highestProgress;
    String displayText = 'Bắt đầu học';
    
    if (highestProgress != null) {
      // Parse để hiển thị thông tin
      final parts = highestProgress.exerciseId.split('_');
      if (parts.length >= 5) {
        final level = parts[1].toUpperCase();
        final unit = parts[2];
        final lesson = parts[3];
        displayText = 'Level $level - Unit $unit - Lesson $lesson';
      }
    }

    return Card(
      color: AppTheme.primaryColor,
      child: InkWell(
        onTap: () async {
          // Hiển thị loading
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          try {
            // Tìm exercise tiếp theo
            final nextExercise = highestProgress != null
                ? await _nextExerciseService.getNextExercise(highestProgress)
                : await _nextExerciseService.getFirstExercise();

            if (mounted) {
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
                    content: const Text('Bạn đã hoàn thành tất cả bài học!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context); // Đóng loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.play_circle_filled, 
                color: Colors.white, 
                size: 48,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.continueLearning,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayText,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, 
                color: Colors.white,
                size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlacementTestCard() {
    return Card(
      color: AppTheme.primaryColor,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PlacementTestScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.placementTestTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.placementTestDescription,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                    color: AppTheme.primaryColor,
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
                    color: Colors.green,
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
            ],
          ),
        ),
      ),
    );
  }

  // Compact Section Widget (cho 2 cột)
  Widget _buildCompactSection(String title, IconData icon, VoidCallback onTap) {
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
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.featureComingSoon,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
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

