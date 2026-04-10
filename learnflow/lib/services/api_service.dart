// lib/services/api_service.dart
// HTTP client กลาง — แนบ Firebase ID Token ทุก request + timeout + error handling

import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // อ่าน baseUrl จาก --dart-define
  // flutter run --dart-define=API_URL=http://192.168.x.x:5000
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  // ADD: timeout ทุก request — ถ้า server ไม่ตอบใน 15 วินาที throw TimeoutException
  static const Duration _timeout = Duration(seconds: 15);

  static Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── GET ────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> get(String path) async {
    final headers = await _authHeaders();
    final response = await http
        .get(Uri.parse('$baseUrl$path'), headers: headers)
        .timeout(_timeout);         // ADD: timeout
    return _handleResponse(response);
  }

  // ── POST ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    final response = await http
        .post(Uri.parse('$baseUrl$path'), headers: headers, body: jsonEncode(body))
        .timeout(_timeout);         // ADD: timeout
    return _handleResponse(response);
  }

  // ── Response handler ───────────────────────────────────────────────────
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded as Map<String, dynamic>;
    }
    if (response.statusCode == 401) {
      throw TokenExpiredException();
    }
    final error = decoded['error'] ?? 'Unknown error (${response.statusCode})';
    throw ApiException(error, response.statusCode);
  }
}

// ── Exceptions ─────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Token หมดอายุหรือไม่ได้ login — ให้ redirect ไป '/'
class TokenExpiredException implements Exception {
  @override
  String toString() => 'Session expired, please login again';
}
