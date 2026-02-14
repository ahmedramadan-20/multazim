import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multazim/features/analytics/domain/entities/daily_summary.dart';

class CompletionTrendChart extends StatelessWidget {
  final List<DailySummary> summaries;

  const CompletionTrendChart({super.key, required this.summaries});

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('لا توجد بيانات لمخطط الاتجاه')),
      );
    }

    // Sort by date just in case
    final data = List.of(summaries)..sort((a, b) => a.date.compareTo(b.date));

    return Container(
      height: 240,
      padding: const EdgeInsets.only(right: 16, left: 4, top: 20, bottom: 0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox();
                  }

                  // Show specific dates (e.g., every 5th day)
                  if (index % 5 == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat.Md().format(data[index].date),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.25, // 0%, 25%, 50%, 75%, 100%
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value * 100).toInt()}%',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
                reservedSize: 35,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 0),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 0),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: 1.05, // slightly above 1.0 for padding
          lineBarsData: [
            LineChartBarData(
              preventCurveOverShooting: true,
              spots: data.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.completionRate);
              }).toList(),
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
