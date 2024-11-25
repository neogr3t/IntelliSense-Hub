import 'package:flutter/material.dart';
import '../../../../shared/services/tts_service.dart';
import '../../../../shared/utils/clipboard_util.dart';
import '../../services/translation_service.dart';

class SpeechResultCard extends StatefulWidget {
  final String text;
  final TTSService ttsService;
  final bool autoSpeak; // New parameter for auto-speak feature

  const SpeechResultCard({
    super.key,
    required this.text,
    required this.ttsService,
    this.autoSpeak = true, // Default to true
  });

  @override
  State<SpeechResultCard> createState() => _SpeechResultCardState();
}

class _SpeechResultCardState extends State<SpeechResultCard> {
  final TranslationService _translationService = TranslationService();
  String? _translatedText;
  LanguageOption? _selectedLanguage;
  bool _isTranslating = false;
  final TextEditingController _textController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.text;
    if (widget.autoSpeak) {
      _autoSpeak(widget.text);
    }
  }

  @override
  void didUpdateWidget(SpeechResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _textController.text = widget.text;
      if (widget.autoSpeak) {
        _autoSpeak(widget.text);
      }
    }
  }

  Future<void> _autoSpeak(String text) async {
    // Small delay to ensure UI is ready
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      widget.ttsService
          .speak(text, () {}, language: _selectedLanguage?.code ?? 'en');
    }
  }

  Future<void> _translateText(LanguageOption language) async {
    if (_selectedLanguage?.code == language.code) return;

    setState(() {
      _isTranslating = true;
      _selectedLanguage = language;
    });

    try {
      final translated = await _translationService.translate(
        _textController.text,
        language.code,
      );
      setState(() {
        _translatedText = translated;
        _isTranslating = false;
      });

      // Auto-speak translated text
      if (widget.autoSpeak) {
        _autoSpeak(translated);
      }
    } catch (e) {
      setState(() {
        _isTranslating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Text:',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isEditing ? Icons.check : Icons.edit,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_isEditing) {
                            // Save changes
                            _translatedText = null;
                            _selectedLanguage = null;
                          }
                          _isEditing = !_isEditing;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isEditing)
                  TextField(
                    controller: _textController,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  )
                else
                  SelectableText(
                    _textController.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                if (_selectedLanguage != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '${_selectedLanguage!.name} Translation:',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isTranslating)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_translatedText != null)
                    SelectableText(
                      _translatedText!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              _ActionButton(
                icon:
                    widget.ttsService.isSpeaking ? Icons.stop : Icons.volume_up,
                label: widget.ttsService.isSpeaking ? 'Stop' : 'Listen',
                isActive: widget.ttsService.isSpeaking,
                onPressed: () {
                  if (widget.ttsService.isSpeaking) {
                    widget.ttsService.stop();
                  } else {
                    final textToSpeak = _translatedText ?? _textController.text;
                    final language = _selectedLanguage?.code ?? 'en';
                    widget.ttsService
                        .speak(textToSpeak, () {}, language: language);
                  }
                },
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: PopupMenuButton<LanguageOption>(
                  itemBuilder: (context) {
                    return TranslationService.supportedLanguages
                        .map(
                          (language) => PopupMenuItem(
                            value: language,
                            child: Text(language.name),
                          ),
                        )
                        .toList();
                  },
                  onSelected: _translateText,
                  child: _ActionButton(
                    icon: Icons.translate,
                    label: 'Translate',
                    isLoading: _isTranslating,
                    isActive: _translatedText != null,
                    onPressed: () {}, // Handled by PopupMenuButton
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              _ActionButton(
                icon: Icons.copy,
                label: 'Copy',
                onPressed: () => ClipboardUtil.copyToClipboard(
                  _translatedText ?? _textController.text,
                  context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            else
              Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
