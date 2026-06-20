import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../services/auth_service.dart';
import '../services/usage_service.dart';
import '../services/api_service.dart';

import '../widgets/translated_text.dart';

import 'login_screen.dart';
import 'result_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? selectedImage;
  Uint8List? imageBytes;
  bool isLoading = false;

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 90,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      selectedImage = image;
      imageBytes = bytes;
    });
  }

  Future<void> selectImageSource() async {
    final loggedIn = await AuthService.isLoggedIn();

    if (!loggedIn) {
      final usage = await UsageService.getUsage();

      if (usage >= 3) {
        _showMessage("Free Limit Reached");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final theme = Theme.of(context);

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              const TranslatedText(
                "Scan Leaf Image",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 10),

              ListTile(
                leading: Icon(Icons.camera_alt,
                    color: theme.colorScheme.primary),
                title: const TranslatedText("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),

              ListTile(
                leading: Icon(Icons.photo_library,
                    color: theme.colorScheme.primary),
                title: const TranslatedText("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> analyzeLeaf() async {
    if (selectedImage == null || isLoading) return;

    setState(() => isLoading = true);

    try {
      final email = await AuthService.currentUser();

      final result = await ApiService.predictDisease(
        selectedImage!,
        email,
      );

      setState(() => isLoading = false);

      if (result == null) {
        _showMessage("Server Error");
        return;
      }

      // ❌ NOT A LEAF CHECK
      if (result.success == false && result.message == "Not a leaf") {
        _showMessage("Upload a leaf image");
        return; // stay on same screen
      }

      // (optional safety check)
      if (result.prediction.isEmpty) {
        _showMessage("Invalid result");
        return;
      }

      final loggedIn = await AuthService.isLoggedIn();
      if (!loggedIn) {
        await UsageService.incrementUsage();
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            imageFile: selectedImage!,
          ),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage("Something Wrong");
    }
  }

  void _showMessage(String key) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TranslatedText(key),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectImageSource,
        icon: const Icon(Icons.document_scanner),
        label: const TranslatedText("Scan"),
      ),

      appBar: AppBar(
        centerTitle: false,
        title: Image.asset(
          isDark
              ? './assets/images/logo_dark.png'
              : './assets/images/logo_light.png',
          height: 150,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              final loggedIn = await AuthService.isLoggedIn();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      loggedIn ? const ProfileScreen() : const LoginScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
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

        child: Column(
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.eco, size: 40, color: color.primary),

                    const SizedBox(width: 10),

                    Expanded(
                      child: const TranslatedText(
                        "Upload a leaf image and get instant AI detection",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: color.shadow.withOpacity(0.1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: selectedImage == null
                        ? InkWell(
                            onTap: selectImageSource,
                            borderRadius: BorderRadius.circular(25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_search,
                                    size: 90, color: color.primary),

                                const SizedBox(height: 10),

                                const TranslatedText("Tap to Scan"),

                                const SizedBox(height: 5),

                                const TranslatedText("Use Camera Gallery"),
                              ],
                            ),
                          )
                        : kIsWeb
                            ? Image.memory(imageBytes!, fit: BoxFit.cover)
                            : Image.file(
                                File(selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: selectedImage == null || isLoading
                      ? null
                      : analyzeLeaf,
                  icon: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.analytics),

                  label: TranslatedText(
                    isLoading ? "Analyzing" : "Analyze Disease",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}