import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/lesson_model.dart';
import '../../providers/language_provider.dart';
import '../../screens/learning/lesson_detail_screen.dart';

const Color _kSurface = Color(0xFFF4F6FF);
const Color _kOnSurface = Color(0xFF14304F);
const Color _kOnSurfaceVariant = Color(0xFF445D7F);
const Color _kSurfaceContainerLowest = Color(0xFFFFFFFF);

/// Bottom sheet: danh sách lesson → tap xem lý thuyết ngay trong panel (không rời bài tập).
class UnitLessonsQuickSheet extends StatefulWidget {
  const UnitLessonsQuickSheet({
    super.key,
    required this.lessons,
    required this.lessonTypeColor,
    required this.lessonTypeIcon,
  });

  final List<LessonModel> lessons;
  final Color Function(LessonType type) lessonTypeColor;
  final IconData Function(LessonType type) lessonTypeIcon;

  @override
  State<UnitLessonsQuickSheet> createState() => _UnitLessonsQuickSheetState();
}

class _UnitLessonsQuickSheetState extends State<UnitLessonsQuickSheet> {
  LessonModel? _selectedLesson;

  @override
  Widget build(BuildContext context) {
    final languageCode =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguageCode;
    final loc = AppLocalizations.of(context)!;
    final selected = _selectedLesson;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.58,
      minChildSize: 0.38,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Material(
          color: _kSurfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 4),
                child: Row(
                  children: [
                    if (selected != null)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: _kOnSurface,
                        onPressed: () => setState(() => _selectedLesson = null),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        selected != null
                            ? selected.getTitle(languageCode)
                            : loc.lessonsList,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _kOnSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: _kOnSurfaceVariant,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: selected == null
                    ? _buildLessonList(scrollController, languageCode)
                    : _buildLessonDetail(scrollController, selected),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLessonList(ScrollController scrollController, String languageCode) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: widget.lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final lesson = widget.lessons[index];
        return Material(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _selectedLesson = lesson),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: widget.lessonTypeColor(lesson.type),
                    child: Icon(
                      widget.lessonTypeIcon(lesson.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lesson.getTitle(languageCode),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: _kOnSurface,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _kOnSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonDetail(ScrollController scrollController, LessonModel lesson) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        LessonDetailScreen(
          key: ValueKey(lesson.id),
          lesson: lesson,
          embedded: true,
        ),
      ],
    );
  }
}

void showUnitLessonsQuickSheet(
  BuildContext context, {
  required List<LessonModel> lessons,
  required Color Function(LessonType type) lessonTypeColor,
  required IconData Function(LessonType type) lessonTypeIcon,
}) {
  if (lessons.isEmpty) return;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => UnitLessonsQuickSheet(
      lessons: lessons,
      lessonTypeColor: lessonTypeColor,
      lessonTypeIcon: lessonTypeIcon,
    ),
  );
}
