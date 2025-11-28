import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCredentials {
  static const String supabaseUrl = 'https://gqrqhzfuvifvvyzyflsh.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdxcnFoemZ1dmlmdnZ5enlmbHNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExMTM1MDcsImV4cCI6MjA3NjY4OTUwN30.UpxpSvulWbrwcbD1KpFsIEoaf-jf6XGxKrkbPnbgG9I';

  static final SupabaseClient client = SupabaseClient(
    supabaseUrl,
    supabaseAnonKey,
  );
}
