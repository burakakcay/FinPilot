import 'package:finpilot/features/auth/services/auth_service.dart';
import 'package:finpilot/features/transactions/screens/add_transaction_screen.dart';
import 'package:finpilot/shared/models/transaction_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService authService = AuthService();
  final List<TransactionModel> transactions = [];

  bool isLoading = false;
  String? hoveredTransactionId;

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

  String formatMoney(double amount) {
    return '₺${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // İşlem formunu açar ve kaydedilen işlemi geçici listeye ekler.
  Future<void> openAddTransaction() async {
    final transaction = await Navigator.push<TransactionModel>(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );

    if (transaction == null || !mounted) return;

    setState(() {
      transactions.insert(0, transaction);
    });
  }

  // Seçilen işlemi listeden kaldırır ve toplamları otomatik günceller.
  void deleteTransaction(TransactionModel transaction) {
    setState(() {
      transactions.removeWhere((item) => item.id == transaction.id);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${transaction.title} silindi.')));
  }

  // Firebase oturumunu kapatır; AuthGate aktifken Login ekranına dönülür.
  Future<void> logout() async {
    setState(() {
      isLoading = true;
    });

    try {
      await authService.logout();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinPilot Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: isLoading ? null : logout,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: const Text('Çıkış Yap'),
          ),
        ],
      ),
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
                    ),
                    DashboardSummaryCard(
                      title: 'Gelir',
                      amount: formatMoney(totalIncome),
                      icon: Icons.trending_up,
                    ),
                    DashboardSummaryCard(
                      title: 'Gider',
                      amount: formatMoney(totalExpense),
                      icon: Icons.trending_down,
                    ),
                    DashboardSummaryCard(
                      title: 'Tasarruf',
                      amount: formatMoney(balance),
                      icon: Icons.savings_outlined,
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
                                  '${isIncome ? '+' : '-'}'
                                  '${formatMoney(transaction.amount)}',
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
  });

  final String title;
  final String amount;
  final IconData icon;

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
              Icon(icon, color: theme.colorScheme.primary),
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
