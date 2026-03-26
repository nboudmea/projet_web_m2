import { TestBed } from '@angular/core/testing';
import { provideZonelessChangeDetection } from '@angular/core';
import { of } from 'rxjs';
import { vi } from 'vitest';

import { ChatComponent } from './chat.component';
import { AuthService } from '../../core/services/auth.service';
import { ChatService } from '../../core/services/chat.service';
import { UserService } from '../../core/services/user.service';

const mockAuthService = {
  currentAppUser$: of(null),
  currentUserId: 'user-1',
};

const mockChatService = {
  getConversations$: vi.fn().mockReturnValue(of([])),
  getUnreadCount$: vi.fn().mockReturnValue(of(0)),
  getMessages$: vi.fn().mockReturnValue(of([])),
  createOrGetConversation: vi.fn().mockResolvedValue('conv-1'),
  markAsRead: vi.fn().mockResolvedValue(undefined),
};

const mockUserService = {
  getUserById$: vi.fn().mockReturnValue(of(null)),
  getElevesOfBenevole$: vi.fn().mockReturnValue(of([])),
};

describe('ChatComponent', () => {
  beforeEach(async () => {
    vi.clearAllMocks();
    await TestBed.configureTestingModule({
      imports: [ChatComponent],
      providers: [
        provideZonelessChangeDetection(),
        { provide: AuthService, useValue: mockAuthService },
        { provide: ChatService, useValue: mockChatService },
        { provide: UserService, useValue: mockUserService },
      ],
    }).compileComponents();
  });

  it('devrait créer le composant', () => {
    const fixture = TestBed.createComponent(ChatComponent);
    expect(fixture.componentInstance).toBeTruthy();
  });

  it('aucune conversation sélectionnée au démarrage', () => {
    const fixture = TestBed.createComponent(ChatComponent);
    expect(fixture.componentInstance.selectedConversationId()).toBeNull();
  });

  it('onConversationSelect met à jour la conversation sélectionnée', () => {
    const fixture = TestBed.createComponent(ChatComponent);
    const fakeUser = { id: 'u2', prenom: 'Bob', nom: 'Martin', email: '', role: 'eleve' as const };
    fixture.componentInstance.onConversationSelect({ conversationId: 'conv-42', otherUser: fakeUser });
    expect(fixture.componentInstance.selectedConversationId()).toBe('conv-42');
    expect(fixture.componentInstance.selectedOtherUser()).toEqual(fakeUser);
  });
});
