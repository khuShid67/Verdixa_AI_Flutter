import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../models/prediction_model.dart';
import '../config/app_config.dart';

class ApiService {

  static Future<PredictionModel?> predictDisease(
    XFile imageFile,
    String? userEmail, // ✔ FIX: nullable
  ) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${AppConfig.baseUrl}/predict"),
      );

      // ✔ ONLY send email if user is logged in
      if (userEmail != null && userEmail.isNotEmpty) {
        request.fields['user_email'] = userEmail;
      }

      final bytes = await imageFile.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          bytes,
          filename: imageFile.name,
        ),
      );

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("STATUS: ${response.statusCode}");
      print("BODY: $responseBody");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return PredictionModel.fromJson(data);
      }

      return null;

    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }
}