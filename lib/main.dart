import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  final languageProvider = LanguageProvider();
  await languageProvider.init();
  await StorageService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: themeProvider,
        ),
        ChangeNotifierProvider.value(
          value: languageProvider,
        ),
      ],
      child: const PlantDiseaseApp(),
    ),
  );
}

class PlantDiseaseApp extends StatelessWidget {
  const PlantDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Verdixa AI',

          // 🌍 LANGUAGE
          locale: languageProvider.locale,

          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('gu'), // Gujarati
            Locale('es'), // Spanish (example)
            Locale('fr'),  // French (example)
             Locale('de'), //German
          ],

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // 🎨 THEMES
          theme: ThemeData(
            colorSchemeSeed: Colors.green,
            brightness: Brightness.light,
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            colorSchemeSeed: Colors.green,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),

          themeMode: themeProvider.themeMode,

          home: const SplashScreen(),
        );
      },
    );
  }
}