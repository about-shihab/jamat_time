import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/event_model.dart';
import '../models/mosque_model.dart';
import '../providers/location_provider.dart';
import '../screens/event_location_picker_screen.dart';
import '../screens/scan_results_screen.dart';
import '../services/event_service.dart';

class EventCreationSheet extends StatefulWidget {
  const EventCreationSheet({
    super.key,
    required this.eventService,
  });

  final EventService eventService;

  @override
  State<EventCreationSheet> createState() => _EventCreationSheetState();
}

class _EventCreationSheetState extends State<EventCreationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueLabelController = TextEditingController();
  final _addressController = TextEditingController();

  EventLocationType _locationType = EventLocationType.mosque;
  DateTime? _startsAt;
  DateTime? _endsAt;
  Mosque? _selectedMosque;
  LatLng? _externalPoint;
  LatLng? _initialCenter;

  bool _fetchingAddress = false;
  bool _submitting = false;
  String? _formError;

  String _formatCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return '';
    }
    final lat = latitude.toStringAsFixed(4);
    final lon = longitude.toStringAsFixed(4);
    return '$lat, $lon';
  }

  @override
  void initState() {
    super.initState();
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final pos = locationProvider.position;
    _initialCenter = pos == null
        ? const LatLng(23.8103, 90.4125)
        : LatLng(pos.latitude, pos.longitude);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueLabelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_startsAt ?? now)
        : (_endsAt ?? _startsAt ?? now.add(const Duration(hours: 1)));
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startsAt = combined;
        if (_endsAt != null && _endsAt!.isBefore(combined)) {
          _endsAt = combined.add(const Duration(hours: 1));
        }
      } else {
        _endsAt = combined;
      }
    });
  }

  Future<void> _chooseMosque() async {
    final mosque = await Navigator.of(context).push<Mosque>(
      MaterialPageRoute(builder: (_) => const ScanResultsScreen()),
    );
    if (!mounted || mosque == null) return;
    setState(() {
      _selectedMosque = mosque;
      _venueLabelController.text = mosque.name;
      final fallback = _formatCoordinates(mosque.latitude, mosque.longitude);
      final address = mosque.address?.trim();
      _addressController.text =
          (address != null && address.isNotEmpty) ? address : fallback;
    });
  }

  Future<void> _pickExternalLocation() async {
    final initial =
        _externalPoint ?? _initialCenter ?? const LatLng(23.8103, 90.4125);
    final point = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => EventLocationPickerScreen(initialPoint: initial),
      ),
    );
    if (!mounted || point == null) return;
    setState(() {
      _externalPoint = point;
      _fetchingAddress = true;
    });
    try {
      final placemarks =
          await placemarkFromCoordinates(point.latitude, point.longitude);
      if (!mounted) return;
      final place = placemarks.isNotEmpty ? placemarks.first : null;
      final segments = <String>[];
      if (place != null) {
        if (place.name != null && place.name!.isNotEmpty) {
          segments.add(place.name!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          segments.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          segments.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          segments.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          segments.add(place.country!);
        }
      }
      setState(() {
        if (_venueLabelController.text.trim().isEmpty && place?.name != null) {
          _venueLabelController.text = place!.name!;
        }
        if (segments.isNotEmpty) {
          _addressController.text = segments.join(', ');
        } else {
          _addressController.text =
              _formatCoordinates(point.latitude, point.longitude);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _addressController.text =
            _formatCoordinates(point.latitude, point.longitude);
      });
    } finally {
      if (mounted) {
        setState(() => _fetchingAddress = false);
      }
    }
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    setState(() => _formError = null);
    if (!_formKey.currentState!.validate()) return;
    if (_startsAt == null) {
      setState(() => _formError = 'Please select when the event starts.');
      return;
    }
    if (_endsAt != null && _endsAt!.isBefore(_startsAt!)) {
      setState(() => _formError = 'Event end time must be after start time.');
      return;
    }

    EventDraft draft;
    if (_locationType == EventLocationType.mosque) {
      final mosque = _selectedMosque;
      if (mosque == null) {
        setState(() => _formError = 'Select a mosque for this event.');
        return;
      }
      final fallback = _formatCoordinates(mosque.latitude, mosque.longitude);
      final addressText = _addressController.text.trim().isEmpty
          ? fallback
          : _addressController.text.trim();
      draft = EventDraft(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startsAt: _startsAt!,
        endsAt: _endsAt,
        locationType: EventLocationType.mosque,
        venueLabel: mosque.name,
        address: addressText,
        mosqueId: mosque.id,
        latitude: mosque.latitude,
        longitude: mosque.longitude,
      );
    } else {
      final label = _venueLabelController.text.trim();
      final address = _addressController.text.trim();
      if (_externalPoint == null) {
        setState(() => _formError = 'Pick the event location on the map.');
        return;
      }
      if (label.isEmpty) {
        setState(() => _formError = 'Provide a label for this location.');
        return;
      }
      if (address.isEmpty) {
        setState(
            () => _formError = 'Add an address or description for the venue.');
        return;
      }
      draft = EventDraft(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startsAt: _startsAt!,
        endsAt: _endsAt,
        locationType: EventLocationType.external,
        venueLabel: label,
        address: address,
        latitude: _externalPoint!.latitude,
        longitude: _externalPoint!.longitude,
      );
    }

    setState(() => _submitting = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      await widget.eventService.createEvent(draft, organizerId: userId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _formError = 'Could not create event. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildDateField({
    required String label,
    DateTime? value,
    required VoidCallback onPressed,
  }) {
    final display = value == null
        ? 'Select date and time'
        : DateFormat('EEE, MMM d h:mm a').format(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.schedule_outlined),
          label: Text(display),
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    if (_locationType == EventLocationType.mosque) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.mosque_outlined,
                  color: Theme.of(context).primaryColor),
            ),
            title: Text(_selectedMosque?.name ?? 'Select mosque'),
            subtitle: Text(
              _addressController.text.isEmpty
                  ? 'Pick a mosque to use its address and map location.'
                  : _addressController.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: TextButton(
              onPressed: _chooseMosque,
              child: Text(_selectedMosque == null ? 'Choose' : 'Change'),
            ),
          ),
        ],
      );
    }

    final coordinateLabel = _externalPoint == null
        ? ''
        : _formatCoordinates(
            _externalPoint!.latitude, _externalPoint!.longitude);
    final buttonLabel = _externalPoint == null
        ? 'Set location on map'
        : 'Update map location (' + coordinateLabel + ')';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _venueLabelController,
          decoration: const InputDecoration(
            labelText: 'Venue label',
            hintText: 'e.g. Community Hall or Park name',
          ),
          validator: (value) {
            if (_locationType == EventLocationType.external &&
                (value == null || value.trim().isEmpty)) {
              return 'Enter a label for the venue.';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Address or description',
            suffixIcon: _fetchingAddress
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    onPressed: _pickExternalLocation,
                    icon: const Icon(Icons.map_outlined),
                    tooltip: 'Choose on map',
                  ),
          ),
          validator: (value) {
            if (_locationType == EventLocationType.external &&
                (value == null || value.trim().isEmpty)) {
              return 'Provide an address or landmark.';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _pickExternalLocation,
            icon: const Icon(Icons.location_on_outlined),
            label: Text(buttonLabel),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Event',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Event name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 16),
              Text('When', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Starts',
                      value: _startsAt,
                      onPressed: () => _pickDateTime(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      label: 'Ends',
                      value: _endsAt,
                      onPressed: () => _pickDateTime(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Location type',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<EventLocationType>(
                segments: const [
                  ButtonSegment(
                    value: EventLocationType.mosque,
                    icon: Icon(Icons.mosque_outlined),
                    label: Text('Mosque'),
                  ),
                  ButtonSegment(
                    value: EventLocationType.external,
                    icon: Icon(Icons.public_outlined),
                    label: Text('Outside mosque'),
                  ),
                ],
                selected: <EventLocationType>{_locationType},
                onSelectionChanged: (value) {
                  if (value.isEmpty) return;
                  setState(() {
                    _locationType = value.first;
                    _formError = null;
                    if (_locationType == EventLocationType.mosque) {
                      _externalPoint = null;
                    } else {
                      _selectedMosque = null;
                      _venueLabelController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildLocationSelector(),
              if (_formError != null) ...[
                const SizedBox(height: 16),
                Text(
                  _formError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _handleSubmit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_submitting ? 'Creating...' : 'Create event'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }
}
