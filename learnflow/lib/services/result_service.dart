// lib/services/result_service.dart  [UPDATED — เพิ่ม hasAttempted()]

import 'api_service.dart';

class ResultService {
  /// GET /api/result/<attempt_id> — ดึงผลลัพธ์ quiz พร้อม grade/badge
  static Future<Map<String, dynamic>> getResult(int attemptId) async {
    return await ApiService.get('/api/result/$attemptId');
  }

  /// GET /api/review/<attempt_id> — ดึงคำตอบ+เฉลย+คำอธิบายทุกข้อ
  static Future<List<Map<String, dynamic>>> getReview(int attemptId) async {
    final data = await ApiService.get('/api/review/$attemptId');
    return List<Map<String, dynamic>>.from(data['answers']);
  }

  /// GET /api/quiz/<quiz_id>/attempted — ตรวจสอบว่า user เคยทำ quiz นี้มาก่อนหรือเปล่า
  /// ใช้สำหรับซ่อน/แสดงปุ่ม Retake ใน DetailBasicMathPage
  static Future<bool> hasAttempted(int quizId) async {
    try {
      final data = await ApiService.get('/api/quiz/$quizId/attempted');
      return data['has_attempted'] == true;
    } catch (_) {
      return false;
    }
  }
}
