import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PrayerTimesProvider extends ChangeNotifier {
  Map<String, String>? _timings; // includes Fajr..Isha and Sunrise, Sunset, Imsak, Midnight
  bool _loading = false;
  String? _error;

  Map<String, String>? get timings => _timings;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchByLatLng(double lat, double lng, {int method = 5}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Use /timings/today to avoid 302 redirect from /timings
      final uri = Uri.parse('https://api.aladhan.com/v1/timings/today').replace(
        queryParameters: {
          'latitude': lat.toString(),
          'longitude': lng.toString(),
          'method': method.toString(),
        },
      );
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        _error = 'Network ${res.statusCode}';
        _loading = false;
        notifyListeners();
        return;
      }
      final data = json.decode(res.body) as Map<String, dynamic>;
      final timings = (data['data']?['timings'] as Map)
          .map((k, v) => MapEntry(k.toString(), v.toString()));
      // Keep primary keys and helpful supporting keys
      _timings = {
        'Fajr': timings['Fajr'] ?? '',
        'Dhuhr': timings['Dhuhr'] ?? '',
        'Asr': timings['Asr'] ?? '',
        'Maghrib': timings['Maghrib'] ?? '',
        'Isha': timings['Isha'] ?? '',
        'Sunrise': timings['Sunrise'] ?? '',
        'Sunset': timings['Sunset'] ?? '',
        'Imsak': timings['Imsak'] ?? '',
        'Midnight': timings['Midnight'] ?? '',
      };
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
