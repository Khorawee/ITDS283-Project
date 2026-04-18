/// lib/services/secure_local_storage_service.dart
/// Encrypted local storage service using Hive with encryption
///
/// Features:
/// - Encrypted storage for sensitive data
/// - AES encryption with randomly generated key
/// - Only caches non-sensitive metadata (not answers)
/// - Automatic cleanup of old cache entries

import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:async';
import 'dart:convert';

// Encryption key generation (256-bit key for AES)
const int _encryptionKeyLength = 32; // 256-bit

// Box names
const String _encryptedCacheBoxName = 'secure_cache';
const String _submissionMetadataBoxName = 'submission_metadata';

class SecureLocalStorageService {
  static late Box<dynamic> _encryptedCacheBox;
  static late Box<dynamic> _metadataBox;
  static late Uint8List _encryptionKey;
  static late encrypt.Key _aesKey;
  static late encrypt.IV _encryptionIV;
  static late encrypt.Encrypter _encrypter;

  /// Initialize secure local storage with encryption
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Generate or retrieve encryption key
    _encryptionKey = await _getOrGenerateEncryptionKey();
    
    // Initialize AES encrypter
    _aesKey = encrypt.Key(_encryptionKey);
    _encryptionIV = encrypt.IV.fromLength(16); // 16 bytes IV for AES
    _encrypter = encrypt.Encrypter(encrypt.AES(_aesKey));
    
    // Open boxes (unencrypted at Hive level, manual encryption applied)
    try {
      _encryptedCacheBox = await Hive.openBox(
        _encryptedCacheBoxName,
      );
      
      _metadataBox = await Hive.openBox(_submissionMetadataBoxName);
    } catch (e) {
      throw Exception('Failed to initialize secure storage: $e');
    }
  }

  /// Generate or retrieve encryption key from secure storage
  static Future<Uint8List> _getOrGenerateEncryptionKey() async {
    // ⚠️ NOTE: In production, store this key in platform-specific secure storage:
    // Android: Use EncryptedSharedPreferences
    // iOS: Use Keychain
    // For now, generate a random key per app session
    
    // In a real app, you would use flutter_secure_storage:
    // final secureStorage = FlutterSecureStorage();
    // final keyString = await secureStorage.read(key: 'hive_encryption_key');
    // if (keyString != null) return base64Decode(keyString);
    
    // For demo, generate random key
    final key = encrypt.Key.fromSecureRandom(_encryptionKeyLength);
    return key.bytes;
  }

  /// Cache quiz submission metadata (NOT answers - those are sensitive)
  /// Only cache: quiz_id, time_spent, timestamp
  static Future<void> cacheQuizSubmissionMetadata({
    required int quizId,
    required int timeSpent,
  }) async {
    try {
      final timestamp = DateTime.now();
      final metadata = {
        'quiz_id': quizId,
        'time_spent': timeSpent,
        'timestamp': timestamp.toIso8601String(),
        'synced': false, // Mark as unsynced
      };
      
      final key = '${quizId}_${timestamp.millisecondsSinceEpoch}';
      await _metadataBox.put(key, metadata);
    } catch (e) {
      throw Exception('Failed to cache submission metadata: $e');
    }
  }

  /// Get all unsynced submission metadata
  static Future<List<Map<String, dynamic>>> getPendingSubmissions() async {
    try {
      final pending = <Map<String, dynamic>>[];
      for (var key in _metadataBox.keys) {
        final data = _metadataBox.get(key) as Map?;
        if (data != null && data['synced'] != true) {
          pending.add(Map<String, dynamic>.from(data));
        }
      }
      return pending;
    } catch (e) {
      throw Exception('Failed to retrieve pending submissions: $e');
    }
  }

  /// Mark submission as synced (synced = true)
  static Future<void> markSubmissionSynced(int quizId, String timestamp) async {
    try {
      final key = '${quizId}_$timestamp';
      final data = _metadataBox.get(key) as Map?;
      if (data != null) {
        data['synced'] = true;
        await _metadataBox.put(key, data);
      }
    } catch (e) {
      throw Exception('Failed to mark submission as synced: $e');
    }
  }

  /// Clear all synced submissions (cleanup cache)
  static Future<void> clearSyncedSubmissions() async {
    try {
      final keysToDelete = <dynamic>[];
      for (var key in _metadataBox.keys) {
        final data = _metadataBox.get(key) as Map?;
        if (data != null && data['synced'] == true) {
          keysToDelete.add(key);
        }
      }
      for (var key in keysToDelete) {
        await _metadataBox.delete(key);
      }
    } catch (e) {
      throw Exception('Failed to clear synced submissions: $e');
    }
  }

  /// Store encrypted data (for future use with sensitive data)
  /// Encrypts the value using AES before storing
  static Future<void> setEncrypted(String key, dynamic value) async {
    try {
      final plaintext = jsonEncode(value);
      final encrypted = _encrypter.encrypt(plaintext, iv: _encryptionIV);
      await _encryptedCacheBox.put(key, encrypted.base64);
    } catch (e) {
      throw Exception('Failed to store encrypted data: $e');
    }
  }

  /// Retrieve encrypted data
  /// Decrypts the value after retrieval
  static Future<dynamic> getEncrypted(String key) async {
    try {
      final encryptedBase64 = _encryptedCacheBox.get(key);
      if (encryptedBase64 == null) return null;
      
      final decrypted = _encrypter.decrypt64(
        encryptedBase64 as String,
        iv: _encryptionIV,
      );
      return jsonDecode(decrypted);
    } catch (e) {
      throw Exception('Failed to retrieve encrypted data: $e');
    }
  }

  /// Cleanup old cache entries (older than 7 days)
  static Future<void> cleanupOldCache() async {
    try {
      final now = DateTime.now();
      final keysToDelete = <dynamic>[];
      
      for (var key in _metadataBox.keys) {
        final data = _metadataBox.get(key) as Map?;
        if (data != null) {
          final timestamp = DateTime.parse(data['timestamp'] as String);
          if (now.difference(timestamp).inDays > 7) {
            keysToDelete.add(key);
          }
        }
      }
      
      for (var key in keysToDelete) {
        await _metadataBox.delete(key);
      }
    } catch (e) {
      throw Exception('Failed to cleanup old cache: $e');
    }
  }
}
