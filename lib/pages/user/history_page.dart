import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../controllers/bus_controller.dart';
import '../../../models/pemesanan_model.dart';
import '../../../controllers/conversion_controller.dart';

class HistoryPage extends StatefulWidget {
  final int userId;
  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const double radius = 12.0;

  final BusController _controller = BusController();
  late Future<List<PemesananModel>> _historyFuture;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _historyFuture = _controller.fetchUserBookings(widget.userId);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'approved':
        return accentGreen;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Pemesanan',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: darkText),
      ),
      body: FutureBuilder<List<PemesananModel>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentGreen));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error memuat data: ${snapshot.error}',
                style: const TextStyle(color: darkText),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 80,
                    color: darkText.withOpacity(0.3),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Anda belum memiliki riwayat pemesanan.',
                    style: TextStyle(fontSize: 16, color: darkText),
                  ),
                ],
              ),
            );
          }
          final bookings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildBookingCardContent(booking),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCardContent(PemesananModel booking) {
    final DateTime timeToConvert = booking.tglPemesanan ?? DateTime.now();
    final timeConversions = ConversionController.getAllTimeConversions(
      timeToConvert,
    );
    final String wibTimeFormatted =
        timeConversions['WIB'] ?? DateFormat('HH:mm').format(timeToConvert);
    final DateTime datePart = booking.tanggalMulai;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    booking.statusPemesanan,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(
                      booking.statusPemesanan,
                    ).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  booking.statusPemesanan.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _getStatusColor(booking.statusPemesanan),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Flexible(
              child: Text(
                'Tgl Pesan: ${DateFormat('dd/MM/yy').format(datePart)} ${wibTimeFormatted}',
                style: TextStyle(
                  fontSize: 12,
                  color: darkText.withOpacity(0.6),
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const Divider(color: lightGrey, height: 25),
        Text(
          booking.busName ?? 'ID: ${booking.busId}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Plat Nomor: ${booking.platNomor ?? '-'}',
          style: const TextStyle(fontSize: 14, color: darkText),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.date_range, size: 16, color: accentGreen),
            const SizedBox(width: 8),
            Text(
              '${_dateFormat.format(booking.tanggalMulai)} - ${_dateFormat.format(booking.tanggalSelesai)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const Spacer(),
            Text(
              '${booking.totalHari} hari',
              style: TextStyle(fontWeight: FontWeight.bold, color: accentGreen),
            ),
          ],
        ),
        const Divider(color: lightGrey, height: 25),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: timeConversions.entries.map((entry) {
            return Chip(
              label: Text(
                '${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 12, color: darkText),
              ),
              backgroundColor: accentGreen.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: accentGreen.withOpacity(0.3)),
              ),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
        const Divider(color: lightGrey, height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TOTAL BIAYA:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: darkText,
              ),
            ),
            Flexible(
              child: Text(
                _currencyFormatter.format(booking.totalHarga),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: accentGreen,
                  fontSize: 20,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
