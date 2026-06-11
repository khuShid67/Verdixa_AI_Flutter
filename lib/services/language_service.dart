import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/language_model.dart';
import '../config/language_config.dart';

class LanguageService {
  static List<LanguageModel> get languages =>
      LanguageConfig.languages;

  static LanguageModel getByCode(String code) {
    return LanguageConfig.getByCode(code);
  }
}