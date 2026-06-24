import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../models/prediction_model.dart';
import '../widgets/translated_text.dart';

class ResultScreen extends StatelessWidget {
  final PredictionModel result;
  final XFile imageFile;

  const ResultScreen({
    super.key,
    required this.result,
    required this.imageFile,
  });

  String formatDisease(String value) {
    if (value.isEmpty) return "Unknown Disease";

    if (value.contains("___")) {
      value = value.split("___").last;
    }

    value = value.replaceAll("_", " ");

    return value
        .split(" ")
        .map((word) =>
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(" ");
  }

  String formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String formatValue(dynamic value) {
    if (value == null) return "";

    if (value is List) {
      return value.map((e) => e.toString()).join(", ");
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isWeb = MediaQuery.of(context).size.width > 800;

    final bool isUnknown =
        result.status.toLowerCase().contains("unknown");

    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText("Analysis Result"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.surface,
              color.surfaceContainerHighest.withOpacity(0.4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isWeb
            ? _buildWebLayout(context, isUnknown)
            : _buildMobileLayout(context, isUnknown),
      ),
    );
  }

  // ================= WEB LAYOUT (FIXED DASHBOARD STYLE) =================
  Widget _buildWebLayout(BuildContext context, bool isUnknown) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN (IMAGE + RESULT)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _imageBox(context),
                    const SizedBox(height: 16),
                    _resultCard(context),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // RIGHT COLUMN (ALL INFO)
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (isUnknown) _unknownCard(context),

                      if (!isUnknown &&
                          result.recommendation != null &&
                          result.recommendation!.isNotEmpty)
                        _infoCard(context),

                      if (result.message != null &&
                          result.message!.trim().isNotEmpty)
                        _messageCard(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= MOBILE LAYOUT (UNCHANGED STRUCTURE) =================
  Widget _buildMobileLayout(BuildContext context, bool isUnknown) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _imageBox(context),
          const SizedBox(height: 18),
          _resultCard(context),
          const SizedBox(height: 18),

          if (isUnknown) _unknownCard(context),

          if (!isUnknown &&
              result.recommendation != null &&
              result.recommendation!.isNotEmpty)
            _infoCard(context),

          if (result.message != null &&
              result.message!.trim().isNotEmpty)
            _messageCard(context),
        ],
      ),
    );
  }

  // ================= IMAGE =================
  Widget _imageBox(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withOpacity(0.15),
            blurRadius: 16,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: kIsWeb
            ? Image.network(imageFile.path, fit: BoxFit.cover)
            : Image.file(File(imageFile.path), fit: BoxFit.cover),
      ),
    );
  }

  // ================= RESULT CARD =================
  Widget _resultCard(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.eco, color: color.primary, size: 45),
          const SizedBox(height: 10),

          TranslatedText(
            result.prediction.isEmpty
                ? "Unknown Disease"
                : formatDisease(result.prediction),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _chip(Icons.verified, "Status", result.status),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _chip(
                  Icons.percent,
                  "Confidence",
                  "${(result.confidence * 100).toStringAsFixed(2)}%",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 6),
          TranslatedText(title,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TranslatedText(value, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ================= UNKNOWN + INFO + MESSAGE (UNCHANGED LOGIC) =================
  Widget _unknownCard(BuildContext context) => _sectionCard(
        context,
        title: "Nearest Matching Diseases",
        icon: Icons.search,
        child: Column(
          children: result.nearestDiseases!
              .map(
                (d) => ListTile(
                  leading: Icon(Icons.eco,
                      color: Theme.of(context).colorScheme.primary),
                  title: TranslatedText(formatDisease(d)),
                ),
              )
              .toList(),
        ),
      );

  Widget _infoCard(BuildContext context) => _sectionCard(
        context,
        title: "Disease Information",
        icon: Icons.info_outline,
        child: Column(
          children: result.recommendation!.entries
              .map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatedText(
                        formatKey(entry.key),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TranslatedText(formatValue(entry.value)),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      );

  Widget _messageCard(BuildContext context) => _sectionCard(
        context,
        title: "Message",
        icon: Icons.message,
        child: TranslatedText(result.message!),
      );

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final color = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color.primary),
              const SizedBox(width: 8),
              TranslatedText(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}