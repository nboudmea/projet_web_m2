import 'package:cloud_firestore/cloud_firestore.dart';

/// Événement de calendrier — miroir de CalendarEvent Angular.
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.titre,
    required this.debut,
    required this.fin,
    required this.participantsIds,
    required this.createurId,
    this.description,
  });

  final String id;
  final String titre;
  final String? description;
  final DateTime debut;
  final DateTime fin;
  final List<String> participantsIds;
  final String createurId;

  factory CalendarEvent.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CalendarEvent(
      id: doc.id,
      titre: data['titre'] as String? ?? '',
      description: data['description'] as String?,
      debut: (data['debut'] as Timestamp).toDate(),
      fin: (data['fin'] as Timestamp).toDate(),
      participantsIds: List<String>.from(data['participantsIds'] ?? []),
      createurId: data['createurId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'titre': titre,
        if (description != null) 'description': description,
        'debut': Timestamp.fromDate(debut),
        'fin': Timestamp.fromDate(fin),
        'participantsIds': participantsIds,
        'createurId': createurId,
      };
}
