import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../models/prediction_model.dart';
import '../config/app_config.dart';

class ApiService {

  static Future<PredictionModel?> predictDisease(
      XFile imageFile) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${AppConfig.baseUrl}/predict"),
      );

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

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return PredictionModel.fromJson(data);
      } else {
        print("Server Error: $responseBody");
        return null;
      }

    } catch (e, s) {
      print("API Error: $e");
      print(s);
      return null;
    }
  }
}