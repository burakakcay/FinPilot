import 'package:finpilot/core/services/ai_insight_service.dart';
import 'package:flutter/material.dart';

class AiInsightCard extends StatefulWidget {
  const AiInsightCard({super.key, required this.summary});

  final String summary;

  @override
  State<AiInsightCard> createState() => _AiInsightCardState();
}

class _AiInsightCardState extends State<AiInsightCard> {
  final AiInsightService aiInsightService = AiInsightService();

  bool isLoading = false;
  String? aiText;

  Future<void> generateInsight() async {
    setState(() {
      isLoading = true;
      aiText = null;
    });

    try {
      final result = await aiInsightService.generateInsight(widget.summary);

      if (!mounted) return;

      setState(() {
        aiText = result;
      });
    } catch (error) {
      debugPrint('AI error: $error');

      if (!mounted) return;

      setState(() {
        aiText = 'AI hatası: $error';
      });
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

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'AI Finansal Değerlendirme',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (aiText != null)
              Text(aiText!, style: theme.textTheme.bodyLarge)
            else
              Text(
                'Finansal durumunuz hakkında yapay zekâ destekli kısa bir değerlendirme alın.',
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isLoading ? null : generateInsight,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                isLoading ? 'Değerlendiriliyor...' : 'AI ile Değerlendir',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
