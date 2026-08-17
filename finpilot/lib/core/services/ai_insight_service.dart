import 'dart:convert';

import 'package:http/http.dart' as http;

class AiInsightService {
  static final Uri endpoint = Uri.parse(
    'http://localhost:3000/generate-insight',
  );

  Future<String> generateInsight(String financialSummary) async {
    final response = await http.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'summary': financialSummary}),
    );

    if (response.statusCode != 200) {
      throw Exception('AI sunucusu hata döndürdü: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return data['text'] as String? ?? 'AI içgörüsü oluşturulamadı.';
  }
}
