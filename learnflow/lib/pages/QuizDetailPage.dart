// lib/pages/QuizDetailPage.dart
// FIX 1: แสดงจำนวนคำถามจริงจาก API (question_count) แทน total_questions ใน DB
// FIX 2: ดึง quiz detail จาก API เพื่อให้ได้ question_count ที่นับจริง

import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
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

  bool _hasAttempted  = false;
  bool _isChecking    = true;
  bool _isLoadingDetail = false;
  int  _quizId        = 1;
  Map<String, dynamic> _quiz = {};

  // FIX: จำนวนคำถามจริงที่นับจาก questions table
  int? _actualQuestionCount;

  // FIX: เวลาจริงจาก API (ตรงกับ QuizPlayPage)
  int? _timeLimitSeconds;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _quiz   = args;
      _quizId = args['quiz_id'] ?? 1;
    }
    _checkPreviousAttempt();
    _loadActualQuestionCount();
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

  // FIX: ดึง question_count จริง และ time_limit_seconds จาก /api/quiz/<id>
  Future<void> _loadActualQuestionCount() async {
    setState(() => _isLoadingDetail = true);
    try {
      final detail = await QuizService.getQuizDetail(_quizId);
      final questions = detail['questions'] as List? ?? [];
      final timeLimitSec = detail['time_limit_seconds'] as int?;
      // fallback คำนวณเหมือน API: EASY=1 นาที/ข้อ, MEDIUM/HARD=1.5 นาที/ข้อ
      final level = (_quiz['level'] ?? 'easy').toString().toUpperCase();
      final minsPerQ = (level == 'EASY') ? 1.0 : 1.5;
      final fallbackSec = ((questions.isNotEmpty ? questions.length : 10) * minsPerQ * 60).toInt();
      setState(() {
        _actualQuestionCount = questions.length;
        _timeLimitSeconds = timeLimitSec ?? fallbackSec;
        _isLoadingDetail = false;
      });
    } catch (_) {
      // fallback ใช้ค่าจาก quiz list ถ้า API ล้มเหลว
      setState(() {
        _actualQuestionCount = _quiz['question_count'] ?? _quiz['total_questions'];
        _timeLimitSeconds = null;
        _isLoadingDetail = false;
      });
    }
  }

  // FIX: แปลงวินาทีเป็น "X MINS" หรือ "X HR Y MINS"
  String _formatTimeLimit(int seconds) {
    final totalMins = (seconds / 60).ceil();
    if (totalMins >= 60) {
      final hrs = totalMins ~/ 60;
      final mins = totalMins % 60;
      return mins == 0 ? '$hrs HR' : '$hrs HR $mins MINS';
    }
    return '$totalMins MINS';
  }

  @override
  Widget build(BuildContext context) {
    final title   = (_quiz['title']          ?? 'QUIZ').toString().toUpperCase();
    final subject = (_quiz['subject_name']   ?? 'SUBJECT').toString().toUpperCase();
    final level   = (_quiz['level']          ?? 'EASY').toString().toUpperCase();

    // FIX: ใช้ _actualQuestionCount ที่นับจริง ถ้ายังโหลดอยู่ใช้ค่า fallback
    final displayQ = _actualQuestionCount
        ?? _quiz['question_count']
        ?? _quiz['total_questions']
        ?? '...';

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
                _buildQuizDetails(subject, level, displayQ),
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
    } else if (subject.contains('PROGRAMMING')) {
      assetPath = 'assets/images/Programming.png';
    } else if (subject.contains('SOCIAL')) {
      assetPath = 'assets/images/Social_Studies.png';
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

  Widget _buildQuizDetails(String subject, String level, dynamic displayQ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('QUIZ DETAILS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              letterSpacing: 1.5, color: primaryGreen)),
      const SizedBox(height: 12),
      _detailRow('SUBJECT :', subject),
      const SizedBox(height: 8),
      // FIX: แสดง loading ถ้ากำลังนับคำถาม
      _isLoadingDetail
          ? _detailRowLoading('QUESTIONS :')
          : _detailRow('QUESTIONS :', '$displayQ'),
      const SizedBox(height: 8),
      // FIX: แสดงเวลาจาก API ให้ตรงกับ QuizPlayPage (ไม่ hardcode 45 MINS)
      _isLoadingDetail
          ? _detailRowLoading('TIME LIMIT :')
          : _detailRow('TIME LIMIT :',
              _timeLimitSeconds != null
                  ? _formatTimeLimit(_timeLimitSeconds!)
                  : '45 MINS'),
      const SizedBox(height: 8),
      _detailRow('DIFFICULTY :', level),
      const SizedBox(height: 8),
      if (_hasAttempted && _quiz['best_score'] != null) ...[
        _detailRow('BEST SCORE :', '${_quiz['best_score']}%'),
        const SizedBox(height: 8),
      ],
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

  // FIX: skeleton สำหรับ loading state
  Widget _detailRowLoading(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: cardGreen, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: Colors.black54)),
        const SizedBox(width: 12),
        const SizedBox(
          width: 12, height: 12,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: primaryGreen),
        ),
      ]),
    );
  }

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
      switch (level) {
        case 'HARD':   return 'Advanced algebra, calculus, and complex problem solving';
        case 'MEDIUM': return 'Intermediate algebra, geometry, and word problems';
        default:       return 'Basic arithmetic, fractions, and simple equations';
      }
    }
    if (subject.contains('ENGLISH')) {
      switch (level) {
        case 'HARD':   return 'Advanced grammar, reading comprehension, and essay writing';
        case 'MEDIUM': return 'Intermediate grammar, paragraph reading, and vocabulary';
        default:       return 'Basic vocabulary, simple grammar, and sentence structure';
      }
    }
    if (subject.contains('PROGRAMMING')) {
      switch (level) {
        case 'HARD':   return 'Advanced algorithms, data structures, and system design';
        case 'MEDIUM': return 'Intermediate OOP, functions, loops, and debugging';
        default:       return 'Basic syntax, variables, conditions, and simple programs';
      }
    }
    if (subject.contains('SOCIAL')) {
      switch (level) {
        case 'HARD':   return 'Advanced history, economics, geopolitics, and civics';
        case 'MEDIUM': return 'Intermediate world history, geography, and society';
        default:       return 'Basic social studies, Thai history, and world geography';
      }
    }
    switch (level) {
      case 'HARD':   return 'Challenging mixed topics — multiple choice format';
      case 'MEDIUM': return 'Intermediate mixed topics — multiple choice format';
      default:       return 'Mixed topics — multiple choice format';
    }
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