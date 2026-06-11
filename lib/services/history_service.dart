import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/detection_history_model.dart';

class HistoryService {
  static const String baseUrl = "http://10.191.21.171:3000";

  // SAVE detection
  static Future<void> addDetection(DetectionHistoryModel data) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/history"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data.toJson()),
      );
    } catch (e) {
      print("History Save Error: $e");
    }
  }

  // GET history (you should pass email in backend if needed)
  static Future<List<DetectionHistoryModel>> getHistory() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/history"),
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
    } catch (e) {
      print("History Fetch Error: $e");
      return [];
    }
  }

  static Future<void> clearHistory() async {
    // optional: implement backend delete API later
    print("Use backend DELETE API for this");
  }
}