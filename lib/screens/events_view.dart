import 'package:flutter/material.dart';
import 'package:jamat_time/models/event_model.dart';
import 'package:jamat_time/widgets/event_card.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> {
  // Mock data for Islamic Events
  final List<EventModel> _events = [
    EventModel(title: "Community Iftar Gathering", location: "Baitul Falah Mosque Courtyard", eventTime: DateTime(2025, 9, 5, 18, 30), goingCount: 128),
    EventModel(title: "Lecture: The Life of the Prophet (PBUH)", location: "Anderkilla Mosque Hall", eventTime: DateTime(2025, 9, 7, 19, 45), goingCount: 76),
    EventModel(title: "Youth Quran Circle", location: "Nasirabad Community Center", eventTime: DateTime(2025, 9, 12, 17, 0), goingCount: 22),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, index) {
        return EventCard(event: _events[index]);
      },
    );
  }
}