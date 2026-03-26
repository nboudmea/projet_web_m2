import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/message.dart';
import '../../../../core/models/user.dart';
import '../../../../core/theme/app_colors.dart';

/// Bulle de message dans une conversation.
/// Les messages envoyés par l'utilisateur courant sont à droite (fond sombre).
/// Les messages reçus sont à gauche avec l'avatar de l'expéditeur.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.senderUser,
  });

  final Message message;
  final bool isMine;
  final AppUser senderUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar expéditeur (messages reçus uniquement)
          if (!isMine) ...[
            _SenderAvatar(user: senderUser),
            const SizedBox(width: 8),
          ],

          // Bulle
          Flexible(
            child: Column(
              crossAxisAlignment: isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.70,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMine
                        ? AppColors.foreground
                        : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMine ? 18 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 18),
                    ),
                    boxShadow: const [AppColors.shadowItem],
                    border: isMine
                        ? null
                        : Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    message.contenu,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMine ? Colors.white : AppColors.foreground,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.dateEnvoi),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.lu
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 14,
                        color: message.lu
                            ? AppColors.accent
                            : AppColors.mutedForeground,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Espace à droite (messages envoyés uniquement)
          if (isMine) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─── Avatar circulaire de l'expéditeur ────────────────────────────────────────

class _SenderAvatar extends StatelessWidget {
  const _SenderAvatar({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final initials =
        '${user.prenom.isNotEmpty ? user.prenom[0] : ''}${user.nom.isNotEmpty ? user.nom[0] : ''}'
            .toUpperCase();

    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.accent,
      backgroundImage:
          user.photoUrl != null && user.photoUrl!.isNotEmpty
              ? NetworkImage(user.photoUrl!)
              : null,
      child: user.photoUrl == null || user.photoUrl!.isEmpty
          ? Text(
              initials.isEmpty ? '?' : initials,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
              ),
            )
          : null,
    );
  }
}
