import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/weak_skill_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/progress_model.dart';
import '../../providers/auth_provider.dart';
import '../learning/lesson_detail_screen.dart';

class WeakSkillScreen extends StatefulWidget {
  const WeakSkillScreen({super.key});

  @override
  State<WeakSkillScreen> createState() => _WeakSkillScreenState();
}

class _WeakSkillScreenState extends State<WeakSkillScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  WeakSkillStats? _stats;

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

    try {
      final progress = await _firestoreService.getUserProgress(authProvider.user!.id);
      final stats = progress?.weakSkillStats ??
          WeakSkillService().buildStats(progress?.exerciseHistory ?? []);
      if (mounted) {
        setState(() {
          _stats = stats;
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.weakSkills),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? Center(
                  child: Text(
                    'Chưa có dữ liệu kỹ năng yếu.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSection(
                      title: 'Kỹ năng',
                      items: _stats!.skillTypes,
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Chủ đề',
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
      return _buildEmptyCard(title, 'Chưa có dữ liệu.');
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
              final percent = (item.accuracy * 100).toStringAsFixed(0);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(item.id),
                subtitle: Text('Đúng $percent% • ${item.attempts} lượt'),
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
      return _buildEmptyCard('Gợi ý bài luyện', 'Chưa có gợi ý.');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gợi ý bài luyện',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...lessonIds.map((lessonId) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(lessonId),
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
