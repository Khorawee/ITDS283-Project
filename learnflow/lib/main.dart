import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'pages/SplashScreen.dart';
import 'pages/OnboardingScreen.dart';
import 'pages/LoginPage.dart';
import 'pages/RegisterPage.dart';
import 'pages/ForgotPasswordPage.dart';
import 'pages/HomePage.dart';
import 'pages/QuizPage.dart';
import 'pages/DetailBasicMathPage.dart';
import 'pages/BasicMathPage.dart';
import 'pages/ResultPage.dart';
import 'pages/ReviewAnswerPage.dart';
import 'pages/Analyticspage.dart';
import 'pages/ProfilePage.dart';
import 'pages/ReminderPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LearnFlow',
      initialRoute: '/splash',
      routes: {
        '/splash':            (context) => const SplashScreen(),
        '/onboarding':        (context) => const OnboardingScreen(),
        '/':                  (context) => const LoginPage(),
        '/register':          (context) => const RegisterPage(),
        '/forgot-password':   (context) => const ForgotPasswordPage(),
        '/home':              (context) => const HomePage(),
        '/quiz':              (context) => const QuizPage(),
        '/detail-basic-math': (context) => const DetailBasicMathPage(),
        '/basic-math':        (context) => const BasicMathPage(),
        '/result':            (context) => const ResultPage(),
        '/review-answer':     (context) => const ReviewAnswerPage(),
        '/analytics':         (context) => AnalyticsScreen(),
        '/profile':           (context) => const ProfilePage(),
        '/reminder':          (context) => const ReminderPage(),
      },
    );
  }
}