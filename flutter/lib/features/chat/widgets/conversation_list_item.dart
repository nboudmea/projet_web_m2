import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/user.dart';
import '../../../../core/theme/app_colors.dart';

/// Élément de la liste des conversations.
/// Affiche avatar, nom, dernier message, badge non-lu et horodatage.
class ConversationListItem extends StatelessWidget {
  const ConversationListItem({
    super.key,
    required this.otherUser,
    required this.onTap,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final AppUser otherUser;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials =
        '${otherUser.prenom.isNotEmpty ? otherUser.prenom[0] : ''}${otherUser.nom.isNotEmpty ? otherUser.nom[0] : ''}'
            .toUpperCase();
    final hasUnread = unreadCount > 0;
    final timeLabel =
        lastMessageAt != null ? _formatTime(lastMessageAt!) : '';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.accent,
              backgroundImage: otherUser.photoUrl != null &&
                      otherUser.photoUrl!.isNotEmpty
                  ? NetworkImage(otherUser.photoUrl!)
                  : null,
              child: otherUser.photoUrl == null ||
                      otherUser.photoUrl!.isEmpty
                  ? Text(
                      initials.isEmpty ? '?' : initials,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.foreground,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${otherUser.prenom} ${otherUser.nom}'.trim(),
                          style: TextStyle(
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 15,
                            color: AppColors.foreground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeLabel.isNotEmpty)
                        Text(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? AppColors.foreground
                                : AppColors.mutedForeground,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage ?? 'Démarrer la conversation',
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread
                                ? AppColors.foreground
                                : AppColors.mutedForeground,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.foreground,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryForeground,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (diff.inDays < 7) {
      return DateFormat('EEE', 'fr_FR').format(dateTime);
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }
}
