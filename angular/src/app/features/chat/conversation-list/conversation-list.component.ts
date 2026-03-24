import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';

import { ConversationVM } from '../../../core/models/message.model';
import { User } from '../../../core/models/user.model';
import { TimestampToDatePipe } from '../../../shared/pipes/timestamp-to-date.pipe';

@Component({
  selector: 'app-conversation-list',
  standalone: true,
  imports: [CommonModule, DatePipe, TimestampToDatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './conversation-list.component.html',
  styleUrl: './conversation-list.component.scss',
})
export class ConversationListComponent {
  // @Input()
  readonly conversations = input.required<ConversationVM[]>();
  readonly selectedId = input<string | null>(null);

  // @Output()
  readonly conversationSelected = output<{ conversationId: string; otherUser: User }>();

  onSelect(conv: ConversationVM): void {
    this.conversationSelected.emit({ conversationId: conv.id, otherUser: conv.otherUser });
  }
}
