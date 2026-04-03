// lib/pages/QuizPage.dart  [UPDATED — เชื่อม API]

import 'package:flutter/material.dart';
import '../services/quiz_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _selectedIndex = 1;

  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color darkGreen    = Color(0xFF27AE60);
  static const Color cardGreen    = Color.fromARGB(255, 129, 227, 171);
  static const Color bgColor      = Color(0xFFF0FBF4);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _selectedSubjects     = {};
  Set<String> _selectedDifficulties = {};

  // ── API state ──────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _quizzes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final quizzes = await QuizService.getQuizzes();
      setState(() { _quizzes = quizzes; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Failed to load quizzes'; _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredQuizzes {
    return _quizzes.where((q) {
      final title    = (q['title'] ?? '').toString().toLowerCase();
      final subject  = (q['subject_name'] ?? '').toString().toUpperCase();
      final level    = (q['level'] ?? '').toString().toUpperCase();
      final matchSearch = _searchQuery.isEmpty || title.contains(_searchQuery.toLowerCase());
      final matchSubj   = _selectedSubjects.isEmpty || _selectedSubjects.contains(subject);
      final matchDiff   = _selectedDifficulties.isEmpty || _selectedDifficulties.contains(level);
      return matchSearch && matchSubj && matchDiff;
    }).toList();
  }

  bool get _hasActiveFilters => _selectedSubjects.isNotEmpty || _selectedDifficulties.isNotEmpty;

  IconData _subjectIcon(String subject) {
    switch (subject.toUpperCase()) {
      case 'MATHEMATICS': return Icons.calculate_outlined;
      case 'ENGLISH':     return Icons.menu_book_outlined;
      case 'SCIENCE':     return Icons.science_outlined;
      case 'PHYSICS':     return Icons.electric_bolt_outlined;
      case 'CHEMISTRY':   return Icons.biotech_outlined;
      default:            return Icons.quiz_outlined;
    }
  }

  void _showFilterBottomSheet() {
    Set<String> tempSubjects     = Set.from(_selectedSubjects);
    Set<String> tempDifficulties = Set.from(_selectedDifficulties);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.tune, color: primaryGreen, size: 22),
                const SizedBox(width: 8),
                const Text('FILTER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const Spacer(),
                if (tempSubjects.isNotEmpty || tempDifficulties.isNotEmpty)
                  GestureDetector(
                    onTap: () => setModalState(() { tempSubjects.clear(); tempDifficulties.clear(); }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade200)),
                      child: Text('Clear All', style: TextStyle(color: Colors.red.shade400, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ]),
              const SizedBox(height: 20),
              const Text('SUBJECT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              Wrap(spacing: 10, children: ['MATHEMATICS', 'ENGLISH', 'SCIENCE'].map((s) =>
                _buildFilterChip(label: s, icon: _subjectIcon(s),
                    isSelected: tempSubjects.contains(s),
                    onTap: () => setModalState(() => tempSubjects.contains(s) ? tempSubjects.remove(s) : tempSubjects.add(s)))
              ).toList()),
              const SizedBox(height: 20),
              const Text('DIFFICULTY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              Row(children: [
                _buildDifficultyChip(label: 'EASY', color: const Color(0xFF27AE60), bgColor: const Color(0xFFE8F8F0),
                    isSelected: tempDifficulties.contains('EASY'),
                    onTap: () => setModalState(() => tempDifficulties.contains('EASY') ? tempDifficulties.remove('EASY') : tempDifficulties.add('EASY'))),
                const SizedBox(width: 10),
                _buildDifficultyChip(label: 'HARD', color: const Color(0xFFE74C3C), bgColor: const Color(0xFFFDECEA),
                    isSelected: tempDifficulties.contains('HARD'),
                    onTap: () => setModalState(() => tempDifficulties.contains('HARD') ? tempDifficulties.remove('HARD') : tempDifficulties.add('HARD'))),
              ]),
              const SizedBox(height: 28),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: primaryGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('CANCEL', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: () {
                    setState(() { _selectedSubjects = Set.from(tempSubjects); _selectedDifficulties = Set.from(tempDifficulties); });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0),
                  child: const Text('APPLY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? primaryGreen : Colors.grey.shade300, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black54),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black54)),
        ]),
      ),
    );
  }

  Widget _buildDifficultyChip({required String label, required Color color, required Color bgColor, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? color : bgColor,
            borderRadius: BorderRadius.circular(30), border: Border.all(color: color, width: 1.5)),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : color)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredQuizzes;
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text('ALL QUIZ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    if (_hasActiveFilters) ...[
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          ..._selectedSubjects.map((s) => _buildActiveChip(s, () => setState(() => _selectedSubjects.remove(s)))),
                          ..._selectedDifficulties.map((d) => _buildActiveChip(d, () => setState(() => _selectedDifficulties.remove(d)))),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (!_isLoading && _error == null)
                      Text('${filtered.length} quiz found',
                          style: const TextStyle(fontSize: 13, color: Colors.black45, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Expanded(child: _buildBody(filtered)),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<Map<String, dynamic>> filtered) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: primaryGreen));
    if (_error != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.black26),
      const SizedBox(height: 12),
      Text(_error!, style: const TextStyle(color: Colors.black45)),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: _loadQuizzes, style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
          child: const Text('Retry', style: TextStyle(color: Colors.white))),
    ]));
    if (filtered.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.search_off_rounded, size: 60, color: primaryGreen.withOpacity(0.4)),
      const SizedBox(height: 12),
      const Text('No quiz found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black45)),
    ]));
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (ctx, i) => _buildQuizCard(filtered[i]),
    );
  }

  Widget _buildActiveChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGreen.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: darkGreen)),
        const SizedBox(width: 4),
        GestureDetector(onTap: onRemove, child: const Icon(Icons.close, size: 13, color: darkGreen)),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Row(children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(30)),
          child: Row(children: [
            const Icon(Icons.menu, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search quiz...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                cursorColor: Colors.white,
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(onTap: () { _searchController.clear(); setState(() => _searchQuery = ''); },
                  child: const Icon(Icons.close, color: Colors.white70, size: 18))
            else
              const Icon(Icons.search, color: Colors.white, size: 20),
          ]),
        ),
      ),
      const SizedBox(width: 12),
      GestureDetector(
        onTap: _showFilterBottomSheet,
        child: Row(children: [
          Stack(clipBehavior: Clip.none, children: [
            Icon(Icons.tune, color: _hasActiveFilters ? primaryGreen : Colors.black54, size: 20),
            if (_hasActiveFilters)
              Positioned(top: -3, right: -3,
                  child: Container(width: 8, height: 8,
                      decoration: const BoxDecoration(color: Color(0xFFE74C3C), shape: BoxShape.circle))),
          ]),
          const SizedBox(width: 4),
          Text('Filter', style: TextStyle(color: _hasActiveFilters ? primaryGreen : Colors.black54, fontSize: 14,
              fontWeight: _hasActiveFilters ? FontWeight.bold : FontWeight.w500)),
        ]),
      ),
    ]);
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    final subject = (quiz['subject_name'] ?? '').toString();
    final level   = (quiz['level'] ?? '').toString().toUpperCase();
    final isHard  = level == 'HARD';
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/detail-basic-math', arguments: quiz),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: cardGreen, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 56, height: 56,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
              child: Icon(_subjectIcon(subject), color: darkGreen, size: 28)),
            const Spacer(),
            Text('DIFFICULTY: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
            Text(level, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                color: isHard ? const Color(0xFFE74C3C) : const Color(0xFF27AE60))),
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(quiz['title'] ?? '',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(20)),
              child: const Text('FOCUS TOPIC',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
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
                  case 0: Navigator.pushReplacementNamed(context, '/home'); break;
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
