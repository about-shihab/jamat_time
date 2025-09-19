enum EventLocationType { mosque, external }

class EventLocationTypeMapper {
  const EventLocationTypeMapper._();

  static EventLocationType fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'mosque':
        return EventLocationType.mosque;
      case 'external':
      case 'outside':
        return EventLocationType.external;
      default:
        return EventLocationType.external;
    }
  }

  static String toStringValue(EventLocationType type) {
    return type == EventLocationType.mosque ? 'mosque' : 'external';
  }
}

class EventModel {
  final String id;
  final String title;
  final String? description;
  final EventLocationType locationType;
  final String venueLabel;
  final String address;
  final int? mosqueId;
  final double? latitude;
  final double? longitude;
  final DateTime startsAt;
  final DateTime? endsAt;
  final int goingCount;
  final bool isCancelled;
  final String? organizerId;
  final bool isUserGoing;

  const EventModel({
    required this.id,
    required this.title,
    required this.locationType,
    required this.venueLabel,
    required this.address,
    required this.startsAt,
    this.description,
    this.mosqueId,
    this.latitude,
    this.longitude,
    this.endsAt,
    this.goingCount = 0,
    this.isCancelled = false,
    this.organizerId,
    this.isUserGoing = false,
  });

  factory EventModel.fromSupabase(Map<String, dynamic> data,
      {String? currentUserId}) {
    final locationType =
        EventLocationTypeMapper.fromString(data['location_type'] as String?);
    final startsAtValue = data['starts_at'];
    final endsAtValue = data['ends_at'];

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value.toLocal();
      return DateTime.tryParse(value.toString())?.toLocal() ?? DateTime.now();
    }

    return EventModel(
      id: data['id'].toString(),
      title: (data['title'] ?? '') as String,
      description: data['description'] as String?,
      locationType: locationType,
      venueLabel: (data['venue_label'] ?? data['address_text'] ?? '') as String,
      address: (data['address_text'] ?? '') as String,
      mosqueId: (data['mosque_id'] as num?)?.toInt(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      startsAt: parseDate(startsAtValue),
      endsAt: endsAtValue == null ? null : parseDate(endsAtValue),
      goingCount: (data['going_count'] as num?)?.toInt() ?? 0,
      isCancelled: data['is_cancelled'] as bool? ?? false,
      organizerId: data['organizer_id']?.toString(),
      isUserGoing: data['is_user_going'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'location_type': EventLocationTypeMapper.toStringValue(locationType),
      'venue_label': venueLabel,
      'address_text': address,
      'mosque_id': mosqueId,
      'latitude': latitude,
      'longitude': longitude,
      'starts_at': startsAt.toUtc().toIso8601String(),
      'ends_at': endsAt?.toUtc().toIso8601String(),
      'going_count': goingCount,
      'is_cancelled': isCancelled,
      'organizer_id': organizerId,
      'is_user_going': isUserGoing,
    };
    map.removeWhere((key, value) => value == null);
    return map;
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    EventLocationType? locationType,
    String? venueLabel,
    String? address,
    int? mosqueId,
    double? latitude,
    double? longitude,
    DateTime? startsAt,
    DateTime? endsAt,
    int? goingCount,
    bool? isCancelled,
    String? organizerId,
    bool? isUserGoing,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      locationType: locationType ?? this.locationType,
      venueLabel: venueLabel ?? this.venueLabel,
      address: address ?? this.address,
      mosqueId: mosqueId ?? this.mosqueId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      goingCount: goingCount ?? this.goingCount,
      isCancelled: isCancelled ?? this.isCancelled,
      organizerId: organizerId ?? this.organizerId,
      isUserGoing: isUserGoing ?? this.isUserGoing,
    );
  }
}

class EventDraft {
  final String title;
  final String? description;
  final DateTime startsAt;
  final DateTime? endsAt;
  final EventLocationType locationType;
  final String venueLabel;
  final String address;
  final int? mosqueId;
  final double? latitude;
  final double? longitude;

  const EventDraft({
    required this.title,
    required this.startsAt,
    required this.locationType,
    required this.venueLabel,
    required this.address,
    this.description,
    this.endsAt,
    this.mosqueId,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toSupabaseInsert({String? organizerId}) {
    final payload = <String, dynamic>{
      'title': title,
      'description': description,
      'location_type': EventLocationTypeMapper.toStringValue(locationType),
      'venue_label': venueLabel,
      'address_text': address,
      'mosque_id': mosqueId,
      'latitude': latitude,
      'longitude': longitude,
      'starts_at': startsAt.toUtc().toIso8601String(),
      'ends_at': endsAt?.toUtc().toIso8601String(),
      'organizer_id': organizerId,
    };
    payload.removeWhere((key, value) => value == null);
    return payload;
  }
}
