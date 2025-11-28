import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/user_controller.dart';
import 'login_page.dart';
import 'location_picker_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _namaC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _alamatC = TextEditingController();
  final _noHpC = TextEditingController();

  final UserController _controller = UserController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  bool _isEmailValid(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _onRegister() async {
    final nama = _namaC.text.trim();
    final email = _emailC.text.trim();
    final pass = _passC.text;
    final alamat = _alamatC.text.trim();
    final noHp = _noHpC.text.trim();

    if (nama.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama, email dan password wajib diisi')),
      );
      return;
    }

    if (!_isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format email tidak valid.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await _controller.registerUser(
      namaLengkap: nama,
      email: email,
      password: pass,
      alamat: alamat,
      noHp: noHp,
    );

    setState(() => _isLoading = false);

    if (res['success'] == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Registrasi berhasil')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Registrasi gagal')),
      );
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerPage()),
    );

    if (result != null && result is String) {
      setState(() {
        _alamatC.text = result;
      });
    }
  }

  @override
  void dispose() {
    _namaC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _alamatC.dispose();
    _noHpC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color accentGreen = Color(0xFF8BC34A);
    const Color darkText = Color(0xFF212121);
    const Color lightGrey = Color(0xFFE0E0E0);
    const double radius = 12.0;
    const double paddingValue = 24.0;

    final modernInputDecoration = (String label, [Widget? suffix]) =>
        InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 20.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: lightGrey, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: lightGrey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: accentGreen, width: 2.0),
          ),
          suffixIcon: suffix,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buat Akun',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(paddingValue),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 50,
                  color: accentGreen,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Daftar Akun Baru',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
                const Text(
                  'Dapatkan akses ke ratusan bus travel terbaik.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _namaC,
                  decoration: modernInputDecoration('Nama Lengkap'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: modernInputDecoration('Email'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passC,
                  obscureText: !_isPasswordVisible,
                  decoration: modernInputDecoration(
                    'Password',
                    IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: accentGreen,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noHpC,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-\+]')),
                  ],
                  decoration: modernInputDecoration('No. HP'),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickLocation,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _alamatC,
                      maxLines: 3,
                      decoration:
                          modernInputDecoration(
                            'Alamat (Pilih dari Peta)',
                            const Icon(
                              Icons.location_on_rounded,
                              color: accentGreen,
                            ),
                          ).copyWith(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 20.0,
                            ),
                          ),
                      validator: (v) =>
                          v!.isEmpty ? 'Alamat wajib diisi' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: accentGreen),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radius),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'DAFTAR AKUN',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun?',
                      style: TextStyle(color: darkText),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: accentGreen),
                      child: const Text(
                        'Login di sini',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
