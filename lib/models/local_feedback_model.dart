class LocalFeedbackModel {
  final int? id;
  final String userId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  LocalFeedbackModel({
    this.id,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LocalFeedbackModel.fromMap(Map<String, dynamic> map) {
    return LocalFeedbackModel(
      id: map['id'] as int?,
      userId: map['userId'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
