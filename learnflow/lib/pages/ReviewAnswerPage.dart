// lib/pages/ReviewAnswerPage.dart  [UPDATED — เชื่อม API]

import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/result_service.dart';

class ReviewAnswerPage extends StatefulWidget {
  final int attemptId;
  const ReviewAnswerPage({super.key, required this.attemptId});

  @override
  State<ReviewAnswerPage> createState() => _ReviewAnswerPageState();
}

class _ReviewAnswerPageState extends State<ReviewAnswerPage> {
  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color cardGreen    = Color(0xFF81E3AB);
  static const Color wrongRed     = Color(0xFFE74C3C);
  static const Color darkText     = Color(0xFF085041);

  List<Map<String, dynamic>> _answers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    try {
      final data = await ResultService.getReview(widget.attemptId);
      setState(() { _answers = data; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _parseChoices(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return List<Map<String, dynamic>>.from(raw);
    // MySQL JSON_ARRAYAGG returns string when fetched via pymysql
    try {
      final decoded = jsonDecode(raw.toString());
      return List<Map<String, dynamic>>.from(decoded);
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Review Answer',
            style: TextStyle(color: primaryGreen, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : Column(children: [
              Expanded(child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                itemCount: _answers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (_, i) => _buildQuestionCard(_answers[i], i + 1),
              )),
              _buildBottomButton(context),
              _buildBottomNavBar(context),
            ]),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> a, int index) {
    final choices       = _parseChoices(a['choices']);
    final correct       = a['correct_choice'] ?? '';
    final selected      = a['selected_choice'] ?? '';
    final explanation   = a['explanation'] ?? '';
    final questionText  = a['question_text'] ?? '';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Question
      Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cardGreen, borderRadius: BorderRadius.circular(14)),
        child: Text('Q$index : $questionText',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText, height: 1.45)),
      ),
      const SizedBox(height: 12),
      // Choices 2×2
      GridView.count(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 3.2,
        children: choices.map((c) {
          final label = c['label'] ?? '';
          final text  = c['text'] ?? '';
          Color bg = primaryGreen;
          if (label == selected && selected != correct) bg = wrongRed;
          return Container(
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text('$label. $text', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
      const SizedBox(height: 12),
      // Explanation
      Container(
        width: double.infinity, padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white,
            border: Border.all(color: cardGreen, width: 1.5), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Explanation :', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 6),
          Text(explanation, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.55)),
        ]),
      ),
    ]);
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: SizedBox(width: double.infinity, child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
        onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
        child: const Text('BACK TO DASHBOARD',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
      )),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final items = [
      {'icon': Icons.home_outlined,      'activeIcon': Icons.home,      'label': 'Home'},
      {'icon': Icons.quiz_outlined,      'activeIcon': Icons.quiz,      'label': 'Quiz'},
      {'icon': Icons.bar_chart_outlined, 'activeIcon': Icons.bar_chart, 'label': 'Analytics'},
      {'icon': Icons.person_outline,     'activeIcon': Icons.person,    'label': 'Profile'},
    ];
    return Container(color: primaryGreen, child: SafeArea(top: false, child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = i == 1;
          return GestureDetector(
            onTap: () {
              if (i == 0) Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
              if (i == 1) Navigator.pushNamedAndRemoveUntil(context, '/quiz', (r) => false);
              if (i == 2) Navigator.pushNamedAndRemoveUntil(context, '/analytics', (r) => false);
              if (i == 3) Navigator.pushNamedAndRemoveUntil(context, '/profile', (r) => false);
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
