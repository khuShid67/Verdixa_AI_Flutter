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

    if (oldWidget.text != widget.text ||
        lang != _currentLang) {
      _updateTranslation(lang, widget.text);
    }
  }

  void _updateTranslation(String lang, String text) {
    if (lang == _currentLang && text == widget.text) return;

    _currentLang = lang;
    _loading = true;

    final int requestId = ++_requestId;

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
    final displayText = _loading
        ? widget.text // or you can show "..."
        : (_translated.isEmpty ? widget.text : _translated);

    return Text(
      displayText,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}