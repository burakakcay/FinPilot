class AiFinancialSummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double savingsRate;
  final String? highestExpenseCategory;
  final double highestExpenseAmount;
  final List<String> budgetWarnings;
  final String expenseTrend;
  final int financialHealthScore;
  final double forecastExpense;

  const AiFinancialSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.savingsRate,
    required this.highestExpenseCategory,
    required this.highestExpenseAmount,
    required this.budgetWarnings,
    required this.expenseTrend,
    required this.financialHealthScore,
    required this.forecastExpense,
  });

  String toPromptText() {
    return '''
Kullanıcının finansal özeti:

Toplam gelir: ₺${totalIncome.toStringAsFixed(2)}
Toplam gider: ₺${totalExpense.toStringAsFixed(2)}
Mevcut bakiye: ₺${balance.toStringAsFixed(2)}
Tasarruf oranı: %${savingsRate.toStringAsFixed(1)}
En yüksek harcama kategorisi: ${highestExpenseCategory ?? 'Belirlenemiyor'}
Bu kategorideki harcama: ₺${highestExpenseAmount.toStringAsFixed(2)}
Harcama trendi: $expenseTrend
Finansal sağlık puanı: $financialHealthScore/100
Gelecek ay tahmini gider: ₺${forecastExpense.toStringAsFixed(2)}
Bütçe uyarıları: ${budgetWarnings.isEmpty ? 'Yok' : budgetWarnings.join(', ')}
''';
  }
}
