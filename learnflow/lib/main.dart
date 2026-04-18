/// lib/main.dart
/// App entry point — LearnFlow Flutter application
/// 
/// Setup:
/// - Firebase initialization
/// - Local storage (Hive) for offline quiz caching
/// - Notification service
/// - Multi-language support (Thai/English)
/// - Global locale state management

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/local_storage_service.dart';

import 'pages/SplashScreen.dart';
import 'pages/OnboardingScreen.dart';
import 'pages/LoginPage.dart';
import 'pages/RegisterPage.dart';
import 'pages/ForgotPasswordPage.dart';
import 'pages/HomePage.dart';
import 'pages/QuizPage.dart';
import 'pages/QuizDetailPage.dart';   
import 'pages/QuizPlayPage.dart';     
import 'pages/ResultPage.dart';
import 'pages/ReviewAnswerPage.dart';
import 'pages/Analyticspage.dart';
import 'pages/Profilepage.dart';
import 'pages/Reminderpage.dart';

/// ตั้งค่า app เริ่มต้น: Firebase, LocalStorage, Notifications
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase authentication + Firestore
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Local storage initialization
  await LocalStorageService.init();

  // Notification service
  await NotificationService.init();
  await NotificationService.requestPermission();

  runApp(const LearnFlowApp());
}

// ── Global locale state ────────────────────────────────────────────────────
class LearnFlowApp extends StatefulWidget {
  const LearnFlowApp({super.key});

  static final GlobalKey<_LearnFlowAppState> _appKey = GlobalKey<_LearnFlowAppState>();

  static Locale get currentLocale =>
      _appKey.currentState?._locale ?? const Locale('en');

  static void setLocale(BuildContext context, Locale locale) {
    _appKey.currentState?._changeLocale(locale);
  }

  @override
  State<LearnFlowApp> createState() => _LearnFlowAppState();
}

class _LearnFlowAppState extends State<LearnFlowApp> {
  Locale _locale = const Locale('en');

  /// เปลี่ยน locale ของทั้ง app (Thai/English)
  void _changeLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: LearnFlowApp._appKey,
      debugShowCheckedModeBanner: false,
      title: 'LearnFlow',
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('th'),
      ],
      initialRoute: '/splash',
      routes: {
        '/splash':          (context) => const SplashScreen(),
        '/onboarding':      (context) => const OnboardingScreen(),
        '/':                (context) => const LoginPage(),
        '/register':        (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home':            (context) => const HomePage(),
        '/quiz':            (context) => const QuizPage(),
        '/quiz-detail':     (context) => const QuizDetailPage(),   // เปลี่ยนจาก /detail-basic-math
        '/quiz-play':       (context) => const QuizPlayPage(),     // เปลี่ยนจาก /basic-math
        '/result':          (context) => const ResultPage(),
        '/review-answer': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final attemptId = args is int ? args : 0;
          return ReviewAnswerPage(attemptId: attemptId);
        },
        '/analytics':       (context) => const AnalyticsScreen(),
        '/profile':         (context) => const ProfilePage(),
        '/reminder':        (context) => const ReminderPage(),
      },
    );
  }
}
