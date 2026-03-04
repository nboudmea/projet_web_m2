import { inject, Injectable } from '@angular/core';
import {
  Firestore,
  collection,
  collectionData,
  doc,
  getDoc,
  query,
  where,
} from '@angular/fire/firestore';
import { from, Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { User } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class UserService {
  private firestore = inject(Firestore);

  /**
   * Retourne les élèves rattachés à un bénévole.
   */
  getElevesOfBenevole$(benevoleId: string): Observable<User[]> {
    const q = query(
      collection(this.firestore, 'users'),
      where('benevoleId', '==', benevoleId)
    );
    return collectionData(q, { idField: 'id' }) as Observable<User[]>;
  }

  /**
   * Retourne un utilisateur par son UID.
   */
  getUserById$(uid: string): Observable<User | null> {
    return from(getDoc(doc(this.firestore, `users/${uid}`))).pipe(
      map(snap => snap.exists() ? ({ id: snap.id, ...snap.data() } as User) : null)
    );
  }
}
