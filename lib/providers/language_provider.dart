import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/language_config.dart';
import '../models/language_model.dart';
import '../services/translation_service.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  bool _initialized = false;
  bool _isChanging = false;

  Locale get locale => _locale;
  bool get isLoading => _isChanging;
  bool get isInitialized => _initialized;

  List<LanguageModel> get supportedLanguages =>
      LanguageConfig.languages;

  LanguageModel get currentLanguage =>
      LanguageConfig.getByCode(_locale.languageCode);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final code = prefs.getString('language') ?? 'en';

    _locale = _safeLocale(code);

    _initialized = true;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _isChanging = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    final safeCode = _safeLocale(code).languageCode;

    await prefs.setString('language', safeCode);

    // IMPORTANT: clear translation cache when language changes
    TranslationService.clearCache();

    _locale = Locale(safeCode);

    _isChanging = false;
    notifyListeners();
  }

  Locale _safeLocale(String code) {
    final normalized = code.toLowerCase();

    final exists = supportedLanguages.any(
      (lang) => lang.code == normalized,
    );

    if (!exists) return const Locale('en');

    return Locale(normalized);
  }
}