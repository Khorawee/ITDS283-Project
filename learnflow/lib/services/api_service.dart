// lib/services/api_service.dart
// HTTP client กลาง — แนบ Firebase ID Token ทุก request อัตโนมัติ

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ── เปลี่ยน baseUrl ให้ตรงกับ server จริง ──────────────────────────────
  // static const String baseUrl = 'http://10.104.245.187:5000'; // Android real
  static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator

  // ── ดึง Firebase ID Token ──────────────────────────────────────────────
  static Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  // ── Headers พร้อม Auth ─────────────────────────────────────────────────
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
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  // ── POST ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // ── Response handler ───────────────────────────────────────────────────
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded as Map<String, dynamic>;
    }
    final error = decoded['error'] ?? 'Unknown error (${response.statusCode})';
    throw ApiException(error, response.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
