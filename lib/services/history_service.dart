import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/detection_history_model.dart';

class HistoryService {
  static const String baseUrl = "http://10.191.21.171:8000";

  static Future<List<DetectionHistoryModel>> getHistory(String email) async {
    final response = await http.get(
      Uri.parse("$baseUrl/history?user_email=$email"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data
          .map((e) => DetectionHistoryModel.fromJson(e))
          .toList()
          .reversed
          .toList();
    }

    return [];
  }
}