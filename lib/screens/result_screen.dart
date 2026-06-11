import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/prediction_model.dart';
import '../widgets/translated_text.dart';

String formatDisease(String value) {
  if (value.isEmpty) return "Unknown Disease";

  // remove plant part
  if (value.contains("___")) {
    value = value.split("___").last;
  }

  // replace underscores with spaces
  value = value.replaceAll("_", " ");

  // capitalize nicely
  return value
      .split(" ")
      .map((word) => word.isEmpty
          ? word
          : word[0].toUpperCase() + word.substring(1))
      .join(" ");
}

class ResultScreen extends StatelessWidget {
  final PredictionModel result;
  final XFile imageFile;

  const ResultScreen({
    super.key,
    required this.result,
    required this.imageFile,
  });

  String formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() +
                    word.substring(1),
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnknown =
        result.status.toLowerCase().contains(
              "unknown",
            );

    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText(
          "Analysis Result",
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            // ================= IMAGE =================

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 240,
                width: double.infinity,
                child: kIsWeb
                    ? Image.network(
                        imageFile.path,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(imageFile.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= RESULT CARD =================

            Card(
              elevation: 4,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  children: [
                    

                    const SizedBox(height: 12),

                    TranslatedText(
                      result.prediction.isEmpty
                          ? "Unknown Disease"
                          : formatDisease(result.prediction),

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const TranslatedText(
                          "Status",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const Text(": "),

                        Expanded(
                          child:
                              TranslatedText(
                            result.status,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const TranslatedText(
                          "Confidence",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const Text(": "),

                        Expanded(
                          child: Text(
                            "${(result.confidence).toStringAsFixed(2)}%",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= UNKNOWN DISEASE =================

            if (isUnknown)
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const TranslatedText(
                        "Nearest Matching Diseases",

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      if (result.nearestDiseases != null &&
                          result.nearestDiseases!
                              .isNotEmpty)

                        ...result
                            .nearestDiseases!
                            .map(
                          (disease) => Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 4,
                            ),

                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                const Text("• "),

                                Expanded(
                                  child:
                                      TranslatedText(
                                    formatDisease(disease),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )

                      else
                        const TranslatedText(
                          "No similar diseases found.",
                        ),
                    ],
                  ),
                ),
              ),

            // ================= KNOWN DISEASE =================

            if (!isUnknown &&
                result.recommendation != null &&
                result.recommendation!
                    .isNotEmpty)

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const TranslatedText(
                        "Disease Information",

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      ...result
                          .recommendation!
                          .entries
                          .where((entry) =>
                          entry.key.toLowerCase() != "plant" &&
                          entry.key.toLowerCase() != "description")
                          .map(
                        (entry) => Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 16,
                          ),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              TranslatedText(
                                formatKey(
                                  entry.key,
                                ),

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              TranslatedText(
                                entry.value
                                    .toString(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ================= MESSAGE =================

            if (result.message != null &&
                result.message!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: TranslatedText(
                    result.message!,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}