import 'package:flutter/material.dart';
import '../models/detection_history_model.dart';
import '../services/history_service.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';
import 'scan_detail_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/translated_text.dart';
import '../providers/language_provider.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  List<DetectionHistoryModel> scans = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadScans();
  }

  Future<void> loadScans() async {
    try {
      final email = await AuthService.currentUser();

      if (email != null) {
        scans = await HistoryService.getHistory(email);
      }
    } catch (e) {
      debugPrint("History load error: $e");
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  String formatDiseaseName(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .skip(1)
        .join(' ')
        .trim();
  }

  String buildImageUrl(String path) {
    if (path.startsWith("http")) return path;
    return "${AppConfig.baseUrl}$path";
  }

  Widget buildImage(String path) {
    final url = buildImageUrl(path);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 70,
          height: 70,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText("Scan History"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),

            child: loading
                ? const Center(child: CircularProgressIndicator())
                : scans.isEmpty
                    ? const Center(
                        child: TranslatedText(
                          "No Scans Yet",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : isWeb
                        ? _buildWebGrid()
                        : _buildMobileList(),
          ),
        ),
      ),
    );
  }

  // =========================
  // WEB UI (NEW DASHBOARD GRID)
  // =========================
  Widget _buildWebGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3.5,
      ),
      itemCount: scans.length,
      itemBuilder: (context, index) {
        return _webCard(scans[index]);
      },
    );
  }

  Widget _webCard(DetectionHistoryModel scan) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanDetailScreen(scan: scan),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),

      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
            )
          ],
        ),

        child: Row(
          children: [
            buildImage(scan.imagePath),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TranslatedText(
                    formatDiseaseName(scan.diseaseName),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const TranslatedText(
                        "Confidence",
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        ": ${(scan.confidence * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  // =========================
  // MOBILE UI (UNCHANGED)
  // =========================
  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: scans.length,
      itemBuilder: (context, index) {
        final scan = scans[index];
        return _scanCard(scan);
      },
    );
  }

  Widget _scanCard(DetectionHistoryModel scan) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanDetailScreen(scan: scan),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
            ),
          ],
        ),

        child: Row(
          children: [
            buildImage(scan.imagePath),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.local_florist,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),

                      Expanded(
                        child: TranslatedText(
                          formatDiseaseName(scan.diseaseName),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.bar_chart,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 6),

                      Row(
                        children: [
                          const TranslatedText(
                            "Confidence Label",
                            style: TextStyle(fontSize: 13),
                          ),
                          Text(
                            ": ${(scan.confidence * 100).toStringAsFixed(1)}%",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}