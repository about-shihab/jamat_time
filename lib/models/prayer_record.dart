class PrayerRecord {
  final DateTime date;
  final Set<int> prayedIndices;

  PrayerRecord({required this.date, Set<int>? prayedIndices})
      : prayedIndices = prayedIndices ?? {};
}