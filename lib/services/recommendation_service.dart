import 'dart:convert';
import 'package:http/http.dart' as http;

class RecommendationService {
  static const baseUrl = "http://10.191.21.171:8000";

  static Future<Map<String, dynamic>?> get(String disease) async {
    final res = await http.get(
      Uri.parse("$baseUrl/recommendation?disease=$disease"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return null;
  }
}