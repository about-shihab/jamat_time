import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/event_model.dart';

class EventCard extends StatefulWidget {
  const EventCard({
    super.key,
    required this.event,
    this.distanceKm,
    this.directionLabel,
  });

  final EventModel event;
  final double? distanceKm;
  final String? directionLabel;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late int _goingCount;
  late bool _isGoing;
  bool _isInterested = false;

  @override
  void initState() {
    super.initState();
    _goingCount = widget.event.goingCount;
    _isGoing = widget.event.isUserGoing;
  }

  @override
  void didUpdateWidget(covariant EventCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.goingCount != widget.event.goingCount) {
      _goingCount = widget.event.goingCount;
    }
    if (oldWidget.event.isUserGoing != widget.event.isUserGoing) {
      _isGoing = widget.event.isUserGoing;
    }
  }

  Future<void> _openDirections(BuildContext context) async {
    final latitude = widget.event.latitude;
    final longitude = widget.event.longitude;
    if (latitude == null || longitude == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location is not available for this event.')),
      );
      return;
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open Google Maps.')),
      );
    }
  }

  void _toggleGoing() {
    setState(() {
      if (_isGoing) {
        if (_goingCount > 0) _goingCount -= 1;
        _isGoing = false;
      } else {
        _goingCount += 1;
        _isGoing = true;
      }
    });
  }

  void _toggleInterested() {
    setState(() => _isInterested = !_isInterested);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dateFormatter = DateFormat('EEE, MMM d - h:mm a');
    final endDisplay = widget.event.endsAt == null
        ? null
        : dateFormatter.format(widget.event.endsAt!);
    final coordinateLabel = (widget.event.latitude != null &&
            widget.event.longitude != null)
        ? '${widget.event.latitude!.toStringAsFixed(3)}, ${widget.event.longitude!.toStringAsFixed(3)}'
        : null;
    final distanceLabel = widget.distanceKm == null
        ? null
        : '${widget.distanceKm!.toStringAsFixed(widget.distanceKm! < 1 ? 1 : 0)} km';
    final headingLabel =
        widget.directionLabel == null || widget.directionLabel!.isEmpty
            ? null
            : widget.directionLabel!.toUpperCase();

    final baseColor = palette.surface;
    final overlay = palette.primary
        .withValues(alpha: theme.brightness == Brightness.dark ? 0.18 : 0.14);

    return Card(
      color: baseColor.withValues(alpha: 0.96),
      elevation: 6,
      shadowColor: palette.primary.withValues(alpha: 0.25),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openDirections(context),
        child: ClipRRect(
          borderRadius:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))
                  .borderRadius,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      baseColor,
                      baseColor.withValues(alpha: 0.94),
                      overlay
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                      color: palette.primary.withValues(alpha: 0.18)),
                ),
              ),
              Positioned(
                top: -30,
                right: -10,
                child: Icon(
                  Icons.mosque,
                  size: 120,
                  color: palette.primary.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                bottom: -36,
                left: -16,
                child: Icon(
                  Icons.star_rate_rounded,
                  size: 110,
                  color: palette.secondary.withValues(alpha: 0.06),
                ),
              ),
              Positioned(
                top: 62,
                right: 48,
                child: Icon(
                  Icons.nightlight_round,
                  size: 48,
                  color: palette.tertiary.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor:
                              palette.primary.withValues(alpha: 0.18),
                          child: Icon(
                            widget.event.locationType ==
                                    EventLocationType.mosque
                                ? Icons.mosque
                                : Icons.diversity_3,
                            color: palette.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.event.title,
                                style: textTheme.titleLarge?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (widget.event.description != null &&
                                  widget.event.description!.trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    widget.event.description!,
                                    style: textTheme.bodyMedium
                                        ?.copyWith(height: 1.4),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _DetailRow(
                      icon: Icons.schedule_outlined,
                      label: dateFormatter.format(widget.event.startsAt),
                      secondary:
                          endDisplay == null ? null : 'Ends - $endDisplay',
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: widget.event.venueLabel,
                      secondary: widget.event.address.isNotEmpty &&
                              widget.event.address != widget.event.venueLabel
                          ? widget.event.address
                          : null,
                    ),
                    if (coordinateLabel != null) ...[
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.my_location_outlined,
                        label: coordinateLabel,
                      ),
                    ],
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: [
                        _MetaChip(
                          icon: Icons.people_alt_outlined,
                          label: '$_goingCount going',
                          background: palette.surfaceContainerHighest
                              .withValues(alpha: 0.85),
                          foreground: palette.onSurfaceVariant,
                        ),
                        if (distanceLabel != null)
                          _MetaChip(
                            icon: Icons.navigation_outlined,
                            label: headingLabel == null
                                ? distanceLabel
                                : '$distanceLabel · $headingLabel',
                            background: palette.secondaryContainer
                                .withValues(alpha: 0.75),
                            foreground: palette.onSecondaryContainer,
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _toggleInterested,
                            icon: Icon(
                              _isInterested
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isInterested
                                  ? palette.primary
                                  : theme.iconTheme.color,
                            ),
                            label: Text(
                                _isInterested ? 'Interested' : 'Interested?'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _toggleGoing,
                            icon: Icon(
                              _isGoing
                                  ? Icons.check_circle
                                  : Icons.event_available,
                            ),
                            label: Text(_isGoing ? 'Going' : 'Join'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    this.secondary,
  });

  final IconData icon;
  final String label;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.hintColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
              if (secondary != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    secondary!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return RawChip(
      avatar: Icon(icon, size: 18, color: foreground),
      label: Text(label),
      labelStyle: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      backgroundColor: background,
      showCheckmark: false,
      pressElevation: 0,
      side: BorderSide.none,
    );
  }
}
