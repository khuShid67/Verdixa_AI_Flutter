class ScanModel {
  final int? id;
  final String email;
  final String imagePath;
  final String disease;
  final double confidence;
  final String date;

  ScanModel({
    this.id,
    required this.email,
    required this.imagePath,
    required this.disease,
    required this.confidence,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'imagePath': imagePath,
      'disease': disease,
      'confidence': confidence,
      'date': date,
    };
  }

  factory ScanModel.fromMap(Map<String, dynamic> map) {
    return ScanModel(
      id: map['id'],
      email: map['email'],
      imagePath: map['imagePath'],
      disease: map['disease'],
      confidence: map['confidence'],
      date: map['date'],
    );
  }
}