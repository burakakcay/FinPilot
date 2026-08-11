import 'package:finpilot/shared/models/transaction_model.dart';
import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  TransactionType selectedType = TransactionType.expense;
  late String selectedCategory;
  DateTime selectedDate = DateTime.now();

  // Gider türünü ve ona ait varsayılan kategoriyi form açılırken seçer.
  @override
  void initState() {
    super.initState();
    selectedCategory = TransactionCategories.expense.first;
  }

  // Form controller kaynaklarını ekran kapandığında serbest bırakır.
  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // Kullanıcının işlem tarihini takvimden seçmesini sağlar.
  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDate = pickedDate;
    });
  }

  // Formu doğrular, işlem modelini oluşturur ve dashboard'a geri gönderir.
  void saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      amount: double.parse(amountController.text.trim().replaceAll(',', '.')),
      type: selectedType,
      category: selectedCategory,
      date: selectedDate,
      note: noteController.text.trim().isEmpty
          ? null
          : noteController.text.trim(),
    );

    Navigator.pop(context, transaction);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = TransactionCategories.forType(selectedType);

    return Scaffold(
      appBar: AppBar(title: const Text('İşlem Ekle')),
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
                    'Yeni İşlem',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gelir veya gider bilgilerinizi girin.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Başlık',
                      hintText: 'Örnek: Market alışverişi',
                      prefixIcon: Icon(Icons.edit_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Başlık boş bırakılamaz.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Tutar',
                      hintText: '0,00',
                      prefixIcon: Icon(Icons.payments_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(
                        value?.trim().replaceAll(',', '.') ?? '',
                      );

                      if (amount == null || amount <= 0) {
                        return 'Geçerli bir tutar girin.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TransactionType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'İşlem Türü',
                      prefixIcon: Icon(Icons.swap_vert),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: TransactionType.income,
                        child: Text('Gelir'),
                      ),
                      DropdownMenuItem(
                        value: TransactionType.expense,
                        child: Text('Gider'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedType = value;
                        selectedCategory = TransactionCategories.forType(
                          value,
                        ).first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(selectedType),
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: categories
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
                  OutlinedButton.icon(
                    onPressed: selectDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}/'
                      '${selectedDate.month.toString().padLeft(2, '0')}/'
                      '${selectedDate.year}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Not (Opsiyonel)',
                      prefixIcon: Icon(Icons.notes_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: saveTransaction,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Kaydet'),
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
