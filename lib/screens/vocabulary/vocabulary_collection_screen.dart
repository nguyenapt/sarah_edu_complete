import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/vocabulary_user_state_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/vocabulary/vocab_card_status.dart';
import '../../core/vocabulary/vocabulary_item_key.dart';
import '../../l10n/app_localizations.dart';
import '../../models/lesson_model.dart';
import '../../models/level_model.dart';
import '../../models/unit_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../practice/vocabulary_flashcard_screen.dart';
import '../../core/ads/ad_ids.dart';
import '../../core/ads/widgets/native_ad_widget.dart';
import '../../core/repositories/catalog_repository.dart';
import '../../core/theme/horizon_colors.dart';

/// Palette đồng bộ mockup vocabulary / exercise (Horizon).
// Light palette defaults (dark mode dùng `HorizonColors.of(context)`).
const Color _kSurface = Color(0xFFF4F6FF);
const Color _kOnSurface = Color(0xFF14304F);
const Color _kOnSurfaceVariant = Color(0xFF445D7F);
const Color _kPrimary = Color(0xFF006286);
const Color _kPrimaryContainer = Color(0xFF2DB7F2);
const Color _kSurfaceContainer = Color(0xFFDDE9FF);
const Color _kCard = Color(0xFFFFFFFF);
const Color _kTertiaryContainer = Color(0xFFFED01B);
const Color _kOnTertiaryContainer = Color(0xFF594700);
const Color _kWeakChipBg = Color(0xFFFFF4E0);
const Color _kWotdTeal = Color(0xFF004D5C);

const LinearGradient _kPracticeGradient = LinearGradient(
  colors: [_kPrimary, _kPrimaryContainer],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

enum VocabularySortOption { wordAsc, wordDesc, definitionAsc, definitionDesc }

enum _VocabFilterChip { all, verbs, nouns, idioms, weak }

class VocabularyCollectionScreen extends StatefulWidget {
  const VocabularyCollectionScreen({super.key});

  @override
  State<VocabularyCollectionScreen> createState() => _VocabularyCollectionScreenState();
}

class _VocabularyCollectionScreenState extends State<VocabularyCollectionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FocusNode _searchFocusNode = FocusNode();
  final List<TopicVocabularyItem> _items = [];
  bool _isLoading = true;
  String _searchQuery = '';
  VocabularySortOption _sortOption = VocabularySortOption.wordAsc;
  _VocabFilterChip _filterChip = _VocabFilterChip.all;
  late final VoidCallback _vocabStateListener;

  @override
  void dispose() {
    VocabularyUserStateService.instance.removeListener(_vocabStateListener);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _vocabStateListener = () {
      if (mounted) setState(() {});
    };
    VocabularyUserStateService.instance.addListener(_vocabStateListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VocabularyUserStateService.instance.ensureLoaded();
    });
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final languageCode =
          Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
      final userLevel = authProvider.user?.currentLevel ?? 'A1';

      final repo = Provider.of<CatalogRepository>(context, listen: false);
      final levels = await repo.getLevels(onFresh: (_) {});
      final allowedLevelIds = _getAllowedLevelIds(levels, userLevel);

      final lessonsRaw = await _firestoreService.getLessonsByLevelsAndType(
        allowedLevelIds,
        LessonType.vocabulary,
      );
      final lessons = List<LessonModel>.from(lessonsRaw);

      final units = await repo.getAllUnits(onFresh: (_) {});
      lessons.sort((a, b) => _compareLessonOrder(a, b, levels, units));

      final deduped = <String, TopicVocabularyItem>{};
      for (final lesson in lessons) {
        final topicVocabulary = lesson.theory?.vocabulary?.topicVocabulary ?? [];
        for (final item in topicVocabulary) {
          final key =
              '${item.word.toLowerCase()}|${item.partOfSpeech.toLowerCase()}|${item.getDefinition(languageCode).toLowerCase()}';
          deduped.putIfAbsent(key, () => item);
        }
      }

      if (mounted) {
        setState(() {
          _items
            ..clear()
            ..addAll(deduped.values);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading vocabulary: $e');
    }
  }

  List<String> _getAllowedLevelIds(List<LevelModel> levels, String userLevelId) {
    final userLevel = levels.where((level) => level.id == userLevelId).toList();
    if (userLevel.isEmpty) {
      return levels.map((level) => level.id).toList();
    }
    final userOrder = userLevel.first.order;
    return levels
        .where((level) => level.order <= userOrder)
        .map((level) => level.id)
        .toList();
  }

  int _compareLessonOrder(
    LessonModel a,
    LessonModel b,
    List<LevelModel> levels,
    List<UnitModel> units,
  ) {
    final levelOrderMap = {for (final level in levels) level.id: level.order};
    final unitOrderMap = {for (final unit in units) unit.id: unit.order};

    final aLevelOrder = levelOrderMap[a.levelId] ?? 999;
    final bLevelOrder = levelOrderMap[b.levelId] ?? 999;
    if (aLevelOrder != bLevelOrder) {
      return aLevelOrder.compareTo(bLevelOrder);
    }

    final aUnitOrder = unitOrderMap[a.unitId] ?? 999;
    final bUnitOrder = unitOrderMap[b.unitId] ?? 999;
    if (aUnitOrder != bUnitOrder) {
      return aUnitOrder.compareTo(bUnitOrder);
    }

    return a.order.compareTo(b.order);
  }

  bool _isVerbPos(String pos) {
    final p = pos.toLowerCase().trim();
    return p.contains('verb') || p == 'v' || p == 'vb' || p.startsWith('v.');
  }

  bool _isNounPos(String pos) {
    final p = pos.toLowerCase().trim();
    return p.contains('noun') || p == 'n' || p.startsWith('n.');
  }

  bool _isIdiomPos(String pos) {
    final p = pos.toLowerCase().trim();
    return p.contains('idiom') || p.contains('phrase') || p.contains('expr');
  }

  List<TopicVocabularyItem> _applyChipFilter(List<TopicVocabularyItem> items) {
    switch (_filterChip) {
      case _VocabFilterChip.all:
        return List<TopicVocabularyItem>.from(items);
      case _VocabFilterChip.verbs:
        return items.where((e) => _isVerbPos(e.partOfSpeech)).toList();
      case _VocabFilterChip.nouns:
        return items.where((e) => _isNounPos(e.partOfSpeech)).toList();
      case _VocabFilterChip.idioms:
        return items.where((e) => _isIdiomPos(e.partOfSpeech)).toList();
      case _VocabFilterChip.weak:
        final now = DateTime.now().toUtc();
        final svc = VocabularyUserStateService.instance;
        return items
            .where((e) =>
                vocabularyIsWeak(svc.stateForKey(vocabularyItemKey(e)), now))
            .toList();
    }
  }

  List<TopicVocabularyItem> _filterSearchSort(
    List<TopicVocabularyItem> items,
    String languageCode,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    final List<TopicVocabularyItem> afterSearch;
    if (query.isEmpty) {
      afterSearch = List<TopicVocabularyItem>.from(items);
    } else {
      afterSearch = <TopicVocabularyItem>[];
      for (final item in items) {
        final word = item.word.toLowerCase();
        final definition = item.getDefinition(languageCode).toLowerCase();
        if (word.contains(query) || definition.contains(query)) {
          afterSearch.add(item);
        }
      }
    }

    final filtered = List<TopicVocabularyItem>.from(_applyChipFilter(afterSearch));

    int compareBy(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());

    filtered.sort((a, b) {
      // if/else thay vì switch: tránh edge-case dart2js với comparator.
      if (_sortOption == VocabularySortOption.wordAsc) {
        return compareBy(a.word, b.word);
      }
      if (_sortOption == VocabularySortOption.wordDesc) {
        return compareBy(b.word, a.word);
      }
      if (_sortOption == VocabularySortOption.definitionAsc) {
        return compareBy(
          a.getDefinition(languageCode),
          b.getDefinition(languageCode),
        );
      }
      if (_sortOption == VocabularySortOption.definitionDesc) {
        return compareBy(
          b.getDefinition(languageCode),
          a.getDefinition(languageCode),
        );
      }
      return 0;
    });

    return filtered;
  }

  TopicVocabularyItem? _wordOfTheDayItem() {
    if (_items.isEmpty) return null;
    final dayIndex = DateTime.now().toUtc().difference(DateTime.utc(2020)).inDays;
    return _items[dayIndex.abs() % _items.length];
  }

  Future<void> _startPractice(
      List<TopicVocabularyItem> items, String languageCode) async {
    if (items.isEmpty) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => VocabularyFlashcardScreen(
          items: items,
          languageCode: languageCode,
        ),
      ),
    );
    if (!mounted) return;
    await VocabularyUserStateService.instance.loadFromPrefs();
    if (mounted) setState(() {});
  }

  (Color bg, Color fg) _posChipColors(String pos) {
    if (_isIdiomPos(pos)) {
      return (_kTertiaryContainer.withValues(alpha: 0.55), _kOnTertiaryContainer);
    }
    return (_kSurfaceContainer, _kPrimary);
  }

  Widget _buildMockChip(
    AppLocalizations loc,
    _VocabFilterChip chip,
    String label, {
    bool weakStyle = false,
  }) {
    final selected = _filterChip == chip;
    final Color bg = selected
        ? _kPrimary
        : weakStyle
            ? _kWeakChipBg
            : _kSurfaceContainer;
    final Color fg = selected
        ? Colors.white
        : weakStyle
            ? _kOnTertiaryContainer
            : _kPrimary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => setState(() => _filterChip = chip),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardTrailing(AppLocalizations loc, TopicVocabularyItem item) {
    final svc = VocabularyUserStateService.instance;
    final key = vocabularyItemKey(item);
    final st = svc.stateForKey(key);
    final now = DateTime.now().toUtc();
    final primary = vocabularyTrailingPrimary(st, now);
    final progress = vocabularyProgress01(st, now);
    final pct = (progress * 100).round().clamp(5, 100);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (st.favorited)
          const Padding(
            padding: EdgeInsets.only(right: 4, top: 2),
            child: Icon(
              Icons.star_rounded,
              size: 20,
              color: _kTertiaryContainer,
            ),
          ),
        _primaryStatusIcon(loc, primary, progress, pct),
      ],
    );
  }

  Widget _primaryStatusIcon(
    AppLocalizations loc,
    VocabTrailingPrimary primary,
    double progress01,
    int pctLabel,
  ) {
    switch (primary) {
      case VocabTrailingPrimary.reviewSoon:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.south_rounded, color: Color(0xFFE53935), size: 22),
            Text(
              loc.vocabularyReviewSoon,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE53935),
                height: 1.1,
              ),
            ),
          ],
        );
      case VocabTrailingPrimary.mastered:
        return Icon(
          Icons.check_circle_rounded,
          color: AppTheme.successColor,
          size: 28,
        );
      case VocabTrailingPrimary.inProgress:
        return SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: progress01.clamp(0.05, 1.0),
                  strokeWidth: 3,
                  backgroundColor: _kSurfaceContainer,
                  color: _kPrimary,
                ),
              ),
              Text(
                '$pctLabel%',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _kOnSurface,
                ),
              ),
            ],
          ),
        );
      case VocabTrailingPrimary.neutral:
        return Icon(
          Icons.star_outline_rounded,
          color: _kOnSurfaceVariant.withValues(alpha: 0.45),
          size: 26,
        );
    }
  }

  Widget _buildVocabularyCard(
    TopicVocabularyItem item,
    String languageCode,
    AppLocalizations loc,
  ) {
    final def = item.getDefinition(languageCode);
    final (posBg, posFg) = _posChipColors(item.partOfSpeech);
    final posLabel = item.partOfSpeech.trim().isEmpty ? '' : item.partOfSpeech.toUpperCase();

    return Material(
      color: _kCard,
      elevation: 0,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.word,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _kOnSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  _buildCardTrailing(loc, item),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                def,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: _kOnSurfaceVariant.withValues(alpha: 0.9),
                ),
              ),
              if (posLabel.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: posBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    posLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: posFg,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordOfTheDayBanner(
    TopicVocabularyItem item,
    AppLocalizations loc,
    String languageCode,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [_kWotdTeal, _kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.vocabularyWordOfTheDay,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.vocabularyWordOfTheDayBody(item.word),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _startPractice([item], languageCode),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              loc.vocabularyExplore,
              style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeFab(AppLocalizations loc, String languageCode, List<TopicVocabularyItem> items) {
    final enabled = items.isNotEmpty;
    return Material(
      elevation: 8,
      shadowColor: _kPrimary.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? () => _startPractice(items, languageCode) : null,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: enabled ? _kPracticeGradient : null,
            color: enabled ? null : Colors.grey.shade400,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: enabled ? Colors.white : Colors.white70,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Text(
                  loc.practice,
                  style: TextStyle(
                    color: enabled ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _emptyMessage(AppLocalizations loc) {
    if (_items.isEmpty) return loc.practiceVocabularyEmpty;
    if (_filterChip == _VocabFilterChip.weak) return loc.vocabularyWeakWordsEmpty;
    return loc.vocabularyNoMatch;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final languageCode = Provider.of<LanguageProvider>(context).currentLanguageCode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final horizon = HorizonColors.of(context);

    final currentItems = _isLoading
        ? const <TopicVocabularyItem>[]
        : _filterSearchSort(List<TopicVocabularyItem>.from(_items), languageCode);
    final wotd = _wordOfTheDayItem();

    return Scaffold(
      backgroundColor: isDark ? horizon.surface : _kSurface,
      appBar: AppBar(
        backgroundColor: isDark ? horizon.surface : _kSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? horizon.onSurface : _kOnSurface,
        iconTheme: IconThemeData(color: isDark ? horizon.onSurface : _kOnSurface),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          loc.vocabulary,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? horizon.onSurface : _kOnSurface,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          PopupMenuButton<VocabularySortOption>(
            tooltip: loc.vocabularySort,
            child: Icon(
              Icons.sort_rounded,
              color: isDark ? horizon.onSurface : _kOnSurface,
            ),
            onSelected: (value) => setState(() => _sortOption = value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: VocabularySortOption.wordAsc,
                child: Text(loc.vocabularySortWordAsc),
              ),
              PopupMenuItem(
                value: VocabularySortOption.wordDesc,
                child: Text(loc.vocabularySortWordDesc),
              ),
              PopupMenuItem(
                value: VocabularySortOption.definitionAsc,
                child: Text(loc.vocabularySortDefinitionAsc),
              ),
              PopupMenuItem(
                value: VocabularySortOption.definitionDesc,
                child: Text(loc.vocabularySortDefinitionDesc),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: loc.vocabularySearchHint,
            onPressed: _searchFocusNode.requestFocus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: TextField(
                        focusNode: _searchFocusNode,
                        style: TextStyle(
                          color: isDark ? horizon.onSurface : _kOnSurface,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: loc.vocabularySearchDictionaryHint,
                          hintStyle: TextStyle(
                            color: (isDark ? horizon.onSurfaceVariant : _kOnSurfaceVariant)
                                .withValues(alpha: 0.65),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: isDark ? horizon.onSurfaceVariant : _kOnSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: isDark ? horizon.card : _kCard,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildMockChip(loc, _VocabFilterChip.all, loc.all),
                          _buildMockChip(loc, _VocabFilterChip.verbs, loc.vocabularyChipVerbs),
                          _buildMockChip(loc, _VocabFilterChip.nouns, loc.vocabularyChipNouns),
                          _buildMockChip(loc, _VocabFilterChip.idioms, loc.vocabularyChipIdioms),
                          _buildMockChip(
                            loc,
                            _VocabFilterChip.weak,
                            loc.vocabularyChipWeakWords,
                            weakStyle: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: Text(
                                loc.vocabularyRecentMasteries,
                                style: const TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w800,
                                  color: _kOnSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          if (currentItems.isEmpty)
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 220,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      _emptyMessage(loc),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _kOnSurfaceVariant.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    const freq = 8; // insert an ad after every 8 items
                                    final adSlots = currentItems.length ~/ freq;
                                    final total = currentItems.length + adSlots;

                                    if (index >= total) return const SizedBox.shrink();

                                    // Ad slot positions: 8,17,26,... (0-based)
                                    final isAdSlot =
                                        index > 0 && (index + 1) % (freq + 1) == 0;
                                    if (isAdSlot) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: NativeAdWidget(
                                          adUnitId: AdMobIds.nativeVocabList,
                                          factoryId: 'listTile',
                                          maxHeight: 180,
                                        ),
                                      );
                                    }

                                    final adsBefore = index ~/ (freq + 1);
                                    final itemIndex = index - adsBefore;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildVocabularyCard(
                                        currentItems[itemIndex],
                                        languageCode,
                                        loc,
                                      ),
                                    );
                                  },
                                  childCount:
                                      currentItems.length + (currentItems.length ~/ 8),
                                ),
                              ),
                            ),
                          if (wotd != null && _items.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  currentItems.isEmpty ? 0 : 8,
                                  16,
                                  0,
                                ),
                                child: _buildWordOfTheDayBanner(wotd, loc, languageCode),
                              ),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 120)),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Center(
                        child: _buildPracticeFab(loc, languageCode, currentItems),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
