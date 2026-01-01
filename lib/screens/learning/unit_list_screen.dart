import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/unit_model.dart';
import '../../core/services/firestore_service.dart';
import '../../models/lesson_model.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';
import 'lesson_detail_screen.dart';

class UnitListScreen extends StatefulWidget {
  final UnitModel? unit; // Optional: nếu có thì hiển thị unit này
  final List<UnitModel>? units; // Optional: nếu có thì hiển thị tất cả units trong group

  const UnitListScreen({
    super.key,
    this.unit,
    this.units,
  }) : assert(unit != null || units != null, 'Phải cung cấp unit hoặc units');

  @override
  State<UnitListScreen> createState() => _UnitListScreenState();
}

class _UnitListScreenState extends State<UnitListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, List<LessonModel>> _lessonsByUnit = {}; // Map unitId -> lessons
  bool _isLoading = true;

  // Lấy danh sách units cần hiển thị
  List<UnitModel> get _unitsToDisplay {
    if (widget.units != null && widget.units!.isNotEmpty) {
      return widget.units!;
    } else if (widget.unit != null) {
      return [widget.unit!];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    try {
      final units = _unitsToDisplay;
      final lessonsMap = <String, List<LessonModel>>{};
      
      // Load lessons cho tất cả units
      for (final unit in units) {
        final lessons = await _firestoreService.getLessonsByUnit(unit.id);
        lessonsMap[unit.id] = lessons;
      }
      
      setState(() {
        _lessonsByUnit = lessonsMap;
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
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(''), // Xóa title
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _unitsToDisplay.map((unit) {
                  final lessons = _lessonsByUnit[unit.id] ?? [];
                  return _buildUnitCard(unit, lessons, languageCode);
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildUnitCard(UnitModel unit, List<LessonModel> lessons, String languageCode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unit.getTitle(languageCode),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(unit.getDescription(languageCode)),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  avatar: const Icon(Icons.access_time, size: 18),
                  label: Text('${unit.estimatedTime} ${AppLocalizations.of(context)!.minutes}'),
                  backgroundColor:
                      AppTheme.primaryColor.withOpacity(0.1),
                ),
                const SizedBox(width: 12),
                Chip(
                  avatar: const Icon(Icons.menu_book, size: 18),
                  label: Text(AppLocalizations.of(context)!.lessonsCount(lessons.length)),
                  backgroundColor:
                      AppTheme.primaryColor.withOpacity(0.1),
                ),
              ],
            ),
            // Danh sách bài học ngay phía dưới
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.lessonsList,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (lessons.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(AppLocalizations.of(context)!.noLessons),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  return _buildLessonCard(lesson, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(LessonModel lesson, int index) {
    final languageCode = Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getLessonTypeColor(lesson.type),
          child: Icon(
            _getLessonTypeIcon(lesson.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          lesson.getTitle(languageCode),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context)!.lessonNumber(index + 1)),
            if (lesson.exercises.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.exercisesCount(lesson.exercises.length),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonDetailScreen(lesson: lesson),
            ),
          );
        },
      ),
    );
  }

  Color _getLessonTypeColor(LessonType type) {
    switch (type) {
      case LessonType.grammar:
        return Colors.blue;
      case LessonType.vocabulary:
        return Colors.green;
      case LessonType.listening:
        return Colors.orange;
      case LessonType.speaking:
        return Colors.purple;
      case LessonType.reading:
        return Colors.teal;
      case LessonType.writing:
        return Colors.red;
    }
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.grammar:
        return Icons.auto_stories;
      case LessonType.vocabulary:
        return Icons.book;
      case LessonType.listening:
        return Icons.headphones;
      case LessonType.speaking:
        return Icons.mic;
      case LessonType.reading:
        return Icons.article;
      case LessonType.writing:
        return Icons.edit;
    }
  }
}

