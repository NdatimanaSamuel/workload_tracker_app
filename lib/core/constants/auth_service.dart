import 'package:workload_tracker_app/core/constants/api_client.dart';
import 'package:workload_tracker_app/core/constants/api_constants.dart';
import 'package:workload_tracker_app/core/constants/token_storage.dart';

class AuthService {
  // login() calls your real /auth/login endpoint, gets back
  // { message, token, user: { id, email, names, role } },
  // and saves the token + role locally so the app "remembers" the session.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('Login attempt for email: $email');
    final response = await ApiClient.post(
      ApiConstants.login,
      {'email': email, 'password': password},
      withAuth: false, // no token exists yet before login succeeds
    );

    print('Login response: $response');

    final token = response['token'];
    final user = response['user'];

    print('Saving token: $token');
    try {
      await TokenStorage.saveSession(
        token: token,
        role: user['role'],
        userId: user['id'],
      );

      // Verify token was saved
      final savedToken = await TokenStorage.getToken();
      print('Token saved successfully: ${savedToken != null}');
    } catch (e) {
      print('Error saving token: $e');
      rethrow;
    }

    return user;
  }

  static Future<Map<String, dynamic>> createUser({
  required String names,
  required String email,
  required String phone,
  required String password,
  required String role,
  required String departmentId,
}) async {
  return await ApiClient.post(
    ApiConstants.users, // "/users"
    {
      'names': names,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'departmentId': departmentId,
    },
  );
}

  static Future<void> logout() async {
    await TokenStorage.clearSession();
  }

  static Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getToken();
    return token != null;
  }
}
