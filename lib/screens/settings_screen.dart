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
    final color = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const TranslatedText(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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

        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            /// ================= THEME CARD =================
            _sectionCard(
              context,
              title: "Theme",
              icon: Icons.palette,
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Column(
                    children: [
                      _radioTile(
                        context,
                        icon: Icons.light_mode,
                        title: "Light Mode",
                        value: ThemeMode.light,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) =>
                            themeProvider.setTheme(value!),
                      ),

                      _radioTile(
                        context,
                        icon: Icons.dark_mode,
                        title: "Dark Mode",
                        value: ThemeMode.dark,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) =>
                            themeProvider.setTheme(value!),
                      ),

                      _radioTile(
                        context,
                        icon: Icons.phone_android,
                        title: "System Default",
                        value: ThemeMode.system,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) =>
                            themeProvider.setTheme(value!),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// ================= LANGUAGE CARD =================
            _sectionCard(
              context,
              title: "Language",
              icon: Icons.language,
              child: Consumer<LanguageProvider>(
                builder: (context, langProvider, child) {
                  return Column(
                    children: langProvider.supportedLanguages.map((language) {
                      return _languageTile(
                        context,
                        title: language.nativeName,
                        subtitle: language.name,
                        value: language.code,
                        groupValue:
                            langProvider.locale.languageCode,
                        onChanged: (value) {
                          if (value != null) {
                            langProvider.setLanguage(value);
                          }
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= SECTION CARD =================
  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withOpacity(0.08),
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

  /// ================= THEME RADIO TILE =================
  Widget _radioTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    final color = Theme.of(context).colorScheme;

    return RadioListTile<ThemeMode>(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: color.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }

  /// ================= LANGUAGE TILE =================
  Widget _languageTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final color = Theme.of(context).colorScheme;

    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(Icons.language, color: color.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}