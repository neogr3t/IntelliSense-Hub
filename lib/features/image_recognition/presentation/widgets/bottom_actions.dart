import 'package:flutter/material.dart';
import '../../../../shared/widgets/action_button.dart';

class BottomActions extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const BottomActions({
    required this.onCameraPressed,
    required this.onGalleryPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ActionButton(
            label: '',
            onPressed: onCameraPressed,
            icon: Icons.camera_alt,
            backgroundColor: theme.colorScheme.primary,
            iconColor: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ActionButton(
            label: '',
            onPressed: onGalleryPressed,
            icon: Icons.photo_library,
            backgroundColor: theme.colorScheme.primary,
            iconColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}
