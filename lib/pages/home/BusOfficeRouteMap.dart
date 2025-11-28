import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

const Color accentGreen = Color(0xFF8BC34A);
const Color darkText = Color(0xFF212121);
const double radius = 12.0;

const LatLng OFFICE_LOCATION = LatLng(-7.761882835201547, 110.40895234198126);
const String OFFICE_ADDRESS =
    "Jl. Padjajaran Jl. Ring Road Utara No.104, Ngropoh, Condongcatur, Sleman, Yogyakarta";

class BusOfficeRouteMap extends StatefulWidget {
  const BusOfficeRouteMap({super.key});

  @override
  State<BusOfficeRouteMap> createState() => _BusOfficeRouteMapState();
}

class _BusOfficeRouteMapState extends State<BusOfficeRouteMap> {
  LatLng? _userLocation;
  List<LatLng> _routePoints = [];
  String _statusMessage = "Mencari lokasi Anda...";
  bool _isLoading = true;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      _determinePositionAndRoute();
    });
  }

  void _fitBoundsToRoute() {
    if (_userLocation == null) return;

    List<LatLng> boundsPoints = [_userLocation!, OFFICE_LOCATION];
    if (_routePoints.isNotEmpty) {
      boundsPoints.addAll(_routePoints);
    }

    double minLat = boundsPoints.map((p) => p.latitude).reduce(min);
    double maxLat = boundsPoints.map((p) => p.latitude).reduce(max);
    double minLon = boundsPoints.map((p) => p.longitude).reduce(min);
    double maxLon = boundsPoints.map((p) => p.longitude).reduce(max);

    final LatLngBounds bounds = LatLngBounds(
      LatLng(minLat, minLon),
      LatLng(maxLat, maxLon),
    );

    if (_mapController.camera.center != null) {
      _mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(
          padding: EdgeInsets.all(50),
          maxZoom: 16.0,
        ),
      );
    }
  }

  Future<void> _determinePositionAndRoute() async {
    setState(() {
      _statusMessage = "Meminta izin lokasi...";
      _isLoading = true;
      _routePoints = [];
    });

    var permission = await Permission.locationWhenInUse.request();
    if (permission.isDenied || permission.isPermanentlyDenied) {
      setState(() {
        _statusMessage = "Izin lokasi ditolak. Aktifkan di pengaturan.";
        _isLoading = false;
        _userLocation = null;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final userLatlng = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLocation = userLatlng;
        _statusMessage = "Menghitung rute...";
      });

      await _getRoute(userLatlng, OFFICE_LOCATION);
    } catch (e) {
      setState(() {
        _statusMessage =
            "Gagal mendapatkan lokasi. Pastikan GPS aktif. Error: ${e.toString()}";
        _isLoading = false;
        _userLocation = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mendapatkan lokasi Anda: ${e.toString()}"),
          ),
        );
      }
    }
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] == null || data['routes'].isEmpty) {
          throw Exception("OSRM tidak dapat menemukan rute yang layak.");
        }

        final coordinates = data['routes'][0]['geometry']['coordinates'];

        List<LatLng> points = [];
        for (var coord in coordinates) {
          points.add(LatLng(coord[1] as double, coord[0] as double));
        }

        setState(() {
          _routePoints = points;
          _isLoading = false;
          _statusMessage = "Rute berhasil dimuat!";
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fitBoundsToRoute();
        });
      } else {
        throw Exception(
          'Gagal mendapatkan rute dari OSRM. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Gagal memuat rute. Coba lagi.";
        _isLoading = false;
        _routePoints = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Rute gagal dihitung: ${e.toString()}")),
        );
      }
    }
  }

  Widget _buildStatusView() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: accentGreen.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? CircularProgressIndicator(color: accentGreen)
                : Icon(
                    Icons.location_off_rounded,
                    size: 50,
                    color: darkText.withOpacity(0.5),
                  ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: darkText, fontWeight: FontWeight.w600),
              ),
            ),
            if (!_isLoading)
              TextButton.icon(
                onPressed: _determinePositionAndRoute,
                icon: Icon(Icons.refresh_rounded, color: darkText),
                label: const Text(
                  "Coba Lagi",
                  style: TextStyle(color: darkText),
                ),
                style: TextButton.styleFrom(foregroundColor: darkText),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final centerPoint = _userLocation ?? OFFICE_LOCATION;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rute ke Kantor Bus',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: darkText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              child: ListTile(
                leading: const Icon(Icons.business_rounded, color: accentGreen),
                title: const Text(
                  "Kantor Tujuan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(OFFICE_ADDRESS),
              ),
            ),
            const SizedBox(height: 16),
            if (_userLocation == null || _isLoading)
              _buildStatusView()
            else
              Container(
                height: 350,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: accentGreen.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: darkText.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: centerPoint,
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.sewabustravel',
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 6.0,
                            color: accentGreen,
                            isDotted: false,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: OFFICE_LOCATION,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.redAccent,
                            size: 40,
                          ),
                        ),
                        Marker(
                          point: _userLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.person_pin_circle_rounded,
                            color: Colors.blueAccent,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Text(
              "Info Rute:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _routePoints.isNotEmpty
                  ? "Peta menunjukkan rute mengemudi terbaik dari lokasi Anda (Biru) ke Kantor Pusat (Merah)."
                  : "Silakan aktifkan GPS dan coba lagi. (Garis rute tidak dapat dimuat saat ini)",
              style: TextStyle(color: darkText.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
