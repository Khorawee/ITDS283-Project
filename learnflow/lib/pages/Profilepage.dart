// lib/pages/Profilepage.dart  [FIXED — Language switching จริง + Notification จริง]

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
import '../services/profile_service.dart';
import '../main.dart' show LearnFlowApp;
import 'ContactUsPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color cardGreen    = Color(0xFF81E3AB);
  static const Color bgColor      = Color(0xFFF0FBF4);

  bool   _notifications    = true;
  String _preferredSubject = 'Computer';
  String _learningMode     = 'Normal';

  Map<String, dynamic> _profile = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await ProfileService.getProfile();
      setState(() { _profile = data; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String get _displayName {
    final first = _profile['first_name'] ?? '';
    final last  = _profile['last_name']  ?? '';
    if (first.isNotEmpty) return '$first $last'.trim();
    return FirebaseAuth.instance.currentUser?.displayName ?? 'User';
  }

  String get _email    => _profile['email'] ?? FirebaseAuth.instance.currentUser?.email ?? 'N/A';
  String get _totalQ   => '${_profile['total_quizzes'] ?? 0}';
  String get _grade    => _profile['grade'] ?? '-';
  double get _avgScore => ((_profile['avg_score'] ?? 0) as num).toDouble();

  // ── Language ────────────────────────────────────────────────────────────────
  // อ่านภาษาปัจจุบันจาก global state ใน main.dart
  Locale get _currentLocale => LearnFlowApp.currentLocale;

  String get _languageLabel =>
      _currentLocale.languageCode == 'th' ? 'ภาษาไทย' : 'English';

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          _currentLocale.languageCode == 'th' ? 'ภาษา' : 'Language',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _currentLocale.languageCode,
              activeColor: primaryGreen,
              onChanged: (val) {
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
              onChanged: (val) {
                LearnFlowApp.setLocale(context, const Locale('th'));
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Notifications toggle ────────────────────────────────────────────────────
  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notifications = value);
    if (value) {
      // เปิดการแจ้งเตือน — request permission อีกครั้ง
      await NotificationService.requestPermission();
      await NotificationService.scheduleDailyReminder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เปิดการแจ้งเตือนแล้ว'),
            backgroundColor: Color(0xFF1DBA78),
          ),
        );
      }
    } else {
      // ปิดการแจ้งเตือน — cancel ทั้งหมด
      await NotificationService.cancelAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ปิดการแจ้งเตือนแล้ว')),
        );
      }
    }
  }

  void _showSubjectDialog() {
    _showRadioDialog(
      'Preferred Subjects',
      ['Computer', 'Math', 'English', 'Science', 'Physics'],
      _preferredSubject,
      (val) => setState(() => _preferredSubject = val),
    );
  }

  void _showLearningModeDialog() {
    _showRadioDialog(
      'Learning Mode',
      ['Normal', 'Intensive', 'Relaxed'],
      _learningMode,
      (val) => setState(() => _learningMode = val),
    );
  }

  void _showRadioDialog(String title, List<String> options, String current, ValueChanged<String> onChanged) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => RadioListTile<String>(
            title: Text(opt),
            value: opt,
            groupValue: current,
            activeColor: primaryGreen,
            onChanged: (val) { onChanged(val!); Navigator.pop(context); },
          )).toList(),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await NotificationService.cancelAll();
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
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
                          Text(_displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(_email, style: const TextStyle(fontSize: 11, color: Colors.black45)),
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
          _buildBottomNavBar(),
        ]),
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U';
    return Stack(children: [
      CircleAvatar(radius: 44, backgroundColor: cardGreen,
          child: Text(initial, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryGreen))),
      Positioned(bottom: 0, right: 0,
          child: Container(width: 28, height: 28,
            decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
            child: const Icon(Icons.edit, color: Colors.white, size: 14))),
    ]);
  }

  Widget _buildStatsRow() {
    final stats = [
      {'icon': Icons.bolt,      'value': _totalQ, 'label': 'Quizzes'},
      {'icon': Icons.bar_chart, 'value': _grade,  'label': 'GRADE'},
    ];
    return Row(children: stats.asMap().entries.map((e) {
      final i = e.key; final s = e.value;
      return Expanded(child: Padding(
        padding: EdgeInsets.only(right: i == 0 ? 10 : 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Icon(s['icon'] as IconData, color: primaryGreen, size: 20),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s['value'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(s['label'] as String, style: const TextStyle(fontSize: 11, color: Colors.black45)),
            ]),
          ]),
        ),
      ));
    }).toList());
  }

  Widget _buildMetricsCard() {
    final metrics = [
      {'label': 'Average Total Score', 'value': (_avgScore / 100).clamp(0.0, 1.0)},
      {'label': 'Quizzes Completed',   'value': (int.parse(_totalQ) / 100).clamp(0.0, 1.0)},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: metrics.map((m) {
        final value = (m['value'] as double);
        final pct   = (value * 100).toInt();
        final barColor = pct >= 70 ? primaryGreen : pct >= 50 ? const Color(0xFFF0B429) : const Color(0xFFE74C3C);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(m['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text('$pct%', style: const TextStyle(fontSize: 11, color: Colors.black45)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: value, minHeight: 7,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor))),
          ]),
        );
      }).toList()),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        ListTile(dense: true,
          leading: const Icon(Icons.edit_note_outlined, color: primaryGreen, size: 20),
          title: const Text('Edit profile information', style: TextStyle(fontSize: 13, color: Colors.black87)),
          trailing: const Icon(Icons.chevron_right, color: Colors.black38, size: 18),
          onTap: () {},
        ),
        _divider(),

        // ── Notifications (จริง) ──────────────────────────────────────────
        ListTile(dense: true,
          leading: const Icon(Icons.notifications_outlined, color: primaryGreen, size: 20),
          title: const Text('Notifications', style: TextStyle(fontSize: 13, color: Colors.black87)),
          trailing: Switch(
            value: _notifications,
            onChanged: _toggleNotifications,
            activeColor: primaryGreen,
          ),
        ),
        _divider(),

        // ── Language (เปลี่ยนจริง) ────────────────────────────────────────
        ListTile(dense: true,
          leading: const Icon(Icons.language_outlined, color: primaryGreen, size: 20),
          title: const Text('Language', style: TextStyle(fontSize: 13, color: Colors.black87)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(_languageLabel, style: const TextStyle(fontSize: 12, color: primaryGreen)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 18),
          ]),
          onTap: _showLanguageDialog,
        ),
        _divider(),

        ListTile(dense: true,
          leading: const Icon(Icons.school_outlined, color: primaryGreen, size: 20),
          title: const Text('Preferred Subjects', style: TextStyle(fontSize: 13, color: Colors.black87)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(_preferredSubject, style: const TextStyle(fontSize: 12, color: primaryGreen)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 18),
          ]),
          onTap: _showSubjectDialog,
        ),
        _divider(),

        ListTile(dense: true,
          leading: const Icon(Icons.psychology_outlined, color: primaryGreen, size: 20),
          title: const Text('Learning Mode', style: TextStyle(fontSize: 13, color: Colors.black87)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(_learningMode, style: const TextStyle(fontSize: 12, color: primaryGreen)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 18),
          ]),
          onTap: _showLearningModeDialog,
        ),
      ]),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200, indent: 16, endIndent: 16);

  Widget _buildContactCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(dense: true,
        leading: const Icon(Icons.chat_bubble_outline, color: primaryGreen, size: 20),
        title: const Text('Contact us', style: TextStyle(fontSize: 13, color: Colors.black87)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black38, size: 18),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsPage())),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: _logout,
        child: const Text('LOGOUT',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final items = [
      {'icon': Icons.home_outlined,      'activeIcon': Icons.home,      'label': 'Home',      'route': '/home'},
      {'icon': Icons.quiz_outlined,      'activeIcon': Icons.quiz,      'label': 'Quiz',      'route': '/quiz'},
      {'icon': Icons.bar_chart_outlined, 'activeIcon': Icons.bar_chart, 'label': 'Analytics', 'route': '/analytics'},
      {'icon': Icons.person_outline,     'activeIcon': Icons.person,    'label': 'Profile',   'route': ''},
    ];
    return Container(color: primaryGreen, child: SafeArea(top: false, child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = i == 3;
          return GestureDetector(
            onTap: () {
              final route = items[i]['route'] as String;
              if (route.isNotEmpty) Navigator.pushReplacementNamed(context, route);
            },
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(isSelected ? items[i]['activeIcon'] as IconData : items[i]['icon'] as IconData,
                  color: isSelected ? Colors.white : Colors.white60, size: 24),
              const SizedBox(height: 3),
              Text(items[i]['label'] as String,
                  style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ]),
          );
        }),
      ),
    )));
  }
}
