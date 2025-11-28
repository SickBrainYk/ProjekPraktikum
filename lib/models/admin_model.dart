class AdminModel {
  final int id;
  final String email;
  final String namaLengkap;

  AdminModel({
    required this.id,
    required this.email,
    required this.namaLengkap,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
    );
  }
}
