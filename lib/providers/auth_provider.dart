import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    initAuth();
  }

  /// Initialize auth from persistent storage
  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user
  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(identifier: identifier, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Quick preset login for testing
  Future<void> quickLogin(UserModel presetUser) async {
    _isLoading = true;
    notifyListeners();

    _currentUser = presetUser;
    await _authService.saveUserSession(presetUser);

    _isLoading = false;
    notifyListeners();
  }

  /// Register new account
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update Profile details
  Future<void> updateProfile({required String name, required String bio, required String avatarUrl, String? phone}) async {
    if (_currentUser == null) return;

    final updated = _currentUser!.copyWith(
      name: name,
      bio: bio,
      phone: phone ?? _currentUser!.phone,
      avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : _currentUser!.avatarUrl,
    );

    _currentUser = await _authService.updateProfile(updated);
    notifyListeners();
  }

  /// Toggle Online/Offline status
  Future<void> toggleOnlineStatus() async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(isOnline: !_currentUser!.isOnline);
    _currentUser = await _authService.updateProfile(updated);
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
