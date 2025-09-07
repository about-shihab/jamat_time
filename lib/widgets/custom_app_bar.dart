import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jamat_time/theme_provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final VoidCallback? onRescanPressed; // Callback for the rescan action

  const CustomAppBar({
    super.key,
    this.title,
    this.onRescanPressed,
  });

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
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      
      // TITLE: Mosque Name + Directions Icon
      title: InkWell(
        onTap: () { /* Add map navigation logic here */ },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.title ?? 'Jamat Time'),
              const SizedBox(width: 8),
              Icon(Icons.directions_outlined, size: 20, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
      
      actions: [
        // LOCATION & RESCAN BUTTON
        TextButton.icon(
          onPressed: widget.onRescanPressed,
          icon: Icon(widget.onRescanPressed != null ? Icons.sync : Icons.location_on_outlined, size: 18),
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