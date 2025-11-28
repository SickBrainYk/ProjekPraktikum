import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../controllers/bus_controller.dart';
import '../../../models/bus_model.dart';
import 'booking_page.dart';

class BusListPage extends StatefulWidget {
  final int userId;
  const BusListPage({super.key, required this.userId});

  @override
  State<BusListPage> createState() => _BusListPageState();
}

class _BusListPageState extends State<BusListPage> {
  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const double radius = 16.0;

  final BusController _busController = BusController();
  Future<List<BusModel>> _busesFuture = Future.value([]);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _busesFuture = _busController.fetchAvailableBuses();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, color: accentGreen, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12, color: darkText)),
      backgroundColor: lightGrey,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Unit Bus Tersedia',
          style: TextStyle(color: darkText),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: darkText),
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari bus berdasarkan nama, tipe, atau plat...',
                prefixIcon: const Icon(Icons.search, color: accentGreen),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: lightGrey.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<BusModel>>(
              future: _busesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: accentGreen),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error memuat data: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final allBuses = snapshot.data ?? [];
                final filteredBuses = allBuses.where((bus) {
                  if (_searchQuery.isEmpty) return true;
                  return bus.namaBus.toLowerCase().contains(_searchQuery) ||
                      bus.tipeBus.toLowerCase().contains(_searchQuery) ||
                      bus.platNomer.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredBuses.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 60,
                            color: darkText.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Maaf, tidak ada unit bus yang tersedia saat ini.'
                                : 'Tidak ditemukan bus untuk pencarian "$_searchQuery".',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredBuses.length,
                  itemBuilder: (context, index) {
                    final bus = filteredBuses[index];
                    final imageUrl = bus.fotoUrl != null
                        ? '${bus.fotoUrl!}?t=$cacheBuster'
                        : null;

                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radius),
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(radius),
                            ),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: lightGrey,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: accentGreen,
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        (loadingProgress
                                                                .expectedTotalBytes ??
                                                            1)
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => Container(
                                            color: lightGrey,
                                            child: Center(
                                              child: Icon(
                                                Icons
                                                    .directions_bus_filled_rounded,
                                                size: 70,
                                                color: darkText.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                    )
                                  : Container(
                                      color: lightGrey,
                                      child: Center(
                                        child: Icon(
                                          Icons.directions_bus_filled_rounded,
                                          size: 70,
                                          color: darkText.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bus.namaBus,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    color: darkText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Plat: ${bus.platNomer} | Tipe: ${bus.tipeBus}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: darkText.withOpacity(0.7),
                                  ),
                                ),
                                const Divider(height: 24),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: [
                                    _buildFeatureChip(
                                      'Kapasitas: ${bus.kapasitas} Kursi',
                                      Icons.people_outline,
                                    ),
                                    _buildFeatureChip(
                                      bus.tipeBus,
                                      Icons.local_gas_station_rounded,
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Harga Sewa:',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: darkText.withOpacity(0.6),
                                            ),
                                          ),
                                          Text(
                                            currencyFormatter.format(
                                              bus.hargaPerHari,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 24,
                                              color: accentGreen,
                                            ),
                                          ),
                                          const Text(
                                            '/ hari',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BookingPage(
                                                bus: bus,
                                                userId: widget.userId,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accentGreen,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          elevation: 4,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                        ),
                                        child: const Text(
                                          'Sewa Bus',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}