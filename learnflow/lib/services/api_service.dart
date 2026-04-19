/// lib/services/api_service.dart
/// Central HTTP client for all API communication
/// 
/// Features:
/// - Firebase ID Token auto-refresh on every request
/// - 15-second timeout per request
/// - Exponential backoff retry (3 attempts: 500ms, 1s, 2s)
/// - Smart retry: skip 4xx errors, retry 5xx + TimeoutException
/// - Custom exception types: ApiException, TokenExpiredException

import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // อ่าน baseUrl จาก --dart-define
  // flutter run --dart-define=API_URL=http://192.168.x.x:5000
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://itds283-project-production.up.railway.app',
  );

  static const Duration _timeout    = Duration(seconds: 15);
  static const int      _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  // ── Token helpers ──────────────────────────────────────────────────────────
  static Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken();
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // NOTE: CSRF removed — backend uses Firebase Auth (Bearer token) instead

  // ── GET with Retry ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> get(String path) async {
    return _retryableRequest(
      () => _get(path),
      method: 'GET',
      path: path,
    );
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    final headers  = await _authHeaders();
    final response = await http
        .get(Uri.parse('$baseUrl$path'), headers: headers)
        .timeout(_timeout);
    return _handleResponse(response);
  }

  // ── POST with Retry ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    return _retryableRequest(
      () => _post(path, body),
      method: 'POST',
      path: path,
    );
  }

  static Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    // NOTE: CSRF token removed — not needed for mobile API with Firebase Auth

    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    return _handleResponse(response);
  }

  // ── Retry Logic ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> _retryableRequest(
    Future<Map<String, dynamic>> Function() request, {
    required String method,
    required String path,
  }) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        return await request();
      } on TimeoutException catch (_) {
        attempts++;
        if (attempts >= _maxRetries) {
          throw TimeoutException(
              'Request to $method $path failed after $_maxRetries attempts');
        }
        await Future.delayed(_retryDelay * attempts);
      } on ApiException catch (e) {
        // ไม่ retry บน 4xx (client error)
        if (e.statusCode >= 400 && e.statusCode < 500) rethrow;
        attempts++;
        if (attempts >= _maxRetries) rethrow;
        // Retry บน 5xx (server error): exponential backoff 500ms, 1s, 2s
        await Future.delayed(_retryDelay * attempts);
      }
    }
    throw ApiException('Request failed after retries', 0);
  }

  // ── Response handler ───────────────────────────────────────────────────────
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded as Map<String, dynamic>;
    }
    if (response.statusCode == 401) throw TokenExpiredException();
    final error = decoded['error'] ?? 'Unknown error (${response.statusCode})';
    throw ApiException(error, response.statusCode);
  }
}

// ── Exceptions ─────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int    statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Token หมดอายุหรือไม่ได้ login — ให้ redirect ไป '/'
class TokenExpiredException implements Exception {
  @override
  String toString() => 'Session expired, please login again';
}