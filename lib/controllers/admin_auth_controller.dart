import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../data/supabase_credentials.dart';
import '../models/admin_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAuthController {
  final SupabaseClient _client = SupabaseCredentials.client;

  String _hashPassword(String password) {
    final trimmedPassword = password.trim();
    final bytes = utf8.encode(trimmedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AdminModel?> loginAdmin(String email, String password) async {
    try {
      final hashed = _hashPassword(password);

      print('--- DEBUG ADMIN LOGIN START ---');
      print('Email dicari: ${email.trim()}');
      print('Hash dibuat Flutter: $hashed');
      print('-----------------------------');

      final dynamic res = await _client
          .from('admin')
          .select()
          .eq('email', email.trim())
          .eq('password', hashed)
          .maybeSingle();

      if (res == null || res is! Map<String, dynamic>) {
        print('Login GAGAL: Kredensial tidak cocok atau RLS memblokir.');
        return null;
      }

      print('Login SUKSES!');
      return AdminModel.fromJson(res);
    } catch (e) {
      print('Admin Login error: $e');
      return null;
    }
  }
}
