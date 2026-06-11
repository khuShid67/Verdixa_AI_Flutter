import 'package:translator/translator.dart';
import 'package:flutter/material.dart';

class TranslationService {
  static final GoogleTranslator _translator =
      GoogleTranslator();

  static final Map<String, String> _cache = {};

  static Future<String> translate(
    String text,
    String targetLanguage,
  ) async {
    // Skip empty text
    if (text.trim().isEmpty) {
      return text;
    }

    // English = no translation needed
    if (targetLanguage == 'en') {
      return text;
    }

    final cacheKey =
        '${targetLanguage}_${text.toLowerCase()}';

    // Cached translation
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final translation =
          await _translator.translate(
        text,
        to: targetLanguage,
      );

      final translatedText =
          translation.text;

      _cache[cacheKey] =
          translatedText;

      return translatedText;
    } catch (e) {
      debugPrint(
        'Translation Error: $e',
      );

      return text;
    }
  }

  static Future<List<String>>
      translateList(
    List<String> texts,
    String targetLanguage,
  ) async {
    return Future.wait(
      texts.map(
        (text) => translate(
          text,
          targetLanguage,
        ),
      ),
    );
  }

  static void clearCache() {
    _cache.clear();
  }

  static int get cacheSize =>
      _cache.length;
}