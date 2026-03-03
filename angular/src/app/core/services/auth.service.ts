import { inject, Injectable } from '@angular/core';
import { Auth, authState, signInWithEmailAndPassword, signOut, sendPasswordResetEmail, createUserWithEmailAndPassword } from '@angular/fire/auth';
import { Firestore, doc, setDoc, serverTimestamp } from '@angular/fire/firestore';
import { Observable } from 'rxjs';
import { User } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private auth = inject(Auth);
  private firestore = inject(Firestore);

  /** Observable Firebase Auth — null = non connecté, FirebaseUser = connecté */
  readonly currentUser$ = authState(this.auth);

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
      .then(userCredential => {
        const user = userCredential.user;
        const userDoc = doc(this.firestore, `users/${user.uid}`);
        return setDoc(userDoc, {
          email: user.email,
          role: role,
          createdAt: serverTimestamp(),
        });
      })
      .catch(error => {
        console.error('Erreur d\'inscription:', error);
        throw error;
      });
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
