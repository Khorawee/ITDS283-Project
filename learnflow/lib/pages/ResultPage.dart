/// lib/pages/ResultPage.dart
/// หน้าแสดงผลลัพธ์หลังจากทำ Quiz เสร็จ
/// 
/// Features:
/// - Display score, grade, badge
/// - Performance breakdown (accuracy, speed, understanding)
/// - Detailed question review link
/// - Retry quiz button
/// - Navigate back to HomePage

import 'package:flutter/material.dart';
import '../services/result_service.dart';
import 'ReviewAnswerPage.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color cardGreen    = Color(0xFF81E3AB);
  static const Color darkText     = Color(0xFF085041);

  Map<String, dynamic>? _result;
  bool _isLoading = true;
  int _attemptId  = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _attemptId = args['attempt_id'] ?? 0;
    }
    _loadResult();
  }

  Future<void> _loadResult() async {
    if (_attemptId == 0) { setState(() => _isLoading = false); return; }
    try {
      final data = await ResultService.getResult(_attemptId);
      setState(() { _result = data; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator(color: primaryGreen)));
    }

    final r            = _result;
    final score        = r?['score'] ?? 0;
    final total        = r?['total'] ?? 0;
    final timeSpent    = r?['time_spent'] ?? 0;
    final correct      = r?['correct'] ?? 0;
    final incorrect    = r?['incorrect'] ?? 0;
    final grade        = r?['grade'] ?? '-';
    final badge        = r?['badge'] ?? '-';
    final subject      = r?['subject_name'] ?? 'QUIZ';
    final quizTitle    = r?['quiz_title'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context)),
        title: const Text('RESULT', style: TextStyle(color: primaryGreen, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(quizTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen)),
            CircleAvatar(radius: 30, backgroundColor: cardGreen,
                child: const Icon(Icons.person, color: primaryGreen, size: 30)),
          ]),
          const SizedBox(height: 16),
          // รูปภาพประจำวิชา — แสดงตามวิชาของข้อสอบที่เลือก
          Center(child: _buildSubjectImage(subject)),
          const SizedBox(height: 24),
          const Text('QUIZ DETAILS', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryGreen)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('SUBJECT :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(subject.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _buildStatCircle('TOTAL SCORE', '$score/$total')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCircle('TIME SPENT', '${(timeSpent / 60).toStringAsFixed(0)} MINS')),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _buildStatCircle('CORRECT\nANSWERS', '$correct/$total')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCircle('INCORRECT\nANSWERS', '$incorrect/$total')),
          ]),
          const SizedBox(height: 24),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardGreen, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('FEEDBACK MESSAGE', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 8),
              Text('GRADE : $grade', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 6),
              Text('PERFORMANCE BADGE : $badge',
                  style: const TextStyle(fontSize: 11, color: darkText, height: 1.5)),
            ]),
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ReviewAnswerPage(attemptId: _attemptId))),
            child: const Text('REVIEW ANSWER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                color: Colors.white, letterSpacing: 1.2)),
          )),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
            child: const Text('BACK TO DASHBOARD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                color: Colors.white, letterSpacing: 1.2)),
          )),
          const SizedBox(height: 36),
        ]),
      ),
    );
  }

  /// รูปภาพประจำวิชา — math.png สำหรับคณิต, Eng.png สำหรับอังกฤษ
  Widget _buildSubjectImage(String subject) {
    String? assetPath;
    final s = subject.toUpperCase();
    if (s.contains('MATH')) {
      assetPath = 'assets/images/math.png';
    } else if (s.contains('ENGLISH')) {
      assetPath = 'assets/images/Eng.png';
    }
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(color: cardGreen.withOpacity(0.4), shape: BoxShape.circle),
      child: assetPath != null
          ? ClipOval(child: Image.asset(assetPath, fit: BoxFit.cover))
          : const Icon(Icons.quiz_outlined, color: primaryGreen, size: 48),
    );
  }

  Widget _buildStatCircle(String label, String value) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: const BoxDecoration(color: cardGreen, shape: BoxShape.circle),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: darkText, height: 1.4)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
        ]),
      ),
    );
  }
}
