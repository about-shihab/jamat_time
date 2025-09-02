class EventModel {
  final String title;
  final String location;
  final DateTime eventTime;
  int goingCount;
  bool isUserGoing;

  EventModel({
    required this.title,
    required this.location,
    required this.eventTime,
    required this.goingCount,
    this.isUserGoing = false,
  });
}