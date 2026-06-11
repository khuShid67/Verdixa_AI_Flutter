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
  State<TranslatedText> createState() =>
      _TranslatedTextState();
}

class _TranslatedTextState
    extends State<TranslatedText> {
  String translated = "";
  String currentLanguage = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final language =
        context.watch<LanguageProvider>()
            .locale
            .languageCode;

    if (language != currentLanguage) {
      currentLanguage = language;
      translated = ""; // reset old translation
      _translate();
    }
  }

  @override
  void didUpdateWidget(
    covariant TranslatedText oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text) {
      translated = "";
      _translate();
    }
  }

  Future<void> _translate() async {
    if (widget.text.trim().isEmpty) return;

    final result =
        await TranslationService.translate(
      widget.text,
      currentLanguage,
    );

    if (!mounted) return;

    setState(() {
      translated = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      translated.isEmpty
          ? widget.text
          : translated,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}