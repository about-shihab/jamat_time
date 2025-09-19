class PrayerRecord {
  final DateTime date;
  final Set<int> prayedIndices;

  PrayerRecord({required this.date, Set<int>? prayedIndices})
      : prayedIndices =
            prayedIndices != null ? Set<int>.from(prayedIndices) : <int>{};

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'prayed': prayedIndices.toList(),
      };

  factory PrayerRecord.fromJson(Map<String, dynamic> json) {
    final prayed = json['prayed'];
    return PrayerRecord(
      date: DateTime.parse(json['date'] as String),
      prayedIndices: prayed is List
          ? prayed.map((e) => (e as num).toInt()).toSet()
          : <int>{},
    );
  }
}
