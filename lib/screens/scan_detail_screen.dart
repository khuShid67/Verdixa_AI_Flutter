import 'package:flutter/material.dart';
import '../models/detection_history_model.dart';
import '../services/recommendation_service.dart';
import '../config/app_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;

class ScanDetailScreen extends StatefulWidget {
  final DetectionHistoryModel scan;

  const ScanDetailScreen({super.key, required this.scan});

  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen> {
  Map<String, dynamic> recommendation = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadRecommendation();
    });
  }

  Future<void> loadRecommendation() async {
    try {
      final diseaseName = widget.scan.diseaseName.trim();

      final raw = await RecommendationService.get(diseaseName);

      if (!mounted) return;

      if (raw == null) {
        setState(() {
          recommendation = {};
          loading = false;
        });
        return;
      }

      final data = (raw is Map && raw["data"] != null)
          ? raw["data"]
          : raw;

      setState(() {
        recommendation = Map<String, dynamic>.from(data);
        loading = false;
      });
    } catch (e) {
      debugPrint("Recommendation error: $e");
      setState(() {
        recommendation = {};
        loading = false;
      });
    }
  }

  String _safeText(dynamic value) {
    if (value == null) return "Not Available";
    if (value is List) return value.join(", ");
    return value.toString();
  }

  Widget buildImage(String path) {
    final url = _buildUrl(path);

    if (kIsWeb) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _errorImage(),
      );
    }

    try {
      final file = File(path);

      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => _errorImage(),
        );
      }
    } catch (e) {
      debugPrint("File error: $e");
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => _errorImage(),
    );
  }

  String _buildUrl(String path) {
    if (path.startsWith("http")) return path;
    return "${AppConfig.baseUrl}$path";
  }

  Widget _errorImage() {
    return Container(
      height: 260,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scan = widget.scan;
    final isWeb = MediaQuery.of(context).size.width > 700;
    final contentWidth = isWeb ? 700.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: Text(_format(scan.diseaseName)),
        centerTitle: true,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),

          child: loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 260,
                          width: double.infinity,
                          child: buildImage(scan.imagePath),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _infoGrid(scan),

                      const SizedBox(height: 20),

                      _section("Symptoms", recommendation["symptoms"], Icons.healing),
                      _section("Organic Treatment", recommendation["organic_treatment"], Icons.eco),
                      _section("Chemical Treatment", recommendation["chemical_treatment"], Icons.science),
                      _section("Prevention", recommendation["prevention"], Icons.shield),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _infoGrid(DetectionHistoryModel scan) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),

      children: [
        _infoItem("Disease", _format(scan.diseaseName)),
        _infoItem("Confidence",
            "${(scan.confidence * 100).toStringAsFixed(1)}%"),
        _infoItem("Severity", _safeText(recommendation["severity"])),
        _infoItem("Status", _safeText(recommendation["status"])),
      ],
    );
  }

  Widget _infoItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(value, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _section(String title, dynamic content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
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
          const SizedBox(height: 10),
          Text(_safeText(content)),
        ],
      ),
    );
  }

  String _format(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .skip(1)
        .join(' ')
        .trim();
  }
}