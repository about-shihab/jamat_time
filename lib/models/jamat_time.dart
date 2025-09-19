class JamatTime {
  final int id;
  final int mosqueId;
  final int prayerTypeId;
  final String jamatTime; // stored as HH:mm per app UI
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  JamatTime({
    required this.id,
    required this.mosqueId,
    required this.prayerTypeId,
    required this.jamatTime,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory JamatTime.fromMap(Map<String, dynamic> map) {
    return JamatTime(
      id: (map['id'] as num).toInt(),
      mosqueId: (map['mosque_id'] as num).toInt(),
      prayerTypeId: (map['prayer_type_id'] as num).toInt(),
      jamatTime: map['jamat_time'] as String,
      startDate: map['start_date'] is String
          ? DateTime.parse(map['start_date'] as String)
          : (map['start_date'] as DateTime),
      endDate: map['end_date'] == null
          ? null
          : (map['end_date'] is String
              ? DateTime.parse(map['end_date'] as String)
              : (map['end_date'] as DateTime)),
      createdAt: map['created_at'] is String
          ? DateTime.parse(map['created_at'] as String)
          : (map['created_at'] as DateTime),
      updatedAt: map['updated_at'] == null
          ? null
          : (map['updated_at'] is String
              ? DateTime.parse(map['updated_at'] as String)
              : (map['updated_at'] as DateTime)),
      createdBy: map['created_by'] as String?,
      updatedBy: map['updated_by'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'mosque_id': mosqueId,
        'prayer_type_id': prayerTypeId,
        'jamat_time': jamatTime,
        'start_date': _toDate(startDate),
        'end_date': endDate != null ? _toDate(endDate!) : null,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'created_by': createdBy,
        'updated_by': updatedBy,
      };
}

String _toDate(DateTime d) =>
    DateTime(d.year, d.month, d.day).toIso8601String();
