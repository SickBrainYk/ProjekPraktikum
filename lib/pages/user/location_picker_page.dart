import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color darkText = Color(0xFF212121);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const double radius = 12.0;
  static const double paddingValue = 24.0;

  LatLng _center = const LatLng(-6.2088, 106.8456);
  String _selectedAddress = "Gerakkan peta untuk memilih lokasi...";
  bool _isLoading = false;
  final MapController _mapController = MapController();

  LatLng? _lastConfirmedCenter;
  final TextEditingController _searchController = TextEditingController();

  static const String _geoApiKey = '8a3c7983124640e5901e52cf281f0438';
  static const String _geoEndpoint =
      'https://api.opencagedata.com/geocode/v1/json';

  @override
  void initState() {
    super.initState();
    _getAddress(_center, forceUpdate: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getAddress(LatLng latLng, {bool forceUpdate = false}) async {
    if (!forceUpdate && latLng == _lastConfirmedCenter) return;

    setState(() {
      _isLoading = true;
      _center = latLng;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final address = placemarks.first;

        final addressComponents = <String>[];
        if (address.street != null && address.street!.isNotEmpty)
          addressComponents.add(address.street!);
        if (address.subLocality != null && address.subLocality!.isNotEmpty)
          addressComponents.add(address.subLocality!);
        if (address.locality != null && address.locality!.isNotEmpty)
          addressComponents.add(address.locality!);
        if (address.subAdministrativeArea != null &&
            address.subAdministrativeArea!.isNotEmpty)
          addressComponents.add(address.subAdministrativeArea!);
        if (address.administrativeArea != null &&
            address.administrativeArea!.isNotEmpty)
          addressComponents.add(address.administrativeArea!);
        if (address.country != null && address.country!.isNotEmpty)
          addressComponents.add(address.country!);

        _selectedAddress = addressComponents.toSet().join(', ');
        _lastConfirmedCenter = latLng;
      } else {
        _selectedAddress = "Alamat tidak ditemukan.";
      }
    } catch (e) {
      _selectedAddress = "Gagal memuat alamat. Cek koneksi.";
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(
        '$_geoEndpoint?q=$query&key=$_geoApiKey&language=id&limit=1',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        if (results.isNotEmpty) {
          final latitude = results.first['geometry']['lat'] as double;
          final longitude = results.first['geometry']['lng'] as double;

          final newCenter = LatLng(latitude, longitude);

          _mapController.move(newCenter, _mapController.camera.zoom);

          await _getAddress(newCenter, forceUpdate: true);
        } else {
          _selectedAddress = "Pencarian tidak menemukan hasil.";
        }
      } else {
        _selectedAddress = "Gagal koneksi ke API Pencarian.";
      }
    } catch (e) {
      _selectedAddress = "Error: $e";
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilih Lokasi',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14.0,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _getAddress(event.camera.center);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.cobaaplikasi1',
              ),
            ],
          ),
          Center(
            child: Icon(
              Icons.location_on_rounded,
              color: accentGreen,
              size: 50,
              shadows: [
                BoxShadow(
                  color: darkText.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari kota, jalan, atau tempat...',
                  prefixIcon: const Icon(Icons.search, color: accentGreen),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(15.0),
                  suffixIcon: _isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accentGreen,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: accentGreen),
                          onPressed: () =>
                              _searchLocation(_searchController.text),
                        ),
                ),
                onFieldSubmitted: _searchLocation,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Card(
              margin: const EdgeInsets.all(paddingValue),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(paddingValue),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Lokasi Terpilih:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoading
                        ? LinearProgressIndicator(
                            color: accentGreen,
                            backgroundColor: lightGrey,
                          )
                        : Text(
                            _selectedAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed:
                          _isLoading ||
                              _selectedAddress.contains("Gerakkan") ||
                              _selectedAddress.contains("tidak ditemukan") ||
                              _selectedAddress.isEmpty
                          ? null
                          : () {
                              Navigator.pop(context, _selectedAddress);
                            },
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 24,
                      ),
                      label: const Text(
                        "KONFIRMASI ALAMAT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
