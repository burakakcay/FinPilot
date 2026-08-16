import 'dart:async';
import 'package:finpilot/core/theme/app_theme.dart';
import 'package:finpilot/features/goals/services/goal_service.dart';
import 'package:finpilot/features/transactions/screens/add_transaction_screen.dart';
import 'package:finpilot/features/transactions/services/transaction_service.dart';
import 'package:finpilot/shared/models/goal_model.dart';
import 'package:finpilot/shared/models/transaction_model.dart';
import 'package:finpilot/shared/widgets/app_navigation_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionService transactionService = TransactionService();
  final List<TransactionModel> transactions = [];
  final GoalService goalService = GoalService();
  final List<GoalModel> goals = [];

  late final StreamSubscription<List<TransactionModel>>
  transactionsSubscription;
  late final StreamSubscription<List<GoalModel>> goalsSubscription;

  String? hoveredTransactionId;

  @override
  void initState() {
    super.initState();

    transactionsSubscription = transactionService.watchTransactions().listen((
      transactionsFromFirestore,
    ) {
      if (!mounted) return;

      setState(() {
        transactions
          ..clear()
          ..addAll(transactionsFromFirestore);
      });
    });
    goalsSubscription = goalService.watchGoals().listen((goalsFromFirestore) {
      if (!mounted) return;

      setState(() {
        goals
          ..clear()
          ..addAll(goalsFromFirestore);
      });
    });
  }

  @override
  void dispose() {
    transactionsSubscription.cancel();
    goalsSubscription.cancel();
    super.dispose();
  }

  // Gelir işlemlerinin toplam tutarını hesaplar.
  double get totalIncome {
    return transactions
        .where((transaction) => transaction.type == TransactionType.income)
        .fold(0, (total, transaction) => total + transaction.amount);
  }

  // Gider işlemlerinin toplam tutarını hesaplar.
  double get totalExpense {
    return transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold(0, (total, transaction) => total + transaction.amount);
  }

  // Mevcut bakiyeyi gelir ve gider farkından üretir.
  double get balance => totalIncome - totalExpense;

  // Tüm tasarruf hedeflerindeki mevcut birikim toplamını hesaplar.
  double get totalSavings {
    return goals.fold(0, (total, goal) => total + goal.currentAmount);
  }

  String formatMoney(double amount) {
    final formattedAmount = amount
        .abs()
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    return amount < 0 ? '- ₺$formattedAmount' : '₺$formattedAmount';
  }

  // İşlem formunu açar ve kaydedilen işlemi geçici listeye ekler.
  Future<void> openAddTransaction() async {
    await Navigator.push<TransactionModel>(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );
  }

  // Seçilen işlemi listeden kaldırır ve toplamları otomatik günceller.
  void deleteTransaction(TransactionModel transaction) async {
    try {
      await transactionService.deleteTransaction(transaction.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${transaction.title} silindi.')));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İşlem silinirken bir hata oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppNavigationLayout(
      selectedIndex: 0,
      title: '',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoş geldiniz!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Finansal durumunuzun özeti',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    DashboardSummaryCard(
                      title: 'Toplam Bakiye',
                      amount: formatMoney(balance),
                      icon: Icons.account_balance_wallet_outlined,
                      accentColor: AppTheme.balanceAccent,
                    ),
                    DashboardSummaryCard(
                      title: 'Gelir',
                      amount: formatMoney(totalIncome),
                      icon: Icons.trending_up,
                      accentColor: AppTheme.incomeAccent,
                    ),
                    DashboardSummaryCard(
                      title: 'Gider',
                      amount: formatMoney(totalExpense),
                      icon: Icons.trending_down,
                      accentColor: AppTheme.expenseAccent,
                    ),
                    DashboardSummaryCard(
                      title: 'Tasarruf',
                      amount: formatMoney(totalSavings),
                      icon: Icons.savings_outlined,
                      accentColor: AppTheme.savingsAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Son İşlemler',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (transactions.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('Henüz işlem eklenmedi.')),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: transactions.map((transaction) {
                        final isIncome =
                            transaction.type == TransactionType.income;

                        return MouseRegion(
                          onEnter: (_) {
                            setState(() {
                              hoveredTransactionId = transaction.id;
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              hoveredTransactionId = null;
                            });
                          },
                          child: ListTile(
                            leading: Icon(
                              isIncome
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: isIncome
                                  ? Colors.green
                                  : theme.colorScheme.error,
                            ),
                            title: Text(transaction.title),
                            subtitle: Text(
                              '${transaction.category} • '
                              '${transaction.date.day.toString().padLeft(2, '0')}/'
                              '${transaction.date.month.toString().padLeft(2, '0')}/'
                              '${transaction.date.year}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${isIncome ? '+' : '-'} ${formatMoney(transaction.amount)}',
                                  style: TextStyle(
                                    color: isIncome
                                        ? Colors.green
                                        : theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!kIsWeb ||
                                    hoveredTransactionId == transaction.id) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    tooltip: 'İşlemi Düzenle',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddTransactionScreen(
                                                transaction: transaction,
                                              ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    tooltip: 'İşlemi Sil',
                                    onPressed: () {
                                      deleteTransaction(transaction);
                                    },
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddTransaction,
        icon: const Icon(Icons.add),
        label: const Text('İşlem Ekle'),
      ),
    );
  }
}

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    amount,
                    style: theme.textTheme.titleLarge?.copyWith(
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
