import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  static const Color bgColor = Color(0xFF7BC8A4);
  static const Color cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      /// 🔻 FIX: แยก bottom nav ออกมา (ไม่ให้ overflow)
      bottomNavigationBar: _buildBottomNav(),

      body: SafeArea(
        /// 🔻 FIX: ทำให้ scroll ได้
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildTimeFilter(),
                const SizedBox(height: 16),

                /// Top cards
                Row(
                  children: [
                    Expanded(child: _buildTopStates()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRevenue()),
                  ],
                ),

                const SizedBox(height: 16),

                /// Growth
                _buildChartBox("Growth"),

                const SizedBox(height: 16),

                /// Bottom charts
                Row(
                  children: [
                    Expanded(child: _buildChartBox("Donut Chart")),
                    const SizedBox(width: 12),
                    Expanded(child: _buildChartBox("Radar Chart")),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return const Center(
      child: Text(
        "Analytics",
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  // ================= TIME FILTER =================
  Widget _buildTimeFilter() {
    final items = ["TODAY", "7 DAY", "14 DAY", "30 DAY"];

    return Row(
      children: items.map((e) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                e,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ================= TOP STATES =================
  Widget _buildTopStates() {
    final data = [
      {"name": "NY", "value": 120},
      {"name": "MA", "value": 80},
      {"name": "NH", "value": 70},
      {"name": "OR", "value": 50},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Top states",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),

          ...data.map((e) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e["name"].toString()),
                    Text("${e["value"]}K"),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (e["value"] as int) / 120,
                  minHeight: 6,
                ),
                const SizedBox(height: 10),
              ],
            );
          })
        ],
      ),
    );
  }

  // ================= REVENUE =================
  Widget _buildRevenue() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Revenues"),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                "15%",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.arrow_upward, color: Colors.green),
            ],
          ),
          SizedBox(height: 6),
          Text(
            "Increase compared to last week",
            style: TextStyle(fontSize: 11, color: Colors.black45),
          )
        ],
      ),
    );
  }

  // ================= CHART PLACEHOLDER =================
  Widget _buildChartBox(String title) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.black45),
        ),
      ),
    );
  }

  // ================= BOTTOM NAV =================
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.green,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home, color: Colors.white),
              Text("Home", style: TextStyle(color: Colors.white, fontSize: 10)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, color: Colors.white70),
              Text("Quiz", style: TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart, color: Colors.white),
              Text("Analytics", style: TextStyle(color: Colors.white, fontSize: 10)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, color: Colors.white70),
              Text("Profile", style: TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}