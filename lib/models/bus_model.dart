class BusModel {
  final int? id;
  final String namaBus;
  final String platNomer;
  final int kapasitas;
  final String tipeBus;
  final int hargaPerHari;
  final bool isAvailable;
  final String? fotoUrl;

  BusModel({
    this.id,
    required this.namaBus,
    required this.platNomer,
    required this.kapasitas,
    required this.tipeBus,
    required this.hargaPerHari,
    this.isAvailable = true,
    this.fotoUrl,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    final dynamic harga =
        json['harga_per_hari'] ?? json['harga_sewa_harian'] ?? 0;

    return BusModel(
      id: json['id'],
      namaBus: json['nama_bus'],
      platNomer: json['plat_nomer'],
      kapasitas: json['kapasitas'],
      tipeBus: json['tipe_bus'] ?? 'Standard',
      hargaPerHari: (harga is String)
          ? int.tryParse(harga) ?? 0
          : (harga as int?) ?? 0,
      isAvailable: json['is_available'] ?? true,
      fotoUrl: json['foto_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_bus': namaBus,
      'plat_nomer': platNomer,
      'kapasitas': kapasitas,
      'tipe_bus': tipeBus,
      'harga_sewa_harian': hargaPerHari,
      'is_available': isAvailable,
    };
  }
}
