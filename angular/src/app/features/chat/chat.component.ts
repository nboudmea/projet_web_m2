import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
  OnInit,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { Observable, combineLatest, map, of, switchMap, take } from 'rxjs';
import { toSignal } from '@angular/core/rxjs-interop';

import { AuthService } from '../../core/services/auth.service';
import { ChatService } from '../../core/services/chat.service';
import { UserService } from '../../core/services/user.service';
import { User } from '../../core/models/user.model';
import { ConversationVM } from '../../core/models/message.model';

import { ConversationListComponent } from './conversation-list/conversation-list.component';
import { MessageListComponent } from './message-list/message-list.component';
import { MessageInputComponent } from './message-input/message-input.component';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [CommonModule, ConversationListComponent, MessageListComponent, MessageInputComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './chat.component.html',
  styleUrl: './chat.component.scss',
})
export class ChatComponent implements OnInit {
  private authService = inject(AuthService);
  private chatService = inject(ChatService);
  private userService = inject(UserService);

  readonly currentUser = toSignal(this.authService.currentAppUser$);

  selectedConversationId = signal<string | null>(null);
  selectedOtherUser = signal<User | null>(null);

  /** Flux de conversations enrichies avec les infos de l'autre participant */
  private readonly conversationVMs$: Observable<ConversationVM[]> = this.authService.currentAppUser$.pipe(
    switchMap(user => {
      if (!user) return of([] as ConversationVM[]);

      return this.chatService.getConversations$(user.id).pipe(
        switchMap(convs => {
          if (!convs.length) return of([] as ConversationVM[]);

          return combineLatest(
            convs.map(conv => {
              const otherId = conv.participantsIds.find(id => id !== user.id) ?? '';

              return combineLatest([
                this.userService.getUserById$(otherId),
                this.chatService.getUnreadCount$(conv.id, user.id),
              ]).pipe(
                map(([otherUser, unreadCount]) => {
                  if (!otherUser) return null;
                  return {
                    id: conv.id,
                    otherUser,
                    lastMessage: conv.lastMessage,
                    lastMessageAt: conv.lastMessageAt,
                    unreadCount,
                  } as ConversationVM;
                }),
              );
            }),
          ).pipe(
            map(vms => vms.filter((vm): vm is ConversationVM => vm !== null)),
          );
        }),
      );
    }),
  );

  readonly conversationVMs = toSignal(this.conversationVMs$, {
    initialValue: [] as ConversationVM[],
  });

  ngOnInit(): void {
    this.authService.currentAppUser$.pipe(take(1)).subscribe(user => {
      if (!user) return;

      if (user.role === 'eleve' && user.benevoleId) {
        // Élève → créer la conversation avec son bénévole
        this.chatService
          .createOrGetConversation(user.id, user.benevoleId)
          .catch(err => console.error('[Chat] Création conversation élève-bénévole :', err));

      } else if (user.role === 'benevole') {
        // Bénévole → pré-créer les conversations avec tous ses élèves
        this.userService.getElevesOfBenevole$(user.id).pipe(take(1)).subscribe(eleves => {
          eleves.forEach(eleve => {
            this.chatService
              .createOrGetConversation(user.id, eleve.id)
              .catch(err => console.error('[Chat] Création conversation bénévole-élève :', err));
          });
        });
      }
    });
  }

  onConversationSelect(event: { conversationId: string; otherUser: User }): void {
    this.selectedConversationId.set(event.conversationId);
    this.selectedOtherUser.set(event.otherUser);

    const userId = this.authService.currentUserId;
    if (userId) {
      this.chatService
        .markAsRead(event.conversationId, userId)
        .catch(err => console.error('[Chat] markAsRead :', err));
    }
  }
}
