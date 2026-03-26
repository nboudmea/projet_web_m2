import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event.dart';

/// Service de gestion du calendrier — miroir de CalendarService Angular.
class CalendarService {
  CalendarService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ─── Lecture temps réel ───────────────────────────────────────────────────

  /// Événements auxquels l'utilisateur participe.
  Stream<List<CalendarEvent>> getEvents(String userId) {
    return _db
        .collection('calendar_events')
        .where('participantsIds', arrayContains: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => CalendarEvent.fromDoc(
              d as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      list.sort((a, b) => a.debut.compareTo(b.debut));
      return list;
    });
  }

  // ─── Écriture ─────────────────────────────────────────────────────────────

  Future<void> createEvent(CalendarEvent event) async {
    await _db.collection('calendar_events').add({
      ...event.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('calendar_events').doc(eventId).delete();
  }
}
