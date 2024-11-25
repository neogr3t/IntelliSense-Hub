import 'package:flutter/material.dart';
import '../../../../shared/utils/clipboard_util.dart';
import '../../services/translation_service.dart';
import '../widgets/speech_status.dart';
import '../widgets/confidence_indicator.dart';
import '../widgets/speech_actions.dart';
import '../../services/speech_service.dart';
import '../../../../shared/services/tts_service.dart';

class SpeechTranslationScreen extends StatefulWidget {
  const SpeechTranslationScreen({super.key});

  @override
  State<SpeechTranslationScreen> createState() =>
      _SpeechRecognitionScreenState();
}

class _SpeechRecognitionScreenState extends State<SpeechTranslationScreen> {
  final SpeechService _speechService = SpeechService();
  final TTSService _ttsService = TTSService();
  final TranslationService _translationService = TranslationService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  String _wordSpoken = "";
  double _confidenceLevel = 0.0;
  bool _isInitialized = false;
  bool _autoSpeak = true;
  LanguageOption _sourceLanguage = TranslationService.supportedLanguages.first;
  LanguageOption _targetLanguage = TranslationService.supportedLanguages[1];
  String? _translatedText;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _sourceLanguage = TranslationService.supportedLanguages.first;
    _targetLanguage = TranslationService.supportedLanguages[1];
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Future.wait([
        _speechService.initialize(),
        _ttsService.initialize(),
      ]);
      setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Initialization failed: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onSpeechResult(String text, double confidence) {
    setState(() {
      _wordSpoken = text;
      _textController.text = text;
      _confidenceLevel = confidence;
      _translatedText = null; // Reset translation when new speech is detected
    });
  }

  Future<void> _translateText() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final translated = await _translationService.translate(
        _textController.text,
        _targetLanguage.code,
      );
      setState(() {
        _translatedText = translated;
        if (_autoSpeak) {
          _ttsService.speak(
            _translatedText!,
            () {},
            language: _targetLanguage.code,
            feature: TTSFeature.speechTranslation,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: $e')),
        );
      }
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final tempCode = _sourceLanguage.code;
      final tempName = _sourceLanguage.name;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = LanguageOption(code: tempCode, name: tempName);

      if (_translatedText != null) {
        final tempText = _textController.text;
        _textController.text = _translatedText!;
        _translatedText = tempText;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _wordSpoken = "";
      _textController.clear();
      _translatedText = null;
      _confidenceLevel = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Initializing speech services...',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Speech Translation',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Speak or type to translate between languages',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Translation Header with Language Selection
                  SliverToBoxAdapter(
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildLanguageDropdown(
                                theme,
                                _sourceLanguage,
                                (LanguageOption? language) {
                                  if (language != null) {
                                    setState(() => _sourceLanguage = language);
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.swap_horiz,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: _swapLanguages,
                            ),
                            Expanded(
                              child: _buildLanguageDropdown(
                                theme,
                                _targetLanguage,
                                (LanguageOption? language) {
                                  if (language != null) {
                                    setState(() => _targetLanguage = language);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Input Section
                  SliverToBoxAdapter(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _textController,
                              maxLines: 4,
                              minLines: 2,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Speak or type your text here',
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() => _wordSpoken = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.volume_up,
                                    color: theme.colorScheme.primary,
                                  ),
                                  onPressed: _textController.text.isEmpty
                                      ? null
                                      : () => _ttsService.speak(
                                            _textController.text,
                                            () {},
                                            language: _sourceLanguage.code,
                                          ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.translate),
                                  label: const Text('Translate'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: _textController.text.isEmpty
                                      ? null
                                      : _translateText,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Translation Result
                  if (_translatedText != null || _isTranslating)
                    SliverToBoxAdapter(
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Translation',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_isTranslating)
                                Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                  child: Text(
                                    _translatedText ?? '',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.volume_up,
                                      color: theme.colorScheme.primary,
                                    ),
                                    onPressed: _translatedText == null
                                        ? null
                                        : () => _ttsService.speak(
                                              _translatedText!,
                                              () {},
                                              language: _targetLanguage.code,
                                            ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.copy),
                                    label: const Text('Copy'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor:
                                          theme.colorScheme.onPrimary,
                                    ),
                                    onPressed: _translatedText == null
                                        ? null
                                        : () => ClipboardUtil.copyToClipboard(
                                              _translatedText!,
                                              context,
                                            ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Confidence Indicator
                  if (_confidenceLevel > 0)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ConfidenceIndicator(
                          confidence: _confidenceLevel,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SpeechActions(
                      speechService: _speechService,
                      ttsService: _ttsService,
                      onSpeechResult: _onSpeechResult,
                      text: _wordSpoken,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(
    ThemeData theme,
    LanguageOption selectedLanguage,
    void Function(LanguageOption?) onChanged,
  ) {
    return DropdownButton<LanguageOption>(
      value: selectedLanguage,
      isExpanded: true,
      dropdownColor: theme.colorScheme.surface,
      style: TextStyle(color: theme.colorScheme.onSurface),
      items: TranslationService.supportedLanguages
          .map((LanguageOption language) => DropdownMenuItem<LanguageOption>(
                value: language,
                child: Text(language.name),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _showSettings(BuildContext context) async {
    final theme = Theme.of(context);
    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Settings',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            SwitchListTile(
              activeColor: theme.colorScheme.primary,
              title: Text(
                'Auto-speak Text',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              subtitle: Text(
                'Automatically speak text after recognition or translation',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              value: _autoSpeak,
              onChanged: (value) {
                setState(() => _autoSpeak = value);
                this.setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
