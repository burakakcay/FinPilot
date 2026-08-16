import 'package:finpilot/features/reports/widgets/category_expense_pie_chart.dart';
import 'package:finpilot/features/reports/widgets/monthly_income_expense_chart.dart';
import 'package:finpilot/features/transactions/services/transaction_service.dart';
import 'package:finpilot/shared/models/transaction_model.dart';
import 'package:finpilot/shared/widgets/app_navigation_layout.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  ReportsScreen({super.key});

  final TransactionService transactionService = TransactionService();

  String formatMoney(double amount) {
    return '₺${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppNavigationLayout(
      selectedIndex: 3,
      title: 'Finansal Raporlar',
      body: StreamBuilder<List<TransactionModel>>(
        stream: transactionService.watchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Raporlar yüklenirken bir hata oluştu.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!;

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

          final sortedCategories = categoryTotals.entries.toList()
            ..sort((first, second) => second.value.compareTo(first.value));

          final maxCategoryAmount = sortedCategories.isEmpty
              ? 0.0
              : sortedCategories.first.value;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Finansal Özet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ReportSummaryCard(
                    title: 'Toplam Gelir',
                    amount: formatMoney(totalIncome),
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  _ReportSummaryCard(
                    title: 'Toplam Gider',
                    amount: formatMoney(totalExpense),
                    icon: Icons.trending_down,
                    color: theme.colorScheme.error,
                  ),
                  _ReportSummaryCard(
                    title: 'Mevcut Bakiye',
                    amount: formatMoney(balance),
                    icon: Icons.account_balance_wallet_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              MonthlyIncomeExpenseChart(transactions: transactions),
              const SizedBox(height: 24),
              CategoryExpensePieChart(categoryTotals: categoryTotals),
              const SizedBox(height: 32),
              Text(
                'Kategori Bazlı Giderler',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (sortedCategories.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('Henüz gider işlemi bulunmuyor.'),
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: sortedCategories.map((entry) {
                        final progress = maxCategoryAmount == 0
                            ? 0.0
                            : entry.value / maxCategoryAmount;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(formatMoney(entry.value)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(value: progress),
                            ],
                          ),
                        );
                      }).toList(),
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

class _ReportSummaryCard extends StatelessWidget {
  const _ReportSummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 4),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
