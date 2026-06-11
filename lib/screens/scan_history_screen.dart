import 'dart:io';

import 'package:flutter/material.dart';

import '../models/scan_model.dart';
import '../services/auth_service.dart';
import '../services/scan_service.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() =>
      _ScanHistoryScreenState();
}

class _ScanHistoryScreenState
    extends State<ScanHistoryScreen> {
  List<ScanModel> scans = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadScans();
  }

  Future<void> loadScans() async {
    final email =
        await AuthService.currentUser();

    if (email != null) {
      scans =
          await ScanService.getUserScans(
        email,
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Scans"),
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : scans.isEmpty
              ? const Center(
                  child: Text(
                    "No scans yet",
                  ),
                )
              : ListView.builder(
                  itemCount: scans.length,
                  itemBuilder: (context, index) {
                    final scan =
                        scans[index];

                    return Card(
                      margin:
                          const EdgeInsets.all(
                        8,
                      ),
                      child: ListTile(
                        leading:
                            File(scan.imagePath)
                                    .existsSync()
                                ? Image.file(
                                    File(
                                      scan.imagePath,
                                    ),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.image,
                                  ),

                        title: Text(
                          scan.disease,
                        ),

                        subtitle: Text(
                          "Confidence: ${(scan.confidence * 100).toStringAsFixed(1)}%\n${scan.date}",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}