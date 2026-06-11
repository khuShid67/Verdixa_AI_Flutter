class DetectionHistoryModel {
  final String imagePath;
  final String diseaseName;
  final double confidence;
  final DateTime date;

  DetectionHistoryModel({
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      "imagePath": imagePath,
      "diseaseName": diseaseName,
      "confidence": confidence,
      "date": date.toIso8601String(),
    };
  }

  factory DetectionHistoryModel.fromJson(Map<String, dynamic> json) {
    return DetectionHistoryModel(
      imagePath: json["imagePath"],
      diseaseName: json["diseaseName"],
      confidence: json["confidence"],
      date: DateTime.parse(json["date"]),
    );
  }
}