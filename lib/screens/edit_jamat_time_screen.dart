import 'package:flutter/material.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:jamat_time/services/jamat_time_service.dart';
import 'package:jamat_time/widgets/aurora_background_painter.dart';
import 'package:intl/intl.dart';

class EditJamatTimeScreen extends StatefulWidget {
  final Mosque mosque;
  const EditJamatTimeScreen({super.key, required this.mosque});

  @override
  State<EditJamatTimeScreen> createState() => _EditJamatTimeScreenState();
}

class _EditJamatTimeScreenState extends State<EditJamatTimeScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _fajrController;
  late TextEditingController _dhuhrController;
  late TextEditingController _asrController;
  late TextEditingController _maghribController;
  late TextEditingController _ishaController;
  // Additional mosque info controllers
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _capacityController;
  late TextEditingController _imamController;
  late TextEditingController _muezzinController;
  bool _femaleAccessible = false;
  bool _wheelchairFacility = false;
  late final AnimationController _animationController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    final times = widget.mosque.jamatTimes;
    _fajrController = TextEditingController(text: times['Fajr']?.jamatTime ?? '');
    _dhuhrController = TextEditingController(text: times['Dhuhr']?.jamatTime ?? '');
    _asrController = TextEditingController(text: times['Asr']?.jamatTime ?? '');
    _maghribController = TextEditingController(text: times['Maghrib']?.jamatTime ?? '');
    _ishaController = TextEditingController(text: times['Isha']?.jamatTime ?? '');
    _phoneController = TextEditingController(text: widget.mosque.phone ?? '');
    _websiteController = TextEditingController(text: widget.mosque.website ?? '');
    _capacityController = TextEditingController(text: widget.mosque.capacity?.toString() ?? '');
    _imamController = TextEditingController(text: widget.mosque.imamName ?? '');
    _muezzinController = TextEditingController(text: widget.mosque.muezzinName ?? '');
    _femaleAccessible = widget.mosque.isFemaleAccessible;
    _wheelchairFacility = widget.mosque.wheelchairFacility ?? false;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fajrController.dispose();
    _dhuhrController.dispose();
    _asrController.dispose();
    _maghribController.dispose();
    _ishaController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _capacityController.dispose();
    _imamController.dispose();
    _muezzinController.dispose();
    super.dispose();
  }

  void _saveTimes() {
    final l10n = AppLocalizations.of(context)!;
    final map = <String, String>{
      'Fajr': _fajrController.text.trim(),
      'Dhuhr': _dhuhrController.text.trim(),
      'Asr': _asrController.text.trim(),
      'Maghrib': _maghribController.text.trim(),
      'Isha': _ishaController.text.trim(),
    };
    unawaited(() async {
      if (mounted) setState(() => _saving = true);
      final ok = await JamatTimeService.saveMosqueAndTimes(
        mosque: widget.mosque,
        jamatTimesText: map,
        isFemaleAccessible: _femaleAccessible,
        wheelchairFacility: _wheelchairFacility,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        capacity: int.tryParse(_capacityController.text.trim()),
        imamName: _imamController.text.trim().isEmpty ? null : _imamController.text.trim(),
        muezzinName: _muezzinController.text.trim().isEmpty ? null : _muezzinController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(ok ? Icons.check_circle_outline : Icons.error_outline,
                  color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(ok ? l10n.thankYouContribution : 'Failed to save. Please try again.')),
            ],
          ),
          backgroundColor: ok
              ? Colors.green.shade600
              : Theme.of(context).colorScheme.error,
        ),
      );
      if (mounted) setState(() => _saving = false);
      if (ok) {
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color1 = theme.primaryColor.withOpacity(0.3);
    final color2 = theme.scaffoldBackgroundColor;
    final color3 = theme.cardColor.withOpacity(0.3);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.updateTimes),
      ),
      body: Stack(
        children: [
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: AuroraBackgroundPainter(
                animation: _animationController,
                color1: color1,
                color2: color2,
                color3: color3,
              ),
            ),
          ),
          ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            widget.mosque.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          Text(
            widget.mosque.address ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _buildTimeInput('Fajr', _fajrController),
          _buildTimeInput('Dhuhr', _dhuhrController),
          _buildTimeInput('Asr', _asrController),
          _buildTimeInput('Maghrib', _maghribController),
          _buildTimeInput('Isha', _ishaController),
          const SizedBox(height: 24),
          Text('Mosque Info', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildText('Phone', _phoneController, keyboardType: TextInputType.phone),
          _buildText('Website', _websiteController, keyboardType: TextInputType.url),
          _buildText('Capacity', _capacityController, keyboardType: TextInputType.number),
          _buildText('Imam Name', _imamController),
          _buildText('Muezzin Name', _muezzinController),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Women Accessible'),
                  value: _femaleAccessible,
                  onChanged: (v) => setState(() => _femaleAccessible = v),
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  title: const Text('Wheelchair Facility'),
                  value: _wheelchairFacility,
                  onChanged: (v) => setState(() => _wheelchairFacility = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
           child: ElevatedButton.icon(
             icon: const Icon(Icons.save_alt_outlined),
              label: _saving
                  ? const Text('Saving...')
                  : Text(AppLocalizations.of(context)!.save),
              onPressed: _saving ? null : _saveTimes,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(String prayerName, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickTime(controller),
        decoration: InputDecoration(
          labelText: '$prayerName Jamat Time',
          hintText: 'e.g., 05:15 AM',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () => _pickTime(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildText(String label, TextEditingController c, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _pickTime(TextEditingController c) async {
    final initial = _parseToTimeOfDay(c.text) ?? TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null) return;
    final dt = DateTime(0, 1, 1, picked.hour, picked.minute);
    final formatted = DateFormat('hh:mm a').format(dt);
    setState(() => c.text = formatted);
  }

  TimeOfDay? _parseToTimeOfDay(String text) {
    try {
      if (text.isEmpty) return null;
      // Accept formats like HH:mm or hh:mm a
      if (text.contains('AM') || text.contains('PM')) {
        final parts = text.split(' ');
        final time = parts[0];
        final ampm = parts[1].toUpperCase();
        final tp = time.split(':');
        var h = int.parse(tp[0]);
        final m = int.parse(tp[1]);
        if (ampm == 'PM' && h != 12) h += 12;
        if (ampm == 'AM' && h == 12) h = 0;
        return TimeOfDay(hour: h, minute: m);
      } else {
        final tp = text.split(':');
        return TimeOfDay(hour: int.parse(tp[0]), minute: int.parse(tp[1]));
      }
    } catch (_) {
      return null;
    }
  }
}
