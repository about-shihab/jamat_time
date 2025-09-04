import 'package:flutter/material.dart';
import 'package:jamat_time/models/mosque_model.dart';

class EditJamatTimeScreen extends StatefulWidget {
  final Mosque mosque;
  const EditJamatTimeScreen({super.key, required this.mosque});

  @override
  State<EditJamatTimeScreen> createState() => _EditJamatTimeScreenState();
}

class _EditJamatTimeScreenState extends State<EditJamatTimeScreen> {
  late TextEditingController _fajrController;
  late TextEditingController _dhuhrController;
  late TextEditingController _asrController;
  late TextEditingController _maghribController;
  late TextEditingController _ishaController;

  @override
  void initState() {
    super.initState();
    final times = widget.mosque.jamatTimes;
    _fajrController = TextEditingController(text: times['Fajr']?.jamatTime ?? '');
    _dhuhrController = TextEditingController(text: times['Dhuhr']?.jamatTime ?? '');
    _asrController = TextEditingController(text: times['Asr']?.jamatTime ?? '');
    _maghribController = TextEditingController(text: times['Maghrib']?.jamatTime ?? '');
    _ishaController = TextEditingController(text: times['Isha']?.jamatTime ?? '');
  }

  @override
  void dispose() {
    _fajrController.dispose();
    _dhuhrController.dispose();
    _asrController.dispose();
    _maghribController.dispose();
    _ishaController.dispose();
    super.dispose();
  }

  void _saveTimes() {
    // In a real app, you would save this data to your database.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('JazakAllah Khair! Times submitted successfully.'),
        // FIX: Using the correct theme property
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
    
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Times'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.save_alt_outlined),
              onPressed: _saveTimes,
              tooltip: 'Save',
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            widget.mosque.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          Text(
            widget.mosque.address,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _buildTimeInput('Fajr', _fajrController),
          _buildTimeInput('Dhuhr', _dhuhrController),
          _buildTimeInput('Asr', _asrController),
          _buildTimeInput('Maghrib', _maghribController),
          _buildTimeInput('Isha', _ishaController),
        ],
      ),
    );
  }

  Widget _buildTimeInput(String prayerName, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: '$prayerName Jamat Time',
          hintText: 'e.g., 05:15 AM',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}