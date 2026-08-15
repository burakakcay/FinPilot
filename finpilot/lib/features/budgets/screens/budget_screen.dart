import 'package:finpilot/features/budgets/screens/add_budget_screen.dart';
import 'package:finpilot/features/budgets/services/budget_service.dart';
import 'package:finpilot/features/transactions/services/transaction_service.dart';
import 'package:finpilot/shared/models/budget_model.dart';
import 'package:finpilot/shared/models/transaction_model.dart';
import 'package:flutter/material.dart';

class BudgetScreen extends StatelessWidget {
  BudgetScreen({super.key});

  final BudgetService budgetService = BudgetService();
  final TransactionService transactionService = TransactionService();

  bool isSameMonth(DateTime first, DateTime second) {
    return first.year == second.year && first.month == second.month;
  }

  double calculateSpent(
    BudgetModel budget,
    List<TransactionModel> transactions,
  ) {
    return transactions
        .where(
          (transaction) =>
              transaction.type == TransactionType.expense &&
              transaction.category == budget.category &&
              isSameMonth(transaction.date, budget.month),
        )
        .fold(0, (total, transaction) => total + transaction.amount);
  }

  String formatMoney(double amount) {
    return '₺${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bütçelerim')),
      body: StreamBuilder<List<BudgetModel>>(
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

          if (budgets.isEmpty) {
            return const Center(child: Text('Henüz bütçe eklenmedi.'));
          }

          return StreamBuilder<List<TransactionModel>>(
            stream: transactionService.watchTransactions(),
            builder: (context, transactionSnapshot) {
              if (transactionSnapshot.hasError) {
                return const Center(
                  child: Text('İşlemler yüklenirken bir hata oluştu.'),
                );
              }

              if (!transactionSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final transactions = transactionSnapshot.data!;

              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: budgets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final budget = budgets[index];
                  final spent = calculateSpent(budget, transactions);
                  final remaining = budget.limit - spent;
                  final progress = (spent / budget.limit)
                      .clamp(0.0, 1.0)
                      .toDouble();
                  final isOverBudget = spent > budget.limit;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  budget.category,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${budget.month.month.toString().padLeft(2, '0')}/'
                                '${budget.month.year}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          LinearProgressIndicator(
                            value: progress,
                            color: isOverBudget
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Harcanan: ${formatMoney(spent)}'),
                              Text('Limit: ${formatMoney(budget.limit)}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isOverBudget
                                ? 'Limit aşıldı: ${formatMoney(spent - budget.limit)}'
                                : 'Kalan: ${formatMoney(remaining)}',
                            style: TextStyle(
                              color: isOverBudget
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Bütçe Ekle'),
      ),
    );
  }
}
