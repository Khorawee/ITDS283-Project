// lib/pages/Analyticspage.dart
// FIX: Growth chart แสดงข้อมูลทั้งหมด (all-time) จาก /api/growth
//      ลบ time filter ออกจาก Growth card
//      แก้ label x-axis ติดกัน — แสดงแค่บางจุด

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';
import '../widgets/bottom_nav.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color bgColor      = Color(0xFF9DE8C0);
  static const Color cardColor    = Colors.white;

  static const _timeOptions = [
    {'label': 'TODAY', 'days': 1},
    {'label': '7 DAY',  'days': 7},
    {'label': '14 DAY', 'days': 14},
    {'label': '30 DAY', 'days': 30},
  ];

  int _selectedTime = 1;

  bool _isLoading       = true;
  bool _isGrowthLoading = true;

  List<Map<String, dynamic>> _barData    = [];
  Map<String, dynamic>       _radarData  = {};

  // FIX: Growth data แยกต่างหาก — all-time
  List<Map<String, dynamic>> _growthData = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadGrowth();   // FIX: โหลด growth แยก
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final days = _timeOptions[_selectedTime]['days'] as int;
      final data = await AnalyticsService.getDashboard(days: days);
      setState(() {
        _barData   = List<Map<String, dynamic>>.from(data['bar_chart']  ?? []);
        _radarData = Map<String, dynamic>.from(data['radar_chart']      ?? {});
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  // FIX: โหลด growth ทั้งหมด ไม่ขึ้นกับ time filter
  Future<void> _loadGrowth() async {
    setState(() => _isGrowthLoading = true);
    try {
      final data = await AnalyticsService.getGrowth();
      setState(() {
        _growthData     = List<Map<String, dynamic>>.from(data['growth'] ?? []);
        _isGrowthLoading = false;
      });
    } catch (_) {
      setState(() => _isGrowthLoading = false);
    }
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'Strong':    return primaryGreen;
      case 'Improving': return const Color(0xFFF9A825);
      default:          return const Color(0xFFE53935);
    }
  }

  // FIX: prepend origin (0,0) เสมอ ให้กราฟเริ่มที่ 0 และเห็นการเปลี่ยนแปลง
  List<FlSpot> get _growthSpots {
    const origin = FlSpot(0, 0);
    if (_growthData.isEmpty) return [origin, const FlSpot(1, 0)];
    final dataSpots = _growthData.asMap().entries.map((e) {
      final val = (e.value['avg_understanding'] ?? 0).toDouble();
      return FlSpot((e.key + 1).toDouble(), val); // +1 เพราะ index 0 = origin
    }).toList();
    return [origin, ...dataSpots];
  }

  // FIX: label สำหรับ x-axis — idx 0 = origin (ไม่มี label), idx 1+ = data
  String? _growthLabel(int idx) {
    if (idx == 0) return ''; // origin ไม่แสดง label
    final dataIdx = idx - 1; // แปลงกลับ index ใน _growthData
    final total = _growthData.length;
    if (total == 0 || dataIdx >= total) return null;

    int step = 1;
    if (total > 7)  step = (total / 5).ceil();
    if (total > 20) step = (total / 5).ceil();

    if (dataIdx % step != 0 && dataIdx != total - 1) return null; // ซ่อน

    final raw = _growthData[dataIdx]['label']?.toString() ?? '';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryGreen))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                      _buildGrowthCard(),   // FIX: ไม่ขึ้นกับ time filter แล้ว
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
          const LearnFlowBottomNav(selectedIndex: 2),
        ]),
      ),
    );
  }

  Widget _buildTitle() => const Center(
    child: Text('Analytics',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
            color: primaryGreen)),
  );

  Widget _buildTimeFilter() {
    return Row(children: [
      const Text('TIME',
          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold,
              fontSize: 13)),
      const SizedBox(width: 8),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!)),
          child: Row(
            children: List.generate(_timeOptions.length, (index) {
              final isSelected = _selectedTime == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedTime = index);
                    _loadDashboard();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: isSelected ? primaryGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(_timeOptions[index]['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.black54)),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    ]);
  }

  Widget _buildTopTopicsCard() {
    final topics = _barData.take(4).toList();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Top Topics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
                color: Colors.black87)),
        const SizedBox(height: 12),
        if (topics.isEmpty)
          const Text('No data yet',
              style: TextStyle(fontSize: 12, color: Colors.black38))
        else
          ...topics.map((t) {
            final name    = t['subject_name'] ?? '';
            final mastery = (t['mastery'] ?? 0).toDouble();
            final level   = t['level'] ?? 'Weak';
            final color   = _levelColor(level);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text(name,
                      style: const TextStyle(fontSize: 11,
                          color: Colors.black54)),
                  Text('${(mastery * 100).toInt()}%',
                      style: TextStyle(fontSize: 11,
                          fontWeight: FontWeight.bold, color: color)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: mastery, minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ]),
            );
          }).toList(),
      ]),
    );
  }

  Widget _buildMasteryCard() {
    final avgMastery = _radarData.isEmpty
        ? 0.0
        : ((_radarData['mastery'] ?? 0.0) as num).toDouble();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Mastery',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
                color: Colors.black87)),
        const SizedBox(height: 16),
        Center(
          child: Text('${(avgMastery * 100).toInt()}%',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold,
                  color: primaryGreen)),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text('Overall mastery\nacross all subjects',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.black45, height: 1.4)),
        ),
      ]),
    );
  }

  // FIX: Growth card — แสดง all-time, ไม่มี time badge, label ไม่ติดกัน
  Widget _buildGrowthCard() {
    final spots = _growthSpots;
    final total = _growthData.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Growth',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
                  color: Colors.black87)),
          // FIX: แสดง "ALL TIME" badge แทน time filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(
              total > 0 ? '$total sessions' : 'ALL TIME',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primaryGreen),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // FIX: ถ้ายังโหลดอยู่
        if (_isGrowthLoading)
          const SizedBox(
            height: 160,
            child: Center(
                child: CircularProgressIndicator(color: primaryGreen)),
          )
        // FIX: ยังไม่มีข้อมูลเลย
        else if (_growthData.isEmpty)
          SizedBox(
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart_rounded,
                    size: 40, color: primaryGreen.withOpacity(0.3)),
                const SizedBox(height: 8),
                const Text(
                  'Complete a quiz to see your growth!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black38),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 160,
            child: LineChart(LineChartData(
              gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: Colors.grey[200]!, strokeWidth: 1)),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 0.2,
                    getTitlesWidget: (v, m) => Text(
                        '${(v * 100).toInt()}%',
                        style: const TextStyle(
                            fontSize: 9, color: Colors.black38)))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (v, m) {
                      final idx = v.toInt();
                      // spots[0] = origin, spots[1+] = data
                      if (idx < 0 || idx > _growthData.length) {
                        return const SizedBox();
                      }
                      final label = _growthLabel(idx);
                      if (label == null || label.isEmpty) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(label,
                            style: const TextStyle(
                                fontSize: 9, color: Colors.black38)),
                      );
                    })),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0, minY: 0, maxY: 1.0,
              lineBarsData: [LineChartBarData(
                spots: spots,
                isCurved: true,
                color: primaryGreen,
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (s, p, b, i) {
                    // ซ่อน dot ที่ origin (index 0)
                    if (i == 0) {
                      return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                          strokeColor: Colors.transparent);
                    }
                    return FlDotCirclePainter(
                        radius: 3,
                        color: primaryGreen,
                        strokeColor: Colors.white,
                        strokeWidth: 1.5);
                  },
                ),
                belowBarData: BarAreaData(
                    show: true,
                    color: primaryGreen.withOpacity(0.1)),
              )],
            )),
          ),
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
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        SizedBox(
          height: 130,
          child: PieChart(PieChartData(
            sectionsSpace: 2, centerSpaceRadius: 36,
            sections: [
              PieChartSectionData(
                  value: total > 0 ? strong.toDouble() : 1,
                  color: primaryGreen, radius: 28, showTitle: false),
              PieChartSectionData(
                  value: total > 0 ? improving.toDouble() : 1,
                  color: const Color(0xFFF9A825), radius: 24,
                  showTitle: false),
              PieChartSectionData(
                  value: total > 0 ? weak.toDouble() : 1,
                  color: const Color(0xFFE53935), radius: 20,
                  showTitle: false),
            ],
          )),
        ),
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
      decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRadarCard() {
    final accuracy = ((_radarData['accuracy'] ?? 0) as num).toDouble() * 100;
    final speed    = ((_radarData['speed']    ?? 0) as num).toDouble() * 100;
    final mastery  = ((_radarData['mastery']  ?? 0) as num).toDouble() * 100;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Skill Profile',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                color: Colors.black87)),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: RadarChart(RadarChartData(
            radarShape: RadarShape.polygon, tickCount: 4,
            ticksTextStyle: const TextStyle(fontSize: 0),
            radarBorderData:
                BorderSide(color: Colors.grey[300]!, width: 1),
            gridBorderData: BorderSide(color: Colors.grey[200]!, width: 1),
            tickBorderData: BorderSide(color: Colors.grey[200]!, width: 1),
            titleTextStyle:
                const TextStyle(fontSize: 10, color: Colors.black54),
            getTitle: (index, angle) {
              const titles = ['Accuracy', 'Speed', 'Mastery'];
              return RadarChartTitle(text: titles[index], angle: angle);
            },
            dataSets: [RadarDataSet(
              dataEntries: [
                RadarEntry(value: accuracy),
                RadarEntry(value: speed),
                RadarEntry(value: mastery),
              ],
              fillColor: primaryGreen.withOpacity(0.2),
              borderColor: primaryGreen, borderWidth: 2, entryRadius: 3,
            )],
          )),
        ),
      ]),
    );
  }
}