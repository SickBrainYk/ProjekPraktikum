import 'package:flutter/material.dart';

import '../user/login_page.dart';
import '../admin/admin_login_page.dart';
import 'BusOfficeRouteMap.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const double radius = 15.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BUS TRAVEL',
          style: TextStyle(
            color: accentGreen,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.directions_bus_filled_rounded,
                size: 100,
                color: accentGreen,
              ),
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih peran Anda untuk melanjutkan layanan sewa bus travel.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_pin_circle_rounded, size: 28),
                label: const Text(
                  'Masuk sebagai Pengguna',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  elevation: 6,
                ),
              ),
              const SizedBox(height: 25),
              OutlinedButton.icon(
                icon: const Icon(Icons.shield_rounded, size: 24),
                label: const Text('Masuk sebagai Admin'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminLoginPage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: darkText,
                  side: BorderSide(color: lightGrey, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.location_on_rounded, size: 24),
                  label: const Text('LIHAT RUTE KE KANTOR'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BusOfficeRouteMap(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accentGreen,
                    side: const BorderSide(color: accentGreen, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
