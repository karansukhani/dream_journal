import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dream_journal/models/mood_model.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodChartView extends StatelessWidget {
  final List<Mood> moods;
  
  const MoodChartView({
    super.key,
    required this.moods,
  });
  
  int _getMoodValue(MoodLevel level) {
    switch (level) {
      case MoodLevel.veryHappy:
        return 5;
      case MoodLevel.happy:
        return 4;
      case MoodLevel.neutral:
        return 3;
      case MoodLevel.sad:
        return 2;
      case MoodLevel.verySad:
        return 1;
    }
  }
  
  Color _getMoodColor(MoodLevel level) {
    switch (level) {
      case MoodLevel.veryHappy:
        return Colors.green;
      case MoodLevel.happy:
        return Colors.lightGreen;
      case MoodLevel.neutral:
        return Colors.blue;
      case MoodLevel.sad:
        return Colors.orange;
      case MoodLevel.verySad:
        return Colors.red;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Sort moods by date
    final sortedMoods = List<Mood>.from(moods)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    if (sortedMoods.isEmpty) {
      return const Center(
        child: Text('No mood data to display'),
      );
    }
    
    // Prepare chart data
    final spots = sortedMoods.map((mood) {
      return FlSpot(
        mood.date.millisecondsSinceEpoch.toDouble(),
        _getMoodValue(mood.level).toDouble(),
      );
    }).toList();
    
    // Get the min and max dates for the X-axis
    final firstDate = sortedMoods.first.date;
    final lastDate = sortedMoods.last.date;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Over Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MoodLegendItem(
                color: Colors.green,
                label: 'Very Happy',
              ),
              _MoodLegendItem(
                color: Colors.lightGreen,
                label: 'Happy',
              ),
              _MoodLegendItem(
                color: Colors.blue,
                label: 'Neutral',
              ),
              _MoodLegendItem(
                color: Colors.orange,
                label: 'Sad',
              ),
              _MoodLegendItem(
                color: Colors.red,
                label: 'Very Sad',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM d').format(date),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                      interval: (lastDate.difference(firstDate).inDays > 7)
                          ? (lastDate.difference(firstDate).inMilliseconds / 5).toDouble()
                          : (24 * 60 * 60 * 1000).toDouble(), // 1 day in milliseconds
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        switch (value.toInt()) {
                          case 1:
                            text = 'Very Sad';
                            break;
                          case 2:
                            text = 'Sad';
                            break;
                          case 3:
                            text = 'Neutral';
                            break;
                          case 4:
                            text = 'Happy';
                            break;
                          case 5:
                            text = 'Very Happy';
                            break;
                        }
                        return Text(
                          text,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                minX: firstDate.millisecondsSinceEpoch.toDouble(),
                maxX: lastDate.millisecondsSinceEpoch.toDouble(),
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7B66FF),
                        Color(0xFFB2A4FF),
                      ],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final mood = sortedMoods[index];
                        return FlDotCirclePainter(
                          radius: 6,
                          color: _getMoodColor(mood.level),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF7B66FF).withOpacity(0.3),
                          const Color(0xFFB2A4FF).withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final mood = sortedMoods[spot.spotIndex];
                        final date = DateFormat('MMM d, yyyy').format(mood.date);
                        return LineTooltipItem(
                          '$date\n${_getMoodText(mood.level)}',
                          const TextStyle(color: Colors.white),
                          children: [
                            if (mood.note != null && mood.note!.isNotEmpty)
                              TextSpan(
                                text: '\n${mood.note}',
                                style: TextStyle(
                                  color: Colors.grey[200],
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getMoodText(MoodLevel level) {
    switch (level) {
      case MoodLevel.veryHappy:
        return 'Very Happy';
      case MoodLevel.happy:
        return 'Happy';
      case MoodLevel.neutral:
        return 'Neutral';
      case MoodLevel.sad:
        return 'Sad';
      case MoodLevel.verySad:
        return 'Very Sad';
    }
  }
}

class _MoodLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  
  const _MoodLegendItem({
    required this.color,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
