class PredictionModel {
  final bool success;
  final String prediction;
  final String status;
  final double confidence;

  final String? message;
  final String? classifierPrediction;

  final int? agreement;
  final double? distance;

  final List<dynamic>? nearestDiseases;
  final List<dynamic>? allDistances;

  final Map<String, dynamic>? recommendation;

  PredictionModel({
    required this.success,
    required this.prediction,
    required this.status,
    required this.confidence,
    this.message,
    this.classifierPrediction,
    this.agreement,
    this.distance,
    this.nearestDiseases,
    this.allDistances,
    this.recommendation,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      success: json["success"] ?? false,
      prediction: json["prediction"] ?? "",
      status: json["status"] ?? "",
      confidence: (json["confidence"] ?? 0).toDouble(),

      message: json["message"],
      classifierPrediction: json["classifier_prediction"],

      agreement: json["agreement"],
      distance: json["distance"]?.toDouble(),

      nearestDiseases: json["nearest_diseases"],
      allDistances: json["all_distances"],

      recommendation: json["recommendation"],
    );
  }
}