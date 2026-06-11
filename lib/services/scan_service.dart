import 'package:hive_flutter/hive_flutter.dart';

import '../models/scan_model.dart';

class ScanService {
  static Future<void> saveScan(
    ScanModel scan,
  ) async {
    final scansBox = Hive.box('scans');

    final scans =
        List<Map<String, dynamic>>.from(
      scansBox.get(scan.email, defaultValue: []),
    );

    scans.add({
      'email': scan.email,
      'imagePath': scan.imagePath,
      'disease': scan.disease,
      'confidence': scan.confidence,
      'date': scan.date,
    });

    await scansBox.put(
      scan.email,
      scans,
    );
  }

  static Future<List<ScanModel>> getUserScans(
    String email,
  ) async {
    final scansBox = Hive.box('scans');

    final scans =
        List<Map<String, dynamic>>.from(
      scansBox.get(email, defaultValue: []),
    );

    return scans.map((scan) {
      return ScanModel(
        email: scan['email'],
        imagePath: scan['imagePath'],
        disease: scan['disease'],
        confidence:
            (scan['confidence'] as num).toDouble(),
        date: scan['date'],
      );
    }).toList().reversed.toList();
  }
}