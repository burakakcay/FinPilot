import 'package:finpilot/features/goals/screens/add_goal_screen.dart';
import 'package:finpilot/features/goals/services/goal_service.dart';
import 'package:finpilot/shared/models/goal_model.dart';
import 'package:finpilot/shared/widgets/app_navigation_layout.dart';
import 'package:flutter/material.dart';

class GoalsScreen extends StatelessWidget {
  GoalsScreen({super.key});

  final GoalService goalService = GoalService();

  String formatMoney(double amount) {
    return '₺${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> deleteGoal(BuildContext context, GoalModel goal) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hedef silinsin mi?'),
          content: Text('${goal.title} hedefi silinecek.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      await goalService.deleteGoal(goal.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${goal.title} hedefi silindi.')));
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hedef silinirken bir hata oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppNavigationLayout(
      selectedIndex: 2,
      title: 'Tasarruf Hedeflerim',
      body: StreamBuilder<List<GoalModel>>(
        stream: goalService.watchGoals(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Hedefler yüklenirken bir hata oluştu.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = snapshot.data!;

          if (goals.isEmpty) {
            return const Center(child: Text('Henüz hedef eklenmedi.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: goals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final goal = goals[index];
              final progress = (goal.currentAmount / goal.targetAmount)
                  .clamp(0.0, 1.0)
                  .toDouble();
              final remaining = goal.targetAmount - goal.currentAmount;
              final percentage = (progress * 100).toStringAsFixed(0);

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.savings_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              goal.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Hedefi Düzenle',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddGoalScreen(goal: goal),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Hedefi Sil',
                            onPressed: () {
                              deleteGoal(context, goal);
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Birikim: ${formatMoney(goal.currentAmount)}'),
                          Text('Hedef: ${formatMoney(goal.targetAmount)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$percentage% tamamlandı • '
                        'Kalan: ${formatMoney(remaining)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hedef tarihi: ${formatDate(goal.targetDate)}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoalScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Hedef Ekle'),
      ),
    );
  }
}
