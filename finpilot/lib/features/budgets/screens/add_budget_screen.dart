import 'package:finpilot/features/budgets/services/budget_service.dart';
import 'package:finpilot/shared/models/budget_model.dart';
import 'package:finpilot/shared/models/transaction_model.dart';
import 'package:flutter/material.dart';

class AddBudgetScreen extends StatefulWidget {
  final BudgetModel? budget;

  const AddBudgetScreen({super.key, this.budget});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final limitController = TextEditingController();
  final BudgetService budgetService = BudgetService();

  late String selectedCategory;
  late DateTime selectedMonth;

  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final budget = widget.budget;

    if (budget != null) {
      selectedCategory = budget.category;
      limitController.text = budget.limit.toString();
      selectedMonth = budget.month;
    } else {
      selectedCategory = TransactionCategories.expense.first;
    }

    final now = DateTime.now();
    selectedMonth = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    limitController.dispose();
    super.dispose();
  }

  Future<void> selectMonth() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;

    setState(() {
      selectedMonth = DateTime(selectedDate.year, selectedDate.month);
    });
  }

  Future<void> saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    final budget = BudgetModel(
      id: widget.budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: selectedCategory,
      limit: double.parse(limitController.text.trim().replaceAll(',', '.')),
      month: selectedMonth,
    );

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      if (widget.budget == null) {
        await budgetService.addBudget(budget);
      } else {
        await budgetService.updateBudget(budget);
      }

      if (!mounted) return;

      Navigator.pop(context, budget);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Bütçe kaydedilirken bir hata oluştu.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Bütçe Ekle' : 'Bütçe Düzenle'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.budget == null ? 'Yeni Bütçe' : 'Bütçeyi Düzenle',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bir harcama kategorisi için aylık limit belirleyin.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: TransactionCategories.expense
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: limitController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Aylık Limit',
                      hintText: '0,00',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final limit = double.tryParse(
                        value?.trim().replaceAll(',', '.') ?? '',
                      );

                      if (limit == null || limit <= 0) {
                        return 'Geçerli bir limit girin.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: selectMonth,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      'Ay: ${selectedMonth.month.toString().padLeft(2, '0')}/'
                      '${selectedMonth.year}',
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (errorMessage != null) ...[
                    Text(
                      errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: isSaving ? null : saveBudget,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        isSaving
                            ? 'Kaydediliyor...'
                            : widget.budget == null
                            ? 'Bütçeyi Kaydet'
                            : 'Bütçeyi Düzenle',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
