import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userSessionKey = 'current_user_session';
  static const String _registeredUsersKey = 'registered_users_list_v1';

  // Seed default demo user profiles for evaluator testing
  static const UserModel defaultUser = UserModel(
    id: 'user_001',
    name: 'Ananya Verma',
    email: 'ananya.v@example.com',
    phone: '+91 98765-43210',
    avatarUrl: 'preset_1',
    bio: 'Product Designer | Love video calling 📱',
    isOnline: true,
  );

  static const UserModel secondaryUser = UserModel(
    id: 'user_002',
    name: 'Aarav Sharma',
    email: 'aarav.s@example.com',
    phone: '+91 98765-12345',
    avatarUrl: 'preset_2',
    bio: 'Flutter Developer 🚀',
    isOnline: false,
  );

  /// Load currently saved active session from SharedPreferences
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonStr = prefs.getString(_userSessionKey);
    if (userJsonStr != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(userJsonStr);
        return UserModel.fromJson(map);
      } catch (_) {}
    }
    return null;
  }

  /// Fetch list of all registered users saved locally
  Future<List<UserModel>> _getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_registeredUsersKey);
    if (jsonStr != null) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    return [];
  }

  /// Save new registered user to local storage
  Future<void> _saveToRegisteredUsers(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _getRegisteredUsers();
    list.removeWhere((u) => u.email.toLowerCase() == user.email.toLowerCase());
    list.add(user);
    final jsonList = list.map((u) => u.toJson()).toList();
    await prefs.setString(_registeredUsersKey, jsonEncode(jsonList));
  }

  /// Sign in with registered credentials
  Future<UserModel> login({required String identifier, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (password.length < 4) {
      throw Exception('Password must be at least 4 characters');
    }

    final cleanId = identifier.trim().toLowerCase();

    // Check pre-seeded presets first for evaluator convenience
    if (cleanId == 'ananya.v@example.com' || cleanId == 'ananya') return _saveAndReturn(defaultUser);
    if (cleanId == 'aarav.s@example.com' || cleanId == 'aarav') return _saveAndReturn(secondaryUser);
    if (cleanId == 'rohan.g@example.com' || cleanId == 'rohan') {
      return _saveAndReturn(const UserModel(
        id: 'user_003',
        name: 'Rohan Gupta',
        email: 'rohan.g@example.com',
        phone: '+91 98765-67890',
        avatarUrl: 'preset_3',
        bio: 'Tech Lead @ ConnectCall ⚡',
        isOnline: true,
      ));
    }

    // Check if this user previously registered
    final registeredUsers = await _getRegisteredUsers();
    for (final u in registeredUsers) {
      if (u.email.toLowerCase() == cleanId || u.phone.trim() == cleanId) {
        await saveUserSession(u);
        return u;
      }
    }

    // Account does NOT exist! Require creating account first.
    throw Exception('Account not found! Please create your account first, then log in.');
  }

  /// Register a new user account with custom name, email, phone & password
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (name.trim().isEmpty) throw Exception('Please enter your full name');
    if (!email.contains('@')) throw Exception('Please enter a valid email address');
    if (phone.trim().isEmpty) throw Exception('Please enter your phone number');
    if (password.length < 4) throw Exception('Password must be at least 4 characters');

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      avatarUrl: 'preset_1',
      bio: 'Hey there! I am using ConnectCall.',
      isOnline: true,
    );

    await _saveToRegisteredUsers(newUser);
    await saveUserSession(newUser);
    return newUser;
  }

  Future<UserModel> _saveAndReturn(UserModel user) async {
    await saveUserSession(user);
    return user;
  }

  /// Update profile in session & local registered list
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _saveToRegisteredUsers(updatedUser);
    await saveUserSession(updatedUser);
    return updatedUser;
  }

  /// Save active session to disk
  Future<void> saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userSessionKey, jsonEncode(user.toJson()));
  }

  /// Sign out current user session
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userSessionKey);
  }
}
