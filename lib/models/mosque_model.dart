import 'package:jamat_time/models/jamat_time_details.dart';

class Mosque {
  final String name;
  final String address;
  final Map<String, JamatTimeDetails> jamatTimes;
  // --- NEW FIELDS ---
  final DateTime lastUpdatedAt;
  final String lastUpdatedBy;

  Mosque({
    required this.name,
    required this.address,
    required this.jamatTimes,
    required this.lastUpdatedAt,
    required this.lastUpdatedBy,
  });
}