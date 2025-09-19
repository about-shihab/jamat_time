import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../models/event_model.dart';
import '../providers/location_provider.dart';
import '../services/event_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/event_card.dart';
import '../widgets/event_creation_sheet.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> {
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().ensureLocation();
    });
  }

  Future<void> _openCreateEventSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EventCreationSheet(eventService: _eventService),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully.')),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 64,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No events yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create the first event for your community and invite others.',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openCreateEventSheet,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create event'),
            ),
          ],
        ),
      ),
    );
  }

  double _distanceKm(Position origin, double latitude, double longitude) {
    final meters = Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      latitude,
      longitude,
    );
    return meters / 1000.0;
  }

  double _bearingDegrees(Position origin, double latitude, double longitude) {
    final lat1 = origin.latitude * math.pi / 180;
    final lat2 = latitude * math.pi / 180;
    final deltaLon = (longitude - origin.longitude) * math.pi / 180;

    final y = math.sin(deltaLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);
    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  String _bearingToDirection(double bearing) {
    const labels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) ~/ 45) % labels.length;
    return labels[index];
  }

  List<_EventEntry> _buildEntries(List<EventModel> events, Position? position) {
    if (position == null) {
      return events.map((event) => _EventEntry(event: event)).toList();
    }

    final entries = <_EventEntry>[];
    for (final event in events) {
      final lat = event.latitude;
      final lon = event.longitude;
      if (lat == null || lon == null) {
        continue;
      }
      final distance = _distanceKm(position, lat, lon);
      if (distance > 10) {
        continue;
      }
      final bearing = _bearingDegrees(position, lat, lon);
      entries.add(
        _EventEntry(
          event: event,
          distanceKm: distance,
          bearingDegrees: bearing,
          directionLabel: _bearingToDirection(bearing),
        ),
      );
    }
    entries.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final position = locationProvider.position;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateEventSheet,
        icon: const Icon(Icons.add),
        label: const Text('New event'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: StreamBuilder<List<EventModel>>(
        stream: _eventService.watchUpcomingEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 56,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load events right now.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check your connection or try again later.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    )
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!;
          if (events.isEmpty) {
            return _buildEmptyState();
          }

          final entries = _buildEntries(events, position);
          if (position != null && entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.travel_explore_outlined,
                      size: 56,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No nearby events',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We couldn't find events within 10 km of you just yet.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () => setState(() {}),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              await context.read<LocationProvider>().ensureLocation();
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 120),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return EventCard(
                  event: entry.event,
                  distanceKm: entry.distanceKm,
                  directionLabel: entry.directionLabel,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EventEntry {
  const _EventEntry({
    required this.event,
    this.distanceKm,
    this.bearingDegrees,
    this.directionLabel,
  });

  final EventModel event;
  final double? distanceKm;
  final double? bearingDegrees;
  final String? directionLabel;
}
