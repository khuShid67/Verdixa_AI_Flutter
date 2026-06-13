import '../models/language_model.dart';

class LanguageConfig {
  static const String defaultLanguageCode = 'en';

  static final List<LanguageModel> languages = [
    LanguageModel(
      code: 'en',
      name: 'English',
      nativeName: 'English',
    ),
    LanguageModel(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिंदी',
    ),
    LanguageModel(
      code: 'gu',
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
    ),
    LanguageModel(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
    ),
    LanguageModel(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
    ),
  ];

  // Fast lookup map (better performance)
  static final Map<String, LanguageModel> _languageMap = {
    for (final lang in languages) lang.code: lang,
  };

  static LanguageModel getByCode(String code) {
    final normalized = _normalize(code);

    return _languageMap[normalized] ??
        _languageMap[defaultLanguageCode]!;
  }

  static bool isSupported(String code) {
    return _languageMap.containsKey(_normalize(code));
  }

  static String _normalize(String code) {
    return code.toLowerCase().split('-').first;
  }

  static List<String> get supportedCodes =>
      languages.map((e) => e.code).toList();
}