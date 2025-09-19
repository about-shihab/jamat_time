import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../models/prayer_record.dart';

class TrackerView extends StatefulWidget {
  const TrackerView({super.key});

  @override
  State<TrackerView> createState() => _TrackerViewState();
}

class _TrackerViewState extends State<TrackerView> {
  static const int _prayerCount = 5;
  final List<String> _prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  final Map<DateTime, PrayerRecord> _records = {};
  bool _loading = true;
  late DateTime _monthAnchor;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _monthAnchor = DateTime(now.year, now.month);
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final key = _storageKey(_monthAnchor);
    final raw = prefs.getString(key);
    final days = _daysInMonth(_monthAnchor.year, _monthAnchor.month);
    final temp = <DateTime, PrayerRecord>{};

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        decoded.forEach((dateKey, value) {
          try {
            final recordJson = value as Map<String, dynamic>;
            final record = PrayerRecord.fromJson(recordJson);
            final normalized =
                DateTime(record.date.year, record.date.month, record.date.day);
            temp[normalized] = record;
          } catch (_) {}
        });
      } catch (_) {}
    }

    for (var day = 1; day <= days; day++) {
      final date = DateTime(_monthAnchor.year, _monthAnchor.month, day);
      temp.putIfAbsent(date, () => PrayerRecord(date: date));
    }

    setState(() {
      _records
        ..clear()
        ..addAll(temp);
      _loading = false;
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      for (final entry in _records.entries)
        entry.key.toIso8601String(): entry.value.toJson(),
    };
    await prefs.setString(_storageKey(_monthAnchor), jsonEncode(map));
  }

  void _togglePrayer(DateTime date, int index) {
    final normalized = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    if (!_isSameDay(normalized, today)) return;
    final record = _records[normalized];
    if (record == null) return;
    setState(() {
      if (record.prayedIndices.contains(index)) {
        record.prayedIndices.remove(index);
      } else {
        record.prayedIndices.add(index);
      }
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final monthLabel = DateFormat.yMMMM().format(_monthAnchor);
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final todayRecord = _records[todayKey];
    final todayCompletion =
        (todayRecord?.prayedIndices.length ?? 0) / _prayerCount;

    final todayNormalized = DateTime(today.year, today.month, today.day);
    final relevantRecords = _records.values
        .where((record) => !record.date.isAfter(todayNormalized))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final totalSlots = relevantRecords.length * _prayerCount;
    final prayedCount = relevantRecords.fold<int>(
      0,
      (prev, record) => prev + record.prayedIndices.length,
    );
    final overallPercent = totalSlots == 0 ? 0.0 : prayedCount / totalSlots;
    final completionByPrayer = <int, double>{
      for (var i = 0; i < _prayerCount; i++)
        i: relevantRecords.isEmpty
            ? 0.0
            : relevantRecords
                    .where((record) => record.prayedIndices.contains(i))
                    .length /
                relevantRecords.length,
    };
    final tableRecords = relevantRecords;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.namazTracker)),
      body: RefreshIndicator(
        onRefresh: _loadRecords,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              DateFormat('EEEE, d MMM').format(todayNormalized),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (todayRecord != null)
              _buildDayRow(context, todayRecord!, l10n, todayNormalized)
            else
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.noDataLabel,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(monthLabel, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _MonthlyOverview(
              completion: completionByPrayer,
              prayerNames: _prayerNames,
              overallPercent: overallPercent,
              l10n: l10n,
            ),
            const SizedBox(height: 16),
            _MissedPrayerTable(
              records: relevantRecords,
              prayerNames: _prayerNames,
              today: todayNormalized,
              l10n: l10n,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, PrayerRecord record,
      AppLocalizations l10n, DateTime today) {
    final dateFormat = DateFormat('EEEE, d MMM');
    final isToday = _isSameDay(record.date, today);
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.65),
        borderRadius: BorderRadius.circular(16),
        border: isToday ? Border.all(color: theme.primaryColor) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateFormat.format(record.date),
              style: theme.textTheme.titleSmall),
          const SizedBox(height: 10),
          IgnorePointer(
            ignoring: !isToday,
            child: Opacity(
              opacity: isToday ? 1 : 0.55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_prayerCount, (index) {
                  final isPrayed = record.prayedIndices.contains(index);
                  final Color backgroundColor;
                  if (isPrayed) {
                    backgroundColor = isToday
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.6);
                  } else {
                    backgroundColor = theme.colorScheme.surfaceVariant
                        .withOpacity(isToday ? 1 : 0.4);
                  }
                  return GestureDetector(
                    onTap: () => _togglePrayer(record.date, index),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: backgroundColor,
                          ),
                          child: isPrayed
                              ? const Icon(Icons.check, color: Colors.white)
                              : const SizedBox(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _prayerNames[index],
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _storageKey(DateTime anchor) =>
      'prayer_records_${anchor.year}_${anchor.month.toString().padLeft(2, '0')}';

  int _daysInMonth(int year, int month) {
    final beginningNextMonth =
        (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    return beginningNextMonth.subtract(const Duration(days: 1)).day;
  }
}

class _MonthlyOverview extends StatelessWidget {
  const _MonthlyOverview({
    required this.completion,
    required this.prayerNames,
    required this.overallPercent,
    required this.l10n,
  });

  final Map<int, double> completion;
  final List<String> prayerNames;
  final double overallPercent;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.monthlyOverviewTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: completion.entries.map((entry) {
                final index = entry.key;
                final percent = entry.value.clamp(0.0, 1.0);
                return _PrayerBar(
                  label: prayerNames[index],
                  percent: percent,
                  color: theme.colorScheme.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.monthlyOverviewCaption,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${(overallPercent * 100).clamp(0, 100).toStringAsFixed(1)}% total prayers completed',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedPrayerName(AppLocalizations l10n, String key) {
    switch (key.toLowerCase()) {
      case 'fajr':
        return l10n.prayerFajr;
      case 'dhuhr':
        return l10n.prayerDhuhr;
      case 'asr':
        return l10n.prayerAsr;
      case 'maghrib':
        return l10n.prayerMaghrib;
      case 'isha':
        return l10n.prayerIsha;
      default:
        return key;
    }
  }
}

class _MissedPrayerTable extends StatelessWidget {
  const _MissedPrayerTable({
    required this.records,
    required this.prayerNames,
    required this.today,
    required this.l10n,
  });

  final List<PrayerRecord> records;
  final List<String> prayerNames;
  final DateTime today;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (records.isEmpty) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.noDataLabel),
        ),
      );
    }

    return Card(
      elevation: 0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith(
            (states) => theme.colorScheme.primary.withOpacity(0.08),
          ),
          columns: [
            DataColumn(label: Text(l10n.trackerDateLabel)),
            ...prayerNames.map((name) => DataColumn(label: Text(_localizedPrayerName(l10n, name)))),
          ],
          rows: records.map((record) {
            final isToday = record.date.year == today.year &&
                record.date.month == today.month &&
                record.date.day == today.day;
            final dateLabel = DateFormat('d MMM').format(record.date);
            return DataRow(
              color: isToday
                  ? MaterialStateProperty.resolveWith(
                      (states) => theme.colorScheme.primary.withOpacity(0.08),
                    )
                  : null,
              cells: [
                DataCell(Text(isToday ? '$dateLabel (${l10n.today})' : dateLabel)),
                ...List.generate(prayerNames.length, (index) {
                  final missing = !record.prayedIndices.contains(index);
                  final icon = missing
                      ? Icon(Icons.close,
                          color: theme.colorScheme.error, size: 18)
                      : Icon(Icons.check,
                          color: theme.colorScheme.primary, size: 18);
                  return DataCell(icon);
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _localizedPrayerName(AppLocalizations l10n, String key) {
    switch (key.toLowerCase()) {
      case 'fajr':
        return l10n.prayerFajr;
      case 'dhuhr':
        return l10n.prayerDhuhr;
      case 'asr':
        return l10n.prayerAsr;
      case 'maghrib':
        return l10n.prayerMaghrib;
      case 'isha':
        return l10n.prayerIsha;
      default:
        return key;
    }
  }
}

class _PrayerBar extends StatelessWidget {
  const _PrayerBar(
      {required this.label, required this.percent, required this.color});

  final String label;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final height = 140.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${(percent * 100).round()}%',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: 20,
            height: height * percent,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
