class CourseFeedbackModel {
  final int id;
  final int userId;
  final String kesan;
  final String saran;
  final DateTime createdAt;
  final String? userName;

  CourseFeedbackModel({
    required this.id,
    required this.userId,
    required this.kesan,
    required this.saran,
    required this.createdAt,
    this.userName,
  });

  factory CourseFeedbackModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'];

    return CourseFeedbackModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      kesan: json['kesan'] as String,
      saran: json['saran'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: userData is Map ? userData['nama_lengkap'] as String? : null,
    );
  }
}
