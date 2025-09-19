import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/location_provider.dart';
import '../services/aladhan_qibla_service.dart';

class QiblaView extends StatefulWidget {
  const QiblaView({super.key});

  @override
  State<QiblaView> createState() => _QiblaViewState();
}

class _QiblaViewState extends State<QiblaView> {
  static const _kaabaLatitude = 21.422487;
  static const _kaabaLongitude = 39.826206;

  final AladhanQiblaService _aladhanService = AladhanQiblaService();
  Future<double?>? _directionFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().ensureLocation();
    });
  }

  void _resetDirection() {
    setState(() => _directionFuture = null);
  }

  double _bearingToQibla(double latitude, double longitude) {
    final lat1 = latitude * math.pi / 180;
    final lat2 = _kaabaLatitude * math.pi / 180;
    final deltaLon = (_kaabaLongitude - longitude) * math.pi / 180;
    final y = math.sin(deltaLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);
    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  double _distanceToQibla(double latitude, double longitude) {
    final meters = Geolocator.distanceBetween(
      latitude,
      longitude,
      _kaabaLatitude,
      _kaabaLongitude,
    );
    return meters / 1000.0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<LocationProvider>();
    final position = provider.position;
    final error = provider.error;

    double? fallbackBearing;
    double? distanceKm;
    if (position != null) {
      fallbackBearing = _bearingToQibla(position.latitude, position.longitude);
      distanceKm = _distanceToQibla(position.latitude, position.longitude);
      _directionFuture ??= _aladhanService.fetchDirection(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }

    final locationLabel = [
      if (provider.city != null && provider.city!.isNotEmpty) provider.city!,
      if (provider.country != null && provider.country!.isNotEmpty)
        provider.country!,
    ].join(', ');

    if (provider.loading && position == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(l10n.qiblaDirection)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.fetchingLocation),
            ],
          ),
        ),
      );
    }

    if (position == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(l10n.qiblaDirection)),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore_off,
                    size: 72, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 20),
                Text(
                  error ?? l10n.enableLocationServices,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await provider.ensureLocation();
                    _resetDirection();
                  },
                  icon: const Icon(Icons.my_location),
                  label: Text(l10n.retryLabel),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final directionFuture = _directionFuture;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.qiblaDirection)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _resetDirection();
            await provider.ensureLocation();
          },
          child: FutureBuilder<double?>(
            future: directionFuture,
            builder: (context, snapshot) {
              final bearing = snapshot.data ?? fallbackBearing;
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                children: [
                  _LocationHeader(
                    locationLabel: locationLabel,
                    latitude: position.latitude,
                    longitude: position.longitude,
                    bearing: bearing,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 24),
                  _OrientationArena(bearing: bearing),
                  const SizedBox(height: 20),
                  _MetricsCard(
                    bearing: bearing,
                    distanceKm: distanceKm,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 20),
                  _DirectionInsightCard(
                    snapshot: snapshot,
                    fallbackBearing: fallbackBearing,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 0,
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.4),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.qiblaTipsTitle,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          ..._fallbackSteps(l10n).map(
                            (step) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('â€¢ '),
                                  Expanded(child: Text(step)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<String> _fallbackSteps(AppLocalizations l10n) => [
        l10n.qiblaAlignStep1,
        l10n.qiblaAlignStep2,
        l10n.qiblaAlignStep3,
      ];
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({
    required this.locationLabel,
    required this.latitude,
    required this.longitude,
    required this.bearing,
    required this.l10n,
  });

  final String locationLabel;
  final double latitude;
  final double longitude;
  final double? bearing;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          locationLabel.isEmpty ? l10n.locationUnknown : locationLabel,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          l10n.coordinatesLabel(
            latitude.toStringAsFixed(4),
            longitude.toStringAsFixed(4),
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (bearing != null) ...[
          const SizedBox(height: 10),
          Chip(
            avatar: const Icon(Icons.navigation, size: 18),
            label: Text(l10n.qiblaBearingLabel(bearing!.toStringAsFixed(1))),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ],
      ],
    );
  }
}

class _OrientationArena extends StatelessWidget {
  const _OrientationArena({required this.bearing});

  final double? bearing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
        width: 320,
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.12),
                    theme.colorScheme.surface.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            for (int i = 0; i < 10; i++)
              _PersonMarker(
                angle: (2 * math.pi / 10) * i - math.pi / 2,
                highlightAngle:
                    bearing == null ? null : ((bearing! - 90) * math.pi / 180),
              ),
            Positioned(
              width: 110,
              height: 110,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer.withOpacity(0.75),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.25),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mosque,
                  size: 52,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            if (bearing != null)
              Transform.rotate(
                angle: (bearing! - 90) * math.pi / 180,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 110,
                      width: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Icon(
                      Icons.place,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PersonMarker extends StatelessWidget {
  const _PersonMarker({
    required this.angle,
    required this.highlightAngle,
  });

  final double angle;
  final double? highlightAngle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = 120.0;
    final offset = Offset(
      radius * math.cos(angle),
      radius * math.sin(angle),
    );

    double? difference;
    if (highlightAngle != null) {
      final raw = angle - highlightAngle!;
      difference = (raw + math.pi) % (2 * math.pi) - math.pi;
    }

    final isHighlighted = difference != null && difference.abs() < math.pi / 8;

    return Transform.translate(
      offset: offset,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isHighlighted ? 52 : 44,
        height: isHighlighted ? 52 : 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isHighlighted
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant.withOpacity(0.8),
          border: Border.all(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.person,
          color: isHighlighted
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({
    required this.bearing,
    required this.distanceKm,
    required this.l10n,
  });

  final double? bearing;
  final double? distanceKm;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.orientationSummary,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.explore, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    bearing == null
                        ? l10n.orientationUnknown
                        : l10n.qiblaBearingLabel(bearing!.toStringAsFixed(1)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.map_outlined, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    distanceKm == null
                        ? l10n.distanceUnknown
                        : l10n
                            .qiblaDistanceLabel(distanceKm!.toStringAsFixed(1)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectionInsightCard extends StatelessWidget {
  const _DirectionInsightCard({
    required this.snapshot,
    required this.fallbackBearing,
    required this.l10n,
  });

  final AsyncSnapshot<double?> snapshot;
  final double? fallbackBearing;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget content;

    if (snapshot.connectionState == ConnectionState.waiting) {
      content = Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(l10n.qiblaSourceLoading)),
        ],
      );
    } else if (snapshot.hasError) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.qiblaSourceTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.qiblaSourceFallback, style: theme.textTheme.bodyMedium),
        ],
      );
    } else if (snapshot.data != null) {
      final direction = snapshot.data!;
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.qiblaSourceTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            l10n.qiblaSourceSuccess(direction.toStringAsFixed(2)),
            style: theme.textTheme.bodyMedium,
          ),
          if (fallbackBearing != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                l10n.qiblaSourceComparison(
                  fallbackBearing!.toStringAsFixed(1),
                ),
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.qiblaSourceTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.qiblaSourceFallback, style: theme.textTheme.bodyMedium),
        ],
      );
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }
}
