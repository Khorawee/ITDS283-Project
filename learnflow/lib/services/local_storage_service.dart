/// lib/services/local_storage_service.dart
/// Local persistent storage สำหรับ quiz submissions (ใช้ Hive)
/// 
/// Features:
/// - cacheQuizSubmission: save locally before API submission
/// - getPendingSubmissions: retrieve all cached submissions
/// - clearSubmission: delete after successful upload
/// - Prevent data loss on network failure

import 'package:hive_flutter/hive_flutter.dart';

// Quiz submission cache box name
const String _quizSubmissionBoxName = 'quiz_submissions';

/// Model for cached quiz submission
class CachedQuizSubmission {
  final int quizId;
  final List<Map<String, dynamic>> answers;
  final int timeSpent;
  final DateTime cachedAt;

  CachedQuizSubmission({
    required this.quizId,
    required this.answers,
    required this.timeSpent,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() => {
    'quiz_id': quizId,
    'answers': answers,
    'time_spent': timeSpent,
    'cached_at': cachedAt.toIso8601String(),
  };

  static CachedQuizSubmission fromJson(Map<String, dynamic> json) {
    return CachedQuizSubmission(
      quizId: json['quiz_id'] as int,
      answers: List<Map<String, dynamic>>.from(json['answers'] as List),
      timeSpent: json['time_spent'] as int,
      cachedAt: DateTime.parse(json['cached_at'] as String),
    );
  }
}

class LocalStorageService {
  static late Box _quizSubmissionBox;

  /// เริ่มต้น local storage (Hive initialization)
  static Future<void> init() async {
    await Hive.initFlutter();
    _quizSubmissionBox = await Hive.openBox(_quizSubmissionBoxName);
  }

  /// เก็บ quiz submission ลง local storage ก่อนส่ง API
  /// Return: cache key สำหรับ retrieve ทีหลัง
  static Future<String> cacheQuizSubmission({
    required int quizId,
    required List<Map<String, dynamic>> answers,
    required int timeSpent,
  }) async {
    final cacheKey = 'quiz_${quizId}_${DateTime.now().millisecondsSinceEpoch}';
    final submission = CachedQuizSubmission(
      quizId: quizId,
      answers: answers,
      timeSpent: timeSpent,
      cachedAt: DateTime.now(),
    );
    
    await _quizSubmissionBox.put(cacheKey, submission.toJson());
    return cacheKey;
  }

  /// ดึง submissions ที่ยังไม่ได้ upload
  static Future<List<CachedQuizSubmission>> getPendingSubmissions() async {
    final submissions = <CachedQuizSubmission>[];
    for (final value in _quizSubmissionBox.values) {
      if (value is Map) {
        submissions.add(CachedQuizSubmission.fromJson(value as Map<String, dynamic>));
      }
    }
    return submissions;
  }

  /// ล้าง cache submission ที่อัพโหลดเรียบร้อยแล้ว
  static Future<void> clearSubmission(String cacheKey) async {
    await _quizSubmissionBox.delete(cacheKey);
  }

  /// ล้าง cache submissions ทั้งหมด
  static Future<void> clearAllSubmissions() async {
    await _quizSubmissionBox.clear();
  }

  /// ดึง จำนวน cached submissions (สำหรับ debugging)
  static int getSubmissionCount() {
    return _quizSubmissionBox.length;
  }
}
