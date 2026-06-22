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

      if (result.success == false && result.message == "Not a leaf") {
        _showMessage("Not A Leaf Image");
        return;
      }

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
      SnackBar(content: TranslatedText(key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isWeb = kIsWeb;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectImageSource,
        icon: const Icon(Icons.document_scanner),
        label: const TranslatedText("Scan"),
      ),

      appBar: AppBar(
        title: Image.asset(
          isDark
              ? './assets/images/logo_dark.png'
              : './assets/images/logo_light.png',
          height: 120,
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

        child: isWeb
            ? _buildWebUI(context, color)
            : _buildMobileUI(context, color),
      ),
    );
  }

  // ========================= WEB UI (NEW + FIXED) =========================
  Widget _buildWebUI(BuildContext context, ColorScheme color) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // LEFT PANEL
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.eco, size: 80),
                    SizedBox(height: 20),
                    TranslatedText(
                      "AI Leaf Disease Detection",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TranslatedText(
                      "Upload a leaf image and analyze disease instantly.",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 20),

            // CENTER IMAGE UPLOAD
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: selectedImage == null
                            ? InkWell(
                                onTap: selectImageSource,
                                child: const Center(
                                  child: TranslatedText(
                                    "Click to Upload Image",
                                  ),
                                ),
                              )
                            : Image.memory(imageBytes!, fit: BoxFit.cover),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ✅ ANALYZE BUTTON (FIXED MISSING BUTTON)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: selectedImage == null || isLoading
                          ? null
                          : analyzeLeaf,
                      icon: isLoading
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Icon(Icons.analytics),
                      label: const TranslatedText("Analyze Image"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================= MOBILE UI (UNCHANGED) =========================
  Widget _buildMobileUI(BuildContext context, ColorScheme color) {
    return Column(
      children: [
        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TranslatedText(
              "Upload a leaf image and get instant AI detection",
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: selectedImage == null
                  ? InkWell(
                      onTap: selectImageSource,
                      child: const Center(
                        child: TranslatedText("Tap to Scan"),
                      ),
                    )
                  : Image.file(File(selectedImage!.path)),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed:
                  selectedImage == null || isLoading ? null : analyzeLeaf,
              icon: const Icon(Icons.analytics),
              label: TranslatedText(
                isLoading ? "Analyzing" : "Analyze Disease",
              ),
            ),
          ),
        ),
      ],
    );
  }
}