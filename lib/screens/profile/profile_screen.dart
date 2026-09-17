import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common_button.dart';
import '../../widgets/custom_avatar.dart';
import '../auth/login_screen.dart';
import 'blocked_users_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showAvatarPicker(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AvatarPickerSheet(
            currentAvatar: currentUser.avatarUrl,
            onAvatarSelected: (newAvatar) {
              authProvider.updateProfile(
                name: currentUser.name,
                bio: currentUser.bio,
                phone: currentUser.phone,
                avatarUrl: newAvatar,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile photo updated!')),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    final nameController = TextEditingController(text: currentUser.name);
    final phoneController = TextEditingController(text: currentUser.phone);
    final bioController = TextEditingController(text: currentUser.bio);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Status Bio'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                authProvider.updateProfile(
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  bio: bioController.text.trim(),
                  avatarUrl: currentUser.avatarUrl,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final int blockedCount = userProvider.blockedUsers.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showEditProfileDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Interactive Profile Avatar Header
            Center(
              child: GestureDetector(
                onTap: () => _showAvatarPicker(context),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomAvatar(
                      avatarUrl: currentUser.avatarUrl,
                      name: currentUser.name,
                      radius: 54,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkBackground : Colors.white,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.add_a_photo_rounded, size: 16, color: AppColors.primary),
              label: const Text(
                'Change Profile Photo',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () => _showAvatarPicker(context),
            ),

            const SizedBox(height: 12),
            Text(
              currentUser.name,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              currentUser.email,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_rounded, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    currentUser.phone,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentUser.bio,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),

            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 16),

            // Settings Options
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Toggle app appearance mode'),
                    secondary: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: AppColors.primary,
                    ),
                    value: themeProvider.isDarkMode,
                    onChanged: (val) => themeProvider.toggleTheme(val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone_rounded, color: AppColors.secondary),
                    title: const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(currentUser.phone),
                    trailing: const Icon(Icons.edit_outlined, size: 18),
                    onTap: () => _showEditProfileDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.block_rounded, color: AppColors.accentRed),
                    title: const Text('Blocked Users', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(blockedCount > 0 ? '$blockedCount blocked contacts' : 'Manage blocked contacts list'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (blockedCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentRed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$blockedCount',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: CommonButton(
                text: 'Log Out',
                backgroundColor: AppColors.accentRed,
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
