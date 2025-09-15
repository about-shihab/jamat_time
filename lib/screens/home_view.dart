import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/models/jamat_time_details.dart';
import 'package:jamat_time/widgets/custom_app_bar.dart';
import 'package:jamat_time/widgets/prayer_glance_item.dart';
import 'package:jamat_time/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/providers/prayer_times_provider.dart';
import 'package:jamat_time/screens/scan_results_screen.dart';
import 'package:jamat_time/screens/landing_screen.dart';
import 'package:jamat_time/screens/edit_jamat_time_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jamat_time/services/jamat_time_service.dart';
import 'package:jamat_time/widgets/next_jamat_card.dart';
import 'package:jamat_time/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/models/jamat_time_details.dart';
import 'package:jamat_time/widgets/custom_app_bar.dart';
import 'package:jamat_time/widgets/prayer_glance_item.dart';
import 'package:jamat_time/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/providers/prayer_times_provider.dart';
import 'package:jamat_time/screens/scan_results_screen.dart';
import 'package:jamat_time/screens/landing_screen.dart';
import 'package:jamat_time/screens/edit_jamat_time_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jamat_time/services/jamat_time_service.dart';
import 'package:jamat_time/widgets/next_jamat_card.dart';
import 'package:jamat_time/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jamat_time/providers/location_provider.dart';

class HomeView extends StatefulWidget {
  final Mosque favoriteMosque;
  const HomeView({super.key, required this.favoriteMosque});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Fallback static times until fetched from API
  final Map<String, String> _fallbackPrayerTimes = const {
    'Fajr': '--:--',
    'Dhuhr': '--:--',
    'Asr': '--:--',
    'Maghrib': '--:--',
    'Isha': '--:--'
  };

  Map<String, String>? _jamatTimes; // fetched from Supabase by mosque id
  Set<String> _alarmsSet = {};

  @override
  void initState() {
    super.initState();
    _loadJamatTimesFromService();
    _loadAlarmState();
    _fetchPrayerTimes();
  }

  @override
  void didUpdateWidget(covariant HomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favoriteMosque.id != widget.favoriteMosque.id) {
      _jamatTimes = null;
      _loadJamatTimesFromService();
      _fetchPrayerTimes(forceRefresh: true);
    }
  }

  Future<void> _fetchPrayerTimes({bool forceRefresh = false}) async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.ensureLocation();
    if (locationProvider.position != null) {
      await context.read<PrayerTimesProvider>().fetchMonthlyPrayerTimes(
            locationProvider.position!.latitude,
            locationProvider.position!.longitude,
            forceRefresh: forceRefresh,
          );
    }
  }

  Future<void> _handleSync() async {
    // Rescan nearby mosques: open results directly and replace MainScreen on choice
    final selected = await Navigator.push<Mosque>(
      context,
      MaterialPageRoute(builder: (context) => ScanResultsScreen()),
    );
    if (selected != null && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LandingScreen(initialMosque: selected)),
        (route) => false,
      );
    }
  }

  Future<void> _loadJamatTimesFromService() async {
    final id = widget.favoriteMosque.id;
    final gpid = widget.favoriteMosque.googlePlaceId;
    final pid = widget.favoriteMosque.providerId;
    try {
      Map<String, String> out = {};
      // Prefer googlePlaceId -> provider_id
      if ((gpid != null && gpid.isNotEmpty) || (pid != null && pid.isNotEmpty)) {
        final byGpOrPid = await JamatTimeService.fetchByPlaceOrProvider(
          googlePlaceId: gpid,
          providerId: pid,
        );
        out = byGpOrPid.map((k, v) => MapEntry(k, v.jamatTime));
      }
      if (out.isEmpty && id != null) {
        final byId = await JamatTimeService.fetchForMosque(id);
        out = byId.map((k, v) => MapEntry(k, v.jamatTime));
      }
      if (!mounted) return;
      if (out.isNotEmpty) {
        setState(() {
          _jamatTimes = out;
        });
        await _loadAlarmState();
      }
    } catch (_) {
      // ignore: keep fallback
    }
  }

  String _alarmKeyFor(String prayerName) {
    final date = DateTime.now();
    final ymd = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final idPart = widget.favoriteMosque.googlePlaceId?.isNotEmpty == true
        ? 'g:${widget.favoriteMosque.googlePlaceId}'
        : (widget.favoriteMosque.id != null ? 'm:${widget.favoriteMosque.id}' : 'm:0');
    return '$idPart:$ymd:$prayerName';
  }

  Future<void> _loadAlarmState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('alarms_set') ?? [];
      setState(() {
        _alarmsSet = list.toSet();
      });
    } catch (_) {}
  }

  Future<void> _markAlarmSet(String prayerName, {required int minutes}) async {
    final key = _alarmKeyFor(prayerName);
    _alarmsSet.add(key);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('alarms_set', _alarmsSet.toList());
    } catch (_) {}
    if (mounted) setState(() {});
  }

  String? _computeNextJamat(Map<String, String> jt) {
    final now = DateTime.now();
    DateTime? bestTime;
    String? bestName;
    for (final entry in jt.entries) {
      final parsed = _parseToToday(entry.value);
      if (parsed == null) continue;
      if (parsed.isAfter(now) && (bestTime == null || parsed.isBefore(bestTime))) {
        bestTime = parsed;
        bestName = entry.key;
      }
    }
    if (bestTime == null || bestName == null) return null;
    return '$bestName|${_format12h(_hhmm(bestTime))}';
  }

  DateTime? _parseToToday(String hhmm) {
    try {
      if (hhmm.contains('AM') || hhmm.contains('PM')) {
        // Normalize to 24h
        final parts = hhmm.split(' ');
        final t = parts[0];
        final ampm = parts.length > 1 ? parts[1].toUpperCase() : '';
        final p = t.split(':');
        int h = int.parse(p[0]);
        final m = int.parse(p[1]);
        if (ampm == 'PM' && h != 12) h += 12;
        if (ampm == 'AM' && h == 12) h = 0;
        final n = DateTime.now();
        return DateTime(n.year, n.month, n.day, h, m);
      }
      final p = hhmm.split(':');
      final h = int.parse(p[0]);
      final m = int.parse(p[1]);
      final n = DateTime.now();
      return DateTime(n.year, n.month, n.day, h, m);
    } catch (_) {
      return null;
    }
  }

  String _hhmm(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<int?> _askMinutesBefore() async {
    return showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Reminder before jamat'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 5),
              child: const Text('5 minutes before'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 10),
              child: const Text('10 minutes before'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 15),
              child: const Text('15 minutes before'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 30),
              child: const Text('30 minutes before'),
            ),
            const Divider(),
            SimpleDialogOption(
              onPressed: () async {
                final res = await showDialog<int>(
                  context: context,
                  builder: (context) {
                    final c = TextEditingController(text: '5');
                    return AlertDialog(
                      title: const Text('Custom minutes'),
                      content: TextField(
                        controller: c,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Enter minutes'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final v = int.tryParse(c.text.trim());
                            Navigator.pop(context, v == null || v < 0 ? 5 : v);
                          },
                          child: const Text('Set'),
                        )
                      ],
                    );
                  },
                );
                if (context.mounted) Navigator.pop(context, res);
              },
              child: const Text('Custom...'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleTrackMosque() async {
    final l10n = AppLocalizations.of(context)!;
    final gpid = widget.favoriteMosque.googlePlaceId;
    final lat = widget.favoriteMosque.latitude;
    final lon = widget.favoriteMosque.longitude;
    final address = widget.favoriteMosque.address;

    if ((gpid == null || gpid.isEmpty) && (lat == null || lon == null) && (address == null || address.isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location data not available for this mosque.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.openingMaps)),
    );

    // Prefer Google Place ID when available
    final Uri uri;
    if (gpid != null && gpid.isNotEmpty) {
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=place_id:$gpid');
    } else if (lat != null && lon != null) {
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');
    } else {
      final query = Uri.encodeComponent(address!);
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$query');
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps application.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prayerTimesProvider = context.watch<PrayerTimesProvider>();
    final timings = prayerTimesProvider.timings;
    final times = timings ?? _fallbackPrayerTimes;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 20),
            // Mosque Header with Islamic Design
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  // Islamic decorative line
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0),
                                Theme.of(context).primaryColor.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomPaint(
                          size: const Size(40, 20),
                          painter: IslamicShapePainter(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.5),
                                Theme.of(context).primaryColor.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Mosque Name Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Track Icon
                      IconButton(
                        onPressed: _handleTrackMosque,
                        icon: Icon(
                          Icons.directions_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        tooltip: l10n.getDirections,
                      ),
                      // Mosque Name
                      Expanded(
                        child: Text(
                          widget.favoriteMosque.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Rescan Nearby Mosques
                      IconButton(
                        onPressed: _handleSync,
                        icon: Icon(
                          Icons.travel_explore,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        tooltip: l10n.rescanNearby,
                      ),
                    ],
                  ),
                  if (widget.favoriteMosque.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.favoriteMosque.address!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.6),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Islamic decorative line bottom
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0),
                                Theme.of(context).primaryColor.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.5),
                                Theme.of(context).primaryColor.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Last updated info
            Builder(builder: (context) {
              final hasFetched = _jamatTimes != null && _jamatTimes!.values.any((v) => v.trim().isNotEmpty && v != '--:--');
              final hasStored = widget.favoriteMosque.jamatTimes.values.any((v) => v.jamatTime.trim().isNotEmpty && v.jamatTime != '--:--');
              if (!(hasFetched || hasStored)) return const SizedBox.shrink();
              final lu = widget.favoriteMosque.lastUpdatedAt;
              final by = widget.favoriteMosque.lastUpdatedBy;
              if (lu == null && (by == null || by.isEmpty)) return const SizedBox.shrink();
              final fmt = '${lu?.year.toString().padLeft(4, '0')}-${lu?.month.toString().padLeft(2, '0')}-${lu?.day.toString().padLeft(2, '0')}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Updated $fmt by ${by ?? '—'}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
              );
            }),
            // Next Jamat removed per new UX
            // Expected times banner with update CTA if using calculated times
            Builder(builder: (context) {
              final timings = context.watch<PrayerTimesProvider>().timings;
              final times = timings ?? _fallbackPrayerTimes;
              final hasFetched = _jamatTimes != null && _jamatTimes!.values.any((v) => v.trim().isNotEmpty && v != '--:--');
              final hasStored = widget.favoriteMosque.jamatTimes.values.any((v) => v.jamatTime.trim().isNotEmpty && v.jamatTime != '--:--');
              final isExpected = !(hasFetched || hasStored);
              if (!isExpected) return const SizedBox.shrink();
              final expectedJt = _currentEffectiveJamatTimes(times);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Expected jamat time • No jamat time found', style: Theme.of(context).textTheme.bodySmall),
                    ),
                    TextButton(
                      onPressed: () {
                        final expectedMap = expectedJt.map((k, v) => MapEntry(k, JamatTimeDetails(jamatTime: v)));
                        final m = Mosque(
                          id: widget.favoriteMosque.id,
                          name: widget.favoriteMosque.name,
                          address: widget.favoriteMosque.address,
                          latitude: widget.favoriteMosque.latitude,
                          longitude: widget.favoriteMosque.longitude,
                          city: widget.favoriteMosque.city,
                          district: widget.favoriteMosque.district,
                          isFemaleAccessible: widget.favoriteMosque.isFemaleAccessible,
                          createdBy: widget.favoriteMosque.createdBy,
                          createdAt: widget.favoriteMosque.createdAt,
                          googlePlaceId: widget.favoriteMosque.googlePlaceId,
                          provider: 'masjidnear.me',
                          providerId: widget.favoriteMosque.providerId,
                          phone: widget.favoriteMosque.phone,
                          website: widget.favoriteMosque.website,
                          capacity: widget.favoriteMosque.capacity,
                          wheelchairFacility: widget.favoriteMosque.wheelchairFacility,
                          imamName: widget.favoriteMosque.imamName,
                          muezzinName: widget.favoriteMosque.muezzinName,
                          jamatTimes: expectedMap,
                          lastUpdatedAt: widget.favoriteMosque.lastUpdatedAt,
                          lastUpdatedBy: widget.favoriteMosque.lastUpdatedBy,
                        );
                        Navigator.push(context, MaterialPageRoute(builder: (_) => EditJamatTimeScreen(mosque: m)));
                      },
                      child: const Text('Add jamat time'),
                    )
                  ],
                ),
              );
            }),
            // Prayer Times Title

            // Prayer Times List using original PrayerGlanceItem
            ...times.keys.where((k) => ['Fajr','Dhuhr','Asr','Maghrib','Isha'].contains(k)).map((prayerName) => PrayerGlanceItem(
                  prayerName: _localizedPrayerName(l10n, prayerName),
                  prayerTime: _format12h(times[prayerName]!),
                  prayerEnd: _format12h(_endFor(prayerName, times)),
                  jamatTime: _format12h(
                      _currentEffectiveJamatTimes(times)[prayerName] ?? '--:--'
                  ),
                  icon: getIconForPrayer(prayerName),
                  alarmSet: _alarmsSet.contains(_alarmKeyFor(prayerName)),
                  onAlarmTap: () async {
                    final jt = _currentEffectiveJamatTimes(times)[prayerName];
                    if (jt == null || jt == '--:--') {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jamat time not available')),
                      );
                      return;
                    }
                    final dt = _parseToToday(jt);
                    if (dt == null) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid jamat time')),
                      );
                      return;
                    }
                    final minutes = await _askMinutesBefore();
                    if (minutes == null) return;
                    await NotificationService().scheduleNotification(prayerName, dt, minutes);
                    await _markAlarmSet(prayerName, minutes: minutes);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Alarm set $minutes minutes before ${_localizedPrayerName(l10n, prayerName)}')),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  Map<String, String> _currentEffectiveJamatTimes(Map<String, String> prayerTimes) {
    final jt = _jamatTimes;
    if (jt != null && jt.values.any((v) => v.trim().isNotEmpty && v != '--:--')) {
      return jt;
    }
    final stored = widget.favoriteMosque.jamatTimes.map((k, v) => MapEntry(k, v.jamatTime));
    if (stored.values.any((v) => v.trim().isNotEmpty && v != '--:--')) {
      return stored;
    }
    Map<String, int> offsets = const {
      'Fajr': 5,
      'Dhuhr': 10,
      'Asr': 10,
      'Maghrib': 5,
      'Isha': 10,
    };
    final result = <String, String>{};
    for (final k in ['Fajr','Dhuhr','Asr','Maghrib','Isha']) {
      final base = prayerTimes[k];
      if (base == null) continue;
      final dt = _parseToToday(base);
      if (dt == null) continue;
      final add = offsets[k] ?? 5;
      final jam = dt.add(Duration(minutes: add));
      result[k] = _hhmm(jam);
    }
    return result;
  }

  IconData getIconForPrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight_outlined;
      case 'dhuhr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.filter_drama_outlined;
      case 'maghrib':
        return Icons.wb_sunny;
      case 'isha':
        return Icons.nightlight_round_outlined;
      default:
        return Icons.access_time;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/models/jamat_time_details.dart';
import 'package:jamat_time/widgets/custom_app_bar.dart';
import 'package:jamat_time/widgets/prayer_glance_item.dart';
import 'package:jamat_time/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/providers/prayer_times_provider.dart';
import 'package:jamat_time/screens/scan_results_screen.dart';
import 'package:jamat_time/screens/landing_screen.dart';
import 'package:jamat_time/screens/edit_jamat_time_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jamat_time/services/jamat_time_service.dart';
import 'package:jamat_time/widgets/next_jamat_card.dart';
import 'package:jamat_time/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jamat_time/providers/location_provider.dart';

class HomeView extends StatefulWidget {
  final Mosque favoriteMosque;
  const HomeView({super.key, required this.favoriteMosque});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Fallback static times until fetched from API
  final Map<String, String> _fallbackPrayerTimes = const {
    'Fajr': '--:--',
    'Dhuhr': '--:--',
    'Asr': '--:--',
    'Maghrib': '--:--',
    'Isha': '--:--'
  };

  Map<String, String>? _jamatTimes; // fetched from Supabase by mosque id
  Set<String> _alarmsSet = {};

  @override
  void initState() {
    super.initState();
    _loadJamatTimesFromService();
    _loadAlarmState();
    _fetchPrayerTimes();
  }

  @override
  void didUpdateWidget(covariant HomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favoriteMosque.id != widget.favoriteMosque.id) {
      _jamatTimes = null;
      _loadJamatTimesFromService();
      _fetchPrayerTimes(forceRefresh: true);
    }
  }

  Future<void> _fetchPrayerTimes({bool forceRefresh = false}) async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.ensureLocation();
    if (locationProvider.position != null) {
      await context.read<PrayerTimesProvider>().fetchMonthlyPrayerTimes(
            locationProvider.position!.latitude,
            locationProvider.position!.longitude,
            forceRefresh: forceRefresh,
          );
    }
  }

  Future<void> _handleSync() async {
    // Rescan nearby mosques: open results directly and replace MainScreen on choice
    final selected = await Navigator.push<Mosque>(
      context,
      MaterialPageRoute(builder: (context) => ScanResultsScreen()),
    );
    if (selected != null && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LandingScreen(initialMosque: selected)),
        (route) => false,
      );
    }
  }

  Future<void> _loadJamatTimesFromService() async {
    final id = widget.favoriteMosque.id;
    final gpid = widget.favoriteMosque.googlePlaceId;
    final pid = widget.favoriteMosque.providerId;
    try {
      Map<String, String> out = {};
      // Prefer googlePlaceId -> provider_id
      if ((gpid != null && gpid.isNotEmpty) || (pid != null && pid.isNotEmpty)) {
        final byGpOrPid = await JamatTimeService.fetchByPlaceOrProvider(
          googlePlaceId: gpid,
          providerId: pid,
        );
        out = byGpOrPid.map((k, v) => MapEntry(k, v.jamatTime));
      }
      if (out.isEmpty && id != null) {
        final byId = await JamatTimeService.fetchForMosque(id);
        out = byId.map((k, v) => MapEntry(k, v.jamatTime));
      }
      if (!mounted) return;
      if (out.isNotEmpty) {
        setState(() {
          _jamatTimes = out;
        });
        await _loadAlarmState();
      }
    } catch (_) {
      // ignore: keep fallback
    }
  }

  String _alarmKeyFor(String prayerName) {
    final date = DateTime.now();
    final ymd = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final idPart = widget.favoriteMosque.googlePlaceId?.isNotEmpty == true
        ? 'g:${widget.favoriteMosque.googlePlaceId}'
        : (widget.favoriteMosque.id != null ? 'm:${widget.favoriteMosque.id}' : 'm:0');
    return '$idPart:$ymd:$prayerName';
  }

  Future<void> _loadAlarmState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('alarms_set') ?? [];
      setState(() {
        _alarmsSet = list.toSet();
      });
    } catch (_) {}
  }

  Future<void> _markAlarmSet(String prayerName, {required int minutes}) async {
    final key = _alarmKeyFor(prayerName);
    _alarmsSet.add(key);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('alarms_set', _alarmsSet.toList());
    } catch (_) {}
    if (mounted) setState(() {});
  }

  String? _computeNextJamat(Map<String, String> jt) {
    final now = DateTime.now();
    DateTime? bestTime;
    String? bestName;
    for (final entry in jt.entries) {
      final parsed = _parseToToday(entry.value);
      if (parsed == null) continue;
      if (parsed.isAfter(now) && (bestTime == null || parsed.isBefore(bestTime))) {
        bestTime = parsed;
        bestName = entry.key;
      }
    }
    if (bestTime == null || bestName == null) return null;
    return '$bestName|${_format12h(_hhmm(bestTime))}';
  }

  DateTime? _parseToToday(String hhmm) {
    try {
      if (hhmm.contains('AM') || hhmm.contains('PM')) {
        // Normalize to 24h
        final parts = hhmm.split(' ');
        final t = parts[0];
        final ampm = parts.length > 1 ? parts[1].toUpperCase() : '';
        final p = t.split(':');
        int h = int.parse(p[0]);
        final m = int.parse(p[1]);
        if (ampm == 'PM' && h != 12) h += 12;
        if (ampm == 'AM' && h == 12) h = 0;
        final n = DateTime.now();
        return DateTime(n.year, n.month, n.day, h, m);
      }
      final p = hhmm.split(':');
      final h = int.parse(p[0]);
      final m = int.parse(p[1]);
      final n = DateTime.now();
      return DateTime(n.year, n.month, n.day, h, m);
    } catch (_) {
      return null;
    }
  }

  String _hhmm(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<int?> _askMinutesBefore() async {
    return showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Reminder before jamat'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 5),
              child: const Text('5 minutes before'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 10),
              child: const Text('10 minutes before'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 15),
              child: const Text('15 minutes before'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 30),
              child: const Text('30 minutes before'),
            ),
            const Divider(),
            SimpleDialogOption(
              onPressed: () async {
                final res = await showDialog<int>(
                  context: context,
                  builder: (context) {
                    final c = TextEditingController(text: '5');
                    return AlertDialog(
                      title: const Text('Custom minutes'),
                      content: TextField(
                        controller: c,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Enter minutes'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final v = int.tryParse(c.text.trim());
                            Navigator.pop(context, v == null || v < 0 ? 5 : v);
                          },
                          child: const Text('Set'),
                        )
                      ],
                    );
                  },
                );
                if (context.mounted) Navigator.pop(context, res);
              },
              child: const Text('Custom...'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleTrackMosque() async {
    final l10n = AppLocalizations.of(context)!;
    final gpid = widget.favoriteMosque.googlePlaceId;
    final lat = widget.favoriteMosque.latitude;
    final lon = widget.favoriteMosque.longitude;
    final address = widget.favoriteMosque.address;

    if ((gpid == null || gpid.isEmpty) && (lat == null || lon == null) && (address == null || address.isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location data not available for this mosque.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.openingMaps)),
    );

    // Prefer Google Place ID when available
    final Uri uri;
    if (gpid != null && gpid.isNotEmpty) {
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=place_id:$gpid');
    } else if (lat != null && lon != null) {
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon');
    } else {
      final query = Uri.encodeComponent(address!);
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$query');
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps application.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prayerTimesProvider = context.watch<PrayerTimesProvider>();
    final timings = prayerTimesProvider.timings;
    final times = timings ?? _fallbackPrayerTimes;

    if (prayerTimesProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prayerTimesProvider.error != null) {
      return Center(child: Text('Error: ${prayerTimesProvider.error}'));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 20),
            // Mosque Header with Islamic Design
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  // Islamic decorative line
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0),
                                Theme.of(context).primaryColor.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomPaint(
                          size: const Size(40, 20),
                          painter: IslamicShapePainter(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.5),
                                Theme.of(context).primaryColor.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Mosque Name Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Track Icon
                      IconButton(
                        onPressed: _handleTrackMosque,
                        icon: Icon(
                          Icons.directions_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        tooltip: l10n.getDirections,
                      ),
                      // Mosque Name
                      Expanded(
                        child: Text(
                          widget.favoriteMosque.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Rescan Nearby Mosques
                      IconButton(
                        onPressed: _handleSync,
                        icon: Icon(
                          Icons.travel_explore,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        tooltip: l10n.rescanNearby,
                      ),
                    ],
                  ),
                  if (widget.favoriteMosque.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.favoriteMosque.address!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.6),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Islamic decorative line bottom
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0),
                                Theme.of(context).primaryColor.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.5),
                                Theme.of(context).primaryColor.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Last updated info
            Builder(builder: (context) {
              final hasFetched = _jamatTimes != null && _jamatTimes!.values.any((v) => v.trim().isNotEmpty && v != '--:--');
              final hasStored = widget.favoriteMosque.jamatTimes.values.any((v) => v.jamatTime.trim().isNotEmpty && v.jamatTime != '--:--');
              if (!(hasFetched || hasStored)) return const SizedBox.shrink();
              final lu = widget.favoriteMosque.lastUpdatedAt;
              final by = widget.favoriteMosque.lastUpdatedBy;
              if (lu == null && (by == null || by.isEmpty)) return const SizedBox.shrink();
              final fmt = '${lu?.year.toString().padLeft(4, '0')}-${lu?.month.toString().padLeft(2, '0')}-${lu?.day.toString().padLeft(2, '0')}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Updated $fmt by ${by ?? '—'}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
              );
            }),
            // Next Jamat removed per new UX
            // Expected times banner with update CTA if using calculated times
            Builder(builder: (context) {
              final timings = context.watch<PrayerTimesProvider>().timings;
              final times = timings ?? _fallbackPrayerTimes;
              final hasFetched = _jamatTimes != null && _jamatTimes!.values.any((v) => v.trim().isNotEmpty && v != '--:--');
              final hasStored = widget.favoriteMosque.jamatTimes.values.any((v) => v.jamatTime.trim().isNotEmpty && v.jamatTime != '--:--');
              final isExpected = !(hasFetched || hasStored);
              if (!isExpected) return const SizedBox.shrink();
              final expectedJt = _currentEffectiveJamatTimes(times);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Expected jamat time • No jamat time found', style: Theme.of(context).textTheme.bodySmall),
                    ),
                    TextButton(
                      onPressed: () {
                        final expectedMap = expectedJt.map((k, v) => MapEntry(k, JamatTimeDetails(jamatTime: v)));
                        final m = Mosque(
                          id: widget.favoriteMosque.id,
                          name: widget.favoriteMosque.name,
                          address: widget.favoriteMosque.address,
                          latitude: widget.favoriteMosque.latitude,
                          longitude: widget.favoriteMosque.longitude,
                          city: widget.favoriteMosque.city,
                          district: widget.favoriteMosque.district,
                          isFemaleAccessible: widget.favoriteMosque.isFemaleAccessible,
                          createdBy: widget.favoriteMosque.createdBy,
                          createdAt: widget.favoriteMosque.createdAt,
                          googlePlaceId: widget.favoriteMosque.googlePlaceId,
                          provider: 'masjidnear.me',
                          providerId: widget.favoriteMosque.providerId,
                          phone: widget.favoriteMosque.phone,
                          website: widget.favoriteMosque.website,
                          capacity: widget.favoriteMosque.capacity,
                          wheelchairFacility: widget.favoriteMosque.wheelchairFacility,
                          imamName: widget.favoriteMosque.imamName,
                          muezzinName: widget.favoriteMosque.muezzinName,
                          jamatTimes: expectedMap,
                          lastUpdatedAt: widget.favoriteMosque.lastUpdatedAt,
                          lastUpdatedBy: widget.favoriteMosque.lastUpdatedBy,
                        );
                        Navigator.push(context, MaterialPageRoute(builder: (_) => EditJamatTimeScreen(mosque: m)));
                      },
                      child: const Text('Add jamat time'),
                    )
                  ],
                ),
              );
            }),
            // Prayer Times Title

            // Prayer Times List using original PrayerGlanceItem
            ...times.keys.where((k) => ['Fajr','Dhuhr','Asr','Maghrib','Isha'].contains(k)).map((prayerName) => PrayerGlanceItem(
                  prayerName: _localizedPrayerName(l10n, prayerName),
                  prayerTime: _format12h(times[prayerName]!),
                  prayerEnd: _format12h(_endFor(prayerName, times)),
                  jamatTime: _format12h(
                      _currentEffectiveJamatTimes(times)[prayerName] ?? '--:--'
                  ),
                  icon: getIconForPrayer(prayerName),
                  alarmSet: _alarmsSet.contains(_alarmKeyFor(prayerName)),
                  onAlarmTap: () async {
                    final jt = _currentEffectiveJamatTimes(times)[prayerName];
                    if (jt == null || jt == '--:--') {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jamat time not available')),
                      );
                      return;
                    }
                    final dt = _parseToToday(jt);
                    if (dt == null) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid jamat time')),
                      );
                      return;
                    }
                    final minutes = await _askMinutesBefore();
                    if (minutes == null) return;
                    await NotificationService().scheduleNotification(prayerName, dt, minutes);
                    await _markAlarmSet(prayerName, minutes: minutes);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Alarm set $minutes minutes before ${_localizedPrayerName(l10n, prayerName)}')),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  Map<String, String> _currentEffectiveJamatTimes(Map<String, String> prayerTimes) {
    final jt = _jamatTimes;
    if (jt != null && jt.values.any((v) => v.trim().isNotEmpty && v != '--:--')) {
      return jt;
    }
    final stored = widget.favoriteMosque.jamatTimes.map((k, v) => MapEntry(k, v.jamatTime));
    if (stored.values.any((v) => v.trim().isNotEmpty && v != '--:--')) {
      return stored;
    }
    Map<String, int> offsets = const {
      'Fajr': 5,
      'Dhuhr': 10,
      'Asr': 10,
      'Maghrib': 5,
      'Isha': 10,
    };
    final result = <String, String>{};
    for (final k in ['Fajr','Dhuhr','Asr','Maghrib','Isha']) {
      final base = prayerTimes[k];
      if (base == null) continue;
      final dt = _parseToToday(base);
      if (dt == null) continue;
      final add = offsets[k] ?? 5;
      final jam = dt.add(Duration(minutes: add));
      result[k] = _hhmm(jam);
    }
    return result;
  }

  IconData getIconForPrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight_outlined;
      case 'dhuhr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.filter_drama_outlined;
      case 'maghrib':
        return Icons.wb_sunny;
      case 'isha':
        return Icons.nightlight_round_outlined;
      default:
        return Icons.access_time;
    }
  }
}

String _format12h(String time24) {
  // Accept "HH:mm" or already formatted values
  if (time24.contains('AM') || time24.contains('PM') || time24 == '--:--') return time24;
  try {
    // Remove any text after the time (e.g., " (+06)")
    final cleanTime = time24.split(' ').first;
    final parts = cleanTime.split(':');
    int h = int.parse(parts[0]);
    final m = parts[1];
    final am = h < 12;
    if (h == 0) h = 12; else if (h > 12) h -= 12;
    return '${h.toString().padLeft(2, '0')}:$m ${am ? 'AM' : 'PM'}';
  } catch (_) {
    return time24;
  }
}

String _endFor(String prayer, Map<String, String> t) {
  switch (prayer) {
    case 'Fajr':
      return t['Sunrise'] ?? '--:--';
    case 'Dhuhr':
      return t['Asr'] ?? '--:--';
    case 'Asr':
      return t['Maghrib'] ?? '--:--';
    case 'Maghrib':
      return t['Isha'] ?? '--:--';
    case 'Isha':
      return t['Midnight'] ?? '--:--';
    default:
      return '--:--';
  }
}

// Custom painter for Islamic decorative shape
String _localizedPrayerName(AppLocalizations l10n, String key){
  switch (key) {
    case 'Fajr': return l10n.prayerFajr;
    case 'Dhuhr': return l10n.prayerDhuhr;
    case 'Asr': return l10n.prayerAsr;
    case 'Maghrib': return l10n.prayerMaghrib;
    case 'Isha': return l10n.prayerIsha;
    default: return key;
  }
}

class IslamicShapePainter extends CustomPainter {
  final Color color;
  final bool isInverted;

  IslamicShapePainter({
    required this.color,
    this.isInverted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (!isInverted) {
      // Top shape
      path.moveTo(size.width * 0.5, 0);
      path.quadraticBezierTo(0, size.height * 0.5, 0, size.height);
      path.lineTo(size.width, size.height);
      path.quadraticBezierTo(
          size.width, size.height * 0.5, size.width * 0.5, 0);
    } else {
      // Bottom shape (inverted)
      path.moveTo(0, 0);
      path.quadraticBezierTo(
          0, size.height * 0.5, size.width * 0.5, size.height);
      path.quadraticBezierTo(size.width, size.height * 0.5, size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
