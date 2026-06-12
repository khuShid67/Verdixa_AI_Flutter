class DetectionHistoryModel {
  final String imagePath;
  final String diseaseName;
  final double confidence;
  final String? severity;
  final String? status;
  final String? symptoms;
  final String? organicTreatment;
  final String? chemicalTreatment;
  final String? prevention;
  final DateTime? createdAt;

  DetectionHistoryModel({
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
    this.severity,
    this.status,
    this.symptoms,
    this.organicTreatment,
    this.chemicalTreatment,
    this.prevention,
    this.createdAt,
  });

  factory DetectionHistoryModel.fromJson(Map<String, dynamic> json) {
    return DetectionHistoryModel(
      imagePath: json["image_path"] ?? "",
      diseaseName: json["disease_name"] ?? "",
      confidence: (json["confidence"] ?? 0).toDouble(),
      severity: json["severity"],
      status: json["status"],
      symptoms: json["symptoms"],
      organicTreatment: json["organic_treatment"],
      chemicalTreatment: json["chemical_treatment"],
      prevention: json["prevention"],
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"])
          : null,
    );
  }
}