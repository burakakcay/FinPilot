import 'package:finpilot/features/goals/services/goal_service.dart';
import 'package:finpilot/shared/models/goal_model.dart';
import 'package:flutter/material.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key, this.goal});

  final GoalModel? goal;

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final targetAmountController = TextEditingController();
  final currentAmountController = TextEditingController(text: '0');
  final GoalService goalService = GoalService();

  late DateTime selectedTargetDate;

  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final goal = widget.goal;

    if (goal != null) {
      titleController.text = goal.title;
      targetAmountController.text = goal.targetAmount.toString();
      currentAmountController.text = goal.currentAmount.toString();
      selectedTargetDate = goal.targetDate;
    } else {
      final now = DateTime.now();
      selectedTargetDate = DateTime(now.year + 1, now.month, now.day);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    targetAmountController.dispose();
    currentAmountController.dispose();
    super.dispose();
  }

  Future<void> selectTargetDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedTargetDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;

    setState(() {
      selectedTargetDate = selectedDate;
    });
  }

  Future<void> saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final goal = GoalModel(
      id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      targetAmount: double.parse(
        targetAmountController.text.trim().replaceAll(',', '.'),
      ),
      currentAmount: double.parse(
        currentAmountController.text.trim().replaceAll(',', '.'),
      ),
      targetDate: selectedTargetDate,
    );

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      if (widget.goal == null) {
        await goalService.addGoal(goal);
      } else {
        await goalService.updateGoal(goal);
      }

      if (!mounted) return;

      Navigator.pop(context, goal);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Hedef kaydedilirken bir hata oluştu.';
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
    final isEditing = widget.goal != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Hedef Düzenle' : 'Hedef Ekle')),
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
                    isEditing ? 'Hedefi Düzenle' : 'Yeni Tasarruf Hedefi',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Birikim hedefinizi ve mevcut ilerlemenizi belirleyin.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Hedef Adı',
                      hintText: 'Örn: Tatil bütçesi',
                      prefixIcon: Icon(Icons.savings_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Hedef adı boş bırakılamaz.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: targetAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Hedef Tutar',
                      hintText: '0,00',
                      prefixIcon: Icon(Icons.flag_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(
                        value?.trim().replaceAll(',', '.') ?? '',
                      );

                      if (amount == null || amount <= 0) {
                        return 'Geçerli bir hedef tutar girin.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: currentAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Mevcut Birikim',
                      hintText: '0,00',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final currentAmount = double.tryParse(
                        value?.trim().replaceAll(',', '.') ?? '',
                      );
                      final targetAmount = double.tryParse(
                        targetAmountController.text.trim().replaceAll(',', '.'),
                      );

                      if (currentAmount == null || currentAmount < 0) {
                        return 'Geçerli bir birikim tutarı girin.';
                      }

                      if (targetAmount != null &&
                          currentAmount > targetAmount) {
                        return 'Mevcut birikim hedef tutarı aşamaz.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: selectTargetDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      'Hedef Tarihi: '
                      '${selectedTargetDate.day.toString().padLeft(2, '0')}/'
                      '${selectedTargetDate.month.toString().padLeft(2, '0')}/'
                      '${selectedTargetDate.year}',
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
                      onPressed: isSaving ? null : saveGoal,
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
                            : isEditing
                            ? 'Hedefi Güncelle'
                            : 'Hedefi Kaydet',
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
