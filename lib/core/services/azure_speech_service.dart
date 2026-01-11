import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import '../../models/voice_config.dart';
import '../config/azure_speech_config.dart';

class AzureSpeechService {
  final String subscriptionKey;
  final String region;
  final http.Client _client;

  AzureSpeechService({
    String? subscriptionKey,
    String? region,
    http.Client? client,
  })  : subscriptionKey = subscriptionKey ?? AzureSpeechConfig.subscriptionKey,
        region = region ?? AzureSpeechConfig.region,
        _client = client ?? http.Client();

  /// Synthesize speech from text using Azure Speech Service
  /// Returns audio bytes in MP3 format
  Future<Uint8List> synthesizeSpeech(String text, VoiceConfig config) async {
    try {
      // Clean text: remove placeholders like {0}, {1} for audio generation
      final cleanText = _cleanTextForAudio(text);
      
      final ssml = _buildSSML(cleanText, config);
      final endpoint = 'https://$region.tts.speech.microsoft.com/cognitiveservices/v1';

      // Debug: Print SSML for troubleshooting
      debugPrint('🔊 SSML to send:');
      debugPrint(ssml);
      debugPrint('🔊 Endpoint: $endpoint');

      final response = await _client.post(
        Uri.parse(endpoint),
        headers: {
          'Ocp-Apim-Subscription-Key': subscriptionKey,
          'Content-Type': 'application/ssml+xml; charset=utf-8',
          'X-Microsoft-OutputFormat': AzureSpeechConfig.audioFormat,
        },
        body: utf8.encode(ssml),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        final errorMsg = 'Azure Speech Service error: ${response.statusCode} - ${response.body}';
        debugPrint('❌ $errorMsg');
        debugPrint('🔊 SSML that caused error:');
        debugPrint(ssml);
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Exception in synthesizeSpeech: $e');
      throw Exception('Failed to synthesize speech: $e');
    }
  }

  /// Build SSML (Speech Synthesis Markup Language) XML
  String _buildSSML(String text, VoiceConfig config) {
    final voiceName = config.toAzureVoiceName();
    final rate = config.rate.toStringAsFixed(2);
    // Pitch: Convert semitones to percentage (-50 to +50 semitones = -50% to +50%)
    // If pitch is 0, omit pitch attribute
    final pitchAttr = config.pitch != 0.0 
        ? ' pitch="${config.pitch > 0 ? '+' : ''}${config.pitch}st"' 
        : '';

    // Escape XML special characters in text
    final escapedText = _escapeXml(text);

    return '''<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="${config.languageCode}">
  <voice name="$voiceName">
    <prosody rate="$rate"$pitchAttr>
      $escapedText
    </prosody>
  </voice>
</speak>''';
  }

  /// Escape XML special characters
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Clean text for audio generation (remove placeholders and speaker names)
  String _cleanTextForAudio(String text) {
    var cleaned = text;
    
    // Remove speaker name (format: "SpeakerName: dialogue text" or "SpeakerName:")
    final speakerRegex = RegExp(r'^([A-Za-z][A-Za-z\s]*?):\s*(.+)?$', multiLine: false);
    final match = speakerRegex.firstMatch(cleaned);
    if (match != null) {
      // If there's dialogue after the colon, use it; otherwise use empty string
      cleaned = match.group(2)?.trim() ?? '';
    }
    
    // Remove placeholders like {0}, {1}, {2} etc.
    cleaned = cleaned.replaceAll(RegExp(r'\{\d+\}'), '');
    
    // Normalize whitespace: replace multiple spaces with single space
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    // Trim leading/trailing spaces
    return cleaned.trim();
  }

  void dispose() {
    _client.close();
  }
}

