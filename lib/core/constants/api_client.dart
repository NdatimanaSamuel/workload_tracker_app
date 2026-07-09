import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'token_storage.dart';

// Custom exception class so services can throw something meaningful
// instead of a generic Exception — screens can catch ApiException
// specifically and show err.message to the user.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
}

// ApiClient is the ONLY class that actually calls http.get/post/etc.
// Every other service (AuthService, ModulesService...) goes through
// this class instead of calling http directly. Benefits:
// - Token attachment happens in ONE place, automatically
// - Error handling is consistent everywhere
// - If you ever need to log every request, or add retry logic,
//   you only touch this file
class ApiClient {
  // Builds the standard headers every request needs — JSON content type,
  // plus the Authorization header IF a token exists (some endpoints,
  // like login, don't need one yet).
  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth) {
      final token = await TokenStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // Every response goes through this — checks the status code and
  // either returns the parsed JSON, or throws a clear error.
  static dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    // 200/201 = success range
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Anything else (400, 401, 403, 404, 409, 500...) is an error —
    // we pull the backend's own "message" field if it exists,
    // since your NestJS controllers already return clear messages
    // like "Invalid email or password" or "Department already exists".
    final message = body['message'] is List
        ? body['message'].join(', ') // class-validator sometimes returns an array of messages
        : (body['message'] ?? 'Something went wrong');

    throw ApiException(message, statusCode: response.statusCode);
  }

  static Future<dynamic> get(String path, {bool withAuth = true}) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: await _headers(withAuth: withAuth),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> data, {
    bool withAuth = true,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> patch(
    String path,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String path) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }
}