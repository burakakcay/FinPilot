import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryExpensePieChart extends StatefulWidget {
  const CategoryExpensePieChart({super.key, required this.categoryTotals});

  final Map<String, double> categoryTotals;

  @override
  State<CategoryExpensePieChart> createState() =>
      _CategoryExpensePieChartState();
}

class _CategoryExpensePieChartState extends State<CategoryExpensePieChart> {
  int touchedIndex = -1;

  static const colors = [
    Color(0xFF16A34A),
    Color(0xFF2563EB),
    Color(0xFFD97706),
    Color(0xFF9333EA),
    Color(0xFFDC2626),
    Color(0xFF0891B2),
  ];

  String formatMoney(double amount) {
    return '₺${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final entries = widget.categoryTotals.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));

    final totalExpense = entries.fold<double>(
      0,
      (total, entry) => total + entry.value,
    );

    if (entries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Grafik için gider verisi bulunmuyor.')),
        ),
      );
    }

    final hasSelection = touchedIndex >= 0 && touchedIndex < entries.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori Dağılımı',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 58,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          final sectionIndex =
                              response?.touchedSection?.touchedSectionIndex;

                          setState(() {
                            if (event is FlPointerExitEvent ||
                                sectionIndex == null ||
                                sectionIndex < 0) {
                              touchedIndex = -1;
                            } else {
                              touchedIndex = sectionIndex;
                            }
                          });
                        },
                      ),
                      sections: [
                        for (var index = 0; index < entries.length; index++)
                          PieChartSectionData(
                            value: entries[index].value,
                            color: colors[index % colors.length],
                            radius: index == touchedIndex ? 86 : 76,
                            title: '',
                          ),
                      ],
                    ),
                  ),
                  if (hasSelection)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entries[touchedIndex].key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatMoney(entries[touchedIndex].value),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    )
                  else
                    Text(
                      formatMoney(totalExpense),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                for (var index = 0; index < entries.length; index++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(entries[index].key),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
