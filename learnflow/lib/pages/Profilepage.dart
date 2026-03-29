import 'package:flutter/material.dart';
import 'ContactUsPage.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color cardGreen = Color(0xFF81E3AB);
  static const Color bgColor = Color(0xFFF0FBF4);

  final List<Map<String, dynamic>> _stats = const [
    {'icon': Icons.bolt, 'value': '55', 'label': 'Quizzes'},
    {'icon': Icons.bar_chart, 'value': 'A', 'label': 'GARD'},
  ];

  final List<Map<String, dynamic>> _metrics = const [
    {'label': 'Average Total Score', 'value': 0.28},
    {'label': 'Time Spent',          'value': 0.35},
    {'label': 'Learning Streak',     'value': 0.40},
    {'label': 'Accuracy',            'value': 0.40},
  ];

  final List<Map<String, dynamic>> _settings = const [
    {'icon': Icons.edit_note_outlined,     'label': 'Edit profile information', 'value': ''},
    {'icon': Icons.notifications_outlined, 'label': 'Notifications',            'value': 'ON'},
    {'icon': Icons.translate_outlined,     'label': 'Language',                 'value': 'English'},
    {'icon': Icons.translate_outlined,     'label': 'Preferred Subjects',       'value': 'Computer'},
    {'icon': Icons.translate_outlined,     'label': 'Learning Mode',            'value': 'Normal'},
  ];

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
                  children: [
                    const SizedBox(height: 24),
                    _buildAvatar(),
                    const SizedBox(height: 12),
                    const Text(
                      'Puerto Rico',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "youremail@domain.com | bachelor's degree",
                      style: TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildMetricsCard(),
                    const SizedBox(height: 16),
                    _buildSettingsCard(context),
                    const SizedBox(height: 16),
                    _buildContactCard(context),
                    const SizedBox(height: 16),
                    _buildLogoutButton(context),
                    const SizedBox(height: 24),
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

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: cardGreen,
          child: const Icon(Icons.person, size: 44, color: primaryGreen),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: _stats.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 0 ? 10 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(s['icon'] as IconData,
                      color: primaryGreen, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['value'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        s['label'] as String,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black45),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: _metrics.map((m) {
          final value = m['value'] as double;
          final pct = (value * 100).toInt();
          Color barColor;
          if (pct >= 70) {
            barColor = primaryGreen;
          } else if (pct >= 50) {
            barColor = const Color(0xFFF0B429);
          } else {
            barColor = const Color(0xFFE74C3C);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      m['label'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$pct% Correct',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black45),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 7,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: _settings.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final isLast = i == _settings.length - 1;
          return Column(
            children: [
              ListTile(
                dense: true,
                leading: Icon(s['icon'] as IconData,
                    color: primaryGreen, size: 20),
                title: Text(
                  s['label'] as String,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                trailing: (s['value'] as String).isNotEmpty
                    ? Text(
                        s['value'] as String,
                        style: const TextStyle(
                            fontSize: 12, color: primaryGreen),
                      )
                    : null,
                onTap: () {},
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.chat_bubble_outline,
            color: primaryGreen, size: 20),
        title: const Text(
          'Contact us',
          style: TextStyle(fontSize: 13, color: Colors.black87),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ContactUsPage()),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B1C1C),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, '/', (r) => false),
        child: const Text(
          'LOGOUT',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final items = [
      {'icon': Icons.home_outlined,   'activeIcon': Icons.home,   'label': 'Home',      'route': '/home'},
      {'icon': Icons.quiz_outlined,   'activeIcon': Icons.quiz,   'label': 'Quiz',      'route': '/quiz'},
      {'icon': Icons.bar_chart_outlined,'activeIcon': Icons.bar_chart,'label': 'Analytics','route': '/analytics'},
      {'icon': Icons.person_outline,  'activeIcon': Icons.person, 'label': 'Profile',   'route': ''},
    ];
    return Container(
      color: const Color(0xFF1DBA78),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isSelected = i == 3;
              return GestureDetector(
                onTap: () {
                  final route = items[i]['route'] as String;
                  if (route.isNotEmpty) {
                    Navigator.pushReplacementNamed(context, route);
                  }
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
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
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