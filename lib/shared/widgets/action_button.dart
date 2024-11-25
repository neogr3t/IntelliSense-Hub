import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final Color? backgroundColor;
  final Color? iconColor;

  const ActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label, // Title parameter added
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ??
            Theme.of(context).primaryColor, // Default to primary color
        foregroundColor: iconColor ??
            Theme.of(context).iconTheme.color, // Default to icon theme color
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        elevation: 2,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: iconColor), // Icon color support
          const SizedBox(width: 8),
          Text(
            label!, // Display the title
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: iconColor ??
                      Theme.of(context).iconTheme.color, // Title color
                ),
          ),
        ],
      ),
    );
  }
}
