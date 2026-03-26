import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import 'auth_providers.dart';

// ─── Service provider ─────────────────────────────────────────────────────────

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

// ─── Conversations ────────────────────────────────────────────────────────────

/// Stream des conversations de l'utilisateur courant, triées par dernier message.
final conversationsProvider =
    StreamProvider.autoDispose<List<Conversation>>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user == null) return const Stream.empty();
  return ref.read(chatServiceProvider).getConversations(user.id);
});

// ─── Messages d'une conversation ─────────────────────────────────────────────

/// Stream des messages d'une conversation.
final messagesProvider =
    StreamProvider.autoDispose.family<List<Message>, String>(
  (ref, conversationId) {
    return ref.read(chatServiceProvider).getMessages(conversationId);
  },
);

// ─── Compteur messages non lus (total) ───────────────────────────────────────

/// Nombre total de messages non lus pour l'utilisateur courant.
/// Utilisé dans le badge de navigation.
final totalUnreadProvider = StreamProvider.autoDispose<int>((ref) {
  final user = ref.watch(currentUserProvider).asData?.value;
  if (user == null) return Stream.value(0);
  return ref.read(chatServiceProvider).getTotalUnreadCount(user.id);
});
