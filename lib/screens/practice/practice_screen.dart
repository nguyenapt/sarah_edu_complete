import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/next_exercise_service.dart';
import '../../core/services/unit_group_service.dart';
import '../../models/unit_model.dart';
import '../../models/level_model.dart';
import '../../models/progress_model.dart';
import '../../models/unit_group_model.dart';
import '../../models/multilanguage_content.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../core/constants/firebase_constants.dart';
import '../learning/unit_list_screen.dart';
import '../learning/exercise_screen.dart';
import 'group_exercise_screen.dart';
import '../../core/services/unit_group_service.dart';

class PracticeScreen extends StatefulWidget {
  final bool reviewMode;
  final String? reviewLevel; // Level để ôn tập (chỉ dùng khi reviewMode = true)
  
  const PracticeScreen({
    super.key,
    this.reviewMode = false,
    this.reviewLevel,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final NextExerciseService _nextExerciseService = NextExerciseService();
  final UnitGroupService _unitGroupService = UnitGroupService();
  final ScrollController _scrollController = ScrollController();
  Map<String, GlobalKey> _unitKeys = {};
  
  List<UnitModel> _allUnits = [];
  List<LevelModel> _levels = [];
  List<UnitGroup> _unitGroups = [];
  bool _isLoading = true;
  String? _selectedLevel; // null = All, hoặc 'A1', 'A2', etc.
  String? _currentUnitId; // Unit hiện tại user đang học (cho authenticated user)
  UserProgressModel? _userProgress;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Xác định level cần load
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? targetLevel;
      
      if (widget.reviewMode && widget.reviewLevel != null) {
        targetLevel = widget.reviewLevel!;
      } else if (authProvider.isAuthenticated && authProvider.user != null) {
        targetLevel = authProvider.user!.currentLevel;
      }

      // Parallel loading: load levels và units song song
      final results = await Future.wait([
        _firestoreService.getLevels(),
        targetLevel != null
            ? _firestoreService.getUnitsByLevel(targetLevel)
            : _firestoreService.getAllUnits(),
      ]);

      final levels = results[0] as List<LevelModel>;
      final units = results[1] as List<UnitModel>;

      // Tạo keys cho mỗi unit để scroll đến (lazy loading - chỉ tạo khi cần)
      final keys = <String, GlobalKey>{};
      // Không tạo keys cho tất cả units ngay, sẽ tạo on-demand

      setState(() {
        _levels = levels.cast();
        _allUnits = units.cast();
        _unitKeys = keys;
      });

      // Nếu user đã đăng nhập và không phải review mode, load userProgress và unit groups
      if (authProvider.isAuthenticated && authProvider.user != null && !widget.reviewMode) {
        final userId = authProvider.user!.id;
        final currentLevel = authProvider.user!.currentLevel;
        
        debugPrint('🔍 Loading data for authenticated user: userId=$userId, currentLevel=$currentLevel');
        
        // Load userProgress (không throw error nếu null)
        await _loadUserProgress(userId);
        
        // Luôn load unit groups, ngay cả khi chưa có userProgress
        // Logic mới của getAllUnitGroups() đã xử lý trường hợp highestProgress == null
        // (sẽ unlock group đầu tiên - index 0)
        try {
          debugPrint('🔍 Loading unit groups from groupUnits collection for level $currentLevel');
          
          // Tạo progress object để pass vào getAllUnitGroups
          // Nếu chưa có userProgress, tạo một UserProgressModel empty
          final progress = _userProgress ?? UserProgressModel(
            userId: userId,
            weakPoints: WeakPoints(),
            lastUpdated: DateTime.now(),
          );
          
          debugPrint('🔍 UserProgress status: hasUserProgress=${_userProgress != null}, highestProgress=${progress.highestProgress?.exerciseId ?? "null"}');
          
          final groups = await _unitGroupService.getAllUnitGroups(
            currentLevel,
            progress,
            progress.highestProgress,
          );
          
          debugPrint('✅ Loaded ${groups.length} unit groups for level $currentLevel');
          if (groups.isNotEmpty) {
            debugPrint('📋 Group details:');
            for (var group in groups) {
              debugPrint('  - ${group.group}: type=${group.type}, unlocked=${group.isUnlocked}, units=${group.units.length}');
            }
          } else {
            debugPrint('⚠️ No groups found! This will trigger fallback to units view.');
          }
          
          if (mounted) {
            setState(() {
              _unitGroups = groups;
              _isLoading = false;
            });
          }
        } catch (e, stackTrace) {
          // Nếu có lỗi load groups, log và tiếp tục với fallback view
          debugPrint('❌ Error loading unit groups: $e');
          debugPrint('Stack trace: $stackTrace');
          if (mounted) {
            setState(() {
              _unitGroups = [];
              _isLoading = false; // Vẫn set false để hiển thị fallback view
            });
          }
        }
      } else {
        // Guest user hoặc review mode: không cần load groups, set loading = false ngay
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToLevel(String? levelId) {
    if (levelId == null) {
      // Scroll to top
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Tìm unit đầu tiên của level
    final firstUnit = _allUnits.firstWhere(
      (unit) => unit.levelId == levelId,
      orElse: () => _allUnits.first,
    );

    _scrollToUnit(firstUnit.id);
  }

  void _scrollToUnit(String unitId) {
    final key = _unitKeys[unitId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1, // Scroll để unit hiển thị ở 10% từ trên
      );
    }
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
          
          // Lấy currentUnit từ levelProgress của currentLevel
          final currentLevel = Provider.of<AuthProvider>(context, listen: false).user?.currentLevel ?? 'A1';
          final levelProgress = _userProgress!.levelProgress[currentLevel];
          _currentUnitId = levelProgress?.currentUnit;
        });
      }
    } catch (e) {
      debugPrint('Error loading user progress: $e');
    }
  }

  void _scrollToCurrentUnit(String currentLevel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Nếu có currentUnit, scroll đến unit đó
      if (_currentUnitId != null && _unitKeys.containsKey(_currentUnitId)) {
        _scrollToUnit(_currentUnitId!);
      } else {
        // Nếu không có, scroll đến unit đầu tiên của level hiện tại
        _scrollToLevel(currentLevel);
      }
    });
  }

  String _getCurrentUnitTitle(String currentLevel) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    // Tìm unit hiện tại
    UnitModel? currentUnit;
    if (_currentUnitId != null) {
      try {
        currentUnit = _allUnits.firstWhere((u) => u.id == _currentUnitId);
      } catch (e) {
        // Unit không tìm thấy
      }
    }
    
    // Nếu không có currentUnit, lấy unit đầu tiên của level hiện tại
    if (currentUnit == null) {
      try {
        currentUnit = _allUnits.firstWhere(
          (u) => u.levelId == currentLevel,
          orElse: () => _allUnits.isNotEmpty ? _allUnits.first : throw Exception('No units'),
        );
      } catch (e) {
        return 'Unit 1';
      }
    }
    
    // Tìm số thứ tự của unit trong level
    final unitsInLevel = _allUnits
        .where((u) => u.levelId == currentUnit!.levelId)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    
    return currentUnit.getTitle(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reviewMode 
            ? AppLocalizations.of(context)!.reviewLevel(widget.reviewLevel ?? "") 
            : AppLocalizations.of(context)!.practice),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (authProvider.isAuthenticated) {
            return _buildAuthenticatedView(authProvider);
          } else {
            return _buildGuestView();
          }
        },
      ),
    );
  }

  // View cho guest user
  Widget _buildGuestView() {
    return Column(
      children: [
        // Group buttons: All, A1, A2, B1, B2, C1, C2
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildLevelButton(
                  null, 
                  AppLocalizations.of(context)!.all, 
                  isFirst: true,
                  isLast: false,
                ),
              ),
              ..._levels.asMap().entries.map((entry) {
                final index = entry.key;
                final level = entry.value;
                return Expanded(
                  child: _buildLevelButton(
                    level.id, 
                    level.id, 
                    isFirst: false,
                    isLast: index == _levels.length - 1,
                  ),
                );
              }),
            ],
          ),
        ),
        // Danh sách units (đã filter)
        Expanded(
          child: _buildUnitsList(),
        ),
      ],
    );
  }

  // View cho authenticated user
  Widget _buildAuthenticatedView(AuthProvider authProvider) {
    final currentLevel = authProvider.user?.currentLevel ?? 'A1';
    // Trong review mode, dùng reviewLevel; không phải review mode thì dùng currentLevel
    final displayLevel = widget.reviewMode && widget.reviewLevel != null 
        ? widget.reviewLevel! 
        : currentLevel;

    // Nếu có unit groups, hiển thị modules
    if (_unitGroups.isNotEmpty) {
      return Column(
        children: [
          // "Tiếp tục học" section - cố định ở trên (chỉ hiển thị khi không phải review mode)
          if (!widget.reviewMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _buildContinueLearningCard(currentLevel),
            ),
          // Danh sách practice modules - scroll được
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ..._unitGroups.map((group) {
                  return _buildPracticeModule(group, displayLevel);
                }),
              ],
            ),
          ),
        ],
      );
    }

    // Fallback: hiển thị view cũ nếu chưa có groups
    // (Có thể do units chưa có field group hoặc chưa load xong)
    // Kiểm tra xem có units trong level không - dùng displayLevel (reviewLevel nếu là review mode)
    final unitsInLevel = _allUnits.where((u) => u.levelId == displayLevel).toList();
    
    if (unitsInLevel.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noUnits,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // "Học tiếp" section - style giống trang chủ (background màu xanh) (chỉ hiển thị khi không phải review mode)
        if (!widget.reviewMode)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: _buildContinueLearningCard(currentLevel),
          ),
        // Danh sách units - dùng displayLevel (reviewLevel nếu là review mode)
        Expanded(
          child: _buildUnitsList(highlightCurrentLevel: displayLevel),
        ),
      ],
    );
  }

  // Widget để build mỗi practice module
  Widget _buildPracticeModule(UnitGroup group, String levelId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 120),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Star icon bên trái - có thể click
              _buildGradeIcon(group, levelId),
              // Text ở giữa - có thể click
              Expanded(
                child: _buildModuleContent(group, levelId),
              ),
              // Vạch phân cách dọc
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Colors.grey[300],
              ),
              // Menu icon bên phải - có thể click
              _buildMenuIcon(group, levelId),
            ],
          ),
        ),
      ),
    );
  }

  // Widget grade icon (ngôi sao) - có thể click
  Widget _buildGradeIcon(UnitGroup group, String levelId) {
    Color iconColor;
    if (group.type == GroupType.locked) {
      iconColor = Colors.grey;
    } else if (group.type == GroupType.review) {
      iconColor = const Color(0xFFB5E48C); // Màu xanh lá nhạt cho ôn tập
    } else if (group.type == GroupType.continuePractice) {
      iconColor = const Color(0xFFFFA726); // Màu cam cho tiếp tục luyện tập
    } else {
      iconColor = AppTheme.primaryColor;
    }

    // Trong review mode, tất cả items đều enable nhưng vẫn hiển thị lock icon nếu locked
    final isEnabled = widget.reviewMode || group.isUnlocked;

    return InkWell(
      onTap: isEnabled
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupExerciseScreen(
                    levelId: levelId,
                    group: group.group,
                    displayName: _getGroupDisplayName(group.type),
                  ),
                ),
              );
            }
          : null,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Star icon
            CustomPaint(
          size: const Size(48, 48),
          painter: GradePainter(color: iconColor),
            ),
            // Lock icon ở giữa star (chỉ hiển thị khi locked)
            if (group.type == GroupType.locked)
              Icon(
                Icons.lock,
                color: Colors.grey[700],
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  // Widget content ở giữa - có thể click
  Widget _buildModuleContent(UnitGroup group, String levelId) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    // Lấy group title từ groupUnits collection
    final groupTitle = group.title != null 
        ? MultilanguageContent.getText(group.title, languageCode)
        : '';

    return InkWell(
      onTap: group.isUnlocked
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupExerciseScreen(
                    levelId: levelId,
                    group: group.group,
                    displayName: _getGroupDisplayName(group.type),
                  ),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Group type name (bỏ qua nếu locked)
            if (group.type != GroupType.locked)
              Text(
                _getGroupDisplayName(group.type),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: group.type == GroupType.review 
                      ? const Color(0xFFB5E48C) // Màu xanh lá nhạt cho ôn tập
                      : group.type == GroupType.continuePractice 
                          ? const Color(0xFFFFA726) // Màu cam cho tiếp tục luyện tập
                          : Colors.black,
                ),
              ),
            // Group title (HTML formatted)
            if (groupTitle.isNotEmpty) ...[
              if (group.type != GroupType.locked) const SizedBox(height: 2),
              Html(
                data: groupTitle,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(12),
                    color: Colors.grey[600],
                    textAlign: TextAlign.left,
                  ),
                  "p": Style(
                    margin: Margins.only(bottom: 4),
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(12),
                    color: Colors.grey[600],
                  ),
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper method để lấy display name đã được localized
  String _getGroupDisplayName(GroupType type) {
    final localizations = AppLocalizations.of(context)!;
    switch (type) {
      case GroupType.review:
        return localizations.review;
      case GroupType.continuePractice:
        return localizations.continuePractice;
      case GroupType.locked:
        return localizations.locked;
      case GroupType.normal:
        return localizations.practice;
    }
  }

  // Widget menu icon bên phải - có thể click
  Widget _buildMenuIcon(UnitGroup group, String levelId) {
    return InkWell(
      onTap: group.isUnlocked && group.units.isNotEmpty
          ? () async {
              // Navigate đến tất cả units trong group
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UnitListScreen(units: group.units),
                ),
              );
            }
          : null,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.menu,
          color: group.isUnlocked ? Colors.grey[700] : Colors.grey[400],
          size: 20,
        ),
      ),
    );
  }

  // Level button cho guest user
  Widget _buildLevelButton(
    String? levelId, 
    String label, {
    required bool isFirst,
    required bool isLast,
  }) {
    final isSelected = _selectedLevel == levelId;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLevel = isSelected ? null : levelId;
        });
        if (!isSelected) {
          _scrollToLevel(levelId);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? const Radius.circular(8) : Radius.zero,
            bottomLeft: isFirst ? const Radius.circular(8) : Radius.zero,
            topRight: isLast ? const Radius.circular(8) : Radius.zero,
            bottomRight: isLast ? const Radius.circular(8) : Radius.zero,
          ),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Danh sách units
  Widget _buildUnitsList({String? highlightCurrentLevel}) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;

    // Nếu đã chọn một level cụ thể (không phải "All")
    if (_selectedLevel != null) {
      final selectedLevelModel = _levels.firstWhere(
        (level) => level.id == _selectedLevel,
        orElse: () => _levels.first,
      );
      
      final filteredUnits = _allUnits
          .where((unit) => unit.levelId == _selectedLevel)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      if (filteredUnits.isEmpty) {
    return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                  Icons.inbox,
                  size: 64,
                  color: Colors.grey[400],
            ),
                const SizedBox(height: 16),
            Text(
                  AppLocalizations.of(context)!.noUnits,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
                  ),
            ),
        );
      }

      return SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedLevelModel.getName(languageCode),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedLevelModel.getDescription(languageCode),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.book,
                          '${selectedLevelModel.totalUnits} ${AppLocalizations.of(context)!.units}',
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.access_time,
                          '${selectedLevelModel.estimatedHours} ${AppLocalizations.of(context)!.hours}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Units List Header
            Text(
              AppLocalizations.of(context)!.lessonsList,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            // Units list
            ...filteredUnits.asMap().entries.map((entry) {
              final index = entry.key;
              final unit = entry.value;
              return _buildUnitCardForLevel(
                unit,
                index,
                _selectedLevel!,
                highlightCurrentLevel != null && 
                unit.levelId == highlightCurrentLevel && 
                (unit.id == _currentUnitId || (_currentUnitId == null && unit == filteredUnits.first)),
              );
            }),
          ],
        ),
      );
    }

    // Nếu chọn "All" - hiển thị tất cả units theo level
    // Nhóm units theo level
    final unitsByLevel = <String, List<UnitModel>>{};
    for (final unit in _allUnits) {
      if (!unitsByLevel.containsKey(unit.levelId)) {
        unitsByLevel[unit.levelId] = [];
      }
      unitsByLevel[unit.levelId]!.add(unit);
    }

    // Sắp xếp levels theo order (chỉ hiển thị levels có units)
    final sortedLevels = _levels.where((level) => unitsByLevel.containsKey(level.id)).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // Nếu không có units nào
    if (sortedLevels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No units available',
                style: TextStyle(
                  fontSize: 16,
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
                padding: const EdgeInsets.all(16),
      itemCount: sortedLevels.length,
      itemBuilder: (context, index) {
        final level = sortedLevels[index];
        final units = unitsByLevel[level.id] ?? [];
        
        if (units.isEmpty) return const SizedBox.shrink();

        // Sắp xếp units theo order để xác định unit đầu tiên
        final sortedUnits = List<UnitModel>.from(units)
          ..sort((a, b) => a.order.compareTo(b.order));

        // Chỉ áp dụng logic khóa cho guest user (khi highlightCurrentLevel == null)
        final isGuestUser = highlightCurrentLevel == null;

        return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            // Units list (không có level header khi chọn "All")
            ...sortedUnits.asMap().entries.map((entry) {
              final unitIndex = entry.key;
              final unit = entry.value;
              final isLocked = isGuestUser && unitIndex > 0; // Unit đầu tiên (index 0) unlock, các unit khác bị khóa (chỉ cho guest user)
              return _buildUnitCard(
                unit,
                highlightCurrentLevel != null && 
                level.id == highlightCurrentLevel && 
                (unit.id == _currentUnitId || (_currentUnitId == null && unit == sortedUnits.first)),
                isLocked: isLocked,
                unitIndex: unitIndex,
              );
            }),
          ],
        );
      },
    );
  }

  // Info chip cho level card
  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }

  // Unit card cho level selection (giống LevelSelectionScreen)
  Widget _buildUnitCardForLevel(UnitModel unit, int index, String levelId, bool isHighlighted) {
    final isLocked = index > 0; // Unit đầu tiên unlock, các unit khác cần hoàn thành unit trước
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isHighlighted ? 4 : 2,
      color: isHighlighted ? AppTheme.primaryColor.withOpacity(0.05) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLocked
              ? Colors.grey[300]
              : AppTheme.levelColors[levelId] ?? AppTheme.primaryColor,
          child: isLocked
              ? Icon(Icons.lock, color: Colors.grey[600])
              : Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                            fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          unit.getTitle(languageCode),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLocked ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              unit.getDescription(languageCode),
              style: TextStyle(
                color: isLocked ? Colors.grey : null,
                          ),
                    ),
                    const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${unit.estimatedTime} ${AppLocalizations.of(context)!.minutes}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.menu_book, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                    Text(
                  AppLocalizations.of(context)!.lessonsCount(unit.lessons.length),
                  style: TextStyle(
                    fontSize: 12,
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
          ],
            ),
        trailing: isLocked
            ? Icon(Icons.lock, color: Colors.grey[400])
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: isLocked
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UnitListScreen(
                      unit: unit,
                    ),
                  ),
                );
              },
      ),
    );
  }

  // Continue learning card - style giống trang chủ (background màu xanh)
  Widget _buildContinueLearningCard(String currentLevel) {
    return Card(
      margin: EdgeInsets.zero,
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
            // Lấy highestProgress
            final highestProgress = _userProgress?.highestProgress;
            
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
                // Đã học hết hoặc không tìm thấy, fallback về unit
                if (_currentUnitId != null) {
                  final unit = _allUnits.firstWhere(
                    (u) => u.id == _currentUnitId,
                    orElse: () => _allUnits.firstWhere(
                      (u) => u.levelId == currentLevel,
                      orElse: () => _allUnits.first,
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UnitListScreen(unit: unit),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bạn đã hoàn thành tất cả bài học!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
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
              const Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.continueLearning,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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

  // Unit card
  Widget _buildUnitCard(UnitModel unit, bool isHighlighted, {bool isLocked = false, int? unitIndex}) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final levelColor = AppTheme.levelColors[unit.levelId] ?? AppTheme.primaryColor;
    
    return Card(
      key: _unitKeys[unit.id],
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isHighlighted && !widget.reviewMode ? 6 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // Trong review mode, không áp dụng border highlight
        side: isHighlighted && !widget.reviewMode
            ? BorderSide(color: levelColor.withOpacity(0.3), width: 2)
            : BorderSide.none,
            ),
      child: InkWell(
        onTap: isLocked
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UnitListScreen(unit: unit),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Trong review mode, không áp dụng gradient background
            gradient: isHighlighted && !widget.reviewMode
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      levelColor.withOpacity(0.08),
                      levelColor.withOpacity(0.03),
                    ],
                  )
                : null,
          ),
              child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level badge với gradient hoặc lock icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isLocked
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              levelColor,
                              levelColor.withOpacity(0.8),
                            ],
                          ),
                    color: isLocked ? Colors.grey[300] : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isLocked
                        ? null
                        : [
                            BoxShadow(
                              color: levelColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Center(
                    child: isLocked
                        ? Icon(Icons.lock, color: Colors.grey[600], size: 24)
                        : Text(
                            unit.levelId,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        unit.getTitle(languageCode),
                        style: TextStyle(
                          fontSize: 18,
                            fontWeight: FontWeight.bold,
                          color: isLocked 
                              ? Colors.grey 
                              : (isHighlighted ? levelColor : null),
                          ),
                    ),
                      if (unit.getDescription(languageCode).isNotEmpty) ...[
                        const SizedBox(height: 6),
                    Text(
                          unit.getDescription(languageCode),
                          style: TextStyle(
                            fontSize: 14,
                            color: isLocked ? Colors.grey[500] : Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isLocked 
                                  ? Colors.grey[200] 
                                  : levelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isLocked 
                                    ? Colors.grey[300]! 
                                    : levelColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: 14,
                                  color: isLocked ? Colors.grey[600] : levelColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${unit.lessons.length} ${AppLocalizations.of(context)!.lessons}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isLocked ? Colors.grey[600] : levelColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isLocked 
                                  ? Colors.grey[200] 
                                  : levelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isLocked 
                                    ? Colors.grey[300]! 
                                    : levelColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: isLocked ? Colors.grey[600] : levelColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${unit.estimatedTime} ${AppLocalizations.of(context)!.minutes}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isLocked ? Colors.grey[600] : levelColor,
                                    fontWeight: FontWeight.w600,
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
              const SizedBox(width: 12),
              // Continue learning badge nếu highlighted (chỉ hiển thị khi không phải review mode)
              if (isHighlighted && !isLocked && !widget.reviewMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        levelColor,
                        levelColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: levelColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.continueLearning,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                isLocked ? Icons.lock : Icons.chevron_right,
                size: 24,
                color: isLocked 
                    ? Colors.grey[400] 
                    : (isHighlighted ? levelColor : Colors.grey[400]),
            ),
          ],
          ),
        ),
        ),
      ),
    );
  }
}

// Custom painter để vẽ hình ngôi sao (grade)
class GradePainter extends CustomPainter {
  final Color color;

  GradePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4; // Bán kính trong cho ngôi sao 5 cánh

    // Vẽ ngôi sao 5 cánh
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi / 5) - (math.pi / 2); // Bắt đầu từ trên
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
