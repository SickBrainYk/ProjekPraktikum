// lib/controllers/user_controller.dart
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../data/supabase_credentials.dart';
import '../models/user_model.dart';
import '../models/course_feedback_model.dart' as feedback;
import 'package:supabase_flutter/supabase_flutter.dart';

class UserController {
  final SupabaseClient _client = SupabaseCredentials.client;
  final String _profileBucketName = 'avatars';

  String _hashPassword(String password) {
    final trimmedPassword = password.trim();
    final bytes = utf8.encode(trimmedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // --- AUTH DAN FETCH USER ---

  Future<UserModel?> loginUser(String email, String password) async {
    try {
      final hashed = _hashPassword(password);
      final dynamic res = await _client
          .from('user')
          .select()
          .eq('email', email.trim())
          .eq('password', hashed)
          .maybeSingle();

      if (res == null || res is! Map<String, dynamic>) return null;

      return UserModel.fromJson(res);
    } on PostgrestException catch (pgErr) {
      print('Login PG error: ${pgErr.message}');
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String namaLengkap,
    required String email,
    required String password,
    String alamat = '',
    String noHp = '',
  }) async {
    try {
      if (namaLengkap.trim().isEmpty ||
          email.trim().isEmpty ||
          password.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Nama, email, dan password wajib diisi',
          'user': null,
        };
      }

      final existing = await _client
          .from('user')
          .select('id')
          .eq('email', email.trim())
          .maybeSingle();
      if (existing != null) {
        return {
          'success': false,
          'message': 'Email sudah terdaftar',
          'user': null,
        };
      }

      final hashed = _hashPassword(password);

      final insertRes = await _client
          .from('user')
          .insert({
            'email': email.trim(),
            'nama_lengkap': namaLengkap.trim(),
            'password': hashed,
            'alamat': alamat.trim(),
            'no_hp': noHp.trim(),
            'tgl_daftar': DateTime.now().toIso8601String(),
            'photo_url': null,
          })
          .select()
          .maybeSingle();

      if (insertRes == null || insertRes is! Map<String, dynamic>) {
        return {
          'success': false,
          'message': 'Gagal membuat akun',
          'user': null,
        };
      }

      final user = UserModel.fromJson(insertRes);
      return {'success': true, 'message': 'Registrasi berhasil', 'user': user};
    } on PostgrestException catch (pgErr) {
      print('Register PG error: ${pgErr.message}');
      return {
        'success': false,
        'message': 'Database error: ${pgErr.message}',
        'user': null,
      };
    } catch (e) {
      print('Register error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan', 'user': null};
    }
  }

  /// Mengambil UserModel berdasarkan ID pengguna.
  Future<UserModel?> fetchUserById(int id) async {
    try {
      // INI ADALAH FUNGSI KRITIS UNTUK MEMUAT SESI PERSISTEN DARI SHARED PREFERENCES
      final res = await _client
          .from('user')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (res == null) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(res));
    } catch (e) {
      print('Fetch User by ID error: $e');
      return null;
    }
  }

  // --- FITUR PROFIL DAN FEEDBACK BARU ---

  // 1. FUNGSI UPLOAD FOTO PROFIL
  Future<String?> uploadProfilePhoto(XFile imageFile, int userId) async {
    try {
      final bucketName = _profileBucketName;
      final fileExtension = path.extension(imageFile.name);
      final fileName = 'profile_$userId$fileExtension';
      final file = File(imageFile.path);

      await _client.storage
          .from(bucketName)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = _client.storage.from(bucketName).getPublicUrl(fileName);
      return publicUrl;
    } on StorageException catch (e) {
      print('Error uploading profile photo: StorageException: ${e.message}');
      return null;
    } catch (e) {
      print('Error uploading profile photo: $e');
      return null;
    }
  }

  // 2. FUNGSI UPDATE DATA PROFIL
  Future<UserModel?> updateProfileData(
    int userId,
    Map<String, dynamic> data,
  ) async {
    try {
      // PERBAIKAN: Hapus field 'password' jika ada untuk menghindari overwrite hash
      if (data.containsKey('password')) {
        data.remove('password');
      }

      final res = await _client
          .from('user')
          .update(data)
          .eq('id', userId)
          .select()
          .maybeSingle();

      if (res == null) return null;

      return UserModel.fromJson(Map<String, dynamic>.from(res));
    } catch (e) {
      print('Error updating profile data: $e');
      return null;
    }
  }

  // 3. FUNGSI KIRIM KESAN DAN SARAN
  Future<bool> sendCourseFeedback(
    int userId,
    String kesan,
    String saran,
  ) async {
    try {
      await _client.from('feedback_mk').insert({
        'user_id': userId,
        'kesan': kesan,
        'saran': saran,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error sending feedback: $e');
      return false;
    }
  }

  // 4. FUNGSI AMBIL RIWAYAT FEEDBACK
  Future<List<feedback.CourseFeedbackModel>> fetchUserFeedback(
    int userId,
  ) async {
    try {
      final res = await _client
          .from('feedback_mk')
          .select('*, user!inner(nama_lengkap)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (res is List) {
        return res
            .map(
              (data) => feedback.CourseFeedbackModel.fromJson(
                data as Map<String, dynamic>,
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user feedback history: $e');
      return [];
    }
  }
}
