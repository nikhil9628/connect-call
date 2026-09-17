import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserService {
  static const String _customUsersKey = 'registered_users_list_v1';
  static const String _deletedUsersKey = 'deleted_users_list_v1';
  static const String _blockedUsersKey = 'blocked_users_list_v1';

  // Seed sample contacts list with clean, professional Indian names
  final List<UserModel> _defaultContacts = [
    const UserModel(
      id: 'user_002',
      name: 'Aarav Sharma',
      email: 'aarav.sharma@example.com',
      phone: '+91 98765-12345',
      avatarUrl: 'preset_1',
      bio: 'Mobile Engineer | Flutter Enthusiast',
      isOnline: true,
    ),
    const UserModel(
      id: 'user_003',
      name: 'Rohan Gupta',
      email: 'rohan.gupta@example.com',
      phone: '+91 98765-67890',
      avatarUrl: 'preset_2',
      bio: 'Tech Lead @ ConnectCall ⚡',
      isOnline: true,
    ),
    const UserModel(
      id: 'user_004',
      name: 'Priya Patel',
      email: 'priya.patel@example.com',
      phone: '+91 98765-54321',
      avatarUrl: 'preset_3',
      bio: 'UX Architect | Design Systems',
      isOnline: true,
    ),
    const UserModel(
      id: 'user_005',
      name: 'Vikram Malhotra',
      email: 'vikram.m@example.com',
      phone: '+91 98765-99887',
      avatarUrl: 'preset_4',
      bio: 'Backend & WebRTC Engineer',
      isOnline: false,
    ),
    const UserModel(
      id: 'user_006',
      name: 'Neha Singh',
      email: 'neha.singh@example.com',
      phone: '+91 98765-11223',
      avatarUrl: 'preset_5',
      bio: 'Product Manager',
      isOnline: true,
    ),
    const UserModel(
      id: 'user_007',
      name: 'Kavya Sharma',
      email: 'kavya.s@example.com',
      phone: '+91 98765-33445',
      avatarUrl: 'preset_6',
      bio: 'DevOps & Cloud Architect',
      isOnline: true,
    ),
    const UserModel(
      id: 'user_008',
      name: 'Aditya Kumar',
      email: 'aditya.k@example.com',
      phone: '+91 98765-55667',
      avatarUrl: 'preset_1',
      bio: 'Frontend Engineer | React & Flutter',
      isOnline: true,
    ),
    const UserModel(
      id: 'user_009',
      name: 'Rajesh Sharma',
      email: 'rajesh.s@example.com',
      phone: '+91 98765-77889',
      avatarUrl: 'preset_2',
      bio: 'AI & Machine Learning Specialist',
      isOnline: false,
    ),
  ];

  Future<Set<String>> _getBlockedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_blockedUsersKey) ?? [];
    return list.toSet();
  }

  Future<void> _saveBlockedIds(Set<String> blockedIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_blockedUsersKey, blockedIds.toList());
  }

  /// Fetch all contacts merging default list with permanently saved registered users
  Future<List<UserModel>> getContacts({String? currentUserId}) async {
    final prefs = await SharedPreferences.getInstance();
    final List<UserModel> allContacts = List.from(_defaultContacts);

    final jsonStr = prefs.getString(_customUsersKey);
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        final customUsers = list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();

        for (final u in customUsers) {
          final existingIndex = allContacts.indexWhere(
            (c) => c.id == u.id || c.email.toLowerCase() == u.email.toLowerCase(),
          );

          if (existingIndex >= 0) {
            allContacts[existingIndex] = u;
          } else {
            allContacts.add(u);
          }
        }
      } catch (_) {}
    }

    // Filter out deleted contacts
    final deletedIds = prefs.getStringList(_deletedUsersKey) ?? [];
    allContacts.removeWhere((u) => deletedIds.contains(u.id));

    final blockedIds = await _getBlockedIds();

    return allContacts
        .where((u) => u.id != currentUserId)
        .map((u) => u.copyWith(isBlocked: blockedIds.contains(u.id)))
        .toList();
  }

  /// Fetch list of blocked users
  Future<List<UserModel>> getBlockedUsers({String? currentUserId}) async {
    final contacts = await getContacts(currentUserId: currentUserId);
    return contacts.where((u) => u.isBlocked).toList();
  }

  /// Manually add or update any person's profile in disk storage
  Future<void> saveContact(UserModel contact) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_customUsersKey);
    List<UserModel> customUsers = [];

    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        customUsers = list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    customUsers.removeWhere((u) => u.id == contact.id || u.email.toLowerCase() == contact.email.toLowerCase());
    customUsers.add(contact);

    final jsonList = customUsers.map((u) => u.toJson()).toList();
    await prefs.setString(_customUsersKey, jsonEncode(jsonList));

    // Remove from deleted list if re-added
    final deletedList = prefs.getStringList(_deletedUsersKey) ?? [];
    if (deletedList.contains(contact.id)) {
      deletedList.remove(contact.id);
      await prefs.setStringList(_deletedUsersKey, deletedList);
    }
  }

  /// Delete a contact permanently
  Future<void> deleteContact(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    
    final jsonStr = prefs.getString(_customUsersKey);
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        final customUsers = list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
        customUsers.removeWhere((u) => u.id == userId);
        final jsonList = customUsers.map((u) => u.toJson()).toList();
        await prefs.setString(_customUsersKey, jsonEncode(jsonList));
      } catch (_) {}
    }

    final deletedList = prefs.getStringList(_deletedUsersKey) ?? [];
    if (!deletedList.contains(userId)) {
      deletedList.add(userId);
      await prefs.setStringList(_deletedUsersKey, deletedList);
    }
  }

  Future<List<UserModel>> searchUsers(String query, {String? currentUserId}) async {
    final contacts = await getContacts(currentUserId: currentUserId);
    if (query.trim().isEmpty) return contacts;

    final q = query.toLowerCase();
    return contacts.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.phone.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> blockUser(String userId) async {
    final blockedIds = await _getBlockedIds();
    blockedIds.add(userId);
    await _saveBlockedIds(blockedIds);
  }

  Future<void> unblockUser(String userId) async {
    final blockedIds = await _getBlockedIds();
    blockedIds.remove(userId);
    await _saveBlockedIds(blockedIds);
  }

  Future<bool> isUserBlocked(String userId) async {
    final blockedIds = await _getBlockedIds();
    return blockedIds.contains(userId);
  }
}
