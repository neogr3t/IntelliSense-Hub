import 'package:translator/translator.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<String> translate(String text, String targetLanguage) async {
    try {
      final translation = await _translator.translate(
        text,
        to: targetLanguage,
      );
      return translation.text;
    } catch (e) {
      throw Exception('Translation failed: $e');
    }
  }

  static List<LanguageOption> get supportedLanguages => [
        const LanguageOption(code: 'en', name: 'English'),
        const LanguageOption(code: 'es', name: 'Spanish'),
        const LanguageOption(code: 'fr', name: 'French'),
        const LanguageOption(code: 'de', name: 'German'),
        const LanguageOption(code: 'it', name: 'Italian'),
        const LanguageOption(code: 'ja', name: 'Japanese'),
        const LanguageOption(code: 'ko', name: 'Korean'),
        const LanguageOption(code: 'zh', name: 'Chinese'),
        const LanguageOption(code: 'ar', name: 'Arabic'),
        const LanguageOption(code: 'hi', name: 'Hindi'),
        const LanguageOption(code: 'pt', name: 'Portuguese'),
        const LanguageOption(code: 'ru', name: 'Russian'),
        const LanguageOption(code: 'nl', name: 'Dutch'),
        const LanguageOption(code: 'tr', name: 'Turkish'),
        const LanguageOption(code: 'pl', name: 'Polish'),
        const LanguageOption(code: 'vi', name: 'Vietnamese'),
        const LanguageOption(code: 'th', name: 'Thai'),
        const LanguageOption(code: 'sv', name: 'Swedish'),
        const LanguageOption(code: 'da', name: 'Danish'),
        const LanguageOption(code: 'fi', name: 'Finnish'),
      ];
}

class LanguageOption {
  final String code;
  final String name;

  const LanguageOption({required this.code, required this.name});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageOption && other.code == code && other.name == name;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode;
}
