/// lib/pages/Profilepage.dart
/// หน้าแสดงผล Profile ของ User
/// 
/// Features:
/// - Display user profile info + quiz stats
/// - Edit profile dialog with validation
/// - Settings: notifications, language, learning mode
/// - Refresh on app resume (WidgetsBindingObserver)
/// - Logout functionality

import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/notification_service.dart';
import '../services/profile_service.dart';
import '../main.dart' show LearnFlowApp;
import '../widgets/bottom_nav.dart';
import 'ContactUsPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color cardGreen    = Color(0xFF81E3AB);
  static const Color bgColor      = Color(0xFFF0FBF4);

  // FIX: เริ่มต้นเป็น false แล้วค่อย load state จริงจาก pending notifications
  bool   _notifications    = false;
  String _preferredSubject = 'Mathematics';
  String _learningMode     = 'Normal';

  Map<String, dynamic> _profile = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
    _loadNotificationState(); // FIX: โหลด notification state จริงตอน init

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadProfile();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadProfile();
      _loadNotificationState(); // FIX: refresh notification state เมื่อกลับมาที่แอป
    }
  }

  // FIX: เช็ค pending notifications จริงเพื่อ sync state ของ Switch
  Future<void> _loadNotificationState() async {
    try {
      final count = await NotificationService.getPendingCount();
      if (mounted) setState(() => _notifications = count > 0);
    } catch (_) {}
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ProfileService.getProfile();
      dev.log('[Profile] API response: $data', name: 'ProfilePage');
      if (mounted) {
        setState(() { _profile = data; _isLoading = false; });
      }
    } catch (e) {
      dev.log('[Profile] ERROR loading profile: $e', name: 'ProfilePage');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String get _displayName {
    final first = _profile['first_name'] ?? '';
    final last  = _profile['last_name']  ?? '';
    if (first.isNotEmpty) return '$first $last'.trim();
    return FirebaseAuth.instance.currentUser?.displayName ?? 'User';
  }

  String get _email => _profile['email'] ?? FirebaseAuth.instance.currentUser?.email ?? 'N/A';

  String get _totalQuizzes {
    final val = _profile['total_quizzes'];
    if (val == null) return '0';
    return val.toString();
  }

  String get _grade => _profile['grade'] ?? '-';

  double get _avgScore {
    final val = _profile['avg_score'];
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  Locale get _currentLocale => LearnFlowApp.currentLocale;
  String get _languageLabel =>
      _currentLocale.languageCode == 'th' ? 'ภาษาไทย' : 'English';

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_currentLocale.languageCode == 'th' ? 'ภาษา' : 'Language',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: _currentLocale.languageCode,
            activeColor: primaryGreen,
            onChanged: (_) {
              LearnFlowApp.setLocale(context, const Locale('en'));
              setState(() {});
              Navigator.pop(context);
            },
          ),
          RadioListTile<String>(
            title: const Text('ภาษาไทย'),
            value: 'th',
            groupValue: _currentLocale.languageCode,
            activeColor: primaryGreen,
            onChanged: (_) {
              LearnFlowApp.setLocale(context, const Locale('th'));
              setState(() {});
              Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }

  void _showEditProfileDialog() {
    final firstCtrl = TextEditingController(text: _profile['first_name'] ?? '');
    final lastCtrl  = TextEditingController(text: _profile['last_name']  ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: firstCtrl,
            decoration: InputDecoration(
              labelText: 'First name',
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primaryGreen)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: lastCtrl,
            decoration: InputDecoration(
              labelText: 'Last name',
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primaryGreen)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              final first = firstCtrl.text.trim();
              final last = lastCtrl.text.trim();

              if (first.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('First name is required'),
                    backgroundColor: Color(0xFFE74C3C),
                  ),
                );
                return;
              }

              if (first.length > 100 || last.length > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Names must be 100 characters or less'),
                    backgroundColor: Color(0xFFE74C3C),
                  ),
                );
                return;
              }

              setState(() {
                _profile['first_name'] = firstCtrl.text.trim();
                _profile['last_name']  = lastCtrl.text.trim();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('อัปเดตข้อมูลแล้ว'),
                    backgroundColor: primaryGreen),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen, elevation: 0),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // FIX: toggle notification พร้อม verify ว่า schedule สำเร็จจริง
  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notifications = value);
    if (value) {
      await NotificationService.requestPermission();
      await NotificationService.scheduleDailyReminder();

      // FIX: ตรวจสอบว่า schedule สำเร็จจริงหรือเปล่า
      final count = await NotificationService.getPendingCount();
      final success = count > 0;
      if (mounted) setState(() => _notifications = success);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? 'เปิดการแจ้งเตือนแล้ว (09:00 ทุกวัน)'
              : 'ไม่สามารถตั้งการแจ้งเตือนได้ กรุณาอนุญาตใน Settings'),
          backgroundColor: success ? primaryGreen : Colors.red,
        ));
      }
    } else {
      await NotificationService.cancelAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ปิดการแจ้งเตือนแล้ว')));
      }
    }
  }

  void _showSubjectDialog() {
    _showRadioDialog('Preferred subjects',
        ['Mathematics', 'English', 'Social Studies', 'Programming'],
        _preferredSubject,
        (val) => setState(() => _preferredSubject = val));
  }

  void _showLearningModeDialog() {
    _showRadioDialog('Learning mode',
        ['Normal', 'Intensive', 'Relaxed'],
        _learningMode,
        (val) => setState(() => _learningMode = val));
  }

  void _showRadioDialog(String title, List<String> options, String current,
      ValueChanged<String> onChanged) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((opt) => RadioListTile<String>(
                    title: Text(opt),
                    value: opt,
                    groupValue: current,
                    activeColor: primaryGreen,
                    onChanged: (val) {
                      onChanged(val!);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  // FIX: logout ต้อง signOut Google Sign-In ด้วย
  Future<void> _logout() async {
    try { await NotificationService.cancelAll(); } catch (_) {}
    try { await GoogleSignIn().signOut(); } catch (_) {}
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProfile,
              color: primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  const SizedBox(height: 24),
                  _buildAvatar(),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const CircularProgressIndicator(color: primaryGreen)
                      : Column(children: [
                          Text(_displayName,
                              style: const TextStyle(fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(_email,
                              style: const TextStyle(fontSize: 11,
                                  color: Colors.black45)),
                        ]),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                  _buildMetricsCard(),
                  const SizedBox(height: 16),
                  _buildSettingsCard(),
                  const SizedBox(height: 16),
                  _buildContactCard(),
                  const SizedBox(height: 16),
                  _buildLogoutButton(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ),
          const LearnFlowBottomNav(selectedIndex: 3),
        ]),
      ),
    );
  }

  Widget _buildAvatar() {
    final initial =
        _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U';
    return Stack(children: [
      CircleAvatar(
        radius: 44,
        backgroundColor: cardGreen,
        child: Text(initial,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold,
                color: primaryGreen)),
      ),
      Positioned(
        bottom: 0, right: 0,
        child: GestureDetector(
          onTap: _showEditProfileDialog,
          child: Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
                color: Colors.black87, shape: BoxShape.circle),
            child: const Icon(Icons.edit, color: Colors.white, size: 14),
          ),
        ),
      ),
    ]);
  }

  Widget _buildStatsRow() {
    final stats = [
      {'icon': Icons.bolt,      'value': _totalQuizzes, 'label': 'Quizzes'},
      {'icon': Icons.bar_chart, 'value': _grade,        'label': 'GRADE'},
    ];
    return Row(
      children: stats.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 0 ? 10 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Icon(s['icon'] as IconData, color: primaryGreen, size: 20),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['value'] as String,
                      style: const TextStyle(fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  Text(s['label'] as String,
                      style: const TextStyle(fontSize: 11,
                          color: Colors.black45)),
                ]),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsCard() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: CircularProgressIndicator(color: primaryGreen, strokeWidth: 2),
          ),
        ),
      );
    }

    final totalQuizzesInt = int.tryParse(_totalQuizzes) ?? 0;
    final avgValue = (_avgScore / 100).clamp(0.0, 1.0);
    final quizValue = (totalQuizzesInt / 20).clamp(0.0, 1.0);

    Color barColor(double v) {
      final pct = (v * 100).toInt();
      if (pct >= 70) return primaryGreen;
      if (pct >= 50) return const Color(0xFFF0B429);
      return const Color(0xFFE74C3C);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        _metricRow(
          label: 'Average total score',
          trailing: '${_avgScore.toStringAsFixed(1)}%',
          value: avgValue,
          color: barColor(avgValue),
        ),
        const SizedBox(height: 14),
        _metricRow(
          label: 'Quizzes completed',
          trailing: '$totalQuizzesInt quiz',
          value: quizValue,
          color: barColor(quizValue),
        ),
      ]),
    );
  }

  Widget _metricRow({
    required String label,
    required String trailing,
    required double value,
    required Color color,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold,
                color: Colors.black87)),
        Text(trailing,
            style: const TextStyle(fontSize: 11, color: Colors.black45)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 7,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    ]);
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        ListTile(
          dense: true,
          leading: const Icon(Icons.edit_note_outlined,
              color: primaryGreen, size: 20),
          title: const Text('Edit profile information',
              style: TextStyle(fontSize: 13, color: Colors.black87)),
          trailing: const Icon(Icons.chevron_right,
              color: Colors.black38, size: 18),
          onTap: _showEditProfileDialog,
        ),
        _divider(),
        ListTile(
          dense: true,
          leading: const Icon(Icons.notifications_outlined,
              color: primaryGreen, size: 20),
          title: const Text('Notifications',
              style: TextStyle(fontSize: 13, color: Colors.black87)),
          trailing: Switch(
              value: _notifications,
              onChanged: _toggleNotifications,
              activeColor: primaryGreen),
        ),
        _divider(),
        ListTile(
          dense: true,
          leading: const Icon(Icons.language_outlined,
              color: primaryGreen, size: 20),
          title: const Text('Language',
              style: TextStyle(fontSize: 13, color: Colors.black87)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(_languageLabel,
                style: const TextStyle(fontSize: 12, color: primaryGreen)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 18),
          ]),
          onTap: _showLanguageDialog,
        ),
        _divider(),
        ListTile(
          dense: true,
          leading: const Icon(Icons.school_outlined,
              color: primaryGreen, size: 20),
          title: const Text('Preferred subjects',
              style: TextStyle(fontSize: 13, color: Colors.black87)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(_preferredSubject,
                style: const TextStyle(fontSize: 12, color: primaryGreen)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 18),
          ]),
          onTap: _showSubjectDialog,
        ),
        _divider(),
        ListTile(
          dense: true,
          leading: const Icon(Icons.psychology_outlined,
              color: primaryGreen, size: 20),
          title: const Text('Learning mode',
              style: TextStyle(fontSize: 13, color: Colors.black87)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(_learningMode,
                style: const TextStyle(fontSize: 12, color: primaryGreen)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 18),
          ]),
          onTap: _showLearningModeDialog,
        ),
      ]),
    );
  }

  Widget _divider() => Divider(
      height: 1,
      color: Colors.grey.shade200,
      indent: 16,
      endIndent: 16);

  Widget _buildContactCard() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.chat_bubble_outline,
            color: primaryGreen, size: 20),
        title: const Text('Contact us',
            style: TextStyle(fontSize: 13, color: Colors.black87)),
        trailing: const Icon(Icons.chevron_right,
            color: Colors.black38, size: 18),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ContactUsPage())),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B1C1C),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: _logout,
        child: const Text('LOGOUT',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                color: Colors.white, letterSpacing: 1.2)),
      ),
    );
  }
}