// lib/pages/HomePage.dart  [UPDATED — เชื่อม API]

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/recommendation_service.dart';
import '../services/profile_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color darkGreen    = Color.fromARGB(255, 35, 146, 81);
  static const Color bgColor      = Color(0xFFF0FBF4);
  static const Color cardGreen    = Color.fromARGB(255, 129, 227, 171);

  // ── API state ──────────────────────────────────────────────────────────────
  Map<String, dynamic> _profile         = {};
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ProfileService.getProfile(),
        RecommendationService.getRecommendations(),
      ]);
      setState(() {
        _profile         = results[0] as Map<String, dynamic>;
        _recommendations = results[1] as List<Map<String, dynamic>>;
        _isLoading       = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String get _displayName {
    final first = _profile['first_name'] ?? '';
    final last  = _profile['last_name']  ?? '';
    if (first.isNotEmpty) return '$first $last'.trim();
    return FirebaseAuth.instance.currentUser?.displayName ?? 'User';
  }

  String get _avgScore => _profile.isNotEmpty
      ? '${_profile['avg_score'] ?? 0}%'
      : '-';

  String get _totalQuizzes => _profile.isNotEmpty
      ? '${_profile['total_quizzes'] ?? 0}'
      : '-';

  String get _grade => _profile['grade'] ?? '-';

  IconData _subjectIcon(String subject) {
    switch ((subject).toUpperCase()) {
      case 'MATHEMATICS': return Icons.calculate_outlined;
      case 'ENGLISH':     return Icons.menu_book_outlined;
      case 'SCIENCE':     return Icons.science_outlined;
      case 'PHYSICS':     return Icons.electric_bolt_outlined;
      case 'CHEMISTRY':   return Icons.biotech_outlined;
      default:            return Icons.quiz_outlined;
    }
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
        child: Column(
          children: [
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
                      _buildSummarySection(),
                      const SizedBox(height: 24),
                      _buildRecommendedSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: const [
              Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.orange),
              SizedBox(width: 6),
              Text('GOOD MORNING',
                  style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 4),
            Text(_displayName,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
          child: CircleAvatar(
            radius: 28, backgroundColor: primaryGreen,
            child: Text(
              _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/reminder'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('REMINDER', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
            SizedBox(height: 2),
            Text('QUIZ STARTS IN 15 MINUTES',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ])),
          const Text('NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SUMMARY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black87)),
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
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardGreen, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
              color: Colors.black54, letterSpacing: 0.5, height: 1.4)),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECOMMENDED FOR YOU',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black87)),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: primaryGreen))
        else if (_recommendations.isEmpty)
          _buildDefaultRecommendations()
        else
          ...(_recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildRecommendationCard(rec),
          ))),
      ],
    );
  }

  // Fallback เมื่อยังไม่มีข้อมูล recommendation ใน DB
  Widget _buildDefaultRecommendations() {
    final defaults = [
      {'title': 'BASIC ALGEBRA REVIEW', 'difficulty': 'EASY', 'icon': Icons.calculate_outlined},
      {'title': 'REVIEW ADVANCED MATH', 'difficulty': 'HARD', 'icon': Icons.functions_outlined},
      {'title': 'REVIEW BASIC ENGLISH', 'difficulty': 'EASY', 'icon': Icons.menu_book_outlined},
    ];
    return Column(children: defaults.map((q) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildStaticQuizCard(q),
    )).toList());
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec) {
    final subject = rec['subject_name'] ?? '';
    final action  = rec['action'] ?? '';
    final mastery = (rec['mastery'] ?? 0).toDouble();
    final badge   = _actionLabel(action);
    final badgeColor = action == 'ฝึกเพิ่ม'
        ? const Color(0xFFE74C3C)
        : action == 'ผ่าน' ? primaryGreen : const Color(0xFFF9A825);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          const Text('STATUS: ', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          Text(badge, style: TextStyle(color: badgeColor == primaryGreen ? Colors.white : badgeColor,
              fontSize: 11, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Container(width: 42, height: 42,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(_subjectIcon(subject), color: Colors.white, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(subject.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Mastery: ${(mastery * 100).toInt()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ])),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, foregroundColor: darkGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
            ),
            child: const Text('START QUIZ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
      ]),
    );
  }

  Widget _buildStaticQuizCard(Map<String, dynamic> quiz) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          const Text('DIFFICULTY: ', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          Text(quiz['difficulty'], style: TextStyle(
              color: quiz['difficulty'] == 'HARD' ? const Color(0xFFFFD700) : Colors.white,
              fontSize: 11, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Container(width: 42, height: 42,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(quiz['icon'] as IconData, color: Colors.white, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(quiz['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(6)),
                child: const Text('FOCUS TOPIC',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/detail-basic-math'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: darkGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
                ),
                child: const Text('START QUIZ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ]),
          ])),
        ]),
      ]),
    );
  }

  Widget _buildBottomNavBar() {
    final items = [
      {'icon': Icons.home_outlined,      'activeIcon': Icons.home,      'label': 'Home'},
      {'icon': Icons.quiz_outlined,      'activeIcon': Icons.quiz,      'label': 'Quiz'},
      {'icon': Icons.bar_chart_outlined, 'activeIcon': Icons.bar_chart, 'label': 'Analytics'},
      {'icon': Icons.person_outline,     'activeIcon': Icons.person,    'label': 'Profile'},
    ];
    return Container(
      decoration: BoxDecoration(color: primaryGreen,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4))]),
      child: SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () {
                switch (index) {
                  case 1: Navigator.pushReplacementNamed(context, '/quiz'); break;
                  case 2: Navigator.pushReplacementNamed(context, '/analytics'); break;
                  case 3: Navigator.pushReplacementNamed(context, '/profile'); break;
                  default: setState(() => _selectedIndex = index);
                }
              },
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(isSelected ? items[index]['activeIcon'] as IconData : items[index]['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.white60, size: 26),
                const SizedBox(height: 4),
                Text(items[index]['label'] as String,
                    style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ]),
            );
          }),
        ),
      )),
    );
  }
}
