import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/firebase_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/firestore_service.dart';
import '../../models/level_model.dart';
import '../../models/progress_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../learning/level_selection_screen.dart';
import '../auth/login_screen.dart';
import '../placement/placement_test_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
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
                  
                  // Levels Section
                  _buildLevelsSection(),
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
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueLearning() {
    return Card(
      color: AppTheme.primaryColor,
      child: InkWell(
        onTap: () {
          // Navigate to current lesson
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
                      'Unit 1: Present Simple',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
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

  Widget _buildLevelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.levels,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _levels.isEmpty ? AppConstants.levels.length : _levels.length,
          itemBuilder: (context, index) {
            if (_levels.isEmpty) {
              final level = AppConstants.levels[index];
              return _buildLevelCard(level, index == 0, null);
            } else {
              final level = _levels[index];
              // A1 luôn unlock, các level khác unlock khi level trước đã hoàn thành
              final isUnlocked = level.id == 'A1' || index < _levels.length;
              return _buildLevelCard(level.id, isUnlocked, level);
            }
          },
        ),
      ],
    );
  }

  Widget _buildLevelCard(String level, bool isUnlocked, LevelModel? levelModel) {
    final color = AppTheme.levelColors[level] ?? AppTheme.primaryColor;
    
    return Card(
      elevation: isUnlocked ? 4 : 2,
        child: InkWell(
        onTap: isUnlocked
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LevelSelectionScreen(
                      levelId: level,
                      levelModel: levelModel,
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isUnlocked
                ? AppTheme.getLevelGradient(level)
                : null,
            color: isUnlocked ? null : Colors.grey[300],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isUnlocked)
                      Icon(
                        Icons.lock,
                        size: 32,
                        color: Colors.grey[600],
                      )
                    else
                      Text(
                        level,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (isUnlocked) ...[
                      const SizedBox(height: 6),
                      Flexible(
                        child: Text(
                          levelModel != null
                              ? levelModel.getName(Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode)
                              : 'Level $level',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        levelModel != null
                            ? '${levelModel.totalUnits} Units'
                            : '0 Units',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isUnlocked)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.unlock,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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

