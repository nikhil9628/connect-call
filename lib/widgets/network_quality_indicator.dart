import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/call_model.dart';

class NetworkQualityIndicator extends StatelessWidget {
  final NetworkQuality quality;

  const NetworkQualityIndicator({super.key, required this.quality});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    int bars;

    switch (quality) {
      case NetworkQuality.good:
        color = AppColors.accentGreen;
        label = 'HD • Good';
        bars = 3;
        break;
      case NetworkQuality.fair:
        color = AppColors.accentYellow;
        label = 'Fair Connection';
        bars = 2;
        break;
      case NetworkQuality.poor:
        color = AppColors.accentRed;
        label = 'Poor Connection';
        bars = 1;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 3.5,
                height: (index + 1) * 4.0,
                decoration: BoxDecoration(
                  color: index < bars ? color : Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
