class UserModel {
  final int id;
  final String email;
  final String namaLengkap;
  final String password;
  final String alamat;
  final String noHp;
  final DateTime tglDaftar;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.namaLengkap,
    required this.password,
    required this.alamat,
    required this.noHp,
    required this.tglDaftar,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      password: json['password'] ?? '',
      alamat: json['alamat'] ?? '',
      noHp: json['no_hp'] ?? '',
      tglDaftar:
          DateTime.tryParse(json['tgl_daftar']?.toString() ?? '') ??
          DateTime.now(),
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama_lengkap': namaLengkap,
      'password': password,
      'alamat': alamat,
      'no_hp': noHp,
      'tgl_daftar': tglDaftar.toIso8601String(),
      'photo_url': photoUrl,
    };
  }

  UserModel copyWith({
    String? namaLengkap,
    String? alamat,
    String? noHp,
    String? photoUrl,
  }) {
    return UserModel(
      id: this.id,
      email: this.email,
      password: this.password,
      tglDaftar: this.tglDaftar,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      alamat: alamat ?? this.alamat,
      noHp: noHp ?? this.noHp,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
