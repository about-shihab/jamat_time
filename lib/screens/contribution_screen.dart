import 'package:flutter/material.dart';
import 'package:jamat_time/widgets/aurora_background_painter.dart';
import 'package:jamat_time/models/mosque_model.dart';
import 'package:jamat_time/screens/edit_jamat_time_screen.dart';
import 'package:jamat_time/l10n/app_localizations.dart';

class ContributionScreen extends StatefulWidget {
  const ContributionScreen({super.key});

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> with SingleTickerProviderStateMixin {
  // Mock data - would come from a database
  final List<Mosque> _allMosques = [ /* ... Add your mock mosque data here ... */ ];
  late List<Mosque> _filteredMosques;
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _filteredMosques = _allMosques;
    _searchController.addListener(_filterMosques);
  }
  
  void _filterMosques() {
    // ... filtering logic remains the same
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color1 = theme.primaryColor.withOpacity(0.3);
    final color2 = theme.scaffoldBackgroundColor;
    final color3 = theme.cardColor.withOpacity(0.3);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.contributeTimes),
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
          Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor.withOpacity(0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredMosques.length,
              itemBuilder: (context, index) {
                final mosque = _filteredMosques[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    title: Text(mosque.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(mosque.address ?? ''),
                    trailing: Icon(Icons.edit_note_outlined, color: Theme.of(context).primaryColor),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EditJamatTimeScreen(mosque: mosque)));
                    },
                  ),
                );
              },
            ),
          ),
        ],
          ),
        ],
      ),
    );
  }
}
