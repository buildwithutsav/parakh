class FeedTestResult {
  const FeedTestResult({
    required this.id,
    required this.feedType,
    required this.testType,
    required this.score,
    required this.riskLevel,
    required this.phValue,
    required this.nutritionStatus,
    required this.impurityStatus,
    required this.recommendationEnglish,
    required this.recommendationHindi,
    required this.createdAt,
  });

  final String id;
  final String feedType;
  final String testType;
  final int score;
  final String riskLevel;
  final double phValue;
  final String nutritionStatus;
  final String impurityStatus;
  final String recommendationEnglish;
  final String recommendationHindi;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feedType': feedType,
      'testType': testType,
      'score': score,
      'riskLevel': riskLevel,
      'phValue': phValue,
      'nutritionStatus': nutritionStatus,
      'impurityStatus': impurityStatus,
      'recommendationEnglish': recommendationEnglish,
      'recommendationHindi': recommendationHindi,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FeedTestResult.fromJson(Map<String, dynamic> json) {
    return FeedTestResult(
      id: json['id'] as String,
      feedType: json['feedType'] as String,
      testType: json['testType'] as String,
      score: json['score'] as int,
      riskLevel: json['riskLevel'] as String,
      phValue: (json['phValue'] as num).toDouble(),
      nutritionStatus: json['nutritionStatus'] as String,
      impurityStatus: json['impurityStatus'] as String,
      recommendationEnglish: json['recommendationEnglish'] as String,
      recommendationHindi: json['recommendationHindi'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
