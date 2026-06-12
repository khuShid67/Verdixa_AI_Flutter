import 'package:flutter/material.dart';
import '../models/detection_history_model.dart';
import '../services/history_service.dart';
import '../services/auth_service.dart';
import 'scan_detail_screen.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  List<DetectionHistoryModel> scans = [];
  bool loading = true;

  final String baseUrl = "http://10.191.21.171:8000";

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

    if (mounted) setState(() => loading = false);
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
    return "$baseUrl$path";
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
    final isWeb = MediaQuery.of(context).size.width > 700;
    final contentWidth = isWeb ? 800.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Scans"),
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
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : scans.isEmpty
                    ? const Center(
                        child: Text(
                          "No scans yet",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: scans.length,
                        itemBuilder: (context, index) {
                          final scan = scans[index];

                          return _scanCard(context, scan);
                        },
                      ),
          ),
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _scanCard(BuildContext context, DetectionHistoryModel scan) {
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
            )
          ],
        ),
        child: Row(
          children: [
            buildImage(scan.imagePath),

            const SizedBox(width: 12),

            // ================= DETAILS =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_florist,
                          size: 18, color: Colors.green),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
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
                      const Icon(Icons.bar_chart,
                          size: 16, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        "Confidence: ${(scan.confidence * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}