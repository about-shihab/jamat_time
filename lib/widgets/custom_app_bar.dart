import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/theme_provider.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  // --- SETTINGS MENU ---
  void _showSettingsMenu(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Wrap(
            runSpacing: 8,
            children: [
              SwitchListTile.adaptive(
                title: const Text('Dark Mode'),
                secondary: Icon(Icons.dark_mode_outlined, color: Theme.of(context).primaryColor),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
              ListTile(
                leading: Icon(Icons.login_outlined, color: Theme.of(context).primaryColor),
                title: const Text('Login / Register'),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                leading: Icon(Icons.info_outline, color: Theme.of(context).iconTheme.color),
                title: const Text('About Us'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.star_border_outlined, color: Theme.of(context).iconTheme.color),
                title: const Text('Rate This App'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriCalendar.now().toFormat("d MMMM yyyy");
    final gregorianDate = DateFormat('d MMMM').format(DateTime.now());
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      
      // DATE AND TIME DISPLAY
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today, $gregorianDate',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            hijriDate,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
      
      actions: [
        // LOCATION BUTTON
        TextButton.icon(
          onPressed: () {
            // Add location selection logic here
          },
          icon: const Icon(Icons.location_on_outlined, size: 18),
          label: Text("Chattogram", style: Theme.of(context).textTheme.bodyMedium),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        
        // SETTINGS BUTTON
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () => _showSettingsMenu(context),
        ),
      ],
    );
  }
}