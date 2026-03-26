import 'package:cloud_firestore/cloud_firestore.dart';

/// Message dans une conversation — miroir de Message Angular.
class Message {
  const Message({
    required this.id,
    required this.expediteurId,
    required this.destinataireId,
    required this.contenu,
    required this.dateEnvoi,
    required this.lu,
  });

  final String id;
  final String expediteurId;
  final String destinataireId;
  final String contenu;
  final DateTime dateEnvoi;
  final bool lu;

  factory Message.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final raw = data['dateEnvoi'];
    DateTime date;
    if (raw is Timestamp) {
      date = raw.toDate();
    } else {
      date = DateTime.now();
    }
    return Message(
      id: doc.id,
      expediteurId: data['expediteurId'] as String? ?? '',
      destinataireId: data['destinataireId'] as String? ?? '',
      contenu: data['contenu'] as String? ?? '',
      dateEnvoi: date,
      lu: data['lu'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'expediteurId': expediteurId,
        'destinataireId': destinataireId,
        'contenu': contenu,
        'lu': lu,
      };
}

/// Conversation entre deux utilisateurs — miroir de Conversation Angular.
class Conversation {
  const Conversation({
    required this.id,
    required this.participantsIds,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String id;
  final List<String> participantsIds;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  /// Nombre de messages non lus (enrichi côté provider)
  final int unreadCount;

  factory Conversation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final raw = data['lastMessageAt'];
    DateTime? lastAt;
    if (raw is Timestamp) {
      lastAt = raw.toDate();
    }
    return Conversation(
      id: doc.id,
      participantsIds: List<String>.from(data['participantsIds'] ?? []),
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: lastAt,
    );
  }

  /// Retourne l'UID de l'autre participant (pas currentUserId)
  String otherUserId(String currentUserId) =>
      participantsIds.firstWhere((id) => id != currentUserId,
          orElse: () => '');

  Conversation copyWith({int? unreadCount}) => Conversation(
        id: id,
        participantsIds: participantsIds,
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
      );
}
