import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/voice_config.dart';
import '../../core/services/azure_speech_service.dart';
import '../../core/services/audio_cache_service.dart';

// Conditional imports for native platforms
import 'question_audio_player_native_stub.dart'
    if (dart.library.io) 'question_audio_player_native_io.dart' as native;

class QuestionAudioPlayer extends StatefulWidget {
  final String questionText;
  final Map<String, VoiceConfig>? speakerVoices;
  final VoiceConfig? defaultVoice;
  final bool autoPlay;

  const QuestionAudioPlayer({
    super.key,
    required this.questionText,
    this.speakerVoices,
    this.defaultVoice,
    this.autoPlay = true,
  });

  @override
  State<QuestionAudioPlayer> createState() => _QuestionAudioPlayerState();
}

class _QuestionAudioPlayerState extends State<QuestionAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  final AzureSpeechService _speechService = AzureSpeechService();
  final AudioCacheService _cacheService = AudioCacheService();
  
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateAndPlayAudio();
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _speechService.dispose();
    super.dispose();
  }

  VoiceConfig? _getVoiceConfigForText() {
    // Parse speaker from question text
    final speakerRegex = RegExp(r'^([A-Za-z][A-Za-z\s]*?):\s+');
    final match = speakerRegex.firstMatch(widget.questionText.trim());
    
    if (match != null) {
      final speakerName = match.group(1)?.trim();
      if (speakerName != null && widget.speakerVoices != null) {
        final voiceConfig = widget.speakerVoices![speakerName];
        if (voiceConfig != null) {
          return voiceConfig;
        }
      }
    }
    
    // Fallback to default voice
    return widget.defaultVoice;
  }

  Future<void> _generateAndPlayAudio() async {
    final voiceConfig = _getVoiceConfigForText();
    if (voiceConfig == null) {
      return; // No voice config, skip audio generation
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Generate cache key
      final cacheKey = _cacheService.generateCacheKey(
        widget.questionText,
        voiceConfig.toString(),
      );

      // Check cache first
      Uint8List? audioBytes = await _cacheService.getCachedAudio(cacheKey);

      if (audioBytes == null) {
        // Generate audio from Azure Speech Service
        audioBytes = await _speechService.synthesizeSpeech(
          widget.questionText,
          voiceConfig,
        );

        // Cache the audio
        await _cacheService.saveAudio(cacheKey, audioBytes);
      }

      // Play audio
      await _playAudio(audioBytes);
    } catch (e) {
      debugPrint('❌ Error in _generateAndPlayAudio: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _playAudio(Uint8List audioBytes) async {
    try {
      // Play audio - use BytesSource for web, DeviceFileSource for native
      if (kIsWeb) {
        // Web: play directly from bytes
        await _player.play(BytesSource(audioBytes));
      } else {
        // Native: save to file and play using conditional import
        await native.playAudioNative(_player, audioBytes);
      }
      
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });

      // Listen to player state changes
      _player.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } catch (e) {
      debugPrint('❌ Error in _playAudio: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _player.stop();
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _stopAudio();
    } else {
      await _generateAndPlayAudio();
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceConfig = _getVoiceConfigForText();
    
    // Don't show audio player if no voice config
    if (voiceConfig == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _togglePlayPause,
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
                    color: Theme.of(context).primaryColor,
                  ),
      ),
    );
  }
}
