import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../services/history_service.dart';
import '../models/detection_history_model.dart';
import '../services/auth_service.dart';
import '../services/usage_service.dart';
import 'login_screen.dart';
import '../models/prediction_model.dart';
import '../services/api_service.dart';
import '../widgets/translated_text.dart';
import 'result_screen.dart';
import 'settings_screen.dart';
import '../models/scan_model.dart';
import '../services/scan_service.dart';
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

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        selectedImage = image;
        imageBytes = bytes;
      });
    } catch (e) {
      _showMessage("Failed to select image");
    }
  }

  Future<void> captureImage() async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        selectedImage = image;
        imageBytes = bytes;
      });
    } catch (e) {
      _showMessage("Failed to capture image");
    }
  }

  Future<void> selectImageSource() async {
    final loggedIn = await AuthService.isLoggedIn();

    if (!loggedIn) {
      final usage = await UsageService.getUsage();

      if (usage >= 3) {
        _showMessage(
          "Free limit reached. Please login to continue.",
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
        return;
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  captureImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage();
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

    setState(() {
      isLoading = true;
    });

    try {
      final PredictionModel? result =
          await ApiService.predictDisease(selectedImage!);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (result == null) {
        _showMessage("Failed to connect to server");
        return;
      }

      final loggedIn = await AuthService.isLoggedIn();

      if (!loggedIn) {
        await UsageService.incrementUsage();
      }

      await HistoryService.addDetection(
        DetectionHistoryModel(
          imagePath: selectedImage!.path,
          diseaseName: result.prediction,
          confidence: result.confidence,
          date: DateTime.now(),
        ),
      );

      final currentUser = await AuthService.currentUser();

      if (currentUser != null) {
        await ScanService.saveScan(
          ScanModel(
            email: currentUser,
            imagePath: selectedImage!.path,
            disease: result.prediction,
            confidence: result.confidence,
            date: DateTime.now().toIso8601String(),
          ),
        );
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
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage("Something went wrong");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TranslatedText(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Disease Detection"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              final loggedIn =
                  await AuthService.isLoggedIn();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => loggedIn
                      ? const ProfileScreen()
                      : const LoginScreen(),
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

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  child: selectedImage == null
                      ? Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_search_rounded,
                              size: 70,
                              color:
                                  theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            TranslatedText(
                              "Select a leaf image",
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius:
                              BorderRadius.circular(20),
                          child: kIsWeb
                              ? Image.memory(
                                  imageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(selectedImage!.path),
                                ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  onPressed:
                      isLoading ? null : selectImageSource,
                  label: const TranslatedText(
                    "Choose Image",
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.analytics),
                  onPressed: selectedImage == null || isLoading
                      ? null
                      : analyzeLeaf,
                  label: isLoading
                      ? const TranslatedText("Analyzing...")
                      : const TranslatedText("Analyze"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}