import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool speechEnabled = false;

  Future<void> initialize() async {
    speechEnabled = await _speechToText.initialize();
  }

  Future<void> startListening(Function(String, double) onResult) async {
    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.confidence);
      },
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;
}
