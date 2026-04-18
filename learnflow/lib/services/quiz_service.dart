/// lib/services/quiz_service.dart
/// API client สำหรับ Quiz operations
/// 
/// Methods:
/// - getQuizzes: ดึง quiz ทั้งหมดทุก page
/// - getQuizDetail: ดึง quiz detail + questions + choices + time_limit
/// - submitQuiz: ส่งคำตอบ + score/accuracy/speed/understanding ไปยัง backend

import 'api_service.dart';

class QuizService {
  /// GET /api/quizzes — ดึง quiz page เดียว (ใช้ภายใน)
  static Future<Map<String, dynamic>> getQuizzesPage({int page = 1, int limit = 50}) async {
    return await ApiService.get('/api/quizzes?page=$page&limit=$limit');
  }

  /// GET /api/quizzes — ดึง quiz ทั้งหมดทุก page
  static Future<List<Map<String, dynamic>>> getQuizzes() async {
    final List<Map<String, dynamic>> allQuizzes = [];
    int page = 1;
    int totalPages = 1;

    do {
      final data = await getQuizzesPage(page: page, limit: 50);
      final quizzes = List<Map<String, dynamic>>.from(data['quizzes'] ?? []);
      allQuizzes.addAll(quizzes);

      final pagination = data['pagination'] as Map<String, dynamic>?;
      totalPages = (pagination?['total_pages'] ?? 1) as int;
      page++;
    } while (page <= totalPages);

    return allQuizzes;
  }

  /// GET /api/quiz/<id> — ดึง quiz + คำถาม + ตัวเลือก
  static Future<Map<String, dynamic>> getQuizDetail(int quizId) async {
    final data = await ApiService.get('/api/quiz/$quizId');
    return data['quiz'] as Map<String, dynamic>;
  }

  /// POST /api/quiz/submit — ส่งคำตอบทั้งหมด
  /// answers: [{ question_id, selected_choice, response_time, attempt_count }]
  static Future<Map<String, dynamic>> submitQuiz({
    required int quizId,
    required int timeSpent,
    required List<Map<String, dynamic>> answers,
  }) async {
    return await ApiService.post('/api/quiz/submit', {
      'quiz_id':    quizId,
      'time_spent': timeSpent,
      'answers':    answers,
    });
  }
}