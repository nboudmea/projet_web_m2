import { inject, Injectable } from '@angular/core';
import { Auth, authState, signInWithEmailAndPassword, signOut, sendPasswordResetEmail, createUserWithEmailAndPassword } from '@angular/fire/auth';
import { Firestore, doc, setDoc, getDoc, getDocs, collection, query, where, serverTimestamp } from '@angular/fire/firestore';
import { Observable, of, switchMap, from, map } from 'rxjs';
import { User } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private auth = inject(Auth);
  private firestore = inject(Firestore);

  /** Observable Firebase Auth (FirebaseUser brut) */
  readonly currentUser$ = authState(this.auth);

  /** Observable User applicatif (avec rôle Firestore) — null si non connecté */
  readonly currentAppUser$: Observable<User | null> = authState(this.auth).pipe(
    switchMap(firebaseUser => {
      if (!firebaseUser) return of(null);
      const ref = doc(this.firestore, `users/${firebaseUser.uid}`);
      return from(getDoc(ref)).pipe(
        map(snap => snap.exists() ? ({ id: snap.id, ...snap.data() } as User) : null)
      );
    })
  );

  login(email: string, password: string): Promise<void> {
    return signInWithEmailAndPassword(this.auth, email, password)
      .then(() => {
        console.log('Connexion réussie');
      })
      .catch(error => {
        console.error('Erreur de connexion:', error);
        throw error;
      });
  }

  logout(): Promise<void> {
    return signOut(this.auth);
  }

  register(email: string, password: string, role: 'eleve' | 'benevole'): Promise<void> {
    return createUserWithEmailAndPassword(this.auth, email, password)
      .then(async userCredential => {
        const user = userCredential.user;
        const userDoc = doc(this.firestore, `users/${user.uid}`);

        // Pour un élève : assigner aléatoirement un bénévole disponible (< 3 élèves)
        let benevoleId: string | undefined;
        if (role === 'eleve') {
          benevoleId = await this.pickBenevoleAleatoire() ?? undefined;
        }

        return setDoc(userDoc, {
          email: user.email,
          role,
          ...(benevoleId ? { benevoleId } : {}),
          createdAt: serverTimestamp(),
        });
      })
      .catch(error => {
        console.error('Erreur d\'inscription:', error);
        throw error;
      });
  }

  /**
   * Sélectionne aléatoirement un bénévole ayant moins de 3 élèves.
   * Retourne null si aucun bénévole n'est disponible.
   */
  private async pickBenevoleAleatoire(): Promise<string | null> {
    const bSnapshot = await getDocs(
      query(collection(this.firestore, 'users'), where('role', '==', 'benevole'))
    );
    if (bSnapshot.empty) return null;

    const eSnapshot = await getDocs(
      query(collection(this.firestore, 'users'), where('role', '==', 'eleve'))
    );

    // Comptage des élèves par bénévole
    const countMap = new Map<string, number>();
    eSnapshot.forEach(d => {
      const bid = d.data()['benevoleId'];
      if (bid) countMap.set(bid, (countMap.get(bid) ?? 0) + 1);
    });

    const available = bSnapshot.docs.filter(d => (countMap.get(d.id) ?? 0) < 3);
    if (available.length === 0) return null;

    return available[Math.floor(Math.random() * available.length)].id;
  }

  resetPassword(email: string): Promise<void> {
    return sendPasswordResetEmail(this.auth, email);
  }

  get isLoggedIn(): boolean {
    return !!this.auth.currentUser;
  }

  get currentUserId(): string | null {
    return this.auth.currentUser?.uid ?? null;
  }

  get currentUserRole(): 'eleve' | 'benevole' {
    // La récupération précise du rôle se fait via Firestore ;
    // ici on renvoie une valeur par défaut safe pendant le chargement.
    return 'eleve';
  }
}
