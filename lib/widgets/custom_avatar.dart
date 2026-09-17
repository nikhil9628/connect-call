import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AvatarPreset {
  final String id;
  final String label;
  final IconData icon;
  final Color backgroundColor;

  const AvatarPreset({
    required this.id,
    required this.label,
    required this.icon,
    required this.backgroundColor,
  });
}

class CustomAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;

  static const List<AvatarPreset> defaultPresets = [
    AvatarPreset(id: 'preset_1', label: 'Indigo', icon: Icons.person_rounded, backgroundColor: Color(0xFF6C5CE7)),
    AvatarPreset(id: 'preset_2', label: 'Teal', icon: Icons.face_rounded, backgroundColor: Color(0xFF00CEC9)),
    AvatarPreset(id: 'preset_3', label: 'Coral', icon: Icons.person_pin_rounded, backgroundColor: Color(0xFFFF7675)),
    AvatarPreset(id: 'preset_4', label: 'Emerald', icon: Icons.account_circle_rounded, backgroundColor: Color(0xFF00B894)),
    AvatarPreset(id: 'preset_5', label: 'Purple', icon: Icons.sentiment_very_satisfied_rounded, backgroundColor: Color(0xFF8E44AD)),
    AvatarPreset(id: 'preset_6', label: 'Amber', icon: Icons.emoji_emotions_rounded, backgroundColor: Color(0xFFF39C12)),
  ];

  const CustomAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.radius = 28,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final int colorIndex = name.isEmpty ? 0 : (name.codeUnitAt(0) % defaultPresets.length);
    final AvatarPreset preset = defaultPresets[colorIndex];

    Widget childWidget;

    if (avatarUrl != null && avatarUrl!.startsWith('preset_')) {
      final matched = defaultPresets.firstWhere(
        (p) => p.id == avatarUrl,
        orElse: () => preset,
      );
      childWidget = CircleAvatar(
        radius: radius,
        backgroundColor: matched.backgroundColor,
        child: Icon(matched.icon, size: radius * 1.1, color: Colors.white),
      );
    } else if (avatarUrl != null && avatarUrl!.startsWith('http')) {
      childWidget = CircleAvatar(
        radius: radius,
        backgroundColor: preset.backgroundColor,
        child: ClipOval(
          child: Image.network(
            avatarUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                initial,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.85,
                ),
              );
            },
          ),
        ),
      );
    } else {
      childWidget = CircleAvatar(
        radius: radius,
        backgroundColor: preset.backgroundColor,
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.85,
          ),
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: childWidget,
      );
    }

    return childWidget;
  }
}

class AvatarPickerSheet extends StatelessWidget {
  final String currentAvatar;
  final Function(String selectedAvatar) onAvatarSelected;

  const AvatarPickerSheet({
    super.key,
    required this.currentAvatar,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urlController = TextEditingController(text: currentAvatar.startsWith('http') ? currentAvatar : '');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Choose Profile Photo',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Pick an Avatar Style:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: CustomAvatar.defaultPresets.length,
              itemBuilder: (context, index) {
                final preset = CustomAvatar.defaultPresets[index];
                final isSelected = currentAvatar == preset.id;

                return GestureDetector(
                  onTap: () {
                    onAvatarSelected(preset.id);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: preset.backgroundColor,
                          child: Icon(preset.icon, size: 30, color: Colors.white),
                        ),
                        if (isSelected)
                          const Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: AppColors.accentGreen,
                              child: Icon(Icons.check, size: 12, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text('Or Enter Custom Photo URL:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    hintText: 'https://example.com/my-photo.jpg',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (urlController.text.trim().isNotEmpty) {
                    onAvatarSelected(urlController.text.trim());
                    Navigator.pop(context);
                  }
                },
                child: const Text('Use URL'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
