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
  final String? googlePlaceId; // googlePlaceId
  final String? provider; // provider
  final String? providerId; // provider_id
  final String? phone; // phone
  final String? website; // website
  final num? capacity; // capacity
  final bool? wheelchairFacility; // wheelchair_facility
  final String? imamName; // imam_name
  final String? muezzinName; // muezzin_name

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
    this.googlePlaceId,
    this.provider,
    this.providerId,
    this.phone,
    this.website,
    this.capacity,
    this.wheelchairFacility,
    this.imamName,
    this.muezzinName,
    required this.jamatTimes,
    required this.lastUpdatedAt,
    required this.lastUpdatedBy,
  });

  factory Mosque.fromSupabase(Map<String, dynamic> row) {
    final name = (row['mosque_name'] ?? 'Mosque').toString();
    final city = (row['city'] ?? '') as String?;
    final addressDesc = (row['address_desc'] ?? '') as String?;
    final address = (addressDesc != null && addressDesc.isNotEmpty)
        ? addressDesc
        : ([city].whereType<String>().where((e) => e.isNotEmpty).toList()
              ..removeWhere((e) => e.isEmpty))
            .join(', ');
    return Mosque(
      id: (row['id'] as num?)?.toInt(),
      name: name,
      address: address.isEmpty ? null : address,
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      city: city,
      district: null, // not provided in new schema
      isFemaleAccessible: (row['is_female_accessible'] as bool?) ?? false,
      createdBy: row['created_by'] as String?,
      createdAt: row['created_at'] is String
          ? DateTime.tryParse(row['created_at'] as String)
          : (row['created_at'] as DateTime?),
      googlePlaceId: row['googlePlaceId'] as String?,
      provider: row['provider'] as String?,
      providerId: row['provider_id'] as String?,
      phone: row['phone'] as String?,
      website: row['website'] as String?,
      capacity: row['capacity'] as num?,
      wheelchairFacility: row['wheelchair_facility'] as bool?,
      imamName: row['imam_name'] as String?,
      muezzinName: row['muezzin_name'] as String?,
      // Defaults for app-specific fields
      jamatTimes: const {},
      lastUpdatedAt: DateTime.now(),
      lastUpdatedBy: row['created_by']?.toString() ?? 'Supabase',
    );
  }
}
