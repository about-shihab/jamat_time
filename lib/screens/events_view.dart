import 'package:flutter/material.dart';
import 'package:jamat_time/models/event_model.dart';
import 'package:jamat_time/widgets/custom_app_bar.dart';
import 'package:jamat_time/widgets/event_card.dart';

class EventsView extends StatefulWidget {
  const EventsView({super.key});

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> {
  final List<EventModel> _events = [
    EventModel(title: "Weekly Tafsir Circle", location: "Baitul Falah Mosque Hall", eventTime: DateTime(2025, 9, 5, 19, 45), goingCount: 45),
    EventModel(title: "Youth Community Iftar", location: "Chittagong Club Ltd.", eventTime: DateTime(2025, 9, 7, 18, 0), goingCount: 112, isUserGoing: true),
    EventModel(title: "Charity Drive for Orphans", location: "Nasirabad Community Center", eventTime: DateTime(2025, 9, 6, 11, 0), goingCount: 32),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const CustomAppBar(),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          return EventCard(event: _events[index]);
        },
      ),
    );
  }
}