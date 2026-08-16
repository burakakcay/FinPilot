import 'package:finpilot/features/transactions/services/transaction_service.dart';
import 'package:finpilot/shared/models/transaction_model.dart';
import 'package:finpilot/shared/widgets/app_navigation_layout.dart';
import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  InsightsScreen({super.key});

  final TransactionService transactionService = TransactionService();

  String formatMoney(double amount) {
    return '₺${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppNavigationLayout(
      selectedIndex: 4,
      title: 'Finansal İçgörüler',
      body: StreamBuilder<List<TransactionModel>>(
        stream: transactionService.watchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('İçgörüler yüklenirken bir hata oluştu.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!;

          if (transactions.isEmpty) {
            return const Center(
              child: Text('İçgörü oluşturmak için işlem ekleyin.'),
            );
          }

          final totalIncome = transactions
              .where(
                (transaction) => transaction.type == TransactionType.income,
              )
              .fold(0.0, (total, transaction) => total + transaction.amount);

          final totalExpense = transactions
              .where(
                (transaction) => transaction.type == TransactionType.expense,
              )
              .fold(0.0, (total, transaction) => total + transaction.amount);

          final balance = totalIncome - totalExpense;

          final categoryTotals = <String, double>{};

          for (final transaction in transactions) {
            if (transaction.type != TransactionType.expense) continue;

            categoryTotals.update(
              transaction.category,
              (value) => value + transaction.amount,
              ifAbsent: () => transaction.amount,
            );
          }

          final highestCategory = categoryTotals.entries.isEmpty
              ? null
              : (categoryTotals.entries.toList()..sort(
                      (first, second) => second.value.compareTo(first.value),
                    ))
                    .first;

          final insights = <_InsightData>[];

          if (totalExpense > totalIncome) {
            insights.add(
              _InsightData(
                title: 'Giderler gelirleri aşıyor',
                description:
                    'Toplam giderleriniz gelirlerinizden '
                    '${formatMoney(totalExpense - totalIncome)} daha fazla.',
                icon: Icons.warning_amber_outlined,
                color: theme.colorScheme.error,
              ),
            );
          } else if (balance > 0) {
            insights.add(
              _InsightData(
                title: 'Pozitif bakiye',
                description:
                    'Gelir ve giderleriniz arasındaki fark '
                    '${formatMoney(balance)}.',
                icon: Icons.check_circle_outline,
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (highestCategory != null && totalExpense > 0) {
            final percentage = (highestCategory.value / totalExpense * 100)
                .toStringAsFixed(0);

            insights.add(
              _InsightData(
                title: 'En yüksek harcama kategorisi',
                description:
                    '${highestCategory.key} kategorisi toplam giderlerin '
                    '%$percentage oranını oluşturuyor.',
                icon: Icons.analytics_outlined,
                color: Colors.orange,
              ),
            );
          }

          if (totalIncome == 0 && totalExpense > 0) {
            insights.add(
              _InsightData(
                title: 'Gelir kaydı eksik',
                description:
                    'Giderlerinizi daha doğru değerlendirmek için '
                    'gelir işlemlerinizi de ekleyin.',
                icon: Icons.info_outline,
                color: Colors.blue,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Otomatik Finansal Değerlendirme',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'İşlemlerinize göre oluşturulan basit içgörüler.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ...insights.map(
                (insight) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(insight.icon, color: insight.color, size: 32),
                    title: Text(
                      insight.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(insight.description),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InsightData {
  const _InsightData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}
