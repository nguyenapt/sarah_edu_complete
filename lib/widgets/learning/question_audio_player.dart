import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/voice_config.dart';
import '../../core/services/azure_speech_service.dart';
import '../../core/services/audio_cache_service.dart';

// Conditional imports for native platforms
import 'question_audio_player_native_stub.dart'
    if (dart.library.io) 'question_audio_player_native_io.dart' as native;

/// Chọn giọng theo role/speaker (`Name:`) hoặc [defaultVoice].
VoiceConfig? resolveVoiceConfigForQuestionText(
  String text, {
  Map<String, VoiceConfig>? speakerVoices,
  VoiceConfig? defaultVoice,
}) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return defaultVoice;

  for (final line in trimmed.split('\n')) {
    final lineTrim = line.trim();
    final match = RegExp(r'^([A-Za-z][A-Za-z\s]*?):\s*').firstMatch(lineTrim);
    if (match != null) {
      final speakerName = match.group(1)?.trim();
      if (speakerName != null && speakerVoices != null) {
        final voice = speakerVoices[speakerName];
        if (voice != null) return voice;
      }
    }
  }

  final headMatch = RegExp(r'^([A-Za-z][A-Za-z\s]*?):\s+').firstMatch(trimmed);
  if (headMatch != null) {
    final speakerName = headMatch.group(1)?.trim();
    if (speakerName != null && speakerVoices != null) {
      final voice = speakerVoices[speakerName];
      if (voice != null) return voice;
    }
  }

  return defaultVoice;
}

/// Phát TTS — dùng cho nút loa và auto-play sequential sau khi điền đủ ô.
class QuestionSpeechController {
  final AudioPlayer _player = AudioPlayer();
  final AzureSpeechService _speechService = AzureSpeechService();
  final AudioCacheService _cacheService = AudioCacheService();

  Future<void> speak(
    String text, {
    String? voiceLookupText,
    Map<String, VoiceConfig>? speakerVoices,
    VoiceConfig? defaultVoice,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final voiceConfig = resolveVoiceConfigForQuestionText(
      (voiceLookupText ?? text).trim(),
      speakerVoices: speakerVoices,
      defaultVoice: defaultVoice,
    );
    if (voiceConfig == null) return;

    final cacheInput = trimmed;

    try {
      await _player.stop();
      final cacheKey = _cacheService.generateCacheKey(
        cacheInput,
        voiceConfig.toString(),
      );
      Uint8List? audioBytes = await _cacheService.getCachedAudio(cacheKey);
      if (audioBytes == null) {
        audioBytes = await _speechService.synthesizeSpeech(trimmed, voiceConfig);
        await _cacheService.saveAudio(cacheKey, audioBytes);
      }
      if (kIsWeb) {
        await _player.play(BytesSource(audioBytes));
      } else {
        await native.playAudioNative(_player, audioBytes);
      }
    } catch (e) {
      debugPrint('❌ QuestionSpeechController.speak: $e');
    }
  }

  Future<void> stop() => _player.stop();

  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  Future<void> dispose() async {
    await _player.dispose();
    _speechService.dispose();
  }
}

class QuestionAudioPlayer extends StatefulWidget {
  /// Dùng để resolve giọng (speaker / default).
  final String questionText;
  /// Nếu set — chỉ dùng cho TTS (ví dụ đã bỏ nhãn "Diana:").
  final String? spokenText;
  final Map<String, VoiceConfig>? speakerVoices;
  final VoiceConfig? defaultVoice;
  final bool autoPlay;
  /// Khi false — hiển thị nhưng không cho bấm (sequential: chờ điền đủ ô).
  final bool enabled;

  const QuestionAudioPlayer({
    super.key,
    required this.questionText,
    this.spokenText,
    this.speakerVoices,
    this.defaultVoice,
    this.autoPlay = true,
    this.enabled = true,
  });

  @override
  State<QuestionAudioPlayer> createState() => _QuestionAudioPlayerState();
}

class _QuestionAudioPlayerState extends State<QuestionAudioPlayer> {
  final QuestionSpeechController _speech = QuestionSpeechController();

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateAndPlayAudio();
      });
    }
  }

  @override
  void didUpdateWidget(QuestionAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled && (_isPlaying || _isLoading)) {
      _speech.stop();
      setState(() {
        _isPlaying = false;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _speech.dispose();
    super.dispose();
  }

  VoiceConfig? _getVoiceConfigForText() {
    return resolveVoiceConfigForQuestionText(
      widget.questionText,
      speakerVoices: widget.speakerVoices,
      defaultVoice: widget.defaultVoice,
    );
  }

  Future<void> _generateAndPlayAudio() async {
    if (!widget.enabled) return;
    final voiceConfig = _getVoiceConfigForText();
    if (voiceConfig == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final toSpeak = (widget.spokenText ?? widget.questionText).trim();
      await _speech.speak(
        toSpeak,
        voiceLookupText: widget.questionText,
        speakerVoices: widget.speakerVoices,
        defaultVoice: widget.defaultVoice,
      );
      if (!mounted) return;
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
      _speech.onPlayerStateChanged.listen((state) {
        if (!mounted) return;
        if (state == PlayerState.completed) {
          setState(() => _isPlaying = false);
        }
      });
    } catch (e) {
      debugPrint('❌ Error in _generateAndPlayAudio: $e');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _speech.stop();
      setState(() => _isPlaying = false);
    } catch (_) {}
  }

  Future<void> _togglePlayPause() async {
    if (!widget.enabled) return;
    if (_isPlaying) {
      await _stopAudio();
    } else {
      await _generateAndPlayAudio();
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceConfig = _getVoiceConfigForText();

    if (voiceConfig == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Theme.of(context).primaryColor;
    const disabledColor = Color(0xFF445D7F);

    return Opacity(
      opacity: widget.enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: widget.enabled ? _togglePlayPause : null,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : _hasError
                  ? const Icon(
                      Icons.error_outline,
                      size: 24,
                      color: Colors.red,
                    )
                  : Icon(
                      _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                      size: 24,
                      color: widget.enabled ? activeColor : disabledColor,
                    ),
        ),
      ),
    );
  }
}
