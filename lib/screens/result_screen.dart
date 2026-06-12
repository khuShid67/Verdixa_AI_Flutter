import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

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

        child: SingleChildScrollView(
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
        ),
      ),
    );
  }

  // ================= IMAGE =================
  Widget _imageBox(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withOpacity(0.12),
            blurRadius: 12,
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
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
          )
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.eco, color: color.primary, size: 42),

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _chip(Icons.verified, "Status", result.status),
              _chip(Icons.percent, "Confidence",
                  "${result.confidence.toStringAsFixed(2)}%"),
            ],
          ),
        ],
      ),
    );
  }

  // ================= CHIP UI =================
  Widget _chip(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ================= UNKNOWN CARD =================
  Widget _unknownCard(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return _sectionCard(
      context,
      title: "Nearest Matching Diseases",
      icon: Icons.search,
      child: result.nearestDiseases != null &&
              result.nearestDiseases!.isNotEmpty
          ? Column(
              children: result.nearestDiseases!
                  .map(
                    (d) => ListTile(
                      leading: Icon(Icons.eco, color: color.primary),
                      title: TranslatedText(formatDisease(d)),
                    ),
                  )
                  .toList(),
            )
          : const TranslatedText("No similar diseases found."),
    );
  }

  // ================= INFO CARD =================
  Widget _infoCard(BuildContext context) {
    return _sectionCard(
      context,
      title: "Disease Information",
      icon: Icons.info_outline,
      child: Column(
        children: result.recommendation!.entries
            .where((e) =>
                e.key.toLowerCase() != "plant" &&
                e.key.toLowerCase() != "description")
            .map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          formatKey(entry.key),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TranslatedText(entry.value.toString()),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ================= MESSAGE =================
  Widget _messageCard(BuildContext context) {
    return _sectionCard(
      context,
      title: "Message",
      icon: Icons.message,
      child: TranslatedText(result.message!),
    );
  }

  // ================= SECTION WRAPPER =================
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
              Text(
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