import { User } from './user.model';

export interface Message {
  id: string;
  expediteurId: string;
  destinataireId: string;
  contenu: string;
  dateEnvoi: Date;
  lu: boolean;
}

export interface Conversation {
  id: string;
  participantsIds: string[];
  lastMessage?: string;
  lastMessageAt?: Date;
}

/** Vue modèle enrichie pour afficher une conversation dans la liste */
export interface ConversationVM {
  id: string;
  otherUser: User;
  lastMessage?: string;
  lastMessageAt?: Date;
  unreadCount: number;
}
