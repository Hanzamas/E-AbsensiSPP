import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../provider/student_attendance_provider.dart';

class StatisticsTab extends StatefulWidget {
  final StudentAttendanceProvider provider;

  const StatisticsTab({super.key, required this.provider});

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  String _selectedPeriod = 'month'; // month, semester, year
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Period Selector
          _buildPeriodSelector(),
          const SizedBox(height: 16),
          
          // Overall Stats Cards
          _buildOverallStatsCard(),
          const SizedBox(height: 16),
          
          // Attendance Chart
          _buildAttendanceChart(),
          const SizedBox(height: 16),
          
          // Subject Breakdown
          _buildSubjectBreakdown(),
          const SizedBox(height: 16),
          
          // Attendance Trend
          _buildAttendanceTrend(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range, color: const Color(0xFF2196F3), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Periode Statistik',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPeriodChip('Bulan Ini', 'month')),
              const SizedBox(width: 8),
              Expanded(child: _buildPeriodChip('Semester', 'semester')),
              const SizedBox(width: 8),
              Expanded(child: _buildPeriodChip('Tahun Ini', 'year')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
        _loadStatisticsForPeriod(value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard() {
    final stats = widget.provider.getAttendanceStats();
    final total = stats['total'] ?? 0;
    final hadir = stats['hadir'] ?? 0;
    final alpha = stats['alpha'] ?? 0;
    final sakit = stats['sakit'] ?? 0;
    final izin = stats['izin'] ?? 0;
    
    final attendanceRate = total > 0 ? (hadir / total * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: const Color(0xFF2196F3), size: 24),
              const SizedBox(width: 12),
              const Text(
                'Statistik Kehadiran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Attendance Rate Circle
          Row(
            children: [
              // Circle Chart
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: hadir.toDouble(),
                            color: const Color(0xFF10B981),
                            radius: 15,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: alpha.toDouble(),
                            color: const Color(0xFFEF4444),
                            radius: 15,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: (sakit + izin).toDouble(),
                            color: const Color(0xFFF59E0B),
                            radius: 15,
                            showTitle: false,
                          ),
                        ],
                        centerSpaceRadius: 35,
                        sectionsSpace: 2,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${attendanceRate.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Text(
                            'Kehadiran',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Stats Grid
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('Total', total.toString(), Colors.blue, Icons.assignment)),
                        Expanded(child: _buildStatItem('Hadir', hadir.toString(), Colors.green, Icons.check_circle)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStatItem('Alpha', alpha.toString(), Colors.red, Icons.cancel)),
                        Expanded(child: _buildStatItem('S/I', '${sakit + izin}', Colors.orange, Icons.healing)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren Kehadiran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 0.5,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        );
                        switch (value.toInt()) {
                          case 0: return Text('Sen', style: style);
                          case 1: return Text('Sel', style: style);
                          case 2: return Text('Rab', style: style);
                          case 3: return Text('Kam', style: style);
                          case 4: return Text('Jum', style: style);
                          case 5: return Text('Sab', style: style);
                          case 6: return Text('Min', style: style);
                        }
                        return Text('', style: style);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateWeeklyAttendanceData(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2196F3),
                        const Color(0xFF64B5F6),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF2196F3),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2196F3).withOpacity(0.3),
                          const Color(0xFF2196F3).withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

  Widget _buildSubjectBreakdown() {
    final subjectStats = widget.provider.getAttendanceBySubject();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Breakdown per Mata Pelajaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          
          if (subjectStats.isEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Belum ada data mata pelajaran',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            Column(
              children: subjectStats.entries.map((entry) {
                return _buildSubjectProgressCard(
                  entry.key,
                  entry.value,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSubjectProgressCard(String subject, Map<String, int> stats) {
    final total = stats['total'] ?? 0;
    final hadir = stats['hadir'] ?? 0;
    final alpha = stats['alpha'] ?? 0;
    final sakit = stats['sakit'] ?? 0;
    final izin = stats['izin'] ?? 0;
    
    final attendanceRate = total > 0 ? (hadir / total) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Text(
                '${(attendanceRate * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: attendanceRate >= 0.8 ? Colors.green : 
                         attendanceRate >= 0.6 ? Colors.orange : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress Bar
          LinearProgressIndicator(
            value: attendanceRate,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              attendanceRate >= 0.8 ? Colors.green : 
              attendanceRate >= 0.6 ? Colors.orange : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('H', hadir, Colors.green),
              _buildMiniStat('A', alpha, Colors.red),
              _buildMiniStat('S', sakit, Colors.orange),
              _buildMiniStat('I', izin, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceTrend() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performa Mingguan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          
          // Weekly performance indicators
          Row(
            children: [
              Expanded(child: _buildTrendCard('Minggu Ini', '85%', '↗', Colors.green)),
              const SizedBox(width: 8),
              Expanded(child: _buildTrendCard('Minggu Lalu', '78%', '↘', Colors.red)),
              const SizedBox(width: 8),
              Expanded(child: _buildTrendCard('Rata-rata', '82%', '→', Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(String label, String value, String trend, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<FlSpot> _generateWeeklyAttendanceData() {
    // Generate mock data for weekly attendance
    // In real implementation, this would come from actual data
    return [
      const FlSpot(0, 4), // Senin
      const FlSpot(1, 5), // Selasa
      const FlSpot(2, 3), // Rabu
      const FlSpot(3, 6), // Kamis
      const FlSpot(4, 4), // Jumat
      const FlSpot(5, 2), // Sabtu
      const FlSpot(6, 0), // Minggu
    ];
  }

  void _loadStatisticsForPeriod(String period) {
    // TODO: Implement period-based statistics loading
    // widget.provider.loadStatisticsForPeriod(period);
  }
}