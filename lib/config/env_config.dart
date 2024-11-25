import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get deepgramApiKey {
    final key = dotenv.env['DEEPGRAM_API_KEY'];
    if (key == null) {
      throw StateError('DEEPGRAM_API_KEY not found in .env');
    }
    return key;
  }

  static String get geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null) {
      throw StateError('GEMINI_API_KEY not found in .env');
    }
    return key;
  }

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }
}
