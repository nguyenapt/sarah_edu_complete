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
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';
import '../../models/lesson_model.dart';

/// Bảng màu gần với mockup Practice (xanh trời, xanh lá, streak vàng).
const Color _kPracticeBg = Color(0xFFF0F9FF);
const Color _kPracticePrimary = Color(0xFF38BDF8);
const Color _kPracticePrimaryDeep = Color(0xFF0369A1);
const Color _kPracticeInk = Color(0xFF0F172A);
const Color _kPracticeCardTint = Color(0xFFE0F2FE);
const Color _kPracticeSuccess = Color(0xFF22C55E);
/// Xanh lá đậm (timeline đã xong) — gần mockup hơn #22C55E.
const Color _kTimelineDoneGreen = Color(0xFF15803D);
const Color _kStreakGradientStart = Color(0xFFFDE68A);
const Color _kStreakGradientEnd = Color(0xFFB45309);
const double _kCardRadius = 18;

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

  /// Nhóm đã xong: mặc định thu gọn; key có trong set = đang mở.
  Set<String>? _expandedCompletedGroups;

  Set<String> get _expandedCompletedGroupKeys {
    _expandedCompletedGroups ??= <String>{};
    return _expandedCompletedGroups!;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPracticeBg,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: _kPracticePrimary,
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPracticeHeader(context, authProvider),
              Expanded(
                child: authProvider.isAuthenticated
                    ? _buildAuthenticatedView(authProvider)
                    : _buildGuestView(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPracticeHeader(BuildContext context, AuthProvider authProvider) {
    final loc = AppLocalizations.of(context)!;
    final title = widget.reviewMode
        ? loc.reviewLevel(widget.reviewLevel ?? '')
        : loc.practice;

    return Material(
      color: _kPracticeBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            children: [
              IconButton(
                tooltip: loc.progress,
                onPressed: () {
                  if (!authProvider.isAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.loginToSync)),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const ProgressScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.insert_chart_outlined_rounded,
                  color: _kPracticeInk.withOpacity(0.85),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _kPracticeInk,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              IconButton(
                tooltip: loc.settings,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: _kPracticeCardTint,
                  child: authProvider.user?.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            authProvider.user!.photoUrl!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person_rounded,
                              color: _kPracticePrimaryDeep,
                              size: 22,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          color: _kPracticePrimaryDeep,
                          size: 22,
                        ),
                ),
              ),
            ],
          ),
        ),
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

    // Nếu có unit groups, hiển thị lộ trình dọc (mockup timeline)
    if (_unitGroups.isNotEmpty) {
      return CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (!widget.reviewMode)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _buildContinueLearningCard(currentLevel),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final group = _unitGroups[index];
                  final prevName = index > 0
                      ? _stripHtmlGroupTitle(_unitGroups[index - 1])
                      : '';
                  return _buildTimelineGroup(
                    group: group,
                    levelId: displayLevel,
                    groupIndex: index,
                    previousGroupTitle: prevName,
                    isLast: index == _unitGroups.length - 1,
                  );
                },
                childCount: _unitGroups.length,
              ),
            ),
          ),
          if (!widget.reviewMode)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: _buildStreakCard(authProvider),
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

  String _stripHtmlGroupTitle(UnitGroup group) {
    final languageCode =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final raw = group.title != null
        ? MultilanguageContent.getText(group.title, languageCode)
        : group.group;
    return raw.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  int _completedLessonsInUnit(UnitModel unit) {
    final progress = _userProgress;
    if (progress == null) return 0;
    final lp = progress.levelProgress[unit.levelId];
    if (lp?.completedUnits.contains(unit.id) ?? false) {
      return unit.lessons.length;
    }
    var done = 0;
    for (final lid in unit.lessons) {
      final ok = progress.exerciseHistory.any(
        (e) => e.lessonId == lid && e.unitId == unit.id && e.score >= 0.5,
      );
      if (ok) done++;
    }
    return done;
  }

  int _completedLessonsInGroup(UnitGroup group) {
    var c = 0;
    for (final u in group.units) {
      c += _completedLessonsInUnit(u);
    }
    return c;
  }

  int _totalLessonsInGroup(UnitGroup group) {
    var t = 0;
    for (final u in group.units) {
      t += u.lessons.length;
    }
    return t;
  }

  double _unitProgressRatio(UnitModel unit) {
    if (unit.lessons.isEmpty) return 0;
    return (_completedLessonsInUnit(unit) / unit.lessons.length).clamp(0.0, 1.0);
  }

  String _completedGroupKey(String levelId, UnitGroup group) =>
      '$levelId::${group.group}';

  bool _isUnitCompleted(UnitModel unit) {
    final lp = _userProgress?.levelProgress[unit.levelId];
    return lp?.completedUnits.contains(unit.id) ?? false;
  }

  int _firstIncompleteUnitIndex(List<UnitModel> sorted, String levelId) {
    final done =
        _userProgress?.levelProgress[levelId]?.completedUnits ?? const <String>[];
    for (var i = 0; i < sorted.length; i++) {
      if (!done.contains(sorted[i].id)) return i;
    }
    return -1;
  }

  Widget _buildTimelineGroup({
    required UnitGroup group,
    required String levelId,
    required int groupIndex,
    required String previousGroupTitle,
    required bool isLast,
  }) {
    final locked = !widget.reviewMode && (!group.isUnlocked || group.type == GroupType.locked);
    final completed = group.isCompleted && group.isUnlocked && !locked;

    _TimelineDotStyle dotStyle;
    if (locked) {
      dotStyle = _TimelineDotStyle.locked;
    } else if (completed) {
      dotStyle = _TimelineDotStyle.done;
    } else {
      dotStyle = _TimelineDotStyle.active;
    }

    // Không dùng IntrinsicHeight + Row + Expanded: intrinsic height sai → Column bị max ~80px và overflow.
    // Cột timeline phải có chiều cao hữu hạn: Stack + chỉ Positioned + maxHeight = ∞ → RenderStack size MISSING (web).
    //
    // Đoạn nét đứt chỉ cần đủ nối xuống nhóm kế — KHÔNG dùng ~320px: Row lấy max(trái, phải),
    // cột trái 348px sẽ kéo cả hàng cao 348px dù thẻ phải thấp → khoảng trống lớn dưới thẻ (như screenshot).
    const double dashSegmentHeight = 44;
    const double dotTop = 4;
    final double railHeight = isLast ? 44.0 : (28 + dashSegmentHeight);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            height: railHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (!isLast)
                  Positioned(
                    left: 19,
                    top: 28,
                    child: SizedBox(
                      width: 2,
                      height: dashSegmentHeight,
                      child: CustomPaint(
                        painter: _VerticalDashedLinePainter(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: dotTop,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _PracticeTimelineDot(style: dotStyle),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: locked
                ? _buildLockedGroupCard(group, previousGroupTitle, levelId)
                : completed
                    ? _buildCompletedGroupCard(group, levelId)
                    : _buildActiveGroupPath(group, levelId),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedGroupCard(
    UnitGroup group,
    String previousGroupTitle,
    String levelId,
  ) {
    final loc = AppLocalizations.of(context)!;
    final title = _stripHtmlGroupTitle(group);
    final hint = previousGroupTitle.isEmpty
        ? loc.notUnlocked
        : '${loc.unlock} “$previousGroupTitle” ${loc.notUnlocked.toLowerCase()}.';

    return Opacity(
      opacity: 0.55,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_kCardRadius),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title.isEmpty ? loc.locked : title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _kPracticeInk.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  /// Nhóm đã xong: mặc định thu gọn; bấm header để xem danh sách unit (REVIEW + thanh tiến độ).
  Widget _buildCompletedGroupCard(UnitGroup group, String levelId) {
    final loc = AppLocalizations.of(context)!;
    final languageCode =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final sorted = List<UnitModel>.from(group.units)
      ..sort((a, b) => a.order.compareTo(b.order));
    final key = _completedGroupKey(levelId, group);
    final expanded = _expandedCompletedGroupKeys.contains(key);
    final done = _completedLessonsInGroup(group);
    final total = _totalLessonsInGroup(group);
    final stripped = _stripHtmlGroupTitle(group);
    final shortTitle =
        stripped.isNotEmpty ? stripped : (group.group.isNotEmpty ? group.group : loc.practice);

    return Container(
      decoration: BoxDecoration(
        color: _kPracticeCardTint,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: _kPracticePrimary.withOpacity(0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (expanded) {
                  _expandedCompletedGroupKeys.remove(key);
                } else {
                  _expandedCompletedGroupKeys.add(key);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shortTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: _kPracticeInk,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$done/$total ${loc.lessons}',
                          style: TextStyle(
                            fontSize: 13,
                            color: _kPracticePrimaryDeep.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: _kPracticePrimaryDeep,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Divider(height: 1, color: _kPracticePrimary.withOpacity(0.2)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (group.title != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8, left: 2),
                                child: Html(
                                  data: MultilanguageContent.getText(
                                    group.title,
                                    languageCode,
                                  ),
                                  style: {
                                    'body': Style(
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                      fontSize: FontSize(13),
                                      fontWeight: FontWeight.w700,
                                      color: _kPracticePrimaryDeep,
                                    ),
                                  },
                                ),
                              ),
                            ...sorted.asMap().entries.map((entry) {
                              final i = entry.key;
                              final unit = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildUnitPathCard(
                                  group: group,
                                  unit: unit,
                                  levelId: levelId,
                                  unitIndex: i,
                                  isCompleted: true,
                                  isLocked: false,
                                  isCurrent: false,
                                  showReviewBadge: false,
                                  reviewStyleRow: true,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGroupPath(UnitGroup group, String levelId) {
    final languageCode =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final sorted = List<UnitModel>.from(group.units)
      ..sort((a, b) => a.order.compareTo(b.order));
    final firstInc = _firstIncompleteUnitIndex(sorted, levelId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (group.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2),
            child: Html(
              data: MultilanguageContent.getText(group.title, languageCode),
              style: {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(13),
                  fontWeight: FontWeight.w700,
                  color: _kPracticePrimaryDeep,
                ),
              },
            ),
          ),
        ...sorted.asMap().entries.map((entry) {
          final i = entry.key;
          final unit = entry.value;
          final isCompleted = _isUnitCompleted(unit);
          final isLocked = !isCompleted && firstInc >= 0 && i > firstInc;
          final isCurrent = !isCompleted && firstInc >= 0 && i == firstInc;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildUnitPathCard(
              group: group,
              unit: unit,
              levelId: levelId,
              unitIndex: i,
              isCompleted: isCompleted,
              isLocked: isLocked,
              isCurrent: isCurrent,
              showReviewBadge: group.type == GroupType.review && i == 0,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUnitPathCard({
    required UnitGroup group,
    required UnitModel unit,
    required String levelId,
    required int unitIndex,
    required bool isCompleted,
    required bool isLocked,
    required bool isCurrent,
    required bool showReviewBadge,
    bool reviewStyleRow = false,
  }) {
    final languageCode =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final title = unit.getTitle(languageCode);
    final ratio = _unitProgressRatio(unit);
    final loc = AppLocalizations.of(context)!;

    final border = isCurrent
        ? Border.all(color: _kPracticePrimary, width: 2)
        : isLocked
            ? Border.all(color: Colors.grey.shade400, width: 1, style: BorderStyle.solid)
            : Border.all(color: Colors.grey.shade200);

    final showReviewHeader = showReviewBadge || reviewStyleRow;

    if (isLocked) {
      return Opacity(
        opacity: 0.65,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_kCardRadius),
            border: Border.all(color: Colors.grey.shade400, width: 1.2),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: Colors.grey.shade500),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${unitIndex + 1}. $title',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: Colors.white,
      elevation: isCurrent ? 2 : 0,
      shadowColor: _kPracticePrimary.withOpacity(0.25),
      borderRadius: BorderRadius.circular(_kCardRadius),
      child: InkWell(
        onTap: isLocked
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => UnitListScreen(unit: unit),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_kCardRadius),
            border: border,
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showReviewHeader) ...[
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _kPracticeCardTint,
                      child: Icon(
                        Icons.history_rounded,
                        color: _kPracticePrimaryDeep,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${unitIndex + 1}. $title',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: _kPracticeInk,
                                ),
                              ),
                            ),
                            if (showReviewHeader) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  loc.review.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent && !isCompleted) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: CircularProgressIndicator(
                              value: ratio,
                              strokeWidth: 3,
                              backgroundColor: _kPracticeCardTint,
                              color: _kPracticePrimary,
                            ),
                          ),
                          Text(
                            '${(ratio * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _kPracticePrimaryDeep,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (isCompleted && !showReviewHeader)
                    Icon(
                      Icons.check_circle_rounded,
                      color: _kTimelineDoneGreen,
                      size: 26,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: _kPracticeCardTint,
                  color: _kPracticePrimary,
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(height: 12),
                _UnitLessonRows(
                  unit: unit,
                  firestore: _firestoreService,
                  userProgress: _userProgress,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(AuthProvider authProvider) {
    final loc = AppLocalizations.of(context)!;
    final streak = authProvider.user?.streak ?? 0;

    return Material(
      borderRadius: BorderRadius.circular(_kCardRadius),
      elevation: 3,
      shadowColor: _kStreakGradientEnd.withOpacity(0.35),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const ProgressScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_kCardRadius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kStreakGradientStart, Color(0xFFD97706)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF78350F), size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${loc.daysStreak}: $streak!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF451A03),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  loc.practiceSuggestions,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Color(0xFF78350F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF78350F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const ProgressScreen(),
                        ),
                      );
                    },
                    child: Text(loc.progress),
                  ),
                ),
              ],
            ),
          ),
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

  // Continue learning card - pill giống mockup (nền xanh đậm)
  Widget _buildContinueLearningCard(String currentLevel) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(_kCardRadius),
      shadowColor: _kPracticePrimary.withOpacity(0.35),
      child: InkWell(
        onTap: () async {
          if (mounted) {
            showDialog<void>(
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
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.allLessonsCompleted),
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
        borderRadius: BorderRadius.circular(_kCardRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_kCardRadius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kPracticePrimaryDeep, Color(0xFF0EA5E9)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                const Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 44,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.continueLearning,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
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

enum _TimelineDotStyle { done, active, locked }

/// Chấm timeline: xong / đang học (có animation breathing) / khóa.
class _PracticeTimelineDot extends StatelessWidget {
  const _PracticeTimelineDot({required this.style});

  final _TimelineDotStyle style;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case _TimelineDotStyle.done:
        return const _StaticTimelineDotDone();
      case _TimelineDotStyle.active:
        return const _BreathingPracticeTimelineDot();
      case _TimelineDotStyle.locked:
        return const _StaticTimelineDotLocked();
    }
  }
}

class _StaticTimelineDotDone extends StatelessWidget {
  const _StaticTimelineDotDone();

  /// Mockup: vòng trắng ngoài → vòng xanh giữa → tam giác play (giống nút play) trong cùng.
  static const double _outerWhite = 34;
  static const double _innerGreen = 22;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _outerWhite,
      height: _outerWhite,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _kTimelineDoneGreen.withOpacity(0.22),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: _innerGreen,
            height: _innerGreen,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _kTimelineDoneGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _StaticTimelineDotLocked extends StatelessWidget {
  const _StaticTimelineDotLocked();

  static const double _k = 28;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _k,
      height: _k,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade600, size: 16),
    );
  }
}

/// Trạng thái "đang practice": animation breathing (nhịp thở — opacity + glow nhẹ).
class _BreathingPracticeTimelineDot extends StatefulWidget {
  const _BreathingPracticeTimelineDot();

  @override
  State<_BreathingPracticeTimelineDot> createState() =>
      _BreathingPracticeTimelineDotState();
}

class _BreathingPracticeTimelineDotState extends State<_BreathingPracticeTimelineDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ).value;
        final glow = 0.18 + 0.55 * t;

        // Mockup: lớp glow xanh nhạt ngoài → vòng trắng → tam giác play xanh (breathing).
        final outerGlowSize = 34.0 + 4 * t;
        return SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: outerGlowSize,
                height: outerGlowSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kPracticePrimary.withOpacity(0.14 + 0.22 * t),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _kPracticePrimary.withOpacity(0.28 + 0.35 * glow),
                      blurRadius: 10 + 12 * t,
                      spreadRadius: 1 + 2.5 * t,
                    ),
                  ],
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: _kPracticePrimaryDeep,
                  size: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VerticalDashedLinePainter extends CustomPainter {
  _VerticalDashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    final mid = size.width / 2;
    const dash = 5.0;
    const gap = 4.0;
    var y = 0.0;
    while (y < size.height) {
      final end = math.min(y + dash, size.height);
      canvas.drawLine(Offset(mid, y), Offset(mid, end), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalDashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _UnitLessonRows extends StatefulWidget {
  const _UnitLessonRows({
    required this.unit,
    required this.firestore,
    required this.userProgress,
  });

  final UnitModel unit;
  final FirestoreService firestore;
  final UserProgressModel? userProgress;

  @override
  State<_UnitLessonRows> createState() => _UnitLessonRowsState();
}

class _UnitLessonRowsState extends State<_UnitLessonRows> {
  List<LessonModel>? _lessons;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await widget.firestore.getLessonsByUnit(widget.unit.id);
      if (mounted) {
        setState(() {
          _lessons = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _lessons = [];
          _loading = false;
        });
      }
    }
  }

  bool _lessonDone(LessonModel lesson) {
    return widget.userProgress?.exerciseHistory.any(
          (e) =>
              e.lessonId == lesson.id &&
              e.unitId == widget.unit.id &&
              e.score >= 0.5,
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: LinearProgressIndicator(minHeight: 2, color: _kPracticePrimary),
      );
    }
    final lessons = _lessons ?? [];
    if (lessons.isEmpty) return const SizedBox.shrink();

    final languageCode =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;

    var firstIncomplete = -1;
    for (var i = 0; i < lessons.length; i++) {
      if (!_lessonDone(lessons[i])) {
        firstIncomplete = i;
        break;
      }
    }

    return Column(
      children: lessons.asMap().entries.map((entry) {
        final i = entry.key;
        final lesson = entry.value;
        final done = _lessonDone(lesson);
        final isCurrent = firstIncomplete >= 0 && i == firstIncomplete;
        final locked = firstIncomplete >= 0 && i > firstIncomplete;

        late Color bg;
        late IconData icon;
        if (done) {
          bg = _kPracticeCardTint;
          icon = Icons.check_circle_rounded;
        } else if (isCurrent) {
          bg = _kPracticePrimary;
          icon = Icons.play_arrow_rounded;
        } else {
          bg = Colors.grey.shade200;
          icon = Icons.lock_outline_rounded;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: locked ? Colors.grey.shade200 : bg,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: locked
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => UnitListScreen(unit: widget.unit),
                        ),
                      );
                    },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(icon, color: locked ? Colors.grey.shade600 : (isCurrent ? Colors.white : _kPracticeSuccess), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lesson.getTitle(languageCode),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: locked ? Colors.grey.shade600 : (isCurrent ? Colors.white : _kPracticeInk),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
