import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000";
    }

    return "http://10.191.21.171:8000";
  }
}