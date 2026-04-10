// lib/pages/Reminderpage.dart  [FIXED]
// แก้: ดึง pending notifications จริงจาก NotificationService
// แก้: ใช้ LearnFlowBottomNav กลาง

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart';
import '../widgets/bottom_nav.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});
  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color cardGreen    = Color(0xFF81E3AB);

  List<PendingNotificationRequest> _pending = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      final list   = await plugin.pendingNotificationRequests();
      setState(() { _pending = list; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelOne(int id) async {
    await NotificationService.cancel(id);
    await _loadPending();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยกเลิกการแจ้งเตือนแล้ว')),
      );
    }
  }

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
          'REMINDER',
          style: TextStyle(color: primaryGreen, fontSize: 18,
              fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        centerTitle: true,
        actions: [
          if (_pending.isNotEmpty)
            TextButton(
              onPressed: () async {
                await NotificationService.cancelAll();
                _loadPending();
              },
              child: const Text('Clear all',
                  style: TextStyle(color: Colors.red, fontSize: 13)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : _pending.isEmpty
              ? _buildEmpty()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  itemCount: _pending.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _buildCard(_pending[i]),
                ),
      bottomNavigationBar: const LearnFlowBottomNav(selectedIndex: 0),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.notifications_off_outlined,
            size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text('ไม่มีการแจ้งเตือนที่ตั้งไว้',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                color: Colors.black45)),
        const SizedBox(height: 8),
        const Text('เปิดการแจ้งเตือนได้ที่ Profile → Notifications',
            style: TextStyle(fontSize: 13, color: Colors.black38),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/profile'),
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              elevation: 0),
          child: const Text('ไปที่ Profile',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _buildCard(PendingNotificationRequest req) {
    final title = req.title ?? 'Reminder';
    final body  = req.body  ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardGreen, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle),
          child: const Icon(Icons.notifications_outlined,
              color: primaryGreen, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(body,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 18, color: Colors.black45),
          onPressed: () => _cancelOne(req.id),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ]),
    );
  }
}
