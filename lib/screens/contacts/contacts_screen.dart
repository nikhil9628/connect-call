import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/call_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/call_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/user_tile.dart';
import '../call/audio_call_screen.dart';
import '../call/video_call_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startCall(UserModel targetUser, CallType type) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    if (targetUser.isBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${targetUser.name} is blocked. Unblock to call.'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    final callProvider = Provider.of<CallProvider>(context, listen: false);
    callProvider.startCall(
      currentUser: currentUser,
      targetUser: targetUser,
      type: type,
    );

    Widget screen = (type == CallType.video)
        ? const VideoCallScreen()
        : const AudioCallScreen();

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _confirmDeleteContact(UserModel user) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Contact'),
          content: Text('Are you sure you want to delete ${user.name} from your contacts list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.endCallRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await userProvider.deleteContact(user.id, currentUserId: authProvider.currentUser?.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${user.name} deleted from contacts.')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddOrEditContactDialog({UserModel? existingUser}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final isEditing = (existingUser != null);
    final nameController = TextEditingController(text: existingUser?.name ?? '');
    final emailController = TextEditingController(text: existingUser?.email ?? '');
    final phoneController = TextEditingController(text: existingUser?.phone ?? '');
    final bioController = TextEditingController(text: existingUser?.bio ?? 'Available on ConnectCall');
    String selectedAvatar = existingUser?.avatarUrl ?? 'preset_1';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(isEditing ? 'Manage Profile' : 'Add New Person'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar Picker Section
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => AvatarPickerSheet(
                            currentAvatar: selectedAvatar,
                            onAvatarSelected: (newAvatar) {
                              setDialogState(() {
                                selectedAvatar = newAvatar;
                              });
                            },
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomAvatar(
                            avatarUrl: selectedAvatar,
                            name: nameController.text.isNotEmpty ? nameController.text : 'User',
                            radius: 36,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 11,
                              backgroundColor: AppColors.primary,
                              child: const Icon(Icons.edit, size: 11, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_android_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bioController,
                      decoration: const InputDecoration(
                        labelText: 'Status Bio',
                        prefixIcon: Icon(Icons.info_outline_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (isEditing)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.endCallRed, size: 18),
                    label: const Text('Delete', style: TextStyle(color: AppColors.endCallRed)),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteContact(existingUser);
                    },
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final phone = phoneController.text.trim();
                    final bio = bioController.text.trim();

                    if (name.isEmpty || email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter name and email')),
                      );
                      return;
                    }

                    final updatedContact = UserModel(
                      id: existingUser?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      email: email,
                      phone: phone.isNotEmpty ? phone : '+91 98765-00000',
                      avatarUrl: selectedAvatar,
                      bio: bio.isNotEmpty ? bio : 'Available on ConnectCall',
                      isOnline: true,
                    );

                    await userProvider.saveContact(updatedContact, currentUserId: authProvider.currentUser?.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? 'Profile updated!' : 'New person added to contacts!')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUserDetailModal(UserModel user) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isBlocked = user.isBlocked;

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
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                CustomAvatar(
                  avatarUrl: user.avatarUrl,
                  name: user.name,
                  radius: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  user.phone,
                  style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: user.isOnline ? AppColors.onlineGreen.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: user.isOnline ? AppColors.onlineGreen : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (isBlocked) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Blocked',
                          style: TextStyle(
                            color: AppColors.accentRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(user.bio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 16),

                // Management Action Buttons: Edit, Block/Unblock, Delete
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.manage_accounts_rounded, size: 16),
                      label: const Text('Edit Profile', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddOrEditContactDialog(existingUser: user);
                      },
                    ),
                    OutlinedButton.icon(
                      icon: Icon(
                        isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                        size: 16,
                        color: isBlocked ? AppColors.accentGreen : AppColors.accentRed,
                      ),
                      label: Text(
                        isBlocked ? 'Unblock' : 'Block',
                        style: TextStyle(
                          fontSize: 12,
                          color: isBlocked ? AppColors.accentGreen : AppColors.accentRed,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        if (isBlocked) {
                          await userProvider.unblockUser(user.id, currentUserId: authProvider.currentUser?.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${user.name} has been unblocked.')));
                          }
                        } else {
                          await userProvider.blockUser(user.id, currentUserId: authProvider.currentUser?.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${user.name} has been blocked.')));
                          }
                        }
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_forever_rounded, size: 16, color: AppColors.endCallRed),
                      label: const Text('Delete', style: TextStyle(fontSize: 12, color: AppColors.endCallRed)),
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDeleteContact(user);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.phone_rounded, size: 18),
                        label: const Text('Audio Call', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: isBlocked ? null : () {
                          Navigator.pop(context);
                          _startCall(user, CallType.audio);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.videocam_rounded, size: 18),
                        label: const Text('Video Call', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: isBlocked ? null : () {
                          Navigator.pop(context);
                          _startCall(user, CallType.video);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final contacts = userProvider.searchResults;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            tooltip: 'Add New Person',
            icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
            onPressed: () => _showAddOrEditContactDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                userProvider.search(val, currentUserId: authProvider.currentUser?.id);
              },
              decoration: InputDecoration(
                hintText: 'Search people by name, email or phone...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          userProvider.search('', currentUserId: authProvider.currentUser?.id);
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Contacts Count Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ALL CONTACTS (${contacts.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.8,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Person', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => _showAddOrEditContactDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Contacts List View
          Expanded(
            child: userProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : contacts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_search_rounded, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No contacts found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.person_add_rounded),
                              label: const Text('Add New Person'),
                              onPressed: () => _showAddOrEditContactDialog(),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final user = contacts[index];
                          return UserTile(
                            user: user,
                            onAudioCall: () => _startCall(user, CallType.audio),
                            onVideoCall: () => _startCall(user, CallType.video),
                            onTap: () => _showUserDetailModal(user),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Person'),
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddOrEditContactDialog(),
      ),
    );
  }
}
