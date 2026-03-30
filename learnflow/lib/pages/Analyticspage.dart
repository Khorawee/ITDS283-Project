import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedIndex = 2;
  int _selectedTime = 1; // 0=TODAY 1=7DAY 2=14DAY 3=30DAY

  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color bgColor = Color(0xFF9DE8C0);
  static const Color cardColor = Colors.white;

  final List<String> _timeFilters = ['TO DAY', '7 DAY', '14 DAY', '30 DAY'];

  // Mockup data — Top topics (Bar Chart)
  final List<Map<String, dynamic>> _topTopics = [
    {'label': 'Algebra', 'value': 0.82, 'level': 'Strong', 'color': Color(0xFF1DBA78)},
    {'label': 'Calculus', 'value': 0.74, 'level': 'Improving', 'color': Color(0xFFF9A825)},
    {'label': 'Geometry', 'value': 0.56, 'level': 'Weak', 'color': Color(0xFFE53935)},
    {'label': 'English', 'value': 0.68, 'level': 'Improving', 'color': Color(0xFFF9A825)},
  ];

  // Mockup data — Line Chart (Growth)
  final List<FlSpot> _lineSpots = [
    FlSpot(0, 0.62),
    FlSpot(1, 0.65),
    FlSpot(2, 0.70),
    FlSpot(3, 0.72),
    FlSpot(4, 0.75),
    FlSpot(5, 0.78),
    FlSpot(6, 0.82),
  ];

  final List<String> _lineLabels = ['Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildTitle(),
                    const SizedBox(height: 12),
                    _buildTimeFilter(),
                    const SizedBox(height: 16),
                    // Row 1 — Top Topics + Mastery %
                    Row(
                      children: [
                        Expanded(child: _buildTopTopicsCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildMasteryCard()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Line Chart — Growth
                    _buildGrowthCard(),
                    const SizedBox(height: 12),
                    // Row 2 — Donut + Radar
                    Row(
                      children: [
                        Expanded(child: _buildDonutCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildRadarCard()),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  // ===== Title =====
  Widget _buildTitle() {
    return const Center(
      child: Text(
        'Analytics',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: primaryGreen,
        ),
      ),
    );
  }

  // ===== Time Filter =====
  Widget _buildTimeFilter() {
    return Row(
      children: [
        const Text(
          'TIME',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: List.generate(_timeFilters.length, (index) {
                final isSelected = _selectedTime == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTime = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _timeFilters[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ===== Top Topics Card (Bar Chart) =====
  Widget _buildTopTopicsCard() {
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
            'Top Topics',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ..._topTopics.map((topic) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      topic['label'],
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    Text(
                      '${(topic['value'] * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: topic['color'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: topic['value'],
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(topic['color']),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ===== Mastery % Card =====
  Widget _buildMasteryCard() {
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
            'Mastery',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '75%',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.arrow_upward, color: primaryGreen, size: 16),
              Text(
                '+5%',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Increase compared\nto last week',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black45,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Growth Line Chart =====
  Widget _buildGrowthCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Growth',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Text('7 Days', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[200]!,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        '${(value * 100).toInt()}%',
                        style: const TextStyle(fontSize: 9, color: Colors.black38),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _lineLabels.length) return const SizedBox();
                        return Text(
                          _lineLabels[idx],
                          style: const TextStyle(fontSize: 9, color: Colors.black38),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0.5,
                maxY: 1.0,
                lineBarsData: [
                  LineChartBarData(
                    spots: _lineSpots,
                    isCurved: true,
                    color: primaryGreen,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: primaryGreen,
                        strokeColor: Colors.white,
                        strokeWidth: 1.5,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryGreen.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Donut Chart =====
  Widget _buildDonutCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 130,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: [
                  PieChartSectionData(
                    value: 40,
                    color: primaryGreen,
                    radius: 28,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 35,
                    color: Colors.grey[300]!,
                    radius: 24,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 25,
                    color: Colors.grey[400]!,
                    radius: 20,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              _buildLegendBadge('Strong', primaryGreen),
              _buildLegendBadge('Improving', const Color(0xFFF9A825)),
              _buildLegendBadge('Weak', const Color(0xFFE53935)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===== Radar Chart =====
  Widget _buildRadarCard() {
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
            'Skill Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 4,
                ticksTextStyle: const TextStyle(fontSize: 0),
                radarBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
                gridBorderData: BorderSide(color: Colors.grey[200]!, width: 1),
                tickBorderData: BorderSide(color: Colors.grey[200]!, width: 1),
                titleTextStyle: const TextStyle(fontSize: 10, color: Colors.black54),
                getTitle: (index, angle) {
                  const titles = ['Accuracy', 'Speed', 'Mastery'];
                  return RadarChartTitle(text: titles[index], angle: angle);
                },
                dataSets: [
                  RadarDataSet(
                    dataEntries: const [
                      RadarEntry(value: 75),
                      RadarEntry(value: 71),
                      RadarEntry(value: 67),
                    ],
                    fillColor: primaryGreen.withOpacity(0.2),
                    borderColor: primaryGreen,
                    borderWidth: 2,
                    entryRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Bottom Nav =====
  Widget _buildBottomNavBar() {
    final items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
      {'icon': Icons.quiz_outlined, 'activeIcon': Icons.quiz, 'label': 'Quiz'},
      {'icon': Icons.bar_chart_outlined, 'activeIcon': Icons.bar_chart, 'label': 'Analytics'},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: primaryGreen,
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
            children: List.generate(items.length, (index) {
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Navigator.pushReplacementNamed(context, '/home');
                  } else if (index == 1) {
                    Navigator.pushReplacementNamed(context, '/quiz');
                  } else {
                    setState(() => _selectedIndex = index);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? items[index]['activeIcon'] as IconData
                          : items[index]['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.white60,
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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