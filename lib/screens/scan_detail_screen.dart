import 'package:flutter/material.dart';
import '../models/detection_history_model.dart';
import '../services/recommendation_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;

class ScanDetailScreen extends StatefulWidget {
  final DetectionHistoryModel scan;

  const ScanDetailScreen({super.key, required this.scan});

  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen> {
  Map<String, dynamic>? recommendation;
  bool loading = true;

  final String baseUrl = "http://10.191.21.171:8000";

  @override
  void initState() {
    super.initState();
    loadRecommendation();
  }

  Future<void> loadRecommendation() async {
    try {
      final data = await RecommendationService.get(
        widget.scan.diseaseName,
      );

      if (mounted) {
        setState(() {
          recommendation = data;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          recommendation = null;
          loading = false;
        });
      }
    }
  }

  // ================= IMAGE =================
  Widget buildImage(String path) {
    final url = _buildUrl(path);

    if (kIsWeb) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _errorImage(),
      );
    } else {
      final file = File(path);

      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => _errorImage(),
        );
      } else {
        return Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => _errorImage(),
        );
      }
    }
  }

  String _buildUrl(String path) {
    if (path.startsWith("http")) return path;
    return "$baseUrl$path";
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
    final color = Theme.of(context).colorScheme;

    final isWeb = MediaQuery.of(context).size.width > 700;
    final contentWidth = isWeb ? 700.0 : double.infinity;

    if (loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: color.primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_format(scan.diseaseName)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ================= IMAGE =================
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: buildImage(scan.imagePath),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= INFO GRID =================
                _infoGrid(scan),

                const SizedBox(height: 20),

                _section("Symptoms", recommendation?["symptoms"], Icons.healing),
                _section("Organic Treatment",
                    recommendation?["organic_treatment"], Icons.eco),
                _section("Chemical Treatment",
                    recommendation?["chemical_treatment"], Icons.science),
                _section("Prevention",
                    recommendation?["prevention"], Icons.shield),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= INFO GRID =================
  Widget _infoGrid(DetectionHistoryModel scan) {
    final items = [
      _infoItem(Icons.local_florist, "Disease", _format(scan.diseaseName)),
      _infoItem(Icons.percent, "Confidence",
          "${(scan.confidence * 100).toStringAsFixed(1)}%"),
      _infoItem(Icons.warning_amber, "Severity",
          recommendation?["severity"] ?? "N/A"),
      _infoItem(Icons.verified, "Status",
          recommendation?["status"] ?? "N/A"),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) => items[index],
    );
  }

  Widget _infoItem(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ================= SECTION =================
  Widget _section(String title, dynamic content, IconData icon) {
    String text;

    if (content == null) {
      text = "Not available";
    } else if (content is List) {
      text = content.join(", ");
    } else {
      text = content.toString();
    }

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
          Text(text),
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