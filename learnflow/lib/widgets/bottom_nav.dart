// lib/widgets/bottom_nav.dart
// Widget กลางสำหรับ Bottom Navigation Bar
// ใช้แทนการ copy _buildBottomNavBar() ในทุกหน้า

import 'package:flutter/material.dart';

class LearnFlowBottomNav extends StatelessWidget {
  final int selectedIndex;

  const LearnFlowBottomNav({super.key, required this.selectedIndex});

  static const Color _green = Color(0xFF1DBA78);

  static const _items = [
    {'icon': Icons.home_outlined,      'active': Icons.home,      'label': 'Home',      'route': '/home'},
    {'icon': Icons.quiz_outlined,      'active': Icons.quiz,      'label': 'Quiz',      'route': '/quiz'},
    {'icon': Icons.bar_chart_outlined, 'active': Icons.bar_chart, 'label': 'Analytics', 'route': '/analytics'},
    {'icon': Icons.person_outline,     'active': Icons.person,    'label': 'Profile',   'route': '/profile'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _green,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final isSelected = selectedIndex == i;
              final item = _items[i];
              return GestureDetector(
                onTap: () {
                  if (isSelected) return;
                  Navigator.pushReplacementNamed(
                    context,
                    item['route'] as String,
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? item['active'] as IconData
                          : item['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.white60,
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontSize: 11,
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
