import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/translated_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const TranslatedText(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // ================= THEME CARD =================

          Card(
            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),

              child: Consumer<ThemeProvider>(
                builder: (
                  context,
                  themeProvider,
                  child,
                ) {
                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: TranslatedText(
                          "Theme",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      RadioListTile<ThemeMode>(
                        secondary: const Icon(
                          Icons.light_mode,
                        ),

                        title: const TranslatedText(
                          "Light Mode",
                        ),

                        value: ThemeMode.light,

                        groupValue:
                            themeProvider.themeMode,

                        onChanged: (value) {
                          themeProvider.setTheme(
                            value!,
                          );
                        },
                      ),

                      RadioListTile<ThemeMode>(
                        secondary: const Icon(
                          Icons.dark_mode,
                        ),

                        title: const TranslatedText(
                          "Dark Mode",
                        ),

                        value: ThemeMode.dark,

                        groupValue:
                            themeProvider.themeMode,

                        onChanged: (value) {
                          themeProvider.setTheme(
                            value!,
                          );
                        },
                      ),

                      RadioListTile<ThemeMode>(
                        secondary: const Icon(
                          Icons.phone_android,
                        ),

                        title: const TranslatedText(
                          "System Default",
                        ),

                        value: ThemeMode.system,

                        groupValue:
                            themeProvider.themeMode,

                        onChanged: (value) {
                          themeProvider.setTheme(
                            value!,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ================= LANGUAGE CARD =================

          Card(
            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),

              child: Consumer<LanguageProvider>(
                builder: (
                  context,
                  langProvider,
                  child,
                ) {
                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: TranslatedText(
                          "Language",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      ...langProvider
                          .supportedLanguages
                          .map(
                        (language) {
                          return RadioListTile<
                              String>(
                            secondary:
                                const Icon(
                              Icons.language,
                            ),

                            title: Text(
                              language.nativeName,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            subtitle: Text(
                              language.name,
                            ),

                            value:
                                language.code,

                            groupValue:
                                langProvider
                                    .locale
                                    .languageCode,

                            onChanged:
                                (value) {
                              if (value !=
                                  null) {
                                langProvider
                                    .setLanguage(
                                  value,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}