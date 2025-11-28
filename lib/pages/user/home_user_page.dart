import 'package:flutter/material.dart';
import 'bus_list_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'feedback_page.dart';
import 'local_feedback_page.dart';
import '../../../models/user_model.dart';
import '../home/home_page.dart';
import '../../data/user_session_manager.dart';

class HomeUserPage extends StatelessWidget {
  final UserModel user;

  const HomeUserPage({super.key, required this.user});

  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const double radius = 15.0;

  void _onLogout(BuildContext context) async {
    await UserSessionManager.clearSession();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  ImageProvider? _getProfileImageProvider() {
    return user.photoUrl != null && user.photoUrl!.isNotEmpty
        ? NetworkImage(user.photoUrl!) as ImageProvider
        : null;
  }

  Widget _buildProfileAvatar({double radius = 18}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      backgroundImage: _getProfileImageProvider(),
      child: user.photoUrl == null || user.photoUrl!.isEmpty
          ? Icon(Icons.person, size: radius * 1.5, color: accentGreen)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Pengguna',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: darkText),
        actions: const [SizedBox.shrink()],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(24.0, 50.0, 24.0, 24.0),
              decoration: const BoxDecoration(color: accentGreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileAvatar(radius: 36),
                  const SizedBox(height: 12),
                  Text(
                    user.namaLengkap,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(
                Icons.account_circle_rounded,
                color: darkText,
              ),
              title: const Text('Edit Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(user: user),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.history_toggle_off_rounded,
                color: darkText,
              ),
              title: const Text('Riwayat Pemesanan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(userId: user.id),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.rate_review_rounded, color: darkText),
              title: const Text('Kesan & Saran (MK)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackPage(userId: user.id),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.star_rate_rounded, color: accentGreen),
              title: const Text('Ulasan Layanan (Offline)'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LocalFeedbackPage(userId: user.id.toString()),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _onLogout(context),
            ),
          ],
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Selamat Datang Kembali,',
                style: TextStyle(
                  fontSize: 20,
                  color: darkText.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.namaLengkap.split(' ').first,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: accentGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.directions_bus_filled_rounded,
                    size: 28,
                  ),
                  label: const Text('CARI DAN SEWA BUS'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusListPage(userId: user.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    elevation: 8,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.history_rounded, size: 24),
                  label: const Text('Lihat Riwayat Pemesanan'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryPage(userId: user.id),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: darkText,
                    side: BorderSide(
                      color: darkText.withOpacity(0.2),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
              Text(
                'Perjalanan nyaman dimulai dari sini.',
                style: TextStyle(
                  fontSize: 16,
                  color: darkText.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
