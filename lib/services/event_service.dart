import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/event_model.dart';

class EventService {
  EventService();

  SupabaseClient get _client => Supabase.instance.client;

  Stream<List<EventModel>> watchUpcomingEvents({int limit = 50}) {
    final now = DateTime.now();
    final stream = _client
        .from('events')
        .stream(primaryKey: ['id'])
        .eq('is_cancelled', false)
        .order('starts_at', ascending: true);

    return stream.map((rows) {
      final events = rows
          .map((data) => EventModel.fromSupabase(data))
          .where((event) =>
              event.startsAt.isAfter(now.subtract(const Duration(days: 30))))
          .toList();
      events.sort((a, b) => a.startsAt.compareTo(b.startsAt));
      if (events.length > limit) {
        return events.sublist(0, limit);
      }
      return events;
    });
  }

  Future<EventModel> createEvent(EventDraft draft,
      {String? organizerId}) async {
    final payload = draft.toSupabaseInsert(organizerId: organizerId);
    final result =
        await _client.from('events').insert(payload).select().single();
    return EventModel.fromSupabase(result);
  }
}
