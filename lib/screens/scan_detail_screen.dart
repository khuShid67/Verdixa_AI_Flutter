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
    loadRecommendation();
  }

  Future<void> loadRecommendation() async {
    try {
      final raw =
          await RecommendationService.get(widget.scan.diseaseName.trim());

      if (!mounted) return;

      dynamic data = {};

      if (raw != null && raw is Map<String, dynamic>) {
        data = raw["data"] ?? raw;
      }

      setState(() {
        recommendation = Map<String, dynamic>.from(data ?? {});
        loading = false;
      });
    } catch (e) {
      setState(() {
        recommendation = {};
        loading = false;
      });
    }
  }

  String _safe(dynamic v) {
    if (v == null) return "Not Available";
    if (v is List) return v.join(", ");
    return v.toString();
  }

  String _format(String raw) {
    return raw.replaceAll('_', ' ').split(' ').skip(1).join(' ');
  }

  Widget _image(String path) {
    final url =
        path.startsWith("http") ? path : "${AppConfig.baseUrl}$path";

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scan = widget.scan;
    final isWeb = kIsWeb;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_format(scan.diseaseName)),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.surface,
                    color.surfaceContainerHighest.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: isWeb ? _web(scan) : _mobile(scan),
            ),
    );
  }

  // ================= WEB =================
  Widget _web(DetectionHistoryModel scan) {
    final color = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                height: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                    )
                  ],
                ),
                child: _image(scan.imagePath),
              ),
            ),
            const SizedBox(width: 20),

            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _header(scan),
                    const SizedBox(height: 15),
                    _card("Symptoms", recommendation["symptoms"]),
                    _card("Organic Treatment", recommendation["organic_treatment"]),
                    _card("Chemical Treatment", recommendation["chemical_treatment"]),
                    _card("Prevention", recommendation["prevention"]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MOBILE =================
  Widget _mobile(DetectionHistoryModel scan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 260, child: _image(scan.imagePath)),
          const SizedBox(height: 16),
          _header(scan),
          const SizedBox(height: 15),
          _card("Symptoms", recommendation["symptoms"]),
          _card("Organic Treatment", recommendation["organic_treatment"]),
          _card("Chemical Treatment", recommendation["chemical_treatment"]),
          _card("Prevention", recommendation["prevention"]),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(DetectionHistoryModel scan) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surface, // ✅ theme fix
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            _format(scan.diseaseName),
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _chip("Confidence",
                  "${(scan.confidence * 100).toStringAsFixed(1)}%"),
              _chip("Status", _safe(recommendation["status"])),
              _chip("Severity", _safe(recommendation["severity"])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.5), // ✅ theme fix
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ================= CARD (THEME FIXED) =================
  Widget _card(String title, dynamic content) {
    final color = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.surface, // ✅ FIX: no Colors.white
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_safe(content)),
        ],
      ),
    );
  }
}