class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String? flag; // optional UI support

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    this.flag,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'],
      name: json['name'],
      nativeName: json['nativeName'],
      flag: json['flag'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'flag': flag,
    };
  }

  LanguageModel copyWith({
    String? code,
    String? name,
    String? nativeName,
    String? flag,
  }) {
    return LanguageModel(
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      flag: flag ?? this.flag,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LanguageModel &&
        other.code == code &&
        other.name == name &&
        other.nativeName == nativeName &&
        other.flag == flag;
  }

  @override
  int get hashCode {
    return code.hashCode ^
        name.hashCode ^
        nativeName.hashCode ^
        flag.hashCode;
  }
}