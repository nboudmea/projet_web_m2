import { inject, Injectable } from '@angular/core';
import {
  Firestore,
  collection,
  collectionData,
  addDoc,
  deleteDoc,
  doc,
  query,
  where,
  serverTimestamp,
} from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { CalendarEvent } from '../models/calendar-event.model';

@Injectable({ providedIn: 'root' })
export class CalendarService {
  private firestore = inject(Firestore);

  /**
   * Événements auxquels l'utilisateur participe ou qu'il a créés
   */
  getEvents$(userId: string): Observable<CalendarEvent[]> {
    const q = query(
      collection(this.firestore, 'calendar_events'),
      where('participantsIds', 'array-contains', userId)
    );
    return collectionData(q, { idField: 'id' }) as Observable<CalendarEvent[]>;
  }

  createEvent(event: Omit<CalendarEvent, 'id'>): Promise<void> {
    const data = Object.fromEntries(
      Object.entries({ ...event, createdAt: serverTimestamp() })
        .filter(([, v]) => v !== undefined)
    );
    return addDoc(collection(this.firestore, 'calendar_events'), data).then(() => undefined);
  }

  deleteEvent(eventId: string): Promise<void> {
    return deleteDoc(doc(this.firestore, `calendar_events/${eventId}`));
  }
}
