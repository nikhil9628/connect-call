import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _contacts = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<UserModel> get contacts => _contacts;
  List<UserModel> get searchResults => _searchQuery.isEmpty ? _contacts : _searchResults;
  List<UserModel> get blockedUsers => _contacts.where((u) => u.isBlocked).toList();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> fetchContacts({String? currentUserId}) async {
    _isLoading = true;
    notifyListeners();

    _contacts = await _userService.getContacts(currentUserId: currentUserId);
    if (_searchQuery.isNotEmpty) {
      _searchResults = await _userService.searchUsers(_searchQuery, currentUserId: currentUserId);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query, {String? currentUserId}) async {
    _searchQuery = query;
    notifyListeners();

    _searchResults = await _userService.searchUsers(query, currentUserId: currentUserId);
    notifyListeners();
  }

  /// Manually add or update any person's profile
  Future<void> saveContact(UserModel contact, {String? currentUserId}) async {
    await _userService.saveContact(contact);
    await fetchContacts(currentUserId: currentUserId);
  }

  /// Delete a contact permanently
  Future<void> deleteContact(String userId, {String? currentUserId}) async {
    await _userService.deleteContact(userId);
    await fetchContacts(currentUserId: currentUserId);
  }

  Future<void> blockUser(String userId, {String? currentUserId}) async {
    await _userService.blockUser(userId);
    await fetchContacts(currentUserId: currentUserId);
  }

  Future<void> unblockUser(String userId, {String? currentUserId}) async {
    await _userService.unblockUser(userId);
    await fetchContacts(currentUserId: currentUserId);
  }
}
