import 'package:flutter/material.dart';
import '../../../../shared/services/tts_service.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../shared/utils/clipboard_util.dart';

class TextActions extends StatefulWidget {
  final String text;
  final TTSService ttsService;

  const TextActions({
    super.key,
    required this.text,
    required this.ttsService,
  });

  @override
  State<TextActions> createState() => _TextActionsState();
}

class _TextActionsState extends State<TextActions> {
  bool isPlaying = false;

  @override
  void dispose() {
    widget.ttsService.stop();
    super.dispose();
  }

  void _onPlayComplete() {
    if (mounted) {
      setState(() {
        isPlaying = false;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      setState(() {
        isPlaying = false;
      });
      await widget.ttsService.stop();
    } else {
      setState(() {
        isPlaying = true;
      });
      await widget.ttsService.speak(widget.text, _onPlayComplete);
    }
  }

  Future<void> _copyToClipboard() async {
    await ClipboardUtil.copyToClipboard(widget.text, context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ActionButton(
            icon: isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
            label: isPlaying ? 'Stop' : 'Play',
            onPressed: _togglePlayPause,
            backgroundColor: theme.colorScheme.primary,
            iconColor: theme.colorScheme.onPrimary,
          ),
          const SizedBox(width: 16),
          ActionButton(
            icon: Icons.copy_rounded,
            label: 'Copy',
            onPressed: _copyToClipboard,
            backgroundColor: theme.colorScheme.primary,
            iconColor: theme.colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }
}
