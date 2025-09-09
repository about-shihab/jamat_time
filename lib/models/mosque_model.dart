import 'package:jamat_time/models/jamat_time_details.dart';

class Mosque {
  // Supabase: mosque_list fields
  final int? id;
  final String name; // mosque_name
  final String? address; // composed from city/district or free text
  final double? latitude; // latitude
  final double? longitude; // longitude
  final String? city; // city
  final String? district; // district
  final bool isFemaleAccessible; // is_female_accessible
  final String? createdBy; // created_by
  final DateTime? createdAt; // created_at

  // App-specific fields
  final Map<String, JamatTimeDetails> jamatTimes;
  final DateTime lastUpdatedAt;
  final String lastUpdatedBy;

  Mosque({
    this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.city,
    this.district,
    this.isFemaleAccessible = false,
    this.createdBy,
    this.createdAt,
    required this.jamatTimes,
    required this.lastUpdatedAt,
    required this.lastUpdatedBy,
  });

  factory Mosque.fromSupabase(Map<String, dynamic> row) {
    final name = (row['mosque_name'] ?? 'Mosque').toString();
    final city = (row['city'] ?? '') as String?;
    final district = (row['district'] ?? '') as String?;
    final address = [city, district]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .join(', ');
    return Mosque(
      id: (row['id'] as num?)?.toInt(),
      name: name,
      address: address.isEmpty ? null : address,
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      city: city,
      district: district,
      isFemaleAccessible: (row['is_female_accessible'] as bool?) ?? false,
      createdBy: row['created_by'] as String?,
      createdAt: row['created_at'] is String
          ? DateTime.tryParse(row['created_at'] as String)
          : (row['created_at'] as DateTime?),
      // Defaults for app-specific fields
      jamatTimes: const {},
      lastUpdatedAt: DateTime.now(),
      lastUpdatedBy: row['created_by']?.toString() ?? 'Supabase',
    );
  }
}
