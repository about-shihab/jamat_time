import 'dart:convert';

import 'package:http/http.dart' as http;

class AladhanQiblaService {
  AladhanQiblaService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<double?> fetchDirection({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://api.aladhan.com/v1/qibla/${latitude.toStringAsFixed(6)}/${longitude.toStringAsFixed(6)}',
    );

    final response =
        await _client.get(uri, headers: const {'accept': 'application/json'});
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Failed to load Qibla direction (status ${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final direction = data['direction'];
      if (direction is num) {
        return direction.toDouble();
      }
    }
    return null;
  }
}
