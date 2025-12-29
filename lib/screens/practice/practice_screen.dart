import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../core/services/firestore_service.dart';
import '../../models/unit_model.dart';
import '../../models/level_model.dart';
import '../../models/progress_model.dart';
import '../../core/constants/firebase_constants.dart';
import '../learning/unit_list_screen.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();
  Map<String, GlobalKey> _unitKeys = {};
  
  List<UnitModel> _allUnits = [];
  List<LevelModel> _levels = [];
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

      // Load levels và units
      final levels = await _firestoreService.getLevels();
      final units = await _firestoreService.getAllUnits();

      // Tạo keys cho mỗi unit để scroll đến
      final keys = <String, GlobalKey>{};
      for (final unit in units) {
        keys[unit.id] = GlobalKey();
      }

      setState(() {
        _levels = levels;
        _allUnits = units;
        _unitKeys = keys;
        _isLoading = false;
      });

      // Nếu user đã đăng nhập, load userProgress và scroll đến unit hiện tại
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.user != null) {
        final userId = authProvider.user!.id;
        final currentLevel = authProvider.user!.currentLevel;
        await _loadUserProgress(userId);
        if (mounted) {
          _scrollToCurrentUnit(currentLevel);
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
    
    final unitIndex = unitsInLevel.indexWhere((u) => u.id == currentUnit!.id);
    final unitNumber = unitIndex >= 0 ? unitIndex + 1 : 1;
    
    // Lấy title của unit
    final unitTitle = currentUnit.getTitle(languageCode);
    
    // Kiểm tra xem title đã có "Unit X:" chưa, nếu có thì chỉ lấy phần sau
    final unitTitleRegex = RegExp(r'^Unit\s+\d+:\s*(.+)$', caseSensitive: false);
    final match = unitTitleRegex.firstMatch(unitTitle);
    
    if (match != null) {
      // Title đã có "Unit X:", chỉ lấy phần sau
      return 'Unit $unitNumber: ${match.group(1)}';
    } else {
      // Title chưa có "Unit X:", thêm vào
      return 'Unit $unitNumber: $unitTitle';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.practice),
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

    return Column(
      children: [
        // "Tiếp tục học" section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: InkWell(
            onTap: () {
              // Navigate to current unit
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
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.continueLearning,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCurrentUnitTitle(currentLevel),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Danh sách units
        Expanded(
          child: _buildUnitsList(highlightCurrentLevel: currentLevel),
        ),
      ],
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Units list (không có level header khi chọn "All")
            ...units.map((unit) => _buildUnitCard(
                  unit,
                  highlightCurrentLevel != null && 
                  level.id == highlightCurrentLevel && 
                  (unit.id == _currentUnitId || (_currentUnitId == null && unit == units.first)),
                )),
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

  // Unit card
  Widget _buildUnitCard(UnitModel unit, bool isHighlighted) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    return Card(
      key: _unitKeys[unit.id],
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isHighlighted ? 4 : 2,
      color: isHighlighted ? AppTheme.primaryColor.withOpacity(0.05) : null,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UnitListScreen(unit: unit),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.levelColors[unit.levelId]?.withOpacity(0.1) ??
                      AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    unit.levelId,
                    style: TextStyle(
                      color: AppTheme.levelColors[unit.levelId] ?? AppTheme.primaryColor,
                      fontSize: 14,
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (unit.getDescription(languageCode).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        unit.getDescription(languageCode),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.book,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${unit.lessons.length} ${AppLocalizations.of(context)!.lessons}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${unit.estimatedTime} ${AppLocalizations.of(context)!.minutes}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isHighlighted)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.continueLearning,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
