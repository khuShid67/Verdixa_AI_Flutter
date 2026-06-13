import 'package:translator/translator.dart';
import 'package:flutter/material.dart';

class TranslationService {
  static final GoogleTranslator _translator = GoogleTranslator();

  static final Map<String, String> _cache = {};
  static final Map<String, Future<String>> _inProgress = {};

  static String _normalizeLang(String lang) {
    return lang.toLowerCase().split('-').first;
  }

  static String _key(String text, String lang) {
    return '${_normalizeLang(lang)}_${text.trim().toLowerCase()}';
  }

  static Future<String> translate(
    String text,
    String targetLanguage,
  ) async {
    if (text.trim().isEmpty) return text;

    final lang = _normalizeLang(targetLanguage);

    if (lang == 'en') return text;

    final cacheKey = _key(text, lang);

    // Return cached result
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // Prevent duplicate API calls
    if (_inProgress.containsKey(cacheKey)) {
      return _inProgress[cacheKey]!;
    }

    final future = _translateFromApi(text, lang);
    _inProgress[cacheKey] = future;

    final result = await future;

    _inProgress.remove(cacheKey);
    _cache[cacheKey] = result;

    return result;
  }

  static Future<String> _translateFromApi(
    String text,
    String lang,
  ) async {
    try {
      final translation = await _translator.translate(
        text,
        to: lang,
      );

      return translation.text;
    } catch (e) {
      debugPrint('Translation Error: $e');
      return text;
    }
  }

  static Future<List<String>> translateList(
    List<String> texts,
    String targetLanguage,
  ) async {
    final lang = _normalizeLang(targetLanguage);

    return Future.wait(
      texts.map((t) => translate(t, lang)),
    );
  }

  static void clearCache() {
    _cache.clear();
    _inProgress.clear();
  }

  static int get cacheSize => _cache.length;
}