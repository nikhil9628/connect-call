import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/user_model.dart';
import 'custom_avatar.dart';

class UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onAudioCall;
  final VoidCallback? onVideoCall;
  final VoidCallback? onTap;

  const UserTile({
    super.key,
    required this.user,
    this.onAudioCall,
    this.onVideoCall,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isDark ? AppColors.darkCard : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CustomAvatar(
              avatarUrl: user.avatarUrl,
              name: user.name,
              radius: 26,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: user.isOnline ? AppColors.onlineGreen : AppColors.offlineGrey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          user.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          user.isOnline ? 'Online • ${user.bio}' : 'Offline • ${user.bio}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: user.isOnline ? AppColors.accentGreen : theme.textTheme.bodyMedium?.color,
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onAudioCall,
              icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
              tooltip: 'Start Audio Call',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onVideoCall,
              icon: const Icon(Icons.videocam_rounded, color: AppColors.secondary),
              tooltip: 'Start Video Call',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
