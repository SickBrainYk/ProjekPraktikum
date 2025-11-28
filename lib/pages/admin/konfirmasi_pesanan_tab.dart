import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../controllers/admin_controller.dart';
import '../../../models/pemesanan_model.dart';

class KonfirmasiPesananTab extends StatefulWidget {
  const KonfirmasiPesananTab({super.key});

  @override
  State<KonfirmasiPesananTab> createState() => _KonfirmasiPesananTabState();
}

class _KonfirmasiPesananTabState extends State<KonfirmasiPesananTab> {
  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const double radius = 12.0;
  static const Color statusConfirmed = Color(0xFF4CAF50);
  static const Color statusRejected = Color(0xFFF44336);
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusReturned = Color(0xFF2196F3);

  final AdminController _controller = AdminController();
  late Future<List<PemesananModel>> _allBookingsFuture;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    setState(() {
      _allBookingsFuture = _controller.fetchPendingBookings();
    });
  }

  Future<void> _updateStatus(int bookingId, String newStatus) async {
    final success = await _controller.updateBookingStatus(bookingId, newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Pesanan berhasil diubah menjadi $newStatus'
                : 'Gagal mengubah status.',
          ),
        ),
      );
      if (success) {
        _loadBookings();
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return statusConfirmed;
      case 'rejected':
        return statusRejected;
      case 'pending':
        return statusPending;
      case 'dikembalikan':
        return statusReturned;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _loadBookings,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Refresh Daftar Pesanan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
                elevation: 4,
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<PemesananModel>>(
            future: _allBookingsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator(color: accentGreen),
                );
              if (snapshot.hasError)
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );

              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const Center(
                  child: Text('Tidak ada pesanan aktif atau pending.'),
                );

              final bookings = snapshot.data!.where((p) {
                final status = p.statusPemesanan.toLowerCase();
                return status != 'dikembalikan' && status != 'rejected';
              }).toList();

              if (bookings.isEmpty)
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 60,
                        color: accentGreen.withOpacity(0.5),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Semua pesanan sudah diselesaikan atau ditolak.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return _buildBookingCard(booking);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(PemesananModel booking) {
    final status = booking.statusPemesanan.toLowerCase();
    final isPending = status == 'pending';
    final isConfirmed = status == 'confirmed';
    final statusColor = _getStatusColor(status);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor, width: 1.5),
                  ),
                  child: Text(
                    booking.statusPemesanan.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  'ID: ${booking.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 1),
            _buildDetailRow(
              'Pemesan',
              booking.userName ?? 'ID: ${booking.userId}',
              Icons.person,
            ),
            _buildDetailRow(
              'Bus',
              booking.busName ?? 'ID: ${booking.busId}',
              Icons.directions_bus,
            ),
            _buildDetailRow(
              'Plat Nomor',
              booking.platNomor ?? '-',
              Icons.confirmation_number,
            ),
            _buildDetailRow(
              'Tujuan',
              booking.tujuanSewa ?? '-',
              Icons.location_on,
            ),
            _buildDetailRow(
              'Periode Sewa',
              '${_dateFormat.format(booking.tanggalMulai)} s/d ${_dateFormat.format(booking.tanggalSelesai)} (${booking.totalHari} Hari)',
              Icons.date_range,
            ),
            const Divider(height: 25, thickness: 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL HARGA:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  _currencyFormatter.format(booking.totalHarga),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: accentGreen,
                  ),
                ),
              ],
            ),
            if (status != 'rejected' && status != 'dikembalikan')
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isConfirmed)
                      _buildActionButton(
                        context,
                        'Dikembalikan',
                        statusReturned,
                        () => _updateStatus(booking.id!, 'Dikembalikan'),
                      ),
                    if (isConfirmed) const SizedBox(width: 10),
                    if (isPending)
                      _buildActionButton(
                        context,
                        'Tolak',
                        statusRejected,
                        () => _updateStatus(booking.id!, 'Rejected'),
                      ),
                    if (isPending) const SizedBox(width: 10),
                    if (isPending)
                      _buildActionButton(
                        context,
                        'Setujui',
                        statusConfirmed,
                        () => _updateStatus(booking.id!, 'Confirmed'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accentGreen.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: darkText.withOpacity(0.8)),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size(0, 35),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
