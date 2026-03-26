import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

/// Service de chat temps réel — miroir de ChatService Angular.
/// Architecture : conversations/{conversationId}/messages/{messageId}
class ChatService {
  ChatService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ─── Lecture temps réel ───────────────────────────────────────────────────

  /// Conversations auxquelles l'utilisateur participe, triées par lastMessageAt.
  Stream<List<Conversation>> getConversations(String userId) {
    return _db
        .collection('conversations')
        .where('participantsIds', arrayContains: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => Conversation.fromDoc(
              d as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      list.sort((a, b) {
        final aT = a.lastMessageAt ?? DateTime(2000);
        final bT = b.lastMessageAt ?? DateTime(2000);
        return bT.compareTo(aT);
      });
      return list;
    });
  }

  /// Messages d'une conversation, ordonnés par date croissante.
  Stream<List<Message>> getMessages(String conversationId) {
    return _db
        .collection('conversations/$conversationId/messages')
        .orderBy('dateEnvoi', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Message.fromDoc(
                d as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  /// Nombre de messages non lus dans une conversation pour un utilisateur.
  Stream<int> getUnreadCount(String conversationId, String userId) {
    return _db
        .collection('conversations/$conversationId/messages')
        .where('lu', isEqualTo: false)
        .where('destinataireId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ─── Écriture ─────────────────────────────────────────────────────────────

  /// Envoie un message et met à jour lastMessage / lastMessageAt de la conversation.
  Future<void> sendMessage({
    required String conversationId,
    required String expediteurId,
    required String destinataireId,
    required String contenu,
  }) async {
    final batch = _db.batch();

    final msgRef =
        _db.collection('conversations/$conversationId/messages').doc();
    batch.set(msgRef, {
      'expediteurId': expediteurId,
      'destinataireId': destinataireId,
      'contenu': contenu,
      'dateEnvoi': FieldValue.serverTimestamp(),
      'lu': false,
    });

    final convRef = _db.collection('conversations').doc(conversationId);
    batch.update(convRef, {
      'lastMessage': contenu,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Marque tous les messages non lus envoyés à [currentUserId] comme lus.
  Future<void> markAsRead(
      String conversationId, String currentUserId) async {
    final snap = await _db
        .collection('conversations/$conversationId/messages')
        .where('lu', isEqualTo: false)
        .where('destinataireId', isEqualTo: currentUserId)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'lu': true});
    }
    await batch.commit();
  }

  /// Crée ou récupère une conversation entre deux utilisateurs.
  /// L'ID est déterministe (UIDs triés + '_') pour éviter les doublons.
  Future<String> getOrCreateConversation(
      String uid1, String uid2) async {
    final participants = [uid1, uid2]..sort();
    final conversationId = participants.join('_');
    final convRef =
        _db.collection('conversations').doc(conversationId);
    final snap = await convRef.get();

    if (!snap.exists) {
      await convRef.set({
        'participantsIds': participants,
        'lastMessage': null,
        'lastMessageAt': null,
      });
    }

    return conversationId;
  }

  /// Nombre total de messages non lus pour un utilisateur (via collectionGroup).
  Stream<int> getTotalUnreadCount(String userId) {
    return _db
        .collectionGroup('messages')
        .where('lu', isEqualTo: false)
        .where('destinataireId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}
