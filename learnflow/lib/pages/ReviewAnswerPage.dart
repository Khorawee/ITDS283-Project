import 'package:flutter/material.dart';

class ReviewAnswerPage extends StatelessWidget {
  const ReviewAnswerPage({super.key});

  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color cardGreen = Color(0xFF81E3AB);
  static const Color wrongRed = Color(0xFFE74C3C);
  static const Color darkText = Color(0xFF085041);

  static final List<Map<String, dynamic>> _questions = [
    {
      'index': 1,
      'question': 'WHICH OF THE FOLLOWING IS A PRIME NUMBER?',
      'choices': ['9', '11', '15', '21'],
      'correctIndex': 1,
      'selectedIndex': 0,
      'explanation':
          '11 is a prime number because it can only be divided evenly by 1 and 11. '
          'The others are not prime because they have more factors.',
    },
    {
      'index': 2,
      'question': 'WHAT IS THE VALUE OF √144?',
      'choices': ['10', '11', '12', '13'],
      'correctIndex': 2,
      'selectedIndex': 2,
      'explanation': '12 × 12 = 144, so √144 = 12.',
    },
    {
      'index': 3,
      'question': 'WHICH PROPERTY STATES THAT a + b = b + a?',
      'choices': ['Associative', 'Distributive', 'Commutative', 'Identity'],
      'correctIndex': 2,
      'selectedIndex': 1,
      'explanation':
          'The Commutative Property states that the order of addition or '
          'multiplication does not change the result.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Review Answer',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              itemCount: _questions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (_, i) => _buildQuestionCard(_questions[i]),
            ),
          ),
          _buildBottomButton(context),
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> q) {
    final int correct  = q['correctIndex']  as int;
    final int selected = q['selectedIndex'] as int;
    final List<String> choices = List<String>.from(q['choices'] as List);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Q${q['index']} : ${q['question']}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: darkText,
              height: 1.45,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Choices 2x2
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3.2,
          children: List.generate(choices.length, (i) {
            Color bg = primaryGreen;
            if (i == selected && selected != correct) bg = wrongRed;
            return Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '${i + 1}. ${choices[i]}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        // Explanation box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: cardGreen, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explanation :',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                q['explanation'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, '/home', (r) => false,
          ),
          child: const Text(
            'BACK TO DASHBOARD',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
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
      color: primaryGreen,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isSelected = i == 2;
              return GestureDetector(
                onTap: () {
                  if (i == 0) Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
                  if (i == 1) Navigator.pushNamedAndRemoveUntil(context, '/quiz', (r) => false);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? items[i]['activeIcon'] as IconData
                          : items[i]['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.white60,
                      size: 24,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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