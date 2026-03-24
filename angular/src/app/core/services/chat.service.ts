import { inject, Injectable } from '@angular/core';
import {
  Firestore,
  collection,
  collectionData,
  addDoc,
  doc,
  updateDoc,
  query,
  where,
  orderBy,
  serverTimestamp,
  getDoc,
  setDoc,
  writeBatch,
  getDocs,
} from '@angular/fire/firestore';
import { Observable, map } from 'rxjs';
import { Conversation, Message } from '../models/message.model';

@Injectable({ providedIn: 'root' })
export class ChatService {
  private firestore = inject(Firestore);

  /** Conversations auxquelles l'utilisateur participe */
  getConversations$(userId: string): Observable<Conversation[]> {
    const q = query(
      collection(this.firestore, 'conversations'),
      where('participantsIds', 'array-contains', userId),
    );
    return collectionData(q, { idField: 'id' }) as Observable<Conversation[]>;
  }

  /** Messages d'une conversation ordonnés par date croissante */
  getMessages$(conversationId: string): Observable<Message[]> {
    const q = query(
      collection(this.firestore, `conversations/${conversationId}/messages`),
      orderBy('dateEnvoi', 'asc'),
    );
    return collectionData(q, { idField: 'id' }) as Observable<Message[]>;
  }

  /** Nombre de messages non lus pour l'utilisateur dans une conversation */
  getUnreadCount$(conversationId: string, userId: string): Observable<number> {
    const q = query(
      collection(this.firestore, `conversations/${conversationId}/messages`),
      where('lu', '==', false),
      where('destinataireId', '==', userId),
    );
    return (collectionData(q) as Observable<unknown[]>).pipe(map(msgs => msgs.length));
  }

  /** Envoie un message et met à jour la conversation */
  async sendMessage(
    conversationId: string,
    expediteurId: string,
    destinataireId: string,
    contenu: string,
  ): Promise<void> {
    const messagesRef = collection(this.firestore, `conversations/${conversationId}/messages`);
    const convRef = doc(this.firestore, `conversations/${conversationId}`);

    await addDoc(messagesRef, {
      expediteurId,
      destinataireId,
      contenu,
      dateEnvoi: serverTimestamp(),
      lu: false,
    });

    await updateDoc(convRef, {
      lastMessage: contenu,
      lastMessageAt: serverTimestamp(),
    });
  }

  /** Marque tous les messages non lus envoyés à currentUserId comme lus */
  async markAsRead(conversationId: string, currentUserId: string): Promise<void> {
    const q = query(
      collection(this.firestore, `conversations/${conversationId}/messages`),
      where('lu', '==', false),
      where('destinataireId', '==', currentUserId),
    );
    const snapshot = await getDocs(q);
    if (snapshot.empty) return;

    const batch = writeBatch(this.firestore);
    snapshot.forEach(d => batch.update(d.ref, { lu: true }));
    await batch.commit();
  }

  /**
   * Crée une conversation entre deux utilisateurs si elle n'existe pas encore.
   * L'ID est déterministe (UIDs triés + jointure par underscore) pour éviter les doublons.
   */
  async createOrGetConversation(uid1: string, uid2: string): Promise<string> {
    const participants = [uid1, uid2].sort();
    const conversationId = participants.join('_');
    const convRef = doc(this.firestore, `conversations/${conversationId}`);
    const snap = await getDoc(convRef);

    if (!snap.exists()) {
      await setDoc(convRef, {
        participantsIds: participants,
        lastMessage: null,
        lastMessageAt: null,
      });
    }

    return conversationId;
  }

  /** Crée une conversation avec un contact (utilisé pour ajouter un contact) */
  addContact(currentUserId: string, contactId: string): Promise<string> {
    return this.createOrGetConversation(currentUserId, contactId);
  }
}
