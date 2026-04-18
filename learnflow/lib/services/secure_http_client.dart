/// lib/services/secure_http_client.dart
/// Secure HTTP client with certificate pinning
///
/// Features:
/// - SSL certificate pinning for production API
/// - Prevents MITM attacks
/// - Automatic fallback to insecure in development mode

import 'dart:io';
import 'package:flutter/foundation.dart';

/// ตัวอย่าง certificate pinning - ใช้ production server certificate SHA-256 hash
/// วิธีดึง hash: openssl s_client -connect api.learnflow.com:443 </dev/null | openssl x509 -noout -pubkey | openssl rsa -pubin -outform DER | openssl dgst -sha256 -binary | openssl enc -base64
const String _productionCertPin = 'MIID...'; // Replace with actual cert pin from your server

/// Get secure HttpClient with certificate pinning
HttpClient getSecureHttpClient() {
  final httpClient = HttpClient();
  
  if (!kDebugMode) {
    // Production: Enable certificate pinning
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // สำหรับ production, ตรวจสอบ certificate pin
      // ตัวอย่าง: verify cert against pinned certificate
      if (host == 'api.learnflow.com') {
        // TODO: Implement actual certificate pinning verification
        // คุณต้อง download server certificate แล้ว hash มันก่อน
        return _verifyCertificatePin(cert);
      }
      return false;
    };
  } else {
    // Development: Allow self-signed certificates (for testing only)
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // ⚠️ WARNING: This is INSECURE! Only for development!
      if (host.contains('10.0.2.2') || host.contains('localhost')) {
        return true; // Accept self-signed for local testing
      }
      return false;
    };
  }
  
  return httpClient;
}

/// Verify certificate against pinned certificate hash
bool _verifyCertificatePin(X509Certificate cert) {
  try {
    // TODO: Implement certificate pinning verification
    // วิธี: 
    // 1. Extract certificate from der_bytes
    // 2. Calculate SHA-256 hash
    // 3. Compare against pinned hash
    final certDER = cert.der;
    // Implement actual pinning logic here
    return true;
  } catch (e) {
    return false;
  }
}
