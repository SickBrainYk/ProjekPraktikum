class PemesananModel {
  final int? id;
  final int userId;
  final int busId;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final int totalHari;
  final double totalHarga;
  final String? tujuanSewa;
  final String statusPemesanan;
  final DateTime? tglPemesanan;

  final String? userName;
  final String? busName;
  final String? platNomor;

  PemesananModel({
    this.id,
    required this.userId,
    required this.busId,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.totalHari,
    required this.totalHarga,
    this.tujuanSewa,
    this.statusPemesanan = 'Pending',
    this.tglPemesanan,
    this.userName,
    this.busName,
    this.platNomor,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'bus_id': busId,
      'tanggal_mulai': tanggalMulai.toIso8601String().substring(0, 10),
      'tanggal_selesai': tanggalSelesai.toIso8601String().substring(0, 10),
      'total_hari': totalHari,
      'total_harga': totalHarga,
      'tujuan_sewa': tujuanSewa,
      'status_pemesanan': statusPemesanan,
      'tgl_pemesanan':
          tglPemesanan?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory PemesananModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'];
    final busData = json['Bus'];

    final totalHarga = (json['total_harga'] is int)
        ? (json['total_harga'] as int).toDouble()
        : json['total_harga'] ?? 0.0;

    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is String) return DateTime.tryParse(date);
      return null;
    }

    return PemesananModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      busId: json['bus_id'] ?? 0,
      tanggalMulai: parseDate(json['tanggal_mulai'])!,
      tanggalSelesai: parseDate(json['tanggal_selesai'])!,
      totalHari: json['total_hari'] ?? 0,
      totalHarga: totalHarga,
      tujuanSewa: json['tujuan_sewa'],
      statusPemesanan: json['status_pemesanan'] ?? 'Pending',
      tglPemesanan: parseDate(json['tgl_pemesanan']),
      userName: userData is Map ? userData['nama_lengkap'] as String? : null,
      busName: busData is Map ? busData['nama_bus'] as String? : null,
      platNomor: busData is Map ? busData['plat_nomer'] as String? : null,
    );
  }
}
