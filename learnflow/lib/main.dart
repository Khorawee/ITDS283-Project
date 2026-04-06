// lib/main.dart  [UPDATED — Language switching + Notification init]

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

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
import 'pages/Profilepage.dart';
import 'pages/Reminderpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Notification service
  await NotificationService.init();
  await NotificationService.requestPermission();

  runApp(const LearnFlowApp());
}

// ── Global locale state ────────────────────────────────────────────────────
// เก็บ locale ปัจจุบันที่ระดับ app เพื่อให้ ProfilePage เรียกได้
class LearnFlowApp extends StatefulWidget {
  const LearnFlowApp({super.key});

  // static key สำหรับเรียก setLocale จากทุกหน้า
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
      // localizationsDelegates ถ้าใช้ flutter_localizations ให้เพิ่มตรงนี้
      // localizationsDelegates: AppLocalizations.localizationsDelegates,
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
        '/review-answer': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final attemptId = args is int ? args : 0;
          return ReviewAnswerPage(attemptId: attemptId);
          },
        '/analytics':         (context) => const AnalyticsScreen(),
        '/profile':           (context) => const ProfilePage(),
        '/reminder':          (context) => const ReminderPage(),
      },
    );
  }
}
