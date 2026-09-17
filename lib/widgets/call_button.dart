import 'package:flutter/material.dart';

class CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const CallButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
    this.backgroundColor,
    this.iconColor,
    this.size = 58,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ??
        (isActive ? Colors.white : Colors.white.withValues(alpha: 0.2));

    final effectiveIconColor = iconColor ??
        (isActive ? Colors.black : Colors.white);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Ink(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: effectiveBgColor,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: size * 0.48,
              ),
            ),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
