import 'package:flutter/material.dart';

class ConfidenceIndicator extends StatelessWidget {
  final double confidence;

  const ConfidenceIndicator({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Text(
            'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 14.0,
              color: theme.textTheme.bodyMedium?.color ??
                  theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: confidence,
            backgroundColor: theme.colorScheme.surface.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              confidence < 0.5 ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
