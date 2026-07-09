import 'dart:html' as html show window;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Cross-platform storage that works on web and mobile
// Uses flutter_secure_storage on mobile (secure) and localStorage on web
class TokenStorage {
  static const _tokenKey = 'jwt_token';
  static const _roleKey = 'user_role';
  static const _userIdKey = 'user_id';

  static const _secureStorage = FlutterSecureStorage();

  // Helper to access localStorage on web
  static String _getStorageKey(String key) => 'workload_tracker_$key';

  static Future<void> saveSession({
    required String token,
    required String role,
    required String userId,
  }) async {
    if (kIsWeb) {
      html.window.localStorage[_getStorageKey(_tokenKey)] = token;
      html.window.localStorage[_getStorageKey(_roleKey)] = role;
      html.window.localStorage[_getStorageKey(_userIdKey)] = userId;
    } else {
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _roleKey, value: role);
      await _secureStorage.write(key: _userIdKey, value: userId);
    }
  }

  static Future<String?> getToken() async {
    if (kIsWeb) {
      return html.window.localStorage[_getStorageKey(_tokenKey)];
    } else {
      return await _secureStorage.read(key: _tokenKey);
    }
  }

  static Future<String?> getRole() async {
    if (kIsWeb) {
      return html.window.localStorage[_getStorageKey(_roleKey)];
    } else {
      return await _secureStorage.read(key: _roleKey);
    }
  }

  static Future<String?> getUserId() async {
    if (kIsWeb) {
      return html.window.localStorage[_getStorageKey(_userIdKey)];
    } else {
      return await _secureStorage.read(key: _userIdKey);
    }
  }

  static Future<void> clearSession() async {
    if (kIsWeb) {
      html.window.localStorage.remove(_getStorageKey(_tokenKey));
      html.window.localStorage.remove(_getStorageKey(_roleKey));
      html.window.localStorage.remove(_getStorageKey(_userIdKey));
    } else {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _roleKey);
      await _secureStorage.delete(key: _userIdKey);
    }
  }
}
