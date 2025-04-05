import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

final supabase = Supabase.instance.client;

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _grades = [];
  Map<String, dynamic> _summary = {};
  
  @override
  void initState() {
    super.initState();
    _loadGrades();
  }
  
  Future<void> _loadGrades() async {
    // In a real app, this would fetch from a database
    // For this demo, we'll use mock data
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _grades = [
          {
            'id': '1',
            'title': 'Math Quiz',
            'class_name': 'Mathematics',
            'grade': 'A',
            'percentage': 92,
            'date': DateTime.now().subtract(const Duration(days: 5)),
          },
          {
            'id': '2',
            'title': 'Science Lab Report',
            'class_name': 'Science',
            'grade': 'B+',
            'percentage': 87,
            'date': DateTime.now().subtract(const Duration(days: 10)),
          },
          {
            'id': '3',
            'title': 'History Essay',
            'class_name': 'History',
            'grade': 'A-',
            'percentage': 90,
            'date': DateTime.now().subtract(const Duration(days: 15)),
          },
          {
            'id': '4',
            'title': 'Literature Analysis',
            'class_name': 'English',
            'grade': 'B',
            'percentage': 85,
            'date': DateTime.now().subtract(const Duration(days: 20)),
          },
        ];
        
        _summary = {
          'overall_gpa': 3.7,
          'overall_percentage': 88.5,
          'pending_assignments': 2,
          'completed_assignments': 4,
          'class_averages': {
            'Mathematics': 90,
            'Science': 87,
            'History': 90,
            'English': 85,
          },
        };
        
        _isLoading = false;
      });
    }
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) {
      return Colors.green;
    } else if (grade.startsWith('B')) {
      return Colors.blue;
    } else if (grade.startsWith('C')) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grades'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Overall GPA',
                          value: _summary['overall_gpa'].toString(),
                          icon: Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Overall %',
                          value: '${_summary['overall_percentage']}%',
                          icon: Icons.percent,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Pending',
                          value: _summary['pending_assignments'].toString(),
                          icon: Icons.pending_actions,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Completed',
                          value: _summary['completed_assignments'].toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  // Class Averages Chart
                  const SizedBox(height: 24),
                  const Text(
                    'Class Averages',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.blueGrey,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              String className = '';
                              switch (groupIndex) {
                                case 0:
                                  className = 'Math';
                                  break;
                                case 1:
                                  className = 'Science';
                                  break;
                                case 2:
                                  className = 'History';
                                  break;
                                case 3:
                                  className = 'English';
                                  break;
                              }
                              return BarTooltipItem(
                                '$className: ${rod.toY.round()}%',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                String text = '';
                                switch (value.toInt()) {
                                  case 0:
                                    text = 'Math';
                                    break;
                                  case 1:
                                    text = 'Sci';
                                    break;
                                  case 2:
                                    text = 'Hist';
                                    break;
                                  case 3:
                                    text = 'Eng';
                                    break;
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    text,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value % 20 == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      '${value.toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                              reservedSize: 30,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: _summary['class_averages']['Mathematics'].toDouble(),
                                color: Colors.blue,
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: _summary['class_averages']['Science'].toDouble(),
                                color: Colors.green,
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: _summary['class_averages']['History'].toDouble(),
                                color: Colors.purple,
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 3,
                            barRods: [
                              BarChartRodData(
                                toY: _summary['class_averages']['English'].toDouble(),
                                color: Colors.orange,
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Recent Grades
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Grades',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _grades.length,
                    itemBuilder: (context, index) {
                      final grade = _grades[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            grade['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Class: ${grade['class_name']}'),
                              const SizedBox(height: 4),
                              Text(
                                'Date: ${grade['date'].day}/${grade['date'].month}/${grade['date'].year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                grade['grade'],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _getGradeColor(grade['grade']),
                                ),
                              ),
                              Text(
                                '${grade['percentage']}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getGradeColor(grade['grade']),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

