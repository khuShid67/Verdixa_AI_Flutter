import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/language_config.dart';
import '../models/language_model.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  List<LanguageModel> get supportedLanguages =>
      LanguageConfig.languages;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final code =
        prefs.getString('language') ?? 'en';

    _locale = Locale(code);

    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('language', code);

    _locale = Locale(code);

    notifyListeners();
  }
}