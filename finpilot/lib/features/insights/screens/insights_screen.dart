import 'package:finpilot/features/budgets/services/budget_service.dart';
import 'package:finpilot/features/insights/models/ai_financial_summary.dart';
import 'package:finpilot/features/insights/widgets/ai_insight_card.dart';
import 'package:finpilot/features/transactions/services/transaction_service.dart';
import 'package:finpilot/shared/models/budget_model.dart';
import 'package:finpilot/shared/models/transaction_model.dart';
import 'package:finpilot/shared/widgets/app_navigation_layout.dart';
import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  InsightsScreen({super.key});

  final TransactionService transactionService = TransactionService();
  final BudgetService budgetService = BudgetService();

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

          final savingsRate = totalIncome == 0
              ? 0.0
              : (balance / totalIncome) * 100;

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

          if (totalIncome > 0) {
            final isPositive = savingsRate >= 20;

            insights.add(
              _InsightData(
                title: 'Tasarruf oranı',
                description: isPositive
                    ? 'Gelirlerinizin yaklaşık %${savingsRate.toStringAsFixed(0)} kadarını tasarruf ediyorsunuz.'
                    : 'Tasarruf oranınız yaklaşık %${savingsRate.toStringAsFixed(0)}. Bu oranı artırmak için gider kategorilerinizi gözden geçirebilirsiniz.',
                icon: isPositive ? Icons.savings_outlined : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.orange,
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

          final now = DateTime.now();

          final currentMonthExpense = transactions
              .where(
                (transaction) =>
                    transaction.type == TransactionType.expense &&
                    transaction.date.year == now.year &&
                    transaction.date.month == now.month,
              )
              .fold(0.0, (total, transaction) => total + transaction.amount);

          final previousMonth = DateTime(now.year, now.month - 1);

          final previousMonthExpense = transactions
              .where(
                (transaction) =>
                    transaction.type == TransactionType.expense &&
                    transaction.date.year == previousMonth.year &&
                    transaction.date.month == previousMonth.month,
              )
              .fold(0.0, (total, transaction) => total + transaction.amount);

          if (previousMonthExpense > 0 &&
              currentMonthExpense > previousMonthExpense * 1.2) {
            insights.add(
              _InsightData(
                title: 'Harcama artışı',
                description:
                    'Bu ayki giderleriniz geçen aya göre belirgin şekilde arttı.',
                icon: Icons.trending_up,
                color: theme.colorScheme.error,
              ),
            );
          } else if (previousMonthExpense > 0 &&
              currentMonthExpense < previousMonthExpense * 0.8) {
            insights.add(
              _InsightData(
                title: 'Harcama azalışı',
                description:
                    'Bu ayki giderleriniz geçen aya göre azaldı. Bu trendi korumaya çalışın.',
                icon: Icons.trending_down,
                color: Colors.green,
              ),
            );
          }

          return StreamBuilder<List<BudgetModel>>(
            stream: budgetService.watchBudgets(),
            builder: (context, budgetSnapshot) {
              if (budgetSnapshot.hasError) {
                return const Center(
                  child: Text('Bütçeler yüklenirken bir hata oluştu.'),
                );
              }

              if (!budgetSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final budgets = budgetSnapshot.data!;
              final currentDate = DateTime.now();
              final budgetWarnings = <String>[];
              var exceededBudgetCount = 0;
              var activeBudgetCount = 0;

              for (final budget in budgets) {
                if (budget.month.year != currentDate.year ||
                    budget.month.month != currentDate.month) {
                  continue;
                }

                activeBudgetCount++;

                final spent = transactions
                    .where(
                      (transaction) =>
                          transaction.type == TransactionType.expense &&
                          transaction.category == budget.category &&
                          transaction.date.year == budget.month.year &&
                          transaction.date.month == budget.month.month,
                    )
                    .fold(
                      0.0,
                      (total, transaction) => total + transaction.amount,
                    );

                if (spent > budget.limit) {
                  exceededBudgetCount++;

                  budgetWarnings.add(
                    '${budget.category}: ${formatMoney(spent - budget.limit)} aşıldı',
                  );

                  insights.add(
                    _InsightData(
                      title: 'Bütçe aşıldı',
                      description:
                          '${budget.category} bütçesini ${formatMoney(spent - budget.limit)} aştınız.',
                      icon: Icons.warning_amber_outlined,
                      color: theme.colorScheme.error,
                    ),
                  );
                }
              }

              final budgetComplianceScore = activeBudgetCount == 0
                  ? 100.0
                  : ((activeBudgetCount - exceededBudgetCount) /
                            activeBudgetCount *
                            100)
                        .clamp(0, 100)
                        .toDouble();

              final savingsScore = savingsRate.clamp(0, 100).toDouble();

              final balanceScore = totalIncome == 0
                  ? 0.0
                  : balance > 0
                  ? 100.0
                  : 25.0;

              final financialHealthScore =
                  (savingsScore * 0.4 +
                          budgetComplianceScore * 0.35 +
                          balanceScore * 0.25)
                      .round();

              final monthlyExpenses = <String, double>{};

              for (final transaction in transactions) {
                if (transaction.type != TransactionType.expense) continue;

                final monthKey =
                    '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';

                monthlyExpenses.update(
                  monthKey,
                  (value) => value + transaction.amount,
                  ifAbsent: () => transaction.amount,
                );
              }

              final sortedMonthlyExpenses = monthlyExpenses.entries.toList()
                ..sort((first, second) => second.key.compareTo(first.key));

              final recentMonths = sortedMonthlyExpenses.take(3).toList();

              final forecastExpense = recentMonths.isEmpty
                  ? 0.0
                  : recentMonths.fold<double>(
                          0.0,
                          (total, entry) => total + entry.value,
                        ) /
                        recentMonths.length;

              final healthColor = financialHealthScore >= 70
                  ? Colors.green
                  : financialHealthScore >= 40
                  ? Colors.orange
                  : theme.colorScheme.error;

              insights.insert(
                0,
                _InsightData(
                  title: 'Finansal sağlık puanı',
                  description:
                      'Finansal durumunuz için hesaplanan puan: $financialHealthScore/100.',
                  icon: Icons.favorite_outline,
                  color: healthColor,
                ),
              );

              if (forecastExpense > 0) {
                insights.insert(
                  1,
                  _InsightData(
                    title: 'Gelecek ay gider tahmini',
                    description:
                        'Son ${recentMonths.length} ayın ortalamasına göre gelecek ay yaklaşık '
                        '${formatMoney(forecastExpense)} gider öngörülüyor.',
                    icon: Icons.auto_graph_outlined,
                    color: Colors.blue,
                  ),
                );
              }

              final expenseTrend = previousMonthExpense == 0
                  ? 'Yeterli veri yok'
                  : currentMonthExpense > previousMonthExpense * 1.2
                  ? 'Artıyor'
                  : currentMonthExpense < previousMonthExpense * 0.8
                  ? 'Azalıyor'
                  : 'Dengeli';

              final aiSummary = AiFinancialSummary(
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                balance: balance,
                savingsRate: savingsRate,
                highestExpenseCategory: highestCategory?.key,
                highestExpenseAmount: highestCategory?.value ?? 0,
                budgetWarnings: budgetWarnings,
                expenseTrend: expenseTrend,
                financialHealthScore: financialHealthScore,
                forecastExpense: forecastExpense,
              );

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  AiInsightCard(summary: aiSummary.toPromptText()),
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
                        leading: Icon(
                          insight.icon,
                          color: insight.color,
                          size: 32,
                        ),
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
