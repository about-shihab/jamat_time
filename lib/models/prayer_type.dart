class PrayerType {
  final int id;
  final String? nameEn;
  final String? nameBn;
  final bool isActive;
  final DateTime createdAt;

  PrayerType({
    required this.id,
    this.nameEn,
    this.nameBn,
    this.isActive = true,
    required this.createdAt,
  });

  factory PrayerType.fromMap(Map<String, dynamic> map) {
    return PrayerType(
      id: (map['id'] as num).toInt(),
      nameEn: map['name_en'] as String?,
      nameBn: map['name_bn'] as String?,
      isActive: (map['is_active'] as bool?) ?? true,
      createdAt: map['created_at'] is String
          ? DateTime.parse(map['created_at'] as String)
          : (map['created_at'] as DateTime),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name_en': nameEn,
        'name_bn': nameBn,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };
}

