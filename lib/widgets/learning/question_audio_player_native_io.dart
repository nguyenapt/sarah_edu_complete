import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<void> playAudioNative(AudioPlayer player, Uint8List audioBytes) async {
  final tempDir = await getTemporaryDirectory();
  final tempFile = File(path.join(tempDir.path, 'question_audio_${DateTime.now().millisecondsSinceEpoch}.mp3'));
  await tempFile.writeAsBytes(audioBytes);
  await player.play(DeviceFileSource(tempFile.path));
}

