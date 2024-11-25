import 'package:flutter_tts/flutter_tts.dart';

enum TTSFeature {
  pdfSummary,
  speechTranslation,
}

enum TTSState {
  stopped,
  playing,
  paused,
}

class TTSService {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  bool _isInitialized = false;
  TTSState _state = TTSState.stopped;
  String _currentText = '';
  // Track language for each feature separately

  final Map<TTSFeature, String> _featureLanguages = {
    TTSFeature.pdfSummary: 'en-US',
    TTSFeature.speechTranslation: 'en-US',
  };

  static final Map<String, String> languageCodes = {
    'en': 'en-US',
    'es': 'es-ES',
    'fr': 'fr-FR',
    'de': 'de-DE',
    'it': 'it-IT',
    'ja': 'ja-JP',
    'ko': 'ko-KR',
    'zh': 'zh-CN',
  };

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Wait a bit before initialization to ensure system TTS is ready
      await Future.delayed(const Duration(milliseconds: 200));

      await flutterTts.awaitSpeakCompletion(true);
      print("TTS await completion setup");

      var result = await flutterTts.setLanguage('en-US');
      print("TTS language setup: $result");

      result = await flutterTts.setSpeechRate(0.5);
      print("TTS speech rate setup: $result");

      result = await flutterTts.setVolume(1.0);
      print("TTS volume setup: $result");

      result = await flutterTts.setPitch(1.0);
      print("TTS pitch setup: $result");

      // Set up completion callback
      flutterTts.setCompletionHandler(() {
        print("TTS completion handler called");
        _state = TTSState.stopped;
        _currentText = '';
      });

      // Set up error callback
      flutterTts.setErrorHandler((msg) {
        print("TTS error: $msg");
        _state = TTSState.stopped;
        _currentText = '';
      });

      // Get available languages
      final List<dynamic>? languages = await flutterTts.getLanguages;
      print('Available TTS languages: $languages');

      // Wait a bit to ensure engine is fully initialized
      await Future.delayed(const Duration(milliseconds: 300));

      _isInitialized = true;
      print("TTS initialization completed successfully");
      return true;
    } catch (e) {
      print('TTS Initialization Error: $e');
      _isInitialized = false;
      return false;
    }
  }

  Future<bool> speak(
    String text,
    Function onComplete, {
    String language = 'en',
    TTSFeature feature = TTSFeature.pdfSummary,
  }) async {
    if (!_isInitialized) {
      print('TTS not initialized. Initializing...');
      bool initResult = await initialize();
      if (!initResult) {
        print('TTS initialization failed');
        return false;
      }
    }

    if (text.isEmpty) return false;

    try {
      // Stop any ongoing speech
      if (_state == TTSState.playing || _state == TTSState.paused) {
        await stop();
        // Add small delay after stopping
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Set the language only if it's different for the current feature
      final languageCode = languageCodes[language] ?? 'en-US';
      if (_featureLanguages[feature] != languageCode) {
        _featureLanguages[feature] = languageCode;

        if (feature == TTSFeature.speechTranslation) {
          await flutterTts.setLanguage(languageCode);
        } else {
          await flutterTts.setLanguage('en-US');
        }
      }

      _currentText = text;
      _state = TTSState.playing;

      // Add a small delay before speaking
      await Future.delayed(const Duration(milliseconds: 100));

      var result = await flutterTts.speak(text);
      print("TTS speak result: $result");

      if (result == 1) {
        // Update completion handler
        flutterTts.setCompletionHandler(() {
          print("TTS completed speaking");
          _state = TTSState.stopped;
          _currentText = '';
          onComplete();
        });
        return true;
      } else {
        print("TTS speak failed with result: $result");
        _state = TTSState.stopped;
        _currentText = '';
        onComplete();
        return false;
      }
    } catch (e) {
      print('TTS Speak Error: $e');
      _state = TTSState.stopped;
      _currentText = '';
      onComplete();
      return false;
    }
  }

  Future<bool> pause() async {
    if (_state == TTSState.playing) {
      try {
        var result = await flutterTts.pause();
        if (result == 1) {
          _state = TTSState.paused;
          return true;
        }
      } catch (e) {
        print('TTS Pause Error: $e');
      }
    }
    return false;
  }

  Future<bool> resume() async {
    if (_state == TTSState.paused && _currentText.isNotEmpty) {
      try {
        var result = await flutterTts.speak(_currentText);
        if (result == 1) {
          _state = TTSState.playing;
          return true;
        }
      } catch (e) {
        print('TTS Resume Error: $e');
      }
    }
    return false;
  }

  Future<bool> stop() async {
    if (_state != TTSState.stopped) {
      try {
        var result = await flutterTts.stop();
        if (result == 1) {
          _state = TTSState.stopped;
          _currentText = '';
          return true;
        }
      } catch (e) {
        print('TTS Stop Error: $e');
      }
    }
    return false;
  }

  bool get isPlaying => _state == TTSState.playing;
  bool get isPaused => _state == TTSState.paused;
  bool get isStopped => _state == TTSState.stopped;

  Future<void> dispose() async {
    try {
      await stop();
      _state = TTSState.stopped;
      _currentText = '';
      _isInitialized = false;
    } catch (e) {
      print('TTS Dispose Error: $e');
    }
  }
}
