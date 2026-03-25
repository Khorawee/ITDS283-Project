import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/images/Img_Onboarding2.webp',
      'title': 'Personalized\nLearning Path',
      'subtitle':
          'LearnFlow creates a personalized learning path for you, '
          'adjusting difficulty and topics in real-time so you always '
          'study at the right level.',
    },
    {
      'image': 'assets/images/Img_Onboarding3.webp',
      'title': 'AI Learning\nAnalysis',
      'subtitle':
          'LearnFlow uses AI to analyze your learning behavior, '
          'identifying weak points and adapting content to improve '
          'your understanding efficiently.',
    },
    {
      'image': 'assets/images/Img_Onboarding.webp',
      'title': 'Learn Smarter\nNot Harder',
      'subtitle':
          'LearnFlow analyzes your strengths and weaknesses, '
          'then guides you to practice exactly what you need. '
          'Study smarter and track your progress every day.',
    },
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _buildSlide(_slides[index]);
            },
          ),

          // ปุ่ม back (หน้า 2 และ 3)
          if (_currentPage > 0)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),

          // ปุ่มด้านล่าง
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ปุ่ม NEXT หรือ GET START
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DBA78),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor:
                            const Color(0xFF1DBA78).withOpacity(0.4),
                      ),
                      onPressed: _nextPage,
                      child: Text(
                        isLastPage ? "GET START" : "NEXT",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ปุ่ม Skip
                  if (!isLastPage)
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(Map<String, String> slide) {
    return Stack(
      children: [
        // รูปพื้นหลัง
        Positioned.fill(
          child: Image.asset(
            slide['image']!,
            fit: BoxFit.cover,
          ),
        ),

        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.35, 0.65, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0x88000000),
                  Color(0xDD000000),
                ],
              ),
            ),
          ),
        ),

        // ข้อความ
        Positioned(
          bottom: 220,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slide['title']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                slide['subtitle']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}