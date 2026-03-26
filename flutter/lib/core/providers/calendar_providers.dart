import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calendar_event.dart';
import '../services/calendar_service.dart';
import 'auth_providers.dart';

// ─── Service provider ─────────────────────────────────────────────────────────

final calendarServiceProvider =
    Provider<CalendarService>((ref) => CalendarService());

// ─── Événements ───────────────────────────────────────────────────────────────

/// Stream des événements de l'utilisateur courant.
final eventsProvider =
    StreamProvider.autoDispose<List<CalendarEvent>>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user == null) return const Stream.empty();
  return ref.read(calendarServiceProvider).getEvents(user.id);
});

/// Stream des événements d'un utilisateur spécifique (pour le bénévole).
final eventsByUserProvider =
    StreamProvider.autoDispose.family<List<CalendarEvent>, String>(
  (ref, userId) {
    return ref.read(calendarServiceProvider).getEvents(userId);
  },
);
