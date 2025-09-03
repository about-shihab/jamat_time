import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jamat_time/models/event_model.dart';

class EventCard extends StatefulWidget {
  final EventModel event;
  const EventCard({super.key, required this.event});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  void _toggleGoing() {
    setState(() {
      if (widget.event.isUserGoing) {
        widget.event.goingCount--;
        widget.event.isUserGoing = false;
      } else {
        widget.event.goingCount++;
        widget.event.isUserGoing = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('MMM d, hh:mm a');
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.event.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(widget.event.location, style: Theme.of(context).textTheme.bodyMedium),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.access_time_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(timeFormatter.format(widget.event.eventTime), style: Theme.of(context).textTheme.bodyMedium),
            ]),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.people_alt_outlined, size: 18, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 6),
                  Text('${widget.event.goingCount} going', style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                ElevatedButton.icon(
                  onPressed: _toggleGoing,
                  icon: Icon(widget.event.isUserGoing ? Icons.check_circle : Icons.add_circle_outline, size: 20),
                  label: Text(widget.event.isUserGoing ? "You're Going" : 'I am Going'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.event.isUserGoing ? Theme.of(context).hintColor : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}