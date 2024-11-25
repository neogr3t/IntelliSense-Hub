import 'package:flutter/material.dart';

class TextRecognitionResult extends StatelessWidget {
  final String text;

  const TextRecognitionResult({
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Extracted Text',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text.isEmpty ? 'No text detected' : text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: text.isEmpty
                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
