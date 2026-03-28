import 'package:flutter/material.dart';
import 'dart:async';

class BasicMathPage extends StatefulWidget {
  const BasicMathPage({super.key});

  @override
  State<BasicMathPage> createState() => _BasicMathPageState();
}

class _BasicMathPageState extends State<BasicMathPage> {
  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color cardGreen = Color.fromARGB(255, 129, 227, 171);
  static const Color bgColor = Color(0xFFF0FBF4);

  int _currentQuestion = 0;
  int _remainingSeconds = 1 * 60; //ตั้งเวลาถอยหลัง
  late Timer _timer;

  late List<int?> _selectedAnswers;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'WHICH OF THE FOLLOWING IS A PRIME NUMBER?',
      'options': ['9', '11', '15', '21'],
    },
    {
      'question': 'WHAT IS 12 × 12?',
      'options': ['124', '144', '164', '184'],
    },
    {
      'question': 'WHAT IS THE SQUARE ROOT OF 81?',
      'options': ['7', '8', '9', '10'],
    },
    {
      'question': 'WHICH NUMBER IS DIVISIBLE BY 6?',
      'options': ['14', '21', '36', '44'],
    },
    {
      'question': 'WHAT IS 25% OF 200?',
      'options': ['25', '40', '50', '75'],
    },
    {
      'question': 'WHAT IS 7³ (7 CUBED)?',
      'options': ['343', '210', '147', '441'],
    },
    {
      'question': 'WHICH OF THE FOLLOWING IS AN ODD NUMBER?',
      'options': ['12', '24', '37', '50'],
    },
    {
      'question': 'WHAT IS 144 ÷ 12?',
      'options': ['10', '11', '12', '13'],
    },
    {
      'question': 'WHAT IS THE VALUE OF π (PI) APPROXIMATELY?',
      'options': ['3.14', '2.71', '1.41', '1.73'],
    },
    {
      'question': 'WHAT IS 15% OF 300?',
      'options': ['30', '40', '45', '60'],
    },
    {
      'question': 'WHICH FRACTION IS EQUIVALENT TO 0.5?',
      'options': ['1/4', '1/3', '1/2', '2/3'],
    },
    {
      'question': 'WHAT IS THE LEAST COMMON MULTIPLE OF 4 AND 6?',
      'options': ['8', '12', '16', '24'],
    },
    {
      'question': 'WHAT IS 2⁸ (2 TO THE POWER OF 8)?',
      'options': ['128', '256', '512', '64'],
    },
    {
      'question': 'WHICH OF THE FOLLOWING IS A COMPOSITE NUMBER?',
      'options': ['2', '7', '11', '15'],
    },
    {
      'question': 'WHAT IS THE GREATEST COMMON FACTOR OF 18 AND 24?',
      'options': ['3', '4', '6', '9'],
    },
    {
      'question': 'WHAT IS 0.75 AS A FRACTION?',
      'options': ['1/4', '1/2', '3/4', '2/3'],
    },
    {
      'question': 'WHAT IS THE PERIMETER OF A SQUARE WITH SIDE 7?',
      'options': ['14', '21', '28', '49'],
    },
    {
      'question': 'WHAT IS THE AREA OF A RECTANGLE 5 × 8?',
      'options': ['26', '35', '40', '45'],
    },
    {
      'question': 'WHICH OF THESE IS A PERFECT SQUARE?',
      'options': ['50', '72', '81', '90'],
    },
    {
      'question': 'WHAT IS THE MEAN OF 4, 8, 12, 16, 20?',
      'options': ['10', '12', '14', '16'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(_questions.length, null);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _showTimeUpDialog(); // ✅ เรียก dialog เมื่อหมดเวลา
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ไอคอน
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEEEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_off_outlined,
                  color: Color(0xFFE74C3C),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),

              // หัวข้อ
              const Text(
                "TIME'S UP!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE74C3C),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              // ข้อความ
              const Text(
                'The quiz time is up,\nand the system will show you your summary score.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // ปุ่มไปหน้าสรุปผล
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, '/result');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SUMMARY',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}.${seconds.toString().padLeft(2, '0')}';
  }

  void _goNext() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    }
  }

  void _goPrevious() {
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
    }
  }

  void _finish() {
    Navigator.pushReplacementNamed(context, '/result');
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final isFirst = _currentQuestion == 0;
    final isLast = _currentQuestion == _questions.length - 1;
    final progress = (_currentQuestion + 1) / _questions.length;
    final currentSelected = _selectedAnswers[_currentQuestion];

    // เปลี่ยนสี timer เป็นแดงเมื่อเหลือน้อยกว่า 5 นาที
    final isLowTime = _remainingSeconds <= 5 * 60;

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

                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    const Center(
                      child: Text(
                        'BASIC MATH REVIEW',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Progress row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'QUESTIONS ${_currentQuestion + 1} / ${_questions.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                            letterSpacing: 0.5,
                          ),
                        ),
                        // Timer เปลี่ยนสีแดงเมื่อเหลือน้อย
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: isLowTime
                                  ? const Color(0xFFE74C3C)
                                  : Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formattedTime,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isLowTime
                                    ? const Color(0xFFE74C3C)
                                    : Colors.black87,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Progress bar
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 300),
                          widthFactor: progress,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: primaryGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Question card
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 100),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          question['question'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Answer options
                    ...List.generate((question['options'] as List).length, (i) {
                      final isSelected = currentSelected == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedAnswers[_currentQuestion] = i;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryGreen : cardGreen,
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(color: primaryGreen, width: 2)
                                  : null,
                            ),
                            child: Text(
                              '${i + 1}. ${question['options'][i]}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  if (!isFirst) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _goPrevious,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryGreen,
                          side: const BorderSide(color: primaryGreen, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'PREVIOUS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLast ? _finish : _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isLast ? 'FINISH' : 'NEXT',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}