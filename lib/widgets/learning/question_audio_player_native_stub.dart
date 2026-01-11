// Stub file for web platform
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

Future<void> playAudioNative(AudioPlayer player, Uint8List audioBytes) async {
  // This should never be called on web
  throw UnsupportedError('Native audio playback not available on web');
}

