// lib/pages/HomePage.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../services/recommendation_service.dart';
import '../services/profile_service.dart';
import '../widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color darkGreen    = Color.fromARGB(255, 35, 146, 81);
  static const Color bgColor      = Color(0xFFF0FBF4);
  static const Color cardGreen    = Color.fromARGB(255, 129, 227, 171);

  Map<String, dynamic>       _profile         = {};
  List<Map<String, dynamic>> _recommendations = [];
  bool   _isLoading = true;
  String _errorMsg  = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ดึงข้อมูลใหม่ทุกครั้งที่หน้า pop กลับ (เช่นจากหน้า Result)
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _errorMsg = ''; });
    try {
      final results = await Future.wait([
        ProfileService.getProfile(),
        RecommendationService.getRecommendations(),
      ]);
      if (mounted) {
        setState(() {
          _profile         = results[0] as Map<String, dynamic>;
          _recommendations = results[1] as List<Map<String, dynamic>>;
          _isLoading       = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; _errorMsg = 'ไม่สามารถโหลดข้อมูลได้'; });
      }
    }
  }

  String get _displayName {
    final first = _profile['first_name'] ?? '';
    final last  = _profile['last_name']  ?? '';
    if (first.isNotEmpty) return '$first $last'.trim();
    return FirebaseAuth.instance.currentUser?.displayName ?? 'User';
  }

  String get _avgScore     => _profile.isNotEmpty ? '${_profile['avg_score'] ?? 0}%' : '-';
  String get _totalQuizzes => _profile.isNotEmpty ? '${_profile['total_quizzes'] ?? 0}' : '-';
  String get _grade        => _profile['grade'] ?? '-';

  IconData _subjectIcon(String subject) {
    switch (subject.toUpperCase()) {
      case 'MATHEMATICS': return Icons.calculate_outlined;
      case 'ENGLISH':     return Icons.menu_book_outlined;
      default:            return Icons.quiz_outlined;
    }
  }

  String? _subjectImageAsset(String subject) {
  switch (subject.toUpperCase()) {
    case 'MATHEMATICS': 
      return 'assets/images/math.png';
    case 'ENGLISH':     
      return 'assets/images/Eng.png';
    case 'SOCIAL STUDIES':  
      return 'assets/images/Social_Studies.png';
    case 'PROGRAMMING':     
      return 'assets/images/Programming.png';
    default:            
      return null;
    }
  }

  Widget _buildSubjectAvatar(String subject, {double size = 42}) {
    final imgPath = _subjectImageAsset(subject);
    if (imgPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.18),
        child: Image.asset(imgPath, width: size, height: size, fit: BoxFit.cover),
      );
    }
    return Icon(_subjectIcon(subject), color: Colors.white, size: size * 0.52);
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'ฝึกเพิ่ม': return 'WEAK';
      case 'ทบทวน':   return 'REVIEW';
      case 'ผ่าน':    return 'STRONG';
      default:         return action;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildReminderCard(),
                    const SizedBox(height: 24),
                    if (_errorMsg.isNotEmpty) _buildErrorBanner(),
                    const SizedBox(height: 8),
                    _buildSummarySection(),
                    const SizedBox(height: 24),
                    _buildRecommendedSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          const LearnFlowBottomNav(selectedIndex: 0),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.orange),
            SizedBox(width: 6),
            Text('GOOD MORNING',
                style: TextStyle(fontSize: 12, color: Colors.grey,
                    letterSpacing: 1.2, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 4),
          Text(_displayName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ]),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
          child: CircleAvatar(
            radius: 28, backgroundColor: primaryGreen,
            child: Text(
              _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U',
              style: const TextStyle(color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // แสดงตลอดเวลา ไม่ขึ้นกับ notification state
  Widget _buildReminderCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/reminder'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: primaryGreen, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('REMINDER',
                      style: TextStyle(color: Colors.white70, fontSize: 11,
                          fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                  SizedBox(height: 2),
                  Text('QUIZ STARTS IN 15 MINUTES',
                      style: TextStyle(color: Colors.white, fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ]),
          ),
          const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
        ]),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: const Color(0xFFFDECEA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE74C3C).withOpacity(0.3))),
      child: Row(children: [
        const Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFFE74C3C)),
        const SizedBox(width: 8),
        Expanded(child: Text(_errorMsg,
            style: const TextStyle(fontSize: 13, color: Color(0xFFE74C3C)))),
        GestureDetector(
          onTap: _loadData,
          child: const Text('Retry',
              style: TextStyle(fontSize: 13, color: Color(0xFFE74C3C),
                  fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _buildSummarySection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('SUMMARY',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              letterSpacing: 1.5, color: Colors.black87)),
      const SizedBox(height: 12),
      _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : Row(children: [
              Expanded(child: _buildSummaryCard('AVERAGE\nSCORE', _avgScore)),
              const SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('QUIZ', _totalQuizzes)),
              const SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('GRADE', _grade)),
            ]),
    ]);
  }

  Widget _buildSummaryCard(String label, String value) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: cardGreen, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                  color: Colors.black54, letterSpacing: 0.5, height: 1.4)),
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('RECOMMENDED FOR YOU',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              letterSpacing: 1.5, color: Colors.black87)),
      const SizedBox(height: 12),
      if (_isLoading)
        const Center(child: CircularProgressIndicator(color: primaryGreen))
      else if (_recommendations.isEmpty)
        _buildEmptyRecommendations()
      else
        ...(_recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRecommendationCard(rec),
            ))),
    ]);
  }

  Widget _buildEmptyRecommendations() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
          color: cardGreen.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(Icons.quiz_outlined, size: 48, color: primaryGreen.withOpacity(0.5)),
        const SizedBox(height: 12),
        const Text('ยังไม่มีคำแนะนำ',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                color: Colors.black54)),
        const SizedBox(height: 4),
        const Text('ทำ Quiz ก่อน เพื่อให้ AI วิเคราะห์และแนะนำบทเรียน',
            style: TextStyle(fontSize: 12, color: Colors.black45),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/quiz'),
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              elevation: 0),
          child: const Text('เริ่มทำ Quiz',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec) {
    final subject = rec['subject_name'] ?? '';

    final quizArgs = {
      'quiz_id':         rec['rec_id'] ?? rec['quiz_id'] ?? 1,
      'title':           rec['topic'] ?? subject,
      'subject_name':    subject,
      'level':           'easy',
      'total_questions': 0,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: primaryGreen, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _buildSubjectAvatar(subject),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(subject.toUpperCase(),
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text(rec['topic'] ?? 'Quiz',
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/quiz-detail', arguments: quizArgs),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: darkGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('START QUIZ',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
      ]),
    );
  }

  Widget _buildDifficultyBadge(String label, Map<String, dynamic>? diffData) {
    if (diffData == null) return const SizedBox.shrink();
    
    final mastery = (diffData['mastery'] ?? 0.0).toDouble();
    final level = diffData['level'] ?? 'Weak';
    
    Color badgeColor;
    if (level == 'Strong') {
      badgeColor = Colors.white;
    } else if (level == 'Improving') {
      badgeColor = const Color(0xFFFFC107);
    } else {
      badgeColor = const Color(0xFFE74C3C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        '$label:${(mastery * 100).toInt()}%',
        style: TextStyle(
          color: badgeColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}