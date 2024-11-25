import 'dart:io';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../config/env_config.dart';

class AudioProcessingService {
  final Deepgram _deepgram;
  String? _currentRecordingPath;

  AudioProcessingService({String? apiKey})
      : _deepgram = Deepgram(EnvConfig.deepgramApiKey, baseQueryParams: {
          'model': 'nova-2-general',
          'detect_language': true,
          'filler_words': false,
          'punctuation': true,
        });

  // Helper method to generate recording file path
  Future<String> _getRecordingPath() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return path.join(appDir.path, 'recording_$timestamp.wav');
  }

  // File transcription
  Future<String> transcribeFile(String filePath) async {
    try {
      final file = File(filePath);
      final result = await _deepgram.transcribeFromFile(file);
      return result.transcript ?? 'No transcript available';
    } catch (e) {
      throw Exception('Transcription failed: $e');
    }
  }

  // URL transcription
  Future<String> transcribeUrl(String url) async {
    try {
      final result = await _deepgram.transcribeFromUrl(url);
      return result.transcript ?? 'No transcript available';
    } catch (e) {
      throw Exception('URL transcription failed: $e');
    }
  }

  Future<void> deleteRecording() async {
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
      _currentRecordingPath = null;
    }
  }

  String? get currentRecordingPath => _currentRecordingPath;

//   void dispose() {
//     _liveTranscriber?.close();
//     _recorder.dispose();
//   }
// }
}
