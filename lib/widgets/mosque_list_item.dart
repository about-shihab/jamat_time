import 'package:flutter/material.dart';
import '../models/mosque_model.dart';

class MosqueListItem extends StatelessWidget {
  final Mosque mosque;
  final VoidCallback onSetFavorite;

  const MosqueListItem({
    super.key,
    required this.mosque,
    required this.onSetFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1D1E33),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        title: Text(mosque.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(mosque.address, style: const TextStyle(color: Colors.white70)),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.tealAccent),
          tooltip: 'Set as Favorite',
          onPressed: onSetFavorite,
        ),
        onTap: onSetFavorite,
      ),
    );
  }
}