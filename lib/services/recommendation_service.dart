import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class RecommendationService {
  static Future<Map<String, dynamic>?> get(String disease) async {
    final uri = Uri.parse("${AppConfig.baseUrl}/recommendation")
        .replace(queryParameters: {
      "disease": disease.trim(),
    });

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      // handle both {data:{}} and direct {}
      if (data is Map && data["data"] != null) {
        return Map<String, dynamic>.from(data["data"]);
      }

      return Map<String, dynamic>.from(data);
    }

    return null;
  }
}