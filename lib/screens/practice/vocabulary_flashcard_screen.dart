import 'dart:math';

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/lesson_model.dart';
import '../../l10n/app_localizations.dart';

class VocabularyFlashcardScreen extends StatefulWidget {
  final List<TopicVocabularyItem> items;
  final String languageCode;

  const VocabularyFlashcardScreen({
    super.key,
    required this.items,
    required this.languageCode,
  });

  @override
  State<VocabularyFlashcardScreen> createState() => _VocabularyFlashcardScreenState();
}

class _VocabularyFlashcardScreenState extends State<VocabularyFlashcardScreen> {
  int _currentIndex = 0;
  bool _showDefinition = false;

  void _goNext() {
    if (widget.items.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.items.length;
      _showDefinition = false;
    });
  }

  void _goPrevious() {
    if (widget.items.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + widget.items.length) % widget.items.length;
      _showDefinition = false;
    });
  }

  void _toggleSide() {
    setState(() {
      _showDefinition = !_showDefinition;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final arrowColor = AppTheme.primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.practiceVocabularyTitle),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context)!.practiceVocabularyEmpty,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  '${_currentIndex + 1}/${items.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: _toggleSide,
                        child: _buildFlashcard(items[_currentIndex]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _goPrevious,
                        color: arrowColor,
                        icon: const Icon(Icons.chevron_left, size: 32),
                      ),
                      Text(
                        _showDefinition
                            ? AppLocalizations.of(context)!.flashcardTapShowWord
                            : AppLocalizations.of(context)!.flashcardTapShowDefinition,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      IconButton(
                        onPressed: _goNext,
                        color: arrowColor,
                        icon: const Icon(Icons.chevron_right, size: 32),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFlashcard(TopicVocabularyItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          final rotate = Tween<double>(begin: pi, end: 0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final isUnder = child!.key != ValueKey<bool>(_showDefinition);
              final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(value),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        child: Container(
          key: ValueKey<bool>(_showDefinition),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: _showDefinition ? _buildBack(item) : _buildFront(item),
        ),
      ),
    );
  }

  Widget _buildFront(TopicVocabularyItem item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          item.word,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
        ),
        const SizedBox(height: 12),
        if (item.partOfSpeech.isNotEmpty)
          Chip(
            label: Text(
              item.partOfSpeech,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.grey[200],
          ),
      ],
    );
  }

  Widget _buildBack(TopicVocabularyItem item) {
    final definition = item.getDefinition(widget.languageCode);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.word,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
        ),
        if (definition.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            definition,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        if (item.examples.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...item.examples.take(2).map(
                (example) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '• $example',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
        ],
      ],
    );
  }
}
