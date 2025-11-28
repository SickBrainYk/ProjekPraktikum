import 'dart:io';
import 'package:path/path.dart' as path;
import '../data/supabase_credentials.dart';
import '../models/pemesanan_model.dart';
import '../models/bus_model.dart';
import '../models/course_feedback_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminController {
  final SupabaseClient _client = SupabaseCredentials.client;
  final String _bucketName = 'bus_images';

  Future<void> _updateBusAvailability(int busId, bool isAvailable) async {
    try {
      await _client
          .from('Bus')
          .update({'is_available': isAvailable})
          .eq('id', busId);
    } catch (e) {
      print('ERROR updating bus availability: $e');
    }
  }

  Future<String?> uploadBusImage(File imageFile, String platNomer) async {
    try {
      final sanitizedPlatNomer = platNomer
          .trim()
          .replaceAll(RegExp(r'\s+'), '_')
          .toUpperCase();

      final fileExtension = path.extension(imageFile.path);
      final storagePath = 'bus_photos/$sanitizedPlatNomer$fileExtension';

      await _client.storage
          .from(_bucketName)
          .upload(
            storagePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(storagePath);
      return publicUrl;
    } on StorageException catch (e) {
      print(
        '!!! SUPABASE STORAGE CRITICAL ERROR: StorageException on Upload: ${e.message}',
      );
      return null;
    } catch (e) {
      print('!!! SUPABASE STORAGE ERROR (General Catch): $e');
      return null;
    }
  }

  Future<List<PemesananModel>> fetchPendingBookings() async {
    try {
      // Menggunakan join implisit dengan '!' untuk mengambil data user dan Bus
      final res = await _client
          .from('pemesanan')
          .select(
            '*, user!inner(nama_lengkap), Bus!inner(nama_bus, plat_nomer)',
          )
          .order('tgl_pemesanan', ascending: true);

      if (res is List) {
        return res
            .map(
              (data) => PemesananModel.fromJson(data as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Admin Error fetching all bookings: $e');
      return [];
    }
  }

  Future<bool> updateBookingStatus(int bookingId, String newStatus) async {
    try {
      // 1. Ambil bus_id dari pemesanan
      final booking = await _client
          .from('pemesanan')
          .select('bus_id')
          .eq('id', bookingId)
          .maybeSingle();

      if (booking == null || booking is! Map<String, dynamic>) return false;

      final int busId = booking['bus_id'];
      final newStatusLower = newStatus.toLowerCase();

      // 2. Update status pemesanan
      await _client
          .from('pemesanan')
          .update({'status_pemesanan': newStatus})
          .eq('id', bookingId);

      // 3. Update ketersediaan Bus berdasarkan status baru
      if (newStatusLower == 'confirmed') {
        // Bus tidak tersedia setelah dikonfirmasi
        await _updateBusAvailability(busId, false);
      } else if (newStatusLower == 'rejected' ||
          newStatusLower == 'dikembalikan') {
        // Bus tersedia kembali jika ditolak/dikembalikan
        await _updateBusAvailability(busId, true);
      }

      return true;
    } catch (e) {
      print('Admin Error updating status: $e');
      return false;
    }
  }

  Future<List<BusModel>> fetchAllBuses() async {
    try {
      final res = await _client
          .from('Bus')
          .select()
          .order('nama_bus', ascending: true);

      if (res is List) {
        return res
            .map((data) => BusModel.fromJson(data as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Admin Error fetching all buses: $e');
      return [];
    }
  }

  Future<bool> createBus(BusModel bus, {String? fotoUrl}) async {
    try {
      final Map<String, dynamic> data = bus.toJson();
      if (fotoUrl != null) {
        data['foto_url'] = fotoUrl;
      }
      await _client.from('Bus').insert(data);
      return true;
    } catch (e) {
      print('Admin Error creating bus: $e');
      return false;
    }
  }

  Future<bool> updateBus(BusModel bus, {String? fotoUrl}) async {
    try {
      if (bus.id == null) return false;

      final Map<String, dynamic> data = bus.toJson();

      // Kelola URL foto: prioritaskan fotoUrl baru, lalu URL bus yang ada, jika tidak, set null.
      if (fotoUrl != null) {
        data['foto_url'] = fotoUrl;
      } else if (bus.fotoUrl != null) {
        data['foto_url'] = bus.fotoUrl;
      } else {
        data['foto_url'] = null;
      }

      await _client.from('Bus').update(data).eq('id', bus.id!);
      return true;
    } catch (e) {
      print('Admin Error updating bus: $e');
      return false;
    }
  }

  Future<bool> deleteBus(int busId) async {
    try {
      await _client.from('Bus').delete().eq('id', busId);
      return true;
    } catch (e) {
      print('Admin Error deleting bus: $e');
      return false;
    }
  }

  Future<List<CourseFeedbackModel>> fetchAllFeedback() async {
    try {
      // Menggunakan join implisit dengan '!' untuk mengambil data user
      final res = await _client
          .from('feedback_mk')
          .select('*, user!inner(nama_lengkap)')
          .order('created_at', ascending: false);

      if (res is List) {
        return res
            .map(
              (data) =>
                  CourseFeedbackModel.fromJson(data as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Admin Error fetching all feedback: $e');
      return [];
    }
  }

  Future<bool> deleteFeedback(int feedbackId) async {
    try {
      await _client.from('feedback_mk').delete().eq('id', feedbackId);
      return true;
    } catch (e) {
      print('Admin Error deleting feedback: $e');
      return false;
    }
  }
}
