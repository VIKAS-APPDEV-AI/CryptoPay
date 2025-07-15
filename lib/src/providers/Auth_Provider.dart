import 'package:crypto_pay/src/models/LoginModel.dart';
import 'package:crypto_pay/src/utils/AuthManager.dart';
import 'package:flutter/material.dart';
import 'package:crypto_pay/src/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  LoginResponseModel? _loginResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  LoginResponseModel? get loginResponse => _loginResponse;

  Future<void> login(String username, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.login(username, password);
      print('API Response: $response'); // Debug API response

      if (response.isSuccess) {
        _isAuthenticated = true;
        _loginResponse = response;
        // Save user data to SharedPreferences
        await AuthManager.saveUserData(
          merchantName: response.merchantName ?? 'Unknown',
          merchantEmail: response.merchantEmail ?? '',
          merchantId: response.merchantId ?? 0,
          merchantLoginIp: response.merchantLoginIp ?? '',
          isSuccess: true,
        );
        print('Saved merchant name in AuthProvider: ${response.merchantName}');
        print('Saved merchant Email in AuthProvider: ${response.merchantEmail}');
        print('Saved merchant ID in AuthProvider: ${response.merchantId}');
      } else {
        _errorMessage = response.error ?? 'Invalid credentials';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthManager.clearUserData();
    _isAuthenticated = false;
    _loginResponse = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Initialize authentication state
  Future<void> initialize() async {
    try {
      _isAuthenticated = await AuthManager.isAuthenticated();
      if (_isAuthenticated) {
        final userData = await AuthManager.getUserData();
        if (userData != null) {
          _loginResponse = LoginResponseModel(
            isSuccess: true,
            merchantName: userData['merchantName'],
            merchantEmail: userData['merchantEmail'],
            merchantId: userData['merchantId'],
            merchantLoginIp: userData['merchantLoginIp'],
            error: null, // Ensure error is null for successful init
          );
        } else {
          _isAuthenticated = false; // Invalidate if userData is missing
        }
      }
    } catch (e) {
      print('AuthProvider: Error initializing auth: $e');
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  // Explicit method to check authentication status
  Future<bool> checkAuthenticationStatus() async {
    await initialize();
    return _isAuthenticated;
  }
}