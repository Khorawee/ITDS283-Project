import 'package:flutter/material.dart';

class DetailBasicMathPage extends StatelessWidget {
  const DetailBasicMathPage({super.key});

  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color darkGreen = Color.fromARGB(255, 35, 146, 81);
  static const Color bgColor = Color(0xFFF0FBF4);
  static const Color cardGreen = Color.fromARGB(255, 129, 227, 171);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildBackButton(context),
                    const SizedBox(height: 16),
                    _buildTitle(),
                    const SizedBox(height: 20),
                    _buildLogo(),
                    const SizedBox(height: 24),
                    _buildQuizDetailsSection(),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 20),
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

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text(
        'BASIC MATH REVIEW',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: primaryGreen,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: const Icon(Icons.image_outlined, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildQuizDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUIZ DETAILS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow('SUBJECT :', 'MATHEMATICAL'),
        const SizedBox(height: 8),
        _buildDetailRow('QUESTIONS :', '20'),
        const SizedBox(height: 8),
        _buildDetailRow('TIME LIMIT :', '45 MINS'),
        const SizedBox(height: 8),
        _buildDetailRow('DIFFICULTY :', 'EASY'),
        const SizedBox(height: 8),
        _buildDetailRow('BEST SCORE :', '85%'),
        const SizedBox(height: 8),
        _buildExamContentBox(),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamContentBox() {
    return Container(
      width: double.infinity,
      height: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Align(
        alignment: Alignment.topLeft,
        child: Text(
          'EXAM CONTENT :',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/basic-math');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Text(
              'START QUIZ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryGreen,
              side: const BorderSide(color: primaryGreen, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'RETAKE',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    const int selectedIndex = 1;

    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {'icon': Icons.quiz_outlined, 'activeIcon': Icons.quiz, 'label': 'Quiz'},
      {
        'icon': Icons.bar_chart_outlined,
        'activeIcon': Icons.bar_chart,
        'label': 'Analytics',
      },
      {
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
        'label': 'Profile',
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
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else if (index == 1) {
                    Navigator.pushReplacementNamed(context, '/quiz');
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
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
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