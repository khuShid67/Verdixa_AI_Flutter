import '../models/language_model.dart';

class LanguageConfig {
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

  static LanguageModel getByCode(String code) {
    return languages.firstWhere(
      (l) => l.code == code,
      orElse: () => languages[0],
    );
  }
}