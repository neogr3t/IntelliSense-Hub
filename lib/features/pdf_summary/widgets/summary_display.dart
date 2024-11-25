import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SummaryDisplay extends StatelessWidget {
  final String summary;
  final VoidCallback onPlay;
  final VoidCallback onStop;

  const SummaryDisplay({
    Key? key,
    required this.summary,
    required this.onPlay,
    required this.onStop,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: summary));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Summary copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(context),
                      tooltip: 'Copy summary',
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: onPlay,
                      tooltip: 'Read summary',
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: onStop,
                      tooltip: 'Stop reading',
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              summary,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
