import 'package:fl_chart/fl_chart.dart';
import 'package:finpilot/shared/models/transaction_model.dart';
import 'package:flutter/material.dart';

class MonthlyIncomeExpenseChart extends StatelessWidget {
  const MonthlyIncomeExpenseChart({super.key, required this.transactions});

  final List<TransactionModel> transactions;

  static const monthNames = [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final months = List.generate(
      6,
      (index) => DateTime(now.year, now.month - 5 + index),
    );

    final incomes = List<double>.filled(6, 0);
    final expenses = List<double>.filled(6, 0);

    for (final transaction in transactions) {
      final monthIndex = months.indexWhere(
        (month) =>
            month.year == transaction.date.year &&
            month.month == transaction.date.month,
      );

      if (monthIndex == -1) continue;

      if (transaction.type == TransactionType.income) {
        incomes[monthIndex] += transaction.amount;
      } else {
        expenses[monthIndex] += transaction.amount;
      }
    }

    final highestValue = [
      ...incomes,
      ...expenses,
    ].reduce((first, second) => first > second ? first : second);

    final maxY = highestValue == 0 ? 1000.0 : highestValue * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aylık Gelir ve Gider',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 5,
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: maxY / 4,
                        getTitlesWidget: (value, meta) {
                          String label;

                          if (value == 0) {
                            label = '₺0';
                          } else if (value >= 1000) {
                            label =
                                '₺${(value / 1000).toStringAsFixed(1).replaceAll('.', ',')}K';
                          } else {
                            label = '₺${value.toStringAsFixed(0)}';
                          }

                          return Text(label, style: theme.textTheme.bodySmall);
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();

                          if (index < 0 || index >= months.length) {
                            return const SizedBox.shrink();
                          }

                          return Text(
                            monthNames[months[index].month - 1],
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (spots) {
                        return spots.map((spot) {
                          final amount = spot.y
                              .toStringAsFixed(2)
                              .replaceAll('.', ',');

                          return LineTooltipItem(
                            '₺$amount',
                            TextStyle(
                              color: spot.bar.color ?? Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var index = 0; index < incomes.length; index++)
                          FlSpot(index.toDouble(), incomes[index]),
                      ],
                      isCurved: false,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: [
                        for (var index = 0; index < expenses.length; index++)
                          FlSpot(index.toDouble(), expenses[index]),
                      ],
                      isCurved: false,
                      color: theme.colorScheme.error,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ChartLegend(color: Colors.green, label: 'Gelir'),
                const SizedBox(width: 20),
                _ChartLegend(color: theme.colorScheme.error, label: 'Gider'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
