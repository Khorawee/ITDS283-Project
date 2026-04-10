// lib/pages/QuizDetailPage.dart  [FIXED UI]
// แก้: EXAM CONTENT กล่องว่าง → แสดง subject + level จริง
// แก้: ใช้ LearnFlowBottomNav กลาง

import 'package:flutter/material.dart';
import '../services/result_service.dart';
import '../widgets/bottom_nav.dart';

class QuizDetailPage extends StatefulWidget {
  const QuizDetailPage({super.key});
  @override
  State<QuizDetailPage> createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color bgColor      = Color(0xFFF0FBF4);
  static const Color cardGreen    = Color.fromARGB(255, 129, 227, 171);

  bool _hasAttempted = false;
  bool _isChecking   = true;
  int  _quizId       = 1;
  Map<String, dynamic> _quiz = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _quiz   = args;
      _quizId = args['quiz_id'] ?? 1;
    }
    _checkPreviousAttempt();
  }

  Future<void> _checkPreviousAttempt() async {
    setState(() => _isChecking = true);
    try {
      final hasDone = await ResultService.hasAttempted(_quizId);
      setState(() { _hasAttempted = hasDone; _isChecking = false; });
    } catch (_) {
      setState(() { _hasAttempted = false; _isChecking = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title   = (_quiz['title']          ?? 'QUIZ').toString().toUpperCase();
    final subject = (_quiz['subject_name']   ?? 'SUBJECT').toString().toUpperCase();
    final level   = (_quiz['level']          ?? 'EASY').toString().toUpperCase();
    final totalQ  = _quiz['total_questions'] ?? 10;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.black87, size: 24),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: primaryGreen, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 20),
                _buildSubjectImage(subject),
                const SizedBox(height: 24),
                _buildQuizDetails(subject, level, totalQ),
                const SizedBox(height: 24),
                _isChecking
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: primaryGreen))
                    : _buildActionButtons(context),
                const SizedBox(height: 20),
              ]),
            ),
          ),
          // FIX: ใช้ widget กลาง
          const LearnFlowBottomNav(selectedIndex: 1),
        ]),
      ),
    );
  }

  Widget _buildSubjectImage(String subject) {
    String? assetPath;
    if (subject.contains('MATH')) {
      assetPath = 'assets/images/math.png';
    } else if (subject.contains('ENGLISH')) {
      assetPath = 'assets/images/Eng.png';
    }
    return Center(
      child: Container(
        width: 130, height: 130,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.grey.shade200),
        child: assetPath != null
            ? ClipOval(
                child: Image.asset(assetPath, fit: BoxFit.cover))
            : const Icon(Icons.quiz_outlined,
                size: 56, color: primaryGreen),
      ),
    );
  }

  Widget _buildQuizDetails(String subject, String level, dynamic totalQ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('QUIZ DETAILS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              letterSpacing: 1.5, color: primaryGreen)),
      const SizedBox(height: 12),
      _detailRow('SUBJECT :', subject),
      const SizedBox(height: 8),
      _detailRow('QUESTIONS :', '$totalQ'),
      const SizedBox(height: 8),
      _detailRow('TIME LIMIT :', '45 MINS'),
      const SizedBox(height: 8),
      _detailRow('DIFFICULTY :', level),
      const SizedBox(height: 8),
      if (_hasAttempted && _quiz['best_score'] != null) ...[
        _detailRow('BEST SCORE :', '${_quiz['best_score']}%'),
        const SizedBox(height: 8),
      ],
      // FIX: EXAM CONTENT แสดงข้อมูลจริงแทนกล่องว่าง
      _buildExamContentBox(subject, level),
    ]);
  }

  Widget _detailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: cardGreen, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: Colors.black54)),
        const SizedBox(width: 12),
        Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                color: Colors.black87)),
      ]),
    );
  }

  // FIX: EXAM CONTENT แสดงข้อมูลที่เป็นประโยชน์แทนกล่องว่าง
  Widget _buildExamContentBox(String subject, String level) {
    final desc = _getExamDescription(subject, level);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: cardGreen, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('EXAM CONTENT :',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: Colors.black54)),
        const SizedBox(height: 6),
        Text(desc,
            style: const TextStyle(fontSize: 12, color: Colors.black54,
                height: 1.5)),
      ]),
    );
  }

  String _getExamDescription(String subject, String level) {
    if (subject.contains('MATH')) {
      return level == 'HARD'
          ? 'Advanced algebra, calculus, and problem solving'
          : 'Basic arithmetic, fractions, and equations';
    }
    if (subject.contains('ENGLISH')) {
      return level == 'HARD'
          ? 'Advanced grammar, reading comprehension, and writing'
          : 'Vocabulary, basic grammar, and sentence structure';
    }
    return 'Mixed topics — multiple choice format';
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/quiz-play',
              arguments: {'quiz_id': _quizId}),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: const Text('START QUIZ',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
        ),
      ),
      if (_hasAttempted) ...[
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/quiz-play',
                arguments: {'quiz_id': _quizId}),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryGreen,
              side: const BorderSide(color: primaryGreen, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('RETAKE',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
          ),
        ),
      ],
    ]);
  }
}
