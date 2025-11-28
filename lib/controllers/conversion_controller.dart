import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/currency_conversion_model.dart';

class ConversionController {
  static const String _geoApiKey = '8a3c7983124640e5901e52cf281f0438';
  static const String _geoEndpoint =
      'https://api.opencagedata.com/geocode/v1/json';
  static const String _currencyEndpoint =
      'https://api.exchangerate-api.com/v4/latest/IDR';

  Future<CurrencyConversionModel?> fetchExchangeRates() async {
    try {
      final response = await http.get(Uri.parse(_currencyEndpoint));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CurrencyConversionModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> getDestinationSuggestions(String query) async {
    if (query.length < 3) {
      return const Iterable<String>.empty().toList();
    }

    try {
      final uri = Uri.parse(
        '$_geoEndpoint?q=$query&key=$_geoApiKey&language=id&limit=8',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((result) {
          return result['formatted'] as String;
        }).toList();
      } else {
        return ['(Gagal memuat saran lokasi - Cek Kuota/Kunci API)'];
      }
    } catch (e) {
      return ['(Gagal koneksi atau fatal error)'];
    }
  }

  static String _convertToTimezone(
    tz.TZDateTime wibBaseTime,
    String targetZoneName,
  ) {
    try {
      final targetLocation = tz.getLocation(targetZoneName);

      final tzTargetTime = tz.TZDateTime.from(wibBaseTime, targetLocation);

      return DateFormat('HH:mm z').format(tzTargetTime);
    } catch (e) {
      return 'N/A';
    }
  }

  static Map<String, String> getAllTimeConversions(DateTime utcDateTime) {
    final tz.Location jakartaLocation = tz.getLocation('Asia/Jakarta');

    final tz.TZDateTime wibBaseTime = tz.TZDateTime(
      jakartaLocation,
      utcDateTime.year,
      utcDateTime.month,
      utcDateTime.day,
      utcDateTime.hour,
      utcDateTime.minute,
      utcDateTime.second,
    );

    return {
      'WIB': _convertToTimezone(wibBaseTime, 'Asia/Jakarta'),
      'WITA': _convertToTimezone(wibBaseTime, 'Asia/Makassar'),
      'WIT': _convertToTimezone(wibBaseTime, 'Asia/Jayapura'),
      'London': _convertToTimezone(wibBaseTime, 'Europe/London'),
    };
  }
}
