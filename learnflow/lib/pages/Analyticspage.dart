// lib/pages/Analyticspage.dart  [UPDATED — เชื่อม API]

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedIndex = 2;
  int _selectedTime  = 1;

  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color bgColor      = Color(0xFF9DE8C0);
  static const Color cardColor    = Colors.white;

  final List<String> _timeFilters = ['TO DAY', '7 DAY', '14 DAY', '30 DAY'];

  // ── API data ───────────────────────────────────────────────────────────────
  bool _isLoading = true;
  List<Map<String, dynamic>> _barData   = [];
  List<Map<String, dynamic>> _lineData  = [];
  Map<String, dynamic>       _radarData = {};

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final data = await AnalyticsService.getDashboard();
      setState(() {
        _barData   = List<Map<String, dynamic>>.from(data['bar_chart']  ?? []);
        _lineData  = List<Map<String, dynamic>>.from(data['line_chart'] ?? []);
        _radarData = Map<String, dynamic>.from(data['radar_chart']      ?? {});
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'Strong':    return primaryGreen;
      case 'Improving': return const Color(0xFFF9A825);
      default:          return const Color(0xFFE53935);
    }
  }

  // Build Line Chart spots from API line_data
  List<FlSpot> get _lineSpots {
    if (_lineData.isEmpty) {
      return List.generate(7, (i) => FlSpot(i.toDouble(), 0));
    }
    return _lineData.asMap().entries.map((e) {
      final val = (e.value['avg_understanding'] ?? 0).toDouble();
      return FlSpot(e.key.toDouble(), val);
    }).toList();
  }

  List<String> get _lineLabels {
    if (_lineData.isEmpty) return List.generate(7, (i) => 'Day${i + 1}');
    return _lineData.map((d) {
      final date = d['date']?.toString() ?? '';
      return date.length >= 10 ? date.substring(5) : date; // MM-DD
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryGreen))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SizedBox(height: 16),
                        _buildTitle(),
                        const SizedBox(height: 12),
                        _buildTimeFilter(),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(child: _buildTopTopicsCard()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildMasteryCard()),
                        ]),
                        const SizedBox(height: 12),
                        _buildGrowthCard(),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _buildDonutCard()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildRadarCard()),
                        ]),
                        const SizedBox(height: 16),
                      ]),
                    ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() => const Center(
    child: Text('Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryGreen)),
  );

  Widget _buildTimeFilter() {
    return Row(children: [
      const Text('TIME', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(width: 8),
      Expanded(child: Container(
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!)),
        child: Row(children: List.generate(_timeFilters.length, (index) {
          final isSelected = _selectedTime == index;
          return Expanded(child: GestureDetector(
            onTap: () { setState(() => _selectedTime = index); _loadDashboard(); },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: isSelected ? primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(6)),
              child: Text(_timeFilters[index], textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black54)),
            ),
          ));
        })),
      )),
    ]);
  }

  Widget _buildTopTopicsCard() {
    final topics = _barData.take(4).toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Top Topics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 12),
        if (topics.isEmpty)
          const Text('No data yet', style: TextStyle(fontSize: 12, color: Colors.black38))
        else
          ...topics.map((t) {
            final name    = t['subject_name'] ?? '';
            final mastery = (t['mastery'] ?? 0).toDouble();
            final level   = t['level'] ?? 'Weak';
            final color   = _levelColor(level);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(name, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  Text('${(mastery * 100).toInt()}%',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: mastery, minHeight: 8,
                        backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color))),
              ]),
            );
          }).toList(),
      ]),
    );
  }

  Widget _buildMasteryCard() {
    final avgMastery = _radarData.isEmpty ? 0.0
        : ((_radarData['mastery'] ?? 0.0) as num).toDouble();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Mastery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 16),
        Center(child: Text('${(avgMastery * 100).toInt()}%',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryGreen))),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(Icons.arrow_upward, color: primaryGreen, size: 16),
          Text('+', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
        const SizedBox(height: 8),
        const Center(child: Text('Overall mastery\nacross all subjects',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black45, height: 1.4))),
      ]),
    );
  }

  Widget _buildGrowthCard() {
    final spots  = _lineSpots;
    final labels = _lineLabels;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Growth', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
            child: Row(children: const [
              Text('7 Days', style: TextStyle(fontSize: 12, color: Colors.black54)),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        SizedBox(height: 160, child: LineChart(LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey[200]!, strokeWidth: 1)),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
                getTitlesWidget: (v, m) => Text('${(v * 100).toInt()}%',
                    style: const TextStyle(fontSize: 9, color: Colors.black38)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                getTitlesWidget: (v, m) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= labels.length) return const SizedBox();
                  return Text(labels[idx], style: const TextStyle(fontSize: 9, color: Colors.black38));
                })),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0, maxY: 1.0,
          lineBarsData: [LineChartBarData(
            spots: spots, isCurved: true, color: primaryGreen, barWidth: 2.5,
            dotData: FlDotData(show: true,
                getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 3, color: primaryGreen,
                    strokeColor: Colors.white, strokeWidth: 1.5)),
            belowBarData: BarAreaData(show: true, color: primaryGreen.withOpacity(0.1)),
          )],
        ))),
      ]),
    );
  }

  Widget _buildDonutCard() {
    final strong    = _barData.where((t) => t['level'] == 'Strong').length;
    final improving = _barData.where((t) => t['level'] == 'Improving').length;
    final weak      = _barData.where((t) => t['level'] == 'Weak').length;
    final total     = _barData.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        SizedBox(height: 130, child: PieChart(PieChartData(
          sectionsSpace: 2, centerSpaceRadius: 36,
          sections: [
            PieChartSectionData(value: total > 0 ? strong.toDouble() : 1, color: primaryGreen, radius: 28, showTitle: false),
            PieChartSectionData(value: total > 0 ? improving.toDouble() : 1, color: const Color(0xFFF9A825), radius: 24, showTitle: false),
            PieChartSectionData(value: total > 0 ? weak.toDouble() : 1, color: const Color(0xFFE53935), radius: 20, showTitle: false),
          ],
        ))),
        const SizedBox(height: 8),
        Wrap(spacing: 6, children: [
          _buildLegendBadge('Strong', primaryGreen),
          _buildLegendBadge('Improving', const Color(0xFFF9A825)),
          _buildLegendBadge('Weak', const Color(0xFFE53935)),
        ]),
      ]),
    );
  }

  Widget _buildLegendBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRadarCard() {
    final accuracy = ((_radarData['accuracy'] ?? 0) as num).toDouble() * 100;
    final speed    = ((_radarData['speed']    ?? 0) as num).toDouble() * 100;
    final mastery  = ((_radarData['mastery']  ?? 0) as num).toDouble() * 100;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Skill Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        SizedBox(height: 150, child: RadarChart(RadarChartData(
          radarShape: RadarShape.polygon, tickCount: 4,
          ticksTextStyle: const TextStyle(fontSize: 0),
          radarBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
          gridBorderData: BorderSide(color: Colors.grey[200]!, width: 1),
          tickBorderData: BorderSide(color: Colors.grey[200]!, width: 1),
          titleTextStyle: const TextStyle(fontSize: 10, color: Colors.black54),
          getTitle: (index, angle) {
            const titles = ['Accuracy', 'Speed', 'Mastery'];
            return RadarChartTitle(text: titles[index], angle: angle);
          },
          dataSets: [RadarDataSet(
            dataEntries: [RadarEntry(value: accuracy), RadarEntry(value: speed), RadarEntry(value: mastery)],
            fillColor: primaryGreen.withOpacity(0.2), borderColor: primaryGreen, borderWidth: 2, entryRadius: 3,
          )],
        ))),
      ]),
    );
  }

  Widget _buildBottomNavBar() {
    final items = [
      {'icon': Icons.home_outlined,      'activeIcon': Icons.home,      'label': 'Home'},
      {'icon': Icons.quiz_outlined,      'activeIcon': Icons.quiz,      'label': 'Quiz'},
      {'icon': Icons.bar_chart_outlined, 'activeIcon': Icons.bar_chart, 'label': 'Analytics'},
      {'icon': Icons.person_outline,     'activeIcon': Icons.person,    'label': 'Profile'},
    ];
    return Container(
      decoration: BoxDecoration(color: primaryGreen,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4))]),
      child: SafeArea(top: false, child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () {
                if (index == 0) Navigator.pushReplacementNamed(context, '/home');
                else if (index == 1) Navigator.pushReplacementNamed(context, '/quiz');
                else if (index == 3) Navigator.pushReplacementNamed(context, '/profile');
                else setState(() => _selectedIndex = index);
              },
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(isSelected ? items[index]['activeIcon'] as IconData : items[index]['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.white60, size: 26),
                const SizedBox(height: 4),
                Text(items[index]['label'] as String,
                    style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ]),
            );
          }),
        ),
      )),
    );
  }
}
