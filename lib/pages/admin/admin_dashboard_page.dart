import 'package:flutter/material.dart';
import 'konfirmasi_pesanan_tab.dart';
import 'manajemen_bus_tab.dart';
import 'manajemen_ulasan_tab.dart';
import 'feedback_admin_tab.dart';
import '../home/home_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color lightBackground = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color darkText = Color(0xFF212121);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onLogout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: lightCard,
        elevation: 1,
        iconTheme: const IconThemeData(color: darkText),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: accentGreen),
            onPressed: _onLogout,
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: accentGreen,
          unselectedLabelColor: darkText.withOpacity(0.6),
          indicatorColor: accentGreen,
          indicatorWeight: 4.0,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: 'Pesanan'),
            Tab(icon: Icon(Icons.directions_bus), text: 'Data Bus'),
            Tab(icon: Icon(Icons.rate_review_rounded), text: 'Kesan'),
            Tab(icon: Icon(Icons.storage), text: 'Ulasan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          KonfirmasiPesananTab(),
          ManajemenBusTab(),
          FeedbackAdminTab(),
          ManajemenUlasanTab(),
        ],
      ),
    );
  }
}
