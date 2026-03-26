import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/chat_providers.dart';
import '../../../../core/providers/user_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/conversation_list_item.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

/// Écran principal du chat.
/// Sur mobile : vue liste → vue conversation (navigation).
/// La conversation sélectionnée est gérée localement avec un état.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String? _selectedConversationId;
  AppUser? _selectedOtherUser;

  @override
  void initState() {
    super.initState();
    // Pré-crée les conversations au chargement de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) => _initConversations());
  }

  Future<void> _initConversations() async {
    final user = ref.read(currentUserProvider).asData?.value;
    if (user == null) return;
    final chatService = ref.read(chatServiceProvider);

    if (user.isEleve && user.benevoleId != null) {
      await chatService
          .getOrCreateConversation(user.id, user.benevoleId!)
          .catchError((_) => '');
    } else if (user.isBenevole) {
      final eleves = ref.read(benevoleElevesProvider(user.id)).asData?.value;
      if (eleves != null) {
        for (final eleve in eleves) {
          await chatService
              .getOrCreateConversation(user.id, eleve.id)
              .catchError((_) => '');
        }
      }
    }
  }

  void _selectConversation(String conversationId, AppUser otherUser) {
    setState(() {
      _selectedConversationId = conversationId;
      _selectedOtherUser = otherUser;
    });
    // Marquer comme lu
    final userId = ref.read(authStateProvider).asData?.value?.uid;
    if (userId != null) {
      ref
          .read(chatServiceProvider)
          .markAsRead(conversationId, userId)
          .catchError((_) {});
    }
  }

  void _back() => setState(() {
        _selectedConversationId = null;
        _selectedOtherUser = null;
      });

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).asData?.value;
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Sur mobile : vue liste ou vue conversation
    if (_selectedConversationId != null && _selectedOtherUser != null) {
      return _ConversationView(
        conversationId: _selectedConversationId!,
        otherUser: _selectedOtherUser!,
        currentUser: currentUser,
        onBack: _back,
      );
    }

    return _ConversationListView(
      currentUser: currentUser,
      onSelect: _selectConversation,
    );
  }
}

// ─── Vue liste des conversations ──────────────────────────────────────────────

class _ConversationListView extends ConsumerWidget {
  const _ConversationListView({
    required this.currentUser,
    required this.onSelect,
  });

  final AppUser currentUser;
  final void Function(String conversationId, AppUser otherUser) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.foreground,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 56, color: AppColors.mutedForeground),
                  SizedBox(height: 12),
                  Text('Aucune conversation',
                      style: TextStyle(color: AppColors.mutedForeground)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final conv = conversations[i];
              final otherId = conv.otherUserId(currentUser.id);

              return _ConversationListItemWrapper(
                conversationId: conv.id,
                otherId: otherId,
                lastMessage: conv.lastMessage,
                lastMessageAt: conv.lastMessageAt,
                currentUserId: currentUser.id,
                onTap: (otherUser) => onSelect(conv.id, otherUser),
              );
            },
          );
        },
      ),
    );
  }
}

class _ConversationListItemWrapper extends ConsumerWidget {
  const _ConversationListItemWrapper({
    required this.conversationId,
    required this.otherId,
    required this.currentUserId,
    required this.onTap,
    this.lastMessage,
    this.lastMessageAt,
  });

  final String conversationId;
  final String otherId;
  final String currentUserId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final void Function(AppUser) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUserAsync = ref.watch(userByIdProvider(otherId));
    final unreadAsync = ref.watch(
      StreamProvider.autoDispose((r) => r
          .read(chatServiceProvider)
          .getUnreadCount(conversationId, currentUserId)),
    );

    return otherUserAsync.when(
      loading: () => const ListTile(title: Text('Chargement...')),
      error: (_, __) => const SizedBox.shrink(),
      data: (otherUser) {
        if (otherUser == null) return const SizedBox.shrink();
        return ConversationListItem(
          otherUser: otherUser,
          lastMessage: lastMessage,
          lastMessageAt: lastMessageAt,
          unreadCount: unreadAsync.asData?.value ?? 0,
          onTap: () => onTap(otherUser),
        );
      },
    );
  }
}

// ─── Vue d'une conversation ───────────────────────────────────────────────────

class _ConversationView extends ConsumerStatefulWidget {
  const _ConversationView({
    required this.conversationId,
    required this.otherUser,
    required this.currentUser,
    required this.onBack,
  });

  final String conversationId;
  final AppUser otherUser;
  final AppUser currentUser;
  final VoidCallback onBack;

  @override
  ConsumerState<_ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends ConsumerState<_ConversationView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.foreground,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: widget.onBack,
        ),
        title: Row(
          children: [
            _Avatar(user: widget.otherUser, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.otherUser.prenom} ${widget.otherUser.nom}'.trim(),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.otherUser.isBenevole ? 'Bénévole' : 'Élève',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0x99FFFFFF)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
              data: (messages) {
                _scrollToBottom();
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Envoyez le premier message !',
                      style:
                          TextStyle(color: AppColors.mutedForeground),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMine =
                        msg.expediteurId == widget.currentUser.id;
                    return MessageBubble(
                      message: msg,
                      isMine: isMine,
                      senderUser:
                          isMine ? widget.currentUser : widget.otherUser,
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(
            conversationId: widget.conversationId,
            expediteurId: widget.currentUser.id,
            destinataireId: widget.otherUser.id,
          ),
        ],
      ),
    );
  }
}

// ─── Widget Avatar ────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, this.size = 40});

  final AppUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials =
        '${user.prenom.isNotEmpty ? user.prenom[0] : ''}${user.nom.isNotEmpty ? user.nom[0] : ''}'
            .toUpperCase();

    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(user.photoUrl!),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.accent,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: AppColors.foreground,
        ),
      ),
    );
  }
}
