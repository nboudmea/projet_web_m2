import {
  ChangeDetectionStrategy,
  Component,
  inject,
  input,
  output,
  signal,
} from '@angular/core';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';

import { ChatService } from '../../../core/services/chat.service';

@Component({
  selector: 'app-message-input',
  standalone: true,
  imports: [ReactiveFormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './message-input.component.html',
  styleUrl: './message-input.component.scss',
})
export class MessageInputComponent {
  private chatService = inject(ChatService);
  private fb = inject(FormBuilder);

  // @Input()
  readonly conversationId = input.required<string>();
  readonly expediteurId = input.required<string>();
  readonly destinataireId = input.required<string>();

  // @Output()
  readonly messageSent = output<void>();

  readonly sending = signal(false);

  readonly form = this.fb.group({
    contenu: ['', [Validators.required, Validators.maxLength(2000)]],
  });

  async onSend(): Promise<void> {
    if (this.form.invalid || this.sending()) return;

    const contenu = this.form.value.contenu?.trim();
    if (!contenu) return;

    this.sending.set(true);
    try {
      await this.chatService.sendMessage(
        this.conversationId(),
        this.expediteurId(),
        this.destinataireId(),
        contenu,
      );
      this.form.reset();
      this.messageSent.emit();
    } catch (err) {
      console.error('[MessageInput] Erreur envoi :', err);
    } finally {
      this.sending.set(false);
    }
  }

  onKeydown(event: KeyboardEvent): void {
    // Entrée seule → envoyer ; Shift+Entrée → saut de ligne
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      this.onSend();
    }
  }
}
