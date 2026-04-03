// lib/services/quiz_service.dart

import 'api_service.dart';

class QuizService {
  /// GET /api/quizzes — ดึง quiz ทั้งหมด
  static Future<List<Map<String, dynamic>>> getQuizzes() async {
    final data = await ApiService.get('/api/quizzes');
    return List<Map<String, dynamic>>.from(data['quizzes']);
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
