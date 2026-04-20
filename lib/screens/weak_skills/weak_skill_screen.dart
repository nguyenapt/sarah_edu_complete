import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/weak_skill_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/progress_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../models/lesson_model.dart';
import '../../models/unit_model.dart';
import '../learning/lesson_detail_screen.dart';
import '../../widgets/common/horizon_top_app_bar.dart';

class WeakSkillScreen extends StatefulWidget {
  const WeakSkillScreen({super.key});

  @override
  State<WeakSkillScreen> createState() => _WeakSkillScreenState();
}

class _WeakSkillScreenState extends State<WeakSkillScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  WeakSkillStats? _stats;
  /// lessonId → localized title từ Firestore (Practice Suggestions).
  Map<String, String> _lessonTitles = {};

  @override
  void initState() {
    super.initState();
    _loadWeakSkills();
  }

  Future<void> _loadWeakSkills() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final lang = Provider.of<LanguageProvider>(context, listen: false)
        .currentLanguageCode;

    try {
      final progress = await _firestoreService.getUserProgress(authProvider.user!.id);
      final stats = progress?.weakSkillStats ??
          WeakSkillService().buildStats(progress?.exerciseHistory ?? []);
      final titles = stats.recommendedLessons.isEmpty
          ? <String, String>{}
          : await _fetchLessonTitles(stats.recommendedLessons, lang);
      if (mounted) {
        setState(() {
          _stats = stats;
          _lessonTitles = titles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, String>> _fetchLessonTitles(
    List<String> ids,
    String languageCode,
  ) async {
    final out = <String, String>{};
    final unitCache = <String, UnitModel?>{};

    Future<UnitModel?> unitCached(String unitId) async {
      if (unitId.isEmpty) return null;
      if (unitCache.containsKey(unitId)) return unitCache[unitId];
      try {
        final u = await _firestoreService.getUnit(unitId);
        unitCache[unitId] = u;
        return u;
      } catch (_) {
        unitCache[unitId] = null;
        return null;
      }
    }

    await Future.wait(ids.map((id) async {
      try {
        final lesson = await _firestoreService.getLesson(id);
        if (lesson == null) return;

        String? resolved;
        // Bài vocabulary: hiển thị title của vocabulary unit (UnitModel), không chỉ lesson.
        if (lesson.type == LessonType.vocabulary && lesson.unitId.isNotEmpty) {
          final unit = await unitCached(lesson.unitId);
          final ut = unit?.getTitle(languageCode).trim() ?? '';
          if (ut.isNotEmpty) resolved = ut;
        }
        if (resolved == null) {
          final lt = lesson.getTitle(languageCode).trim();
          if (lt.isNotEmpty) resolved = lt;
        }
        if (resolved != null) out[id] = resolved;
      } catch (_) {
        // Bỏ qua từng bài lỗi; UI vẫn hiển thị humanize id.
      }
    }));
    return out;
  }

  /// Hiển thị slug/technical id dễ đọc khi chưa có title đa ngôn ngữ.
  String _humanizeSlug(String raw) {
    if (raw.isEmpty) return raw;
    return raw
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) {
          if (w.length == 1) return w.toUpperCase();
          return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: HorizonTopAppBar(title: localizations.weakSkills),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.noWeakSkillsData,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSection(
                      title: AppLocalizations.of(context)!.skills,
                      items: _stats!.skillTypes,
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: AppLocalizations.of(context)!.topics,
                      items: _stats!.grammarTopics,
                    ),
                    const SizedBox(height: 16),
                    _buildRecommendedLessons(_stats!.recommendedLessons),
                  ],
                ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<WeakSkillItem> items,
  }) {
    if (items.isEmpty) {
      return _buildEmptyCard(title, AppLocalizations.of(context)!.noData);
    }

    final sorted = List<WeakSkillItem>.from(items)
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));
    final displayItems = sorted.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...displayItems.map((item) {
              final percent = (item.accuracy * 100).toInt();
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(_humanizeSlug(item.id)),
                subtitle: Text(AppLocalizations.of(context)!.correctPercent(percent, item.attempts)),
                trailing: Icon(
                  Icons.trending_down,
                  color: AppTheme.primaryColor,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedLessons(List<String> lessonIds) {
    if (lessonIds.isEmpty) {
      return _buildEmptyCard(AppLocalizations.of(context)!.practiceSuggestions, AppLocalizations.of(context)!.noSuggestions);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.practiceSuggestions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...lessonIds.map((lessonId) {
              final label =
                  _lessonTitles[lessonId] ?? _humanizeSlug(lessonId);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(label),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () async {
                  final lesson = await _firestoreService.getLesson(lessonId);
                  if (lesson == null || !mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonDetailScreen(lesson: lesson),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String title, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
