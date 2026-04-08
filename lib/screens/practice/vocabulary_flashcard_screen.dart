import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/vocabulary_user_state_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/vocabulary/vocabulary_item_key.dart';
import '../../l10n/app_localizations.dart';
import '../../models/lesson_model.dart';
import '../../models/vocabulary_word_state.dart';
import '../../providers/auth_provider.dart';

const Color _kSurface = Color(0xFFF4F6FF);
const Color _kOnSurface = Color(0xFF14304F);
const Color _kOnSurfaceVariant = Color(0xFF445D7F);
const Color _kPrimary = Color(0xFF006286);
const Color _kPrimaryContainer = Color(0xFF2DB7F2);
const Color _kSurfaceContainer = Color(0xFFDDE9FF);
const Color _kCard = Color(0xFFFFFFFF);
const Color _kTertiaryContainer = Color(0xFFFED01B);
const Color _kOnTertiaryContainer = Color(0xFF594700);
const Color _kStillLearningBg = Color(0xFFFFEBEE);
const Color _kGotItBg = Color(0xFFE8F5E9);

const LinearGradient _kProgressFill = LinearGradient(
  colors: [_kPrimary, _kPrimaryContainer],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

/// Giống nút Continue / Tiếp trong `exercise_screen.dart`.
const LinearGradient _kPrimaryCtaGradient = LinearGradient(
  colors: [_kPrimary, _kPrimaryContainer],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class VocabularyFlashcardScreen extends StatefulWidget {
  final List<TopicVocabularyItem> items;
  final String languageCode;

  const VocabularyFlashcardScreen({
    super.key,
    required this.items,
    required this.languageCode,
  });

  @override
  State<VocabularyFlashcardScreen> createState() =>
      _VocabularyFlashcardScreenState();
}

class _VocabularyFlashcardScreenState extends State<VocabularyFlashcardScreen> {
  final _vocab = VocabularyUserStateService.instance;
  int _currentIndex = 0;
  bool _showDefinition = false;
  bool _flushing = false;

  @override
  void initState() {
    super.initState();
    _vocab.ensureLoaded();
  }

  Future<void> _leave() async {
    if (!mounted) return;
    final uid = Provider.of<AuthProvider>(context, listen: false).user?.id;
    setState(() => _flushing = true);
    try {
      await _vocab.flushPendingToFirestore(uid);
    } catch (_) {
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(loc.vocabularyFlashcardSyncFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _flushing = false);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _onOutcome(VocabOutcome outcome) async {
    if (widget.items.isEmpty) return;
    final item = widget.items[_currentIndex];
    final key = vocabularyItemKey(item);
    await _vocab.recordOutcome(key, outcome);

    if (_currentIndex >= widget.items.length - 1) {
      await _leave();
      return;
    }
    setState(() {
      _currentIndex++;
      _showDefinition = false;
    });
  }

  void _toggleSide() {
    setState(() => _showDefinition = !_showDefinition);
  }

  void _goPreviousCard() {
    if (_flushing || _currentIndex <= 0) return;
    setState(() {
      _currentIndex--;
      _showDefinition = false;
    });
  }

  void _goNextCard() {
    if (_flushing || _currentIndex >= widget.items.length - 1) return;
    setState(() {
      _currentIndex++;
      _showDefinition = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final items = widget.items;

    if (items.isEmpty) {
      return Scaffold(
        backgroundColor: _kSurface,
        body: Center(
          child: Text(
            loc.practiceVocabularyEmpty,
            style: TextStyle(color: _kOnSurfaceVariant.withValues(alpha: 0.9)),
          ),
        ),
      );
    }

    final item = items[_currentIndex];
    final key = vocabularyItemKey(item);
    final fav = _vocab.stateForKey(key).favorited;

    final total = items.length;
    final currentN = _currentIndex + 1;
    final progress = currentN / total;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _leave();
      },
      child: Scaffold(
        backgroundColor: _kSurface,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: _kOnSurface,
                          onPressed: _flushing ? null : _leave,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    loc.vocabularyFlashcardCurrentSession,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                      color: _kOnSurfaceVariant.withValues(
                                          alpha: 0.85),
                                    ),
                                  ),
                                  Text(
                                    '$currentN/$total',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _kOnSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: SizedBox(
                                  height: 8,
                                  width: double.infinity,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      const ColoredBox(color: _kSurfaceContainer),
                                      FractionallySizedBox(
                                        widthFactor: progress.clamp(0.0, 1.0),
                                        alignment: Alignment.centerLeft,
                                        child: const DecoratedBox(
                                          decoration: BoxDecoration(
                                              gradient: _kProgressFill),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      // Chừa không gian cho 2 hàng nút ở footer.
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 168),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Thu nhỏ khu vực flashcard ~1/2 chiều cao vùng còn lại.
                          final targetHeight =
                              (constraints.maxHeight * 0.5).clamp(220.0, 360.0);
                          return Center(
                            child: SizedBox(
                              height: targetHeight,
                              child: GestureDetector(
                                onTap: _toggleSide,
                                child: _buildFlashcard(
                                  context,
                                  item,
                                  key,
                                  fav,
                                  loc,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _OutcomeButton(
                              bg: _kStillLearningBg,
                              icon: Icons.close_rounded,
                              iconBg: const Color(0xFFE53935),
                              iconFg: Colors.white,
                              label: loc.vocabularyFlashcardStillLearning,
                              onPressed: _flushing
                                  ? null
                                  : () => _onOutcome(VocabOutcome.stillLearning),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _OutcomeButton(
                              bg: _kGotItBg,
                              icon: Icons.check_rounded,
                              iconBg: AppTheme.successColor,
                              iconFg: const Color(0xFF1B5E20),
                              label: loc.vocabularyFlashcardGotIt,
                              onPressed:
                                  _flushing ? null : () => _onOutcome(VocabOutcome.gotIt),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _FlashcardOutlineNavButton(
                              label: loc.back,
                              onPressed: _flushing || _currentIndex <= 0 ? null : _goPreviousCard,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _FlashcardGradientNextButton(
                              label: loc.next,
                              onPressed: _flushing || _currentIndex >= items.length - 1
                                  ? null
                                  : _goNextCard,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_flushing)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: Color(0x33000000),
                      child: Center(
                        child: CircularProgressIndicator(color: _kPrimary),
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

  Widget _buildFlashcard(
    BuildContext context,
    TopicVocabularyItem item,
    String key,
    bool favorited,
    AppLocalizations loc,
  ) {
    return Material(
      color: _kCard,
      elevation: 0,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, minHeight: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) {
              final rotate =
                  Tween<double>(begin: math.pi, end: 0).animate(animation);
              return AnimatedBuilder(
                animation: rotate,
                child: child,
                builder: (context, child) {
                  final isUnder =
                      child!.key != ValueKey<bool>(_showDefinition);
                  final value =
                      isUnder ? math.min(rotate.value, math.pi / 2) : rotate.value;
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: _showDefinition
                  ? _buildBack(context, item, loc)
                  : _buildFront(context, item, key, favorited, loc),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFront(
    BuildContext context,
    TopicVocabularyItem item,
    String key,
    bool favorited,
    AppLocalizations loc,
  ) {
    final phonetic = item.phonetic?.trim();

    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Material(
            color: _kTertiaryContainer,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _flushing
                  ? null
                  : () async {
                      await _vocab.toggleFavorite(key);
                      setState(() {});
                    },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  favorited ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: _kOnTertiaryContainer,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 4, right: 44),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      loc.vocabularyFlashcardWordOfTheMoment,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        height: 1.15,
                        color: _kPrimary.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.word,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _kOnSurface,
                        letterSpacing: -0.4,
                        height: 1.1,
                      ),
                    ),
                    if (phonetic != null && phonetic.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _kSurfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          phonetic,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_rounded, color: _kPrimary, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      loc.vocabularyFlashcardTapToFlip,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _kPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBack(
      BuildContext context, TopicVocabularyItem item, AppLocalizations loc) {
    final definition = item.getDefinition(widget.languageCode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.word,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _kOnSurface,
          ),
        ),
        if (definition.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            definition,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: _kOnSurfaceVariant.withValues(alpha: 0.95),
            ),
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
        const Spacer(),
        Center(
          child: Text(
            loc.vocabularyFlashcardTapToFlip,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FlashcardGradientNextButton extends StatelessWidget {
  const _FlashcardGradientNextButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? _kPrimaryCtaGradient : null,
          color: enabled ? null : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlashcardOutlineNavButton extends StatelessWidget {
  const _FlashcardOutlineNavButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled ? _kPrimary : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: enabled ? _kPrimary : Colors.grey.shade500,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutcomeButton extends StatelessWidget {
  const _OutcomeButton({
    required this.bg,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.label,
    required this.onPressed,
  });

  final Color bg;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: iconBg,
                radius: 22,
                child: Icon(icon, color: iconFg, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: _kOnSurfaceVariant.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
