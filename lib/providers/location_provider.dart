import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider extends ChangeNotifier {
  Position? _position;
  String? _city;
  String? _district;
  String? _country;
  bool _loading = false;
  String? _error;
  Future<void>? _inFlight;
  bool _loadedFromCache = false;

  Position? get position => _position;
  String? get city => _city;
  String? get district => _district;
  String? get country => _country;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> ensureLocation() async {
    if (_position != null) return;
    // If another call is in-flight, await it to avoid returning early with null
    if (_inFlight != null) {
      await _inFlight;
      return;
    }
    _inFlight = _acquireLocation();
    await _inFlight;
    _inFlight = null;
  }

  Future<void> _acquireLocation() async {
    if (_loading) return; // Guard to prevent multiple loading attempts
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Try to get from cache first
      if (!_loadedFromCache) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final lat = prefs.getDouble('last_loc_lat');
          final lon = prefs.getDouble('last_loc_lon');
          final city = prefs.getString('last_loc_city');
          final district = prefs.getString('last_loc_district');
          final country = prefs.getString('last_loc_country');
          if (lat != null && lon != null) {
            _position = Position(
              latitude: lat,
              longitude: lon,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              floor: null,
              isMocked: false,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
            _city = city;
            _district = district;
            _country = country;
            _loadedFromCache = true;
            notifyListeners();
          }
        } catch (_) {}
      }

      // Ensure permissions are set
      final perm = await _ensurePermission();
      if (!perm) {
        _error ??= 'Location permission denied or services disabled';
        return;
      }

      // Check if we are on a web platform
      Position? pos;
      if (kIsWeb) {
        // Web platform: Use current position directly as lastKnownPosition is unsupported
        try {
          pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
        } catch (e) {
          _error = 'Unable to get location on the web';
        }
      } else {
        // Try last known position first for mobile platforms
        pos = await Geolocator.getLastKnownPosition();
        if (pos == null) {
          // If last known position is not available, try current position
          try {
            pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 10),
            );
          } on TimeoutException {
            // Fall back to low accuracy if high accuracy times out
            pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
            );
          }
        }
      }

      if (pos != null) {
        _position = pos;
        try {
          final placemarks =
              await geo.placemarkFromCoordinates(pos.latitude, pos.longitude);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            // Prefer district (subAdministrativeArea) for app bar, fallback to locality
            _district = (p.subAdministrativeArea?.isNotEmpty == true)
                ? p.subAdministrativeArea
                : null;
            _city = (p.locality?.isNotEmpty == true) ? p.locality : _district;
            _country = p.country;
          }

          // Persist latest location snapshot to SharedPreferences
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setDouble('last_loc_lat', pos.latitude);
            await prefs.setDouble('last_loc_lon', pos.longitude);
            if (_city != null) await prefs.setString('last_loc_city', _city!);
            if (_district != null)
              await prefs.setString('last_loc_district', _district!);
            if (_country != null)
              await prefs.setString('last_loc_country', _country!);
          } catch (_) {}
        } catch (_) {}
      } else {
        _error ??= 'Unable to get current position';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Try to prompt the user to enable location services
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled';
        return false;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error = 'Location permission denied';
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _error = 'Location permission permanently denied';
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }
}
