import 'package:flutter/material.dart';
import '../../controllers/admin_auth_controller.dart';
import 'admin_dashboard_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color lightBackground = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color darkText = Color(0xFF212121);
  static const Color secondaryText = Colors.grey;
  static const double radius = 12.0;
  static const Color inputFillColor = Color(0xFFF0F0F0);

  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final AdminAuthController _controller = AdminAuthController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _onLogin() async {
    final email = _emailC.text.trim();
    final pass = _passC.text;

    if (email.isEmpty || pass.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email dan password wajib diisi')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    final admin = await _controller.loginAdmin(email, pass);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (admin != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang, ${admin.namaLengkap} (Admin)!'),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kredensial Admin salah atau tidak terdaftar.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: secondaryText),
      prefixIcon: Icon(icon, color: secondaryText),
      filled: true,
      fillColor: inputFillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: accentGreen, width: 2.0),
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: secondaryText,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: const Text(
          'Admin Login',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: lightCard,
        iconTheme: const IconThemeData(color: darkText),
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: accentGreen,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Dashboard Administrasi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const Text(
                  'Masuk menggunakan kredensial admin Anda.',
                  style: TextStyle(fontSize: 14, color: secondaryText),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: darkText),
                  decoration: _buildInputDecoration(
                    'Email Admin',
                    Icons.email_rounded,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passC,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: darkText),
                  decoration: _buildInputDecoration(
                    'Password',
                    Icons.lock_rounded,
                    isPassword: true,
                  ),
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator(color: accentGreen)
                    : SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: lightBackground,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radius),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'LOGIN ADMIN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
