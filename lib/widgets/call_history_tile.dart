import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/duration_formatter.dart';
import '../models/call_model.dart';
import 'custom_avatar.dart';

class CallHistoryTile extends StatelessWidget {
  final CallModel call;
  final String currentUserId;
  final VoidCallback onCallBack;

  const CallHistoryTile({
    super.key,
    required this.call,
    required this.currentUserId,
    required this.onCallBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isOutgoing = (call.callerId == currentUserId);
    final String partnerName = isOutgoing ? call.calleeName : call.callerName;
    final String partnerAvatar = isOutgoing ? call.calleeAvatar : call.callerAvatar;
    final bool isMissed = (call.status == CallStatus.missed || call.status == CallStatus.rejected);
    final bool isVideo = (call.type == CallType.video);

    IconData directionIcon;
    Color directionColor;

    if (isMissed) {
      directionIcon = Icons.call_missed_rounded;
      directionColor = AppColors.missedRed;
    } else if (isOutgoing) {
      directionIcon = Icons.call_made_rounded;
      directionColor = AppColors.accentGreen;
    } else {
      directionIcon = Icons.call_received_rounded;
      directionColor = AppColors.primary;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      color: isDark ? AppColors.darkCard : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CustomAvatar(
          avatarUrl: partnerAvatar,
          name: partnerName,
          radius: 24,
        ),
        title: Text(
          partnerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isMissed ? AppColors.missedRed : theme.textTheme.titleMedium?.color,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(directionIcon, size: 16, color: directionColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${isVideo ? "Video" : "Audio"} Call • ${DateFormatter.formatCallTimestamp(call.timestamp)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (call.durationSeconds > 0)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DurationFormatter.formatSeconds(call.durationSeconds),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            IconButton(
              onPressed: onCallBack,
              icon: Icon(
                isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
