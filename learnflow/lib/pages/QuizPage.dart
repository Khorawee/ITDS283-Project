import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _selectedIndex = 1;

  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color darkGreen = Color(0xFF27AE60);
  static const Color cardGreen = Color.fromARGB(255, 129, 227, 171);
  static const Color bgColor = Color(0xFFF0FBF4);

  final List<Map<String, dynamic>> _quizzes = [
    {
      'title': 'BASIC MATH REVIEW',
      'difficulty': 'EASY',
      'icon': Icons.calculate_outlined,
    },
    {
      'title': 'REVIEW ADVANCED MATH',
      'difficulty': 'HARD',
      'icon': Icons.functions_outlined,
    },
    {
      'title': 'REVIEW BASIC ENGLISH',
      'difficulty': 'EASY',
      'icon': Icons.menu_book_outlined,
    },
    {
      'title': 'REVIEW ADVANCED ENGLISH',
      'difficulty': 'HARD',
      'icon': Icons.menu_book_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'ALL QUIZ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _quizzes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) =>
                            _buildQuizCard(_quizzes[index]),
                      ),
                    ),
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

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hinted search text',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(Icons.search, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: const [
            Icon(Icons.tune, color: Colors.black54, size: 20),
            SizedBox(width: 4),
            Text(
              'Filter',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    final bool isHard = quiz['difficulty'] == 'HARD';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail-basic-math', arguments: quiz);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(quiz['icon'], color: darkGreen, size: 28),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text(
                      'DIFFICULTY: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      quiz['difficulty'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isHard
                            ? const Color(0xFFE74C3C)
                            : const Color(0xFF27AE60),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quiz['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'FOCUS TOPIC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {'icon': Icons.quiz_outlined, 'activeIcon': Icons.quiz, 'label': 'Quiz'},
      {
        'icon': Icons.bar_chart_outlined,
        'activeIcon': Icons.bar_chart,
        'label': 'Analytics'
      },
      {
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
        'label': 'Profile'
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: primaryGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    setState(() => _selectedIndex = index);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? items[index]['activeIcon'] as IconData
                          : items[index]['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.white60,
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}