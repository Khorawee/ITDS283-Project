/// lib/pages/QuizPlayPage.dart
/// หน้า Quiz ระหว่างการทำข้อสอบ
/// 
/// Features:
/// - Display quiz questions + choices (A/B/C/D)
/// - Timer countdown with auto-submit on time-up
/// - Track per-question response time
/// - Local cache quiz submission before API (prevent data loss)
/// - Retry on submission failure
/// - Navigate to ResultPage on success
///
/// Timer Management:
/// - Fetches time_limit_seconds from API
/// - Nullable Timer to prevent memory leak
/// - Safe dispose in _finish() and dispose()

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../services/local_storage_service.dart';
import '../services/analytics_service.dart';

class QuizPlayPage extends StatefulWidget {
  const QuizPlayPage({super.key});

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color cardGreen    = Color.fromARGB(255, 129, 227, 171);
  static const Color bgColor      = Color(0xFFF0FBF4);

  // ── API data ───────────────────────────────────────────────────────────────
  Map<String, dynamic>? _quizData;
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  String? _error;

  int _quizId      = 1; // default; overridden by route arguments
  int _timeLimitSec = 45 * 60;  // Default fallback; will be overridden by API

  // ── Quiz state ─────────────────────────────────────────────────────────────
  int _currentQuestion = 0;
  int _remainingSeconds = 0;
  Timer? _timer;  // FIX: Allow null to track if timer exists
  late List<int?> _selectedAnswers;
  // track response time per question (seconds)
  late List<double> _responseTimes;
  DateTime? _questionStartTime;

  // ── Labels A/B/C/D → index 0/1/2/3 ───────────────────────────────────────
  static const _labelToIndex = {'A': 0, 'B': 1, 'C': 2, 'D': 3};
  static const _indexToLabel = ['A', 'B', 'C', 'D'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _quizId = args['quiz_id'] ?? 1;
    }
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await QuizService.getQuizDetail(_quizId);
      final questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
      
      // FIX: Get time_limit from API instead of hardcoding
      // fallback: EASY=1 นาที/ข้อ, MEDIUM/HARD=1.5 นาที/ข้อ (เหมือน API)
      final timeLimitFromApi = data['time_limit_seconds'] as int?;
      final level = ((data['level'] ?? 'easy') as String).toUpperCase();
      final minsPerQ = (level == 'EASY') ? 1.0 : 1.5;
      final fallbackSec = (questions.length * minsPerQ * 60).toInt();
      final timeLimitToUse = timeLimitFromApi ?? fallbackSec;
      
      setState(() {
        _quizData          = data;
        _questions         = questions;
        _selectedAnswers   = List.filled(questions.length, null);
        _responseTimes     = List.filled(questions.length, 0);
        _timeLimitSec      = timeLimitToUse;  // Use API value
        _remainingSeconds  = timeLimitToUse;
        _isLoading         = false;
        _questionStartTime = DateTime.now();
      });
      _startTimer();
    } catch (e) {
      setState(() { _error = 'Failed to load quiz'; _isLoading = false; });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _showTimeUpDialog();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _recordResponseTime() {
    if (_questionStartTime != null) {
      _responseTimes[_currentQuestion] =
          DateTime.now().difference(_questionStartTime!).inSeconds.toDouble();
    }
    _questionStartTime = DateTime.now();
  }

  void _goNext() {
    _recordResponseTime();
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    }
  }

  void _goPrevious() {
    _recordResponseTime();
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
    }
  }

  Future<void> _finish() async {
    _recordResponseTime();
    // FIX: Safely cancel timer
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    await _submitQuiz();
  }

  Future<void> _submitQuiz() async {
    final answers = <Map<String, dynamic>>[];
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final selectedIdx = _selectedAnswers[i];
      answers.add({
        'question_id':    q['question_id'],
        'selected_choice': selectedIdx != null ? _indexToLabel[selectedIdx] : 'A',
        'response_time':  _responseTimes[i],
        'attempt_count':  1,
      });
    }
    final timeSpent = _timeLimitSec - _remainingSeconds;

    // Cache locally before sending
    await LocalStorageService.cacheQuizSubmission(
      quizId: _quizId,
      answers: answers,
      timeSpent: timeSpent,
    );

    // Show loading dialog while submitting
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: primaryGreen),
        ),
      );
    }

    try {
      final result = await QuizService.submitQuiz(
        quizId:    _quizId,
        timeSpent: timeSpent,
        answers:   answers,
      );

      // Invalidate analytics cache so Home/Analytics show updated data
      AnalyticsService.invalidateCache();

      if (mounted) {
        Navigator.of(context).pop(); // close loading dialog
        Navigator.pushReplacementNamed(context, '/result',
            arguments: {'attempt_id': result['attempt_id']});
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ส่งคำตอบไม่สำเร็จ กรุณาลองใหม่'),
            backgroundColor: const Color(0xFFE74C3C),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'ลองใหม่',
              textColor: Colors.white,
              onPressed: () => _submitQuiz(),
            ),
          ),
        );
      }
    }
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 72, height: 72,
              decoration: const BoxDecoration(color: Color(0xFFFFEEEE), shape: BoxShape.circle),
              child: const Icon(Icons.timer_off_outlined, color: Color(0xFFE74C3C), size: 36)),
            const SizedBox(height: 16),
            const Text("TIME'S UP!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                color: Color(0xFFE74C3C), letterSpacing: 1.5)),
            const SizedBox(height: 8),
            const Text('The quiz time is up,\nand the system will show you your summary score.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () { Navigator.of(context).pop(); _submitQuiz(); },
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
              child: const Text('SUMMARY', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // FIX: Safely cancel timer if it exists and is active
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    super.dispose();
  }

  String get _formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}.${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: bgColor,
          body: Center(child: CircularProgressIndicator(color: primaryGreen)));
    }
    if (_error != null) {
      return Scaffold(backgroundColor: bgColor, body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.black26),
        const SizedBox(height: 12),
        Text(_error!, style: const TextStyle(color: Colors.black45)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _loadQuiz, style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            child: const Text('Retry', style: TextStyle(color: Colors.white))),
      ])));
    }

    final question       = _questions[_currentQuestion];
    final choices        = List<Map<String, dynamic>>.from(question['choices'] ?? []);
    final isFirst        = _currentQuestion == 0;
    final isLast         = _currentQuestion == _questions.length - 1;
    final progress       = (_currentQuestion + 1) / _questions.length;
    final currentSelected = _selectedAnswers[_currentQuestion];
    final isLowTime      = _remainingSeconds <= 5 * 60;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 16),
                  GestureDetector(onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.black87, size: 24)),
                  const SizedBox(height: 12),
                  Center(child: Text(
                    (_quizData?['title'] ?? 'QUIZ').toString().toUpperCase(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                        color: primaryGreen, letterSpacing: 1.2),
                  )),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('QUESTIONS ${_currentQuestion + 1} / ${_questions.length}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                    Row(children: [
                      Icon(Icons.timer_outlined, size: 14, color: isLowTime ? const Color(0xFFE74C3C) : Colors.black54),
                      const SizedBox(width: 4),
                      Text(_formattedTime, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                          color: isLowTime ? const Color(0xFFE74C3C) : Colors.black87)),
                    ]),
                  ]),
                  const SizedBox(height: 6),
                  Stack(children: [
                    Container(height: 6, width: double.infinity,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
                    AnimatedFractionallySizedBox(duration: const Duration(milliseconds: 300), widthFactor: progress,
                        child: Container(height: 6,
                            decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(4)))),
                  ]),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity, constraints: const BoxConstraints(minHeight: 100),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: cardGreen, borderRadius: BorderRadius.circular(14)),
                    child: Text(question['question_text'] ?? '',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.4)),
                  ),
                  const SizedBox(height: 20),
                  // Choices from API (A/B/C/D)
                  ...choices.map((choice) {
                    final label = choice['choice_label'] ?? '';
                    final idx   = _labelToIndex[label] ?? 0;
                    final isSelected = currentSelected == idx;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedAnswers[_currentQuestion] = idx),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryGreen : cardGreen,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected ? Border.all(color: primaryGreen, width: 2) : null,
                          ),
                          child: Text('$label. ${choice['choice_text']}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.black87)),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(children: [
                if (!isFirst) ...[
                  Expanded(child: OutlinedButton(
                    onPressed: _goPrevious,
                    style: OutlinedButton.styleFrom(foregroundColor: primaryGreen,
                        side: const BorderSide(color: primaryGreen, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: const Text('PREVIOUS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  )),
                  const SizedBox(width: 12),
                ],
                Expanded(child: ElevatedButton(
                  onPressed: isLast ? _finish : _goNext,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
                  child: Text(isLast ? 'FINISH' : 'NEXT',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                )),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}