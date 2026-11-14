import 'package:flutter/material.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuthStatus() async {
    final token = await StorageService.getToken();
    final cachedUser = await StorageService.getUser();

    if (token != null && cachedUser != null) {
      _user = UserModel.fromJson(cachedUser);
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> login(String loginIdentifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'login': loginIdentifier.trim(),
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        final token = response.data['data']['token'] as String;
        final userData = response.data['data']['user'] as Map<String, dynamic>;

        await StorageService.saveToken(token);
        await StorageService.saveUser(userData);

        _user = UserModel.fromJson(userData);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.put(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      _isLoading = false;
      notifyListeners();
      return response.data['success'] == true;
    } catch (e) {
      _errorMessage = ApiClient.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore network errors on logout
    }
    await StorageService.clearAuth();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
