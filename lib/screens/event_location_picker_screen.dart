import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EventLocationPickerScreen extends StatefulWidget {
  const EventLocationPickerScreen({
    super.key,
    required this.initialPoint,
  });

  final LatLng initialPoint;

  @override
  State<EventLocationPickerScreen> createState() =>
      _EventLocationPickerScreenState();
}

class _EventLocationPickerScreenState extends State<EventLocationPickerScreen> {
  late final MapController _mapController;
  LatLng? _selectedPoint;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedPoint = widget.initialPoint;
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    setState(() => _selectedPoint = point);
  }

  Future<void> _confirmSelection() async {
    if (_selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tap anywhere on the map to select a location.')),
      );
      return;
    }
    Navigator.of(context).pop(_selectedPoint);
  }

  @override
  Widget build(BuildContext context) {
    final marker = _selectedPoint == null
        ? <Marker>[]
        : [
            Marker(
              point: _selectedPoint!,
              width: 40,
              height: 40,
              alignment: Alignment.topCenter,
              child: const Icon(Icons.location_pin,
                  size: 38, color: Colors.redAccent),
            ),
          ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Event Location'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPoint ?? widget.initialPoint,
              initialZoom: 15,
              onTap: _handleTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.jamat_time.app',
              ),
              MarkerLayer(markers: marker),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 100,
            child: Card(
              color: Theme.of(context).cardColor.withValues(alpha: 0.85),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _selectedPoint == null
                      ? 'Tap on the map to pinpoint the event location.'
                      : 'Selected: , ',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirmSelection,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Use this location'),
      ),
    );
  }
}
