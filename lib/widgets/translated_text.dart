import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../services/translation_service.dart';

class TranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String _translated = '';
  bool _loading = false;

  String _currentLang = '';
  String _currentText = '';

  int _requestId = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final lang =
        context.watch<LanguageProvider>().locale.languageCode;

    _updateTranslation(lang, widget.text);
  }

  @override
  void didUpdateWidget(covariant TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final lang =
        context.read<LanguageProvider>().locale.languageCode;

    _updateTranslation(lang, widget.text);
  }

  void _updateTranslation(String lang, String text) {
    if (lang == _currentLang &&
        text == _currentText) {
      return;
    }

    _currentLang = lang;
    _currentText = text;

    setState(() {
      _loading = true;
      _translated = '';
    });

    final requestId = ++_requestId;

    TranslationService.translate(text, lang).then((result) {
      if (!mounted || requestId != _requestId) return;

      setState(() {
        _translated = result;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _loading
          ? widget.text
          : (_translated.isEmpty
                ? widget.text
                : _translated),
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}