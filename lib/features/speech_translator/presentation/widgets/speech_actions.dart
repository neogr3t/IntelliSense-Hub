import 'package:flutter/material.dart';
import '../../services/speech_service.dart';
import '../../../../shared/services/tts_service.dart';

class SpeechActions extends StatelessWidget {
  final SpeechService speechService;
  final TTSService ttsService;
  final Function(String, double) onSpeechResult;
  final String text;

  const SpeechActions({
    super.key,
    required this.speechService,
    required this.ttsService,
    required this.onSpeechResult,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: () async {
        if (speechService.isListening) {
          await speechService.stopListening();
        } else {
          await speechService.startListening(onSpeechResult);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: theme.colorScheme.primary.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            speechService.isListening ? Icons.mic_off : Icons.mic,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            speechService.isListening ? 'Stop Listening' : 'Start Speaking',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
