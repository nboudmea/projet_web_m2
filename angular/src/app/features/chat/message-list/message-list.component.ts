import {
  ChangeDetectionStrategy,
  Component,
  effect,
  ElementRef,
  inject,
  input,
  viewChild,
} from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { toObservable, toSignal } from '@angular/core/rxjs-interop';
import { switchMap, of } from 'rxjs';

import { ChatService } from '../../../core/services/chat.service';
import { TimestampToDatePipe } from '../../../shared/pipes/timestamp-to-date.pipe';

@Component({
  selector: 'app-message-list',
  standalone: true,
  imports: [CommonModule, DatePipe, TimestampToDatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './message-list.component.html',
  styleUrl: './message-list.component.scss',
})
export class MessageListComponent {
  private chatService = inject(ChatService);

  // @Input()
  readonly conversationId = input.required<string>();
  readonly currentUserId = input.required<string>();

  private readonly scrollContainer = viewChild.required<ElementRef<HTMLDivElement>>('scrollContainer');

  readonly messages = toSignal(
    toObservable(this.conversationId).pipe(
      switchMap(id => (id ? this.chatService.getMessages$(id) : of([]))),
    ),
    { initialValue: [] },
  );

  constructor() {
    // Auto-scroll vers le bas à chaque nouveau message
    effect(() => {
      const msgs = this.messages();
      if (msgs.length > 0) {
        // Après le rendu Angular
        setTimeout(() => {
          const el = this.scrollContainer().nativeElement;
          el.scrollTop = el.scrollHeight;
        }, 0);
      }
    });
  }
}
