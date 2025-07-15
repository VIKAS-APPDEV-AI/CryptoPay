import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthManager {
  static const _storage = FlutterSecureStorage();
  static const String _isSuccessKey = 'isSuccess';
  static const String _merchantNameKey = 'merchantName';
  static const String _merchantEmailKey = 'merchantEmail';
  static const String _merchantIdKey = 'merchantId';
  static const String _merchantLoginIpKey = 'merchantLoginIp';
  static const String _errorKey = 'error';
  static const String _rememberMeKey = 'rememberMe';

  static Future<void> saveUserData({
    required bool isSuccess,
    required String? merchantName,
    required String? merchantEmail,
    required int? merchantId,
    required String? merchantLoginIp,
    String? error,
  }) async {
    await _storage.write(key: _isSuccessKey, value: isSuccess.toString());
    await _storage.write(key: _merchantNameKey, value: merchantName ?? '');
    await _storage.write(key: _merchantEmailKey, value: merchantEmail ?? '');
    await _storage.write(key: _merchantIdKey, value: (merchantId ?? 0).toString());
    await _storage.write(key: _merchantLoginIpKey, value: merchantLoginIp ?? '');
    await _storage.write(key: _errorKey, value: error ?? '');
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final allValues = await _storage.readAll();
    if (allValues.containsKey(_merchantIdKey)) {
      return {
        'isSuccess': allValues[_isSuccessKey] == 'true',
        'merchantName': allValues[_merchantNameKey]?.isNotEmpty == true ? allValues[_merchantNameKey] : null,
        'merchantEmail': allValues[_merchantEmailKey]?.isNotEmpty == true ? allValues[_merchantEmailKey] : null,
        'merchantId': int.tryParse(allValues[_merchantIdKey] ?? '0') ?? 0,
        'merchantLoginIp': allValues[_merchantLoginIpKey]?.isNotEmpty == true ? allValues[_merchantLoginIpKey] : null,
        'error': allValues[_errorKey]?.isNotEmpty == true ? allValues[_errorKey] : null,
      };
    }
    return null;
  }

  static Future<bool> isAuthenticated() async {
    final allValues = await _storage.readAll();
    return allValues.containsKey(_merchantIdKey) && allValues[_merchantIdKey] != '0';
  }

  static Future<void> clearUserData() async {
    await _storage.deleteAll();
  }

  static Future<void> saveRememberMe(bool rememberMe) async {
    await _storage.write(key: _rememberMeKey, value: rememberMe.toString());
  }

  static Future<bool?> getRememberMe() async {
    final value = await _storage.read(key: _rememberMeKey);
    return value == 'true' ? true : value == 'false' ? false : null;
  }
}