import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000";
    }

    return "http://10.230.188.171:8000";
  }
}