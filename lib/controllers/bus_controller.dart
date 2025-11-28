import '../data/supabase_credentials.dart';
import '../models/bus_model.dart';
import '../models/pemesanan_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusController {
  final SupabaseClient _client = SupabaseCredentials.client;

  Future<List<BusModel>> fetchAvailableBuses() async {
    try {
      final res = await _client
          .from('Bus')
          .select()
          .eq('is_available', true); // Hanya bus yang tersedia

      if (res is List) {
        return res
            .map((data) => BusModel.fromJson(data as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching buses: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createBooking(PemesananModel booking) async {
    try {
      final res = await _client
          .from('pemesanan')
          .insert(booking.toJson())
          .select() // Mengambil data yang baru saja dimasukkan
          .maybeSingle();

      if (res == null || res is! Map<String, dynamic>) {
        return {'success': false, 'message': 'Gagal menyimpan pemesanan.'};
      }
      return {
        'success': true,
        'message': 'Pemesanan berhasil dibuat!',
        'data': PemesananModel.fromJson(res),
      };
    } on PostgrestException catch (e) {
      print('Booking error: ${e.message}');
      // Menangkap error spesifik dari PostgREST (Supabase)
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat membuat pemesanan: ${e.message}',
      };
    } catch (e) {
      print('Booking general error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat membuat pemesanan.',
      };
    }
  }

  Future<List<PemesananModel>> fetchUserBookings(int userId) async {
    try {
      // Mengambil pemesanan pengguna, termasuk detail dari user dan Bus (join)
      final res = await _client
          .from('pemesanan')
          .select('*, user!inner(*), Bus!inner(*)')
          .eq('user_id', userId)
          .order('tgl_pemesanan', ascending: false);

      if (res is List) {
        return res
            .map(
              (data) => PemesananModel.fromJson(data as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user history: $e');
      return [];
    }
  }
}
