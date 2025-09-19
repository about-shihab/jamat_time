import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesProvider extends ChangeNotifier {
  Map<String, Map<String, String>>?
      _monthlyTimings; // Key: day (e.g., "01"), Value: daily timings
  bool _loading = false;
  String? _error;

  Map<String, String>? get timings {
    if (_monthlyTimings == null || _monthlyTimings!.isEmpty) return null;
    final today = DateTime.now().day.toString().padLeft(2, '0');
    return _monthlyTimings![today];
  }

  bool get loading => _loading;
  String? get error => _error;

  static const _cacheKey = 'monthly_prayer_times';
  static const _cacheTimestampKey = 'monthly_prayer_times_timestamp';
  static const _cacheLatKey = 'monthly_prayer_times_lat';
  static const _cacheLngKey = 'monthly_prayer_times_lng';

  Future<void> fetchMonthlyPrayerTimes(double lat, double lng,
      {int method = 5, bool forceRefresh = false}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    // Check cache first
    if (!forceRefresh) {
      final cachedData = prefs.getString(_cacheKey);
      final cachedTimestamp = prefs.getInt(_cacheTimestampKey);
      final cachedLat = prefs.getDouble(_cacheLatKey);
      final cachedLng = prefs.getDouble(_cacheLngKey);

      if (cachedData != null &&
          cachedTimestamp != null &&
          cachedLat == lat &&
          cachedLng == lng) {
        final lastFetchDate =
            DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
        // Check if cache is for the current month and not older than a day
        if (lastFetchDate.month == currentMonth &&
            lastFetchDate.year == currentYear &&
            DateTime.now().difference(lastFetchDate).inHours < 24) {
          _monthlyTimings = (json.decode(cachedData) as Map<String, dynamic>)
              .map((k, v) => MapEntry(
                  k,
                  (v as Map<String, dynamic>)
                      .map((k2, v2) => MapEntry(k2, v2.toString()))));
          _loading = false;
          notifyListeners();
          return;
        }
      }
    }

    // Fetch from API
    try {
      final uri = Uri.parse(
              'https://api.aladhan.com/v1/calendar/$currentYear/$currentMonth')
          .replace(
        queryParameters: {
          'latitude': lat.toString(),
          'longitude': lng.toString(),
          'method': method.toString(),
        },
      );
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        _error = 'Network ${res.statusCode}';
        // If API call fails, try to load any existing cache as a fallback
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          _monthlyTimings = (json.decode(cachedData) as Map<String, dynamic>)
              .map((k, v) => MapEntry(
                  k,
                  (v as Map<String, dynamic>)
                      .map((k2, v2) => MapEntry(k2, v2.toString()))));
        }
        _loading = false;
        notifyListeners();
        return;
      }
      final data = json.decode(res.body) as Map<String, dynamic>;
      final monthlyData = <String, Map<String, String>>{};

      for (final dayEntry in (data['data'] as List<dynamic>)) {
        final date = dayEntry['date']['gregorian']['day'] as String;
        final timings = (dayEntry['timings'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k.toString(), v.toString()));
        monthlyData[date] = {
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
      }
      _monthlyTimings = monthlyData;

      // Save to cache
      await prefs.setString(_cacheKey, json.encode(monthlyData));
      await prefs.setInt(
          _cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setDouble(_cacheLatKey, lat);
      await prefs.setDouble(_cacheLngKey, lng);
    } catch (e) {
      _error = e.toString();
      // Fallback to cache if API call fails
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        _monthlyTimings = (json.decode(cachedData) as Map<String, dynamic>).map(
            (k, v) => MapEntry(
                k,
                (v as Map<String, dynamic>)
                    .map((k2, v2) => MapEntry(k2, v2.toString()))));
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
